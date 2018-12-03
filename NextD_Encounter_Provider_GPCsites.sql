/****************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                          */
/* - require: 1. FinalStatsTable1 local version where dates are nor masked                                      */
/*            2. date_shifts generated from FinalStatsTable1 extraction                                         */
/*            3. run NPI2NPPESTaxonomy.sql to obtain a NPI_TAXONOMY_PROV_CAT_LOCAL mapping table                */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C4R1 */
/****************************************************************************************************************/

/*This extraction schema assumes: PROVIDERID in CDM matches with provider_dimension.PROVIDER_ID in local I2B2*/

/*Note: 'KUMC specific' issue are marked as such*/

/**************************************************************************/
/************************Table 3 - Encounter Table*************************/
/**************************************************************************/

/*Step 1 - Get all eligible encounters 
 - visit age between 18 and 89;
 - no pregancy exception, nor encounter type restrictions*/
 
create table Eligible_Encounters as
with enc_with_age_at_visit as (
select enc.PATID
      ,enc.ENCOUNTERID
      ,enc.ADMIT_DATE+ds.days_shift as REAL_ADMIT_DATE
	  ,enc.ADMITTING_SOURCE 
	  ,enc.DISCHARGE_DATE+ds.days_shift as REAL_DISCHARGE_DATE
	  ,enc.DISCHARGE_STATUS 
      ,enc.ENC_TYPE
      ,enc.FACILITYID
      ,enc.PROVIDERID
	  ,enc.FACILITY_TYPE 
      ,round((enc.ADMIT_DATE - pat.BIRTH_DATE)/365.25,2) AS age_at_visit
from /*provide current PCORNET_CDM.Encounter table here*/ "&&PCORNET_CDM".ENCOUNTER enc
join /*provide current PCORNET_CDM.Demographic table here*/"&&PCORNET_CDM".DEMOGRAPHIC pat
on enc.PATID = pat.PATID
where exists (select 1 from FinalStatTable1 sc
              where sc.PATID = enc.PATID)
)
select distinct PATID 
               ,ENCOUNTERID
               ,REAL_ADMIT_DATE
			   ,ADMITTING_SOURCE
			   ,REAL_DISCHARGE_DATE
			   ,DISCHARGE_STATUS
               ,ENC_TYPE
               ,FACILITYID
               ,PROVIDERID
			   ,FACILITY_TYPE
