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
/************************Table 12 - PROVIDER Table ************************/
/**************************************************************************/

/*Step 1 - Get all eligible encounters 
 - visit age between 18 and 89;
 - no pregancy exception, nor encounter type restrictions*/
 
create table Eligible_PROVIDER as
with enc_with_age_at_visit as (
select enc.PROVIDERID
from /*provide current PCORNET_CDM.Encounter table here*/ "&&PCORNET_CDM".PROVIDER enc
)
select distinct PROVIDERID
from enc_with_age_at_visit
; 

           
/*Step 2: get final Encounter table and apply date-unshifting and date-blinding*/
create table NEXTD2_PROVIDER as
-- unshift dates and obtain NPI
with NEXTD2_PROVIDER_NPI as (
select eenc.PROVIDERID
	  ,pd.NPI
      ,case when pd.NPI is null then null 
            else dense_rank() over (order by pd.NPI) 
       end as NPI_analogue /*surrogate of NPI -- KUMC specific*/
from Eligible_PROVIDER eenc
left join nightherondata.provider_dimension pd
on eenc.PROVIDERID = pd.PROVIDER_ID
)
-- get NPPES Taxonomy and categorize NPI as requested
   ,NEXTD2_PROVIDER_NPI_NPPES as (
select en.PROVIDERID
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
from NEXTD2_PROVIDER_NPI en
left join NPI_TAXONOMY_PROV_CAT_LOCAL nm
on en.NPI = nm.NPI
) 
--blind the real dates
select  enc.PROVIDERID
       ,enc.NPI
       ,enc.NPI_analogue
       ,enc.TAXONOMY 
       ,enc.ENTITY_TYPE
       ,enc.PROVIDER_CATEGORY 
from NEXTD2_PROVIDER_NPI_NPPES enc
; 

/*eyeball final table and make sure the format is IRB-approved*/
select ENCOUNTERID,'|' as Pipe2
       ,PROVIDERID,'|' as Pipe3
       ,enc.NPI,'|' as Pipe4
       ,enc.NPI_analogue,'|' as Pipe5
       ,enc.TAXONOMY ,'|' as Pipe6
       ,enc.PROVIDER_CATEGORY,'ENDALONAEND' as ENDOFLINE   
from NEXTD2_PROVIDER;

/*save local NEXTD_ENCOUNTER.csv file*/
/****************************************************************************************************/
/***************************************************************************************************/
