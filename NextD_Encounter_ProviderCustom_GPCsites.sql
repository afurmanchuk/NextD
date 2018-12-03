/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - require: 1. FinalStatsTable1 local version where dates are nor masked                                        */
/*            2. date_unshifts generated from FinalStatsTable1 extraction                                         */
/*            3. run NPI2NPPESTaxonomy.sql to obtain a NPI_TAXONOMY_PROV_CAT_LOCAL mapping table                  */
/*                                                                                                                */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C4R1   */
/******************************************************************************************************************/

/*This extraction schema assumes: PROVIDERID in CDM may NOT necessarily match with provider_dimension.PROVIDER_ID in local I2B2*/

/*Note: 'KUMC-specific' issue are marked as such*/

/**************************************************************************/
/************************Table 3 - Encounter Table*************************/
/**************************************************************************/

/*Step 0 - get the I2B2 version corresponding to current PCORNET_CDM*/
create table I2B2_version as
--get CDM version
/*require: PCORNET_CDM harvest table*/
with cdm_version as(
select * from /*provide PCORNET_CDM harvest table here -- KUMC specific*/"&&PCORNET_CDM".harvest
)
--get the most likely HERON release corresponding to PCORNET_CDM
/*require: HERON backup_info table*/
select  BACKUP_DATE 
       ,BACKUP_ID
       ,BACKUP_DESCRIPTION
       ,BACKUP_DB
       ,RELEASE_DATE
from (select rb.*, row_number() over (order by rb.backup_date desc) rn   
      from /*provide HERON backup_info table here -- KUMC specific */ nheron_backup.backup_info rb 
      where exists (select 1 from cdm_version cdm
                    where cdm.REFRESH_DEMOGRAPHIC_DATE >= rb.backup_date))
where rn = 1
;


/*Step 1 - Get all eligible encounters 
 - age restriction: between 18 and 89;
 - study period restriction: after 01-01-2010;
 - no pregancy exception, nor encounter type restrictions*/
 
create table Eligible_Encounters as
with enc_with_age_realdate as (
select enc.PATID
      ,enc.ENCOUNTERID
      ,enc.ADMIT_DATE+ds.days_shift as REAL_ADMIT_DATE
      ,enc.ENC_TYPE
      ,enc.FACILITYID
      ,enc.PROVIDERID
      ,round((enc.ADMIT_DATE - pat.BIRTH_DATE)/365.25,2) AS age_at_visit
from /*provide current PCORNET_CDM.Encounter table here*/ "&&PCORNET_CDM".ENCOUNTER enc
join /*provide current PCORNET_CDM.Demographic table here*/"&&PCORNET_CDM".DEMOGRAPHIC pat
on enc.PATID = pat.PATID
left join date_unshifts ds
on enc.PATID = ds.PATID
)
select distinct PATID 
               ,ENCOUNTERID
               ,REAL_ADMIT_DATE
               ,ENC_TYPE
               ,FACILITYID
               ,PROVIDERID
from enc_with_age_realdate
where age_at_visit between 18 and 89 and /*age restriction*/
      REAL_ADMIT_DATE between Date '2010-01-01' and CURRENT_DATE /*time restriction*/   
; /*140.432 seconds*/

/*indexing for better efficiency*/
create index Eligible_Encounters_ENCID_IDX on Eligible_Encounters(ENCOUNTERID);

/*Step 2: Get corresponding Epic encounter number 
(can be useful, especially when CDM and HERON are from different releases)*/

create table CDM_ENCI2B2_CW_EPIC as
select distinct cdm.PROVIDERID
               ,cdm.PATID
               ,cdm.ENCOUNTERID
               ,cw.ENCOUNTER_NUM
from /*provide encounter_mapping_backup table here - KUMC specific*/ nheron_backup.encounter_mapping_backup@KUMC encmb
join Eligible_Encounters cdm
on encmb.ENCOUNTER_NUM = cdm.ENCOUNTERID 
join /*provide current HERON encounter_mapping table here*/ nightherondata.encounter_mapping cw
on encmb.ENCOUNTER_IDE = cw.ENCOUNTER_IDE
where exists (select 1 from I2B2_version i2b2
              where encmb.backup_id = i2b2.backup_id and
                    encmb.ENCOUNTER_IDE_SOURCE like 'Epic@%') and /*EHR source - KUMC specific*/
      cw.ENCOUNTER_IDE_SOURCE like 'Epic@%' /*EHR source - KUMC specific*/
;/*571.61 seconds*/