from enc_with_age_at_visit
where age_at_visit between 18 and 89
; /*140.432 seconds*/

           
/*Step 2: get final Encounter table and apply date-unshifting and date-blinding*/
create table NEXTD2_ENCOUNTER as
-- unshift dates and obtain NPI
with NEXTD2_ENCOUNTER_NPI as (
select eenc.PATID
      ,eenc.ENCOUNTERID
      ,eenc.PROVIDERID
	  ,eenc.ADMIT_DATE+ds.days_shift as REAL_ADMIT_DATE
	  ,eenc.ADMITTING_SOURCE 
	  ,eenc.DISCHARGE_DATE+ds.days_shift as REAL_DISCHARGE_DATE
	  ,eenc.DISCHARGE_STATUS 
      ,eenc.ENC_TYPE
      ,eenc.FACILITYID
	  ,eenc.FACILITY_TYPE
      ,pd.NPI
      ,case when pd.NPI is null then null 
            else dense_rank() over (order by pd.NPI) 
       end as NPI_analogue /*surrogate of NPI -- KUMC specific*/
from Eligible_Encounters eenc
left join nightherondata.provider_dimension pd
on eenc.PROVIDERID = pd.PROVIDER_ID
left join date_unshifts ds
on eenc.PATID = ds.PATID
)
-- get NPPES Taxonomy and categorize NPI as requested
   ,NEXTD2_ENCOUNTER_NPI_NPPES as (
select en.PATID
      ,en.ENCOUNTERID
      ,en.PROVIDERID
      ,en.REAL_ADMIT_DATE
      ,en.ADMITTING_SOURCE 
	  ,en.REAL_DISCHARGE_DATE
	  ,en.DISCHARGE_STATUS 
      ,en.ENC_TYPE
      ,en.FACILITYID
	  ,en.FACILITY_TYPE
      ,en.NPI
      ,en.NPI_analogue /*KUMC specific*/
      ,nm.TAXONOMY
      ,case when nm.INDIVIDUAL_TAXONOMY=1 then 'Individual'
            when nm.INDIVIDUAL_TAXONOMY=0 then 'Organization'
            else null 
       end as ENTITY_TYPE
      ,case when nm.PROVIDER_CATEGORY = ' Physician' then 'Physician'
            else nm.PROVIDER_CATEGORY 
       end as PROVIDER_CATEGORY
from NEXTD2_ENCOUNTER_NPI en
left join NPI_TAXONOMY_PROV_CAT_LOCAL nm
on en.NPI = nm.NPI
) 
--blind the real dates
select  enc.PATID
       ,enc.ENCOUNTERID
       ,enc.PROVIDERID
       ,cast(to_char(enc.REAL_ADMIT_DATE,'YYYY') as INTEGER) ADMIT_YEAR
       ,cast(to_char(enc.REAL_ADMIT_DATE,'MM') as INTEGER) ADMIT_MONTH
       ,enc.REAL_ADMIT_DATE - pat.FirstVisit as ADMIT_Days_from_FirstEncounter
	   ,enc.ADMITTING_SOURCE
	   ,cast(to_char(enc.REAL_DISCHARGE_DATE,'YYYY') as INTEGER) DISCHARGE_YEAR
       ,cast(to_char(enc.REAL_DISCHARGE_DATE,'MM') as INTEGER) DISCHARGE_MONTH
       ,enc.REAL_DISCHARGE_DATE - pat.FirstVisit as DISCHARGE_Days_from_FirstEncounter
       ,enc.ENC_TYPE
       ,enc.FACILITYID
	   ,enc.FACILITY_TYPE
       ,enc.NPI
       ,enc.NPI_analogue
       ,enc.TAXONOMY 
       ,enc.ENTITY_TYPE
       ,enc.PROVIDER_CATEGORY 
from NEXTD2_ENCOUNTER_NPI_NPPES enc
left join FinalStatTable1 pat
on pat.PATID = enc.PATID
; /*393.82 seconds*/

/*eyeball final table and make sure the format is IRB-approved*/
select PATID,'|' as Pipe1
       ,ENCOUNTERID,'|' as Pipe2
       ,PROVIDERID,'|' as Pipe3
       ,ADMIT_YEAR,'|' as Pipe4
       ,ADMIT_MONTH,'|' as Pipe5
       ,ADMIT_Days_from_FirstEncounter,'|' as Pipe6
       ,ADMITTING_SOURCE,'|' as Pipe7
       ,DISCHARGE_YEAR,'|' as Pipe8
       ,DISCHARGE_MONTH,'|' as Pipe9
       ,DISCHARGE_Days_from_FirstEncounter,'|' as Pipe10
       ,ENC_TYPE,'|' as Pipe11
       ,FACILITYID,'|' as Pipe12
       ,FACILITY_TYPE,'ENDALONAEND' as ENDOFLINE
from NEXTD2_ENCOUNTER;

/*save local NEXTD_ENCOUNTER.csv file*/
/****************************************************************************************************/


/***************************************************************************************************/
/*The following checks are optional*/
/*Some additional quality-assurance checks*/
/*check1 - Is provider category complete?*/
--select distinct PROVIDER_CATEGORY from NEXTD2_ENCOUNTER;

--/*check2 - overall summary*/
--select count(distinct PATID) pat_cnt, 
--       count(distinct ENCOUNTERID) enc_cnt, 
--       count(distinct NPI_analogue) prov_cnt 
--from NEXTD2_ENCOUNTER;

--/*check3 - available data summary*/
--select count(distinct PATID) pat_cnt,
--       count(distinct ENCOUNTERID) enc_cnt, 
--       count(distinct NPI_analogue) prov_cnt 
--from NEXTD2_ENCOUNTER where NPI_analogue is not null;

--/*check4 - missing data summary*/
--select ENC_TYPE, FACILITYID, 
--       count(distinct ENCOUNTERID) enc_cnt
--from NEXTD2_ENCOUNTER
--where NPI_analogue is not null
--group by ENC_TYPE, FACILITYID
--order by enc_cnt desc
;
