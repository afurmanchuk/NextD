/******************************************************************************************************************/
/* NextD Clinical Variable Extractions - Diagnosis Table                                                          */
/* exclude pregancy                                                                                               */
/******************************************************************************************************************/

/* Tables required in this code: 
- 1. NEXTD_ENCOUNTER: output table of NextD_Encounter_GPCsites-2019-11-25-SX.sql 
- 2. NextD_preg_masked_encounters: an intermediate table with non-pregnacy encounters
- 3. &&PCORNET_CDM.DIAGNOSIS                                  
*/

/*global parameters:
 &&PCORNET_CDM: name of CDM schema (>v5.0)
 "KUMC specific" fields: may need to be adjusted with local EMR values
*/

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
      ,enc.ADMIT_Days_from_FirstEnc
      ,'ENDALONAEND' as ENDOFLINE
from "&&PCORNET_CDM".DIAGNOSIS dx
join NEXTD_ENCOUNTER enc on enc.ENCOUNTERID = dx.ENCOUNTERID
where exists (select 1 from NextD_preg_masked_encounters exclud_pregn
              where dx.ENCOUNTERID = exclud_pregn.ENCOUNTERID)
;

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----- 1. Download table NEXTD_DIAGNOSIS as .csv file for final delivery                                  ------
---------------------------------------------------------------------------------------------------------------