/*Step 3: hit clarity table and prov_map for NPI*/
create table ENC_EPIC_PROVIDER_NPI_FULL as
with ENC_PROVD as (
select enc.PATID
      ,enc.ENCOUNTERID
--      ,provd.ENCOUNTER_NUM
      ,enc.PROVIDERID
      ,provd.UHC_PROVIDER_IDE
      ,provd.IDX_PROVIDER_IDE
      ,provd.EPIC_PROVIDER_IDE 
from CDM_ENCI2B2_CW_EPIC enc
left join /*provide the PROV_MAP table here, an intermediate table from HERON ETL - KUMC specific*/ HERON_ETL_1.prov_map provd
on enc.ENCOUNTER_NUM = provd.ENCOUNTER_NUM
where coalesce(provd.EPIC_PROVIDER_IDE,provd.IDX_PROVIDER_IDE,provd.UHC_PROVIDER_IDE) is not null
)
    ,PROVD_NPI as (
select enc.*
      ,c1.PROV_NAME
      ,case when (c2.NPI is null and enc.IDX_PROVIDER_IDE is not null) then enc.IDX_PROVIDER_IDE
            else c2.NPI end as NPI
from ENC_PROVD enc
left join /*provide source clariry.CLARITY_SER here*/ clarity.CLARITY_SER c1
on c1.prov_id=enc.epic_provider_ide
left join /*provide source clariry.CLARITY_SER_2 here*/ clarity.CLARITY_SER_2 c2
on c2.prov_id=enc.epic_provider_ide
)

select  npi.PATID
       ,npi.ENCOUNTERID
       ,npi.PROV_NAME
       ,npi.NPI
       ,nm.TAXONOMY
       ,nm.INDIVIDUAL_TAXONOMY
       ,nm.PROVIDER_CATEGORY
from PROVD_NPI npi
left join NPI_TAXONOMY_PROV_CAT_LOCAL nm
on npi.NPI = nm.NPI
where npi.NPI is not null
; /*115.919 seconds*/


/*Step 4: get final Encounter table and apply date-unshifting and date-blinding*/
create table NEXTD_ENCOUNTER as
--date unshifting
with NEXTD_ENCOUNTER_RDATE as (
select eenc.PATID
      ,eenc.ENCOUNTERID
      ,eenc.PROVIDERID
      ,eenc.ADMIT_DATE + ds.days_shift REAL_ADMIT_DATE
      ,eenc.ENC_TYPE
      ,eenc.FACILITYID
      ,case when eprov.NPI is null then null 
            else dense_rank() over (order by eprov.NPI) 
       end as NPI_analogue /*surrogate of NPI*/
      ,eprov.TAXONOMY
      ,case when eprov.INDIVIDUAL_TAXONOMY=1 then 'Individual'
            when eprov.INDIVIDUAL_TAXONOMY=0 then 'Organization'
            else null 
       end as ENTITY_TYPE
       ,case when eprov.PROVIDER_CATEGORY = ' Physician' then 'Physician' 
             else eprov.PROVIDER_CATEGORY 
       end as PROVIDER_CATEGORY
from Eligible_Encounters@nheronA1 eenc
left join date_shifts@nheronA1 ds
on eenc.PATID = ds.PATID
left join ENC_EPIC_PROVIDER_NPI_FULL eprov
on eenc.ENCOUNTERID = eprov.ENCOUNTERID
)
--date blinding
select  enc.PATID
       ,enc.ENCOUNTERID
       ,enc.PROVIDERID
       ,cast(to_char(enc.REAL_ADMIT_DATE,'YYYY') as INTEGER) ADMIT_YEAR
       ,cast(to_char(enc.REAL_ADMIT_DATE,'MM') as INTEGER) ADMIT_MONTH
       ,enc.REAL_ADMIT_DATE - pat.FirstVisit as ADMIT_Days_from_FirstEncounter
       ,enc.ENC_TYPE
       ,enc.FACILITYID
       ,enc.NPI_analogue
       ,enc.TAXONOMY 
       ,enc.ENTITY_TYPE
       ,enc.PROVIDER_CATEGORY 
from NEXTD_ENCOUNTER_RDATE enc
left join FinalStatTable1@nheronA1 pat
on pat.PATID = enc.PATID
; /*393.82 seconds*/

/*eyeball final table and make sure the format is IRB-approved*/
select * from NEXTD_ENCOUNTER;

/*save local NEXTD_ENCOUNTER.csv file*/
/****************************************************************************************************/


/***************************************************************************************************/
/*The following checks are optional*/
/*Some additional quality-assurance checks*/
/*check1 - Is provider category complete?*/
select distinct PROVIDER_CATEGORY from NEXTD2_ENCOUNTER;

/*check2 - overall summary*/
select count(distinct PATID) pat_cnt, 
       count(distinct ENCOUNTERID) enc_cnt, 
       count(distinct NPI_analogue) prov_cnt,
       sum(case when PROVIDERID is null then 1 else 0 end) prov_null
from NEXTD2_ENCOUNTER;

/*check3 - available data summary*/
select count(distinct PATID) pat_cnt,
       count(distinct ENCOUNTERID) enc_cnt, 
       count(distinct NPI_analogue) prov_cnt 
from NEXTD2_ENCOUNTER where NPI_analogue is not null;

/*check4 - missing data summary*/
select ENC_TYPE, FACILITYID, 
       count(distinct ENCOUNTERID) enc_cnt
from NEXTD2_ENCOUNTER
where NPI_analogue is not null
group by ENC_TYPE, FACILITYID
order by enc_cnt desc
;
