/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - FinalStatsTable1: PCORNET_CDM_C4R1                                                                           */
/* - require: 1. NEXTD_ENCOUNTER                                                                                  */
/*            2. NEXTD_PRESCRIBING                                                                                */
/*            3. PROVIDER_CATEGORY: upload mapping file PROVIDER_CATEGORY.csv                                     */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C5R2   */
/******************************************************************************************************************/


/***************************************************************************/
/***********************Table 12 -- Provider *******************************/
/***************************************************************************/
create table NEXTD_PROVIDER as
select distinct
       prov.PROVIDERID,'|' as Pipe1
      ,prov.PROVIDER_NPI,'|' as Pipe2
      ,prov.PROVIDER_SPECIALTY_PRIMARY,'|' as Pipe3
      ,cat.category as PROVIDER_CATEGORY
      ,'ENDALONAEND' as ENDOFLINE
from "&&PCORNET_CDM".PROVIDER prov 
left join Provider_Category cat
on prov.PROVIDER_SPECIALTY_PRIMARY=cat.TAXONOMY
where exists (select 1 from NEXTD_ENCOUNTER enc 
              where enc.PROVIDERID = prov.PROVIDERID) OR
      exists (select 1 from NEXTD_PRESCRIBING presc 
              where presc.RX_PROVIDERID = prov.PROVIDERID)
; 

