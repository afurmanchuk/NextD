/******************************************************************************************************************/
/* NextD Clinical Variable Extractions - Provider Table                                                              */
/******************************************************************************************************************/

/* Tables required in this code:                                     
- 1. NEXTD_ENCOUNTER: output table of NextD_Encounter_GPCsites-2019-11-25-SX.sql
- 2. NEXTD_PRESCRIBING: output table of NextD_PrescribedMed_GPCsites-2019-11-25-SX.sql
- 3. &&PCORNET_CDM.PROVIDER 
- 4. PROVIDER_CATEGORY (optional): if Provider_Categpry.csv has been saved in previous refresh, just upload it;
     otherwise, you can download the file directly from https://www.dropbox.com/s/xjbekep4hudyld1/NPPES-taxonomy-code-counts-2017-07-07-bb.xlsx?dl=0
         - copy and save column A,G from the second tab 'taxonomy codes' as seperate file as 'PROVIDER_CATEGORY.csv'
         - upload 'PROVIDER_CATEGORY.csv' and rename the following columnes due to oracle naming convention 
              -- 'Taxonomy code' to 'TAXONOMY'
              -- 'Our Proposed Classification' to 'CATEGORY'
*/

/*global parameters:
 &&PCORNET_CDM: name of CDM schema (>v5.0)
 "KUMC specific" fields: may need to be adjusted with local EMR values
*/

/*for better efficiency*/
create index TAXONOMY_CAT_IDX on PROVIDER_CATEGORY(TAXONOMY);


create table NEXTD_PROVIDERS as
select distinct
       prov.PROVIDERID,'|' as Pipe1
      ,prov.PROVIDER_NPI,'|' as Pipe2
      ,prov.PROVIDER_SPECIALTY_PRIMARY,'|' as Pipe3
      ,cat.CATEGORY as PROVIDER_NPPES_CAT
      ,'ENDALONAEND' as ENDOFLINE
from "&&PCORNET_CDM".PROVIDER prov 
left join PROVIDER_CATEGORY cat
on prov.PROVIDER_SPECIALTY_PRIMARY=cat.TAXONOMY
where exists (select 1 from NEXTD_ENCOUNTER enc 
              where enc.PROVIDERID = prov.PROVIDERID) OR
      exists (select 1 from NEXTD_PRESCRIBING presc 
              where presc.RX_PROVIDERID = prov.PROVIDERID)
; 


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----- 1. Download table NEXTD_PROVIDERS as .csv  file for final delivery                                     ------
---------------------------------------------------------------------------------------------------------------

