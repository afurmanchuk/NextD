/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - require: 1. FinalStatTable1_local: the local version where dates neither shifted nor masked                  */
/*                                                                                                                */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C5R2   */
/******************************************************************************************************************/


/**************************************************************************/
/***********************Table 9 -- Death_Cause*****************************/
/**************************************************************************/
create table NEXTD_DEATH_CAUSE as
select fst.PATID,'|' as Pipe1
      ,dc.DEATH_CAUSE,'|' as Pipe2
      ,dc.DEATH_CAUSE_CODE,'|' as Pipe3
      ,dc.DEATH_CAUSE_TYPE,'|' as Pipe4
      ,dc.DEATH_CAUSE_SOURCE,'|' as Pipe5
      ,dc.DEATH_CAUSE_CONFIDENCE, 'ENDALONAEND' as ENDOFLINE
from FinalStatTable1_local fst
left join "&&PCORNET_CDM".DEATH_CAUSE dc 
on fst.PATID = dc.PATID
; 


