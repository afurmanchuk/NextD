/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - require: 1. NEXTD_ENCOUNTER: NextD Encounter table                                                           */
/*                                                                                                                */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C5R2   */
/******************************************************************************************************************/

/*Note: 'KUMC specific' issue are marked as such*/

/**************************************************************************/
/***********************Table 7 -- Diagnoses*******************************/
/**************************************************************************/
/*for better efficiency*/
create index NextD_ENC_PAT_IDX on NEXTD_ENCOUNTER(ENCOUNTERID);

create table NEXTD_DIAGNOSIS as
select dx.PATID,'|' as Pipe1
      ,dx.ENCOUNTERID,'|' as Pipe2
      ,dx.DIAGNOSISID,'|' as Pipe3
      ,dx.DX,'|' as Pipe4
      ,dx.PDX,'|' as Pipe5
      ,dx.DX_TYPE,'|' as Pipe6
      ,dx.DX_SOURCE,'|' as Pipe7
      ,dx.DX_ORIGIN,'|' as Pipe8
      ,enc.ENC_TYPE,'|' as Pipe9
      ,enc.ADMIT_YEAR,'|' as Pipe10
      ,enc.ADMIT_MONTH,'|' as Pipe11
      ,enc.ADMIT_Days_from_FirstEnc,'ENDALONAEND' as ENDOFLINE
from /*provide current PCORNET_CDM.Diagnosis table here*/"&&PCORNET_CDM".DIAGNOSIS dx
join NEXTD_ENCOUNTER enc on enc.ENCOUNTERID = dx.ENCOUNTERID
;
