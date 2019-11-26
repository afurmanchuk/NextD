/******************************************************************************************************************/
/* NextD Clinical Variable Extractions - Procedure Table                                                          */
/* no pregnancy exclusion                                                                                         */
/******************************************************************************************************************/

/* Tables required in this code: 
- 1. FinalStatsTable1_local: the local version of FinalStatsTable1 (output of SQLTable1_GPCsites_orcale-2019-11-25-SX.sql)                             
- 2. NEXTD_ENCOUNTER: output of NextD_Encounter_GPCsites-2019-11-25-SX.sql                       
- 3. &&PCORNET_CDM.PROCEDURES              
*/

/*global parameters:
 &&PCORNET_CDM: name of CDM schema (>v5.0)
 "KUMC specific" fields: may need to be adjusted with local EMR values
*/

create table NEXTD_PROCEDURES as
select enc.PATID,'|' as Pipe1
      ,enc.ENCOUNTERID,'|' as Pipe2
      ,enc.ENC_TYPE,'|' as Pipe3
      ,enc.ADMIT_YEAR,'|' as Pipe4
      ,enc.ADMIT_MONTH,'|' as Pipe5
      ,enc.ADMIT_Days_from_FirstEnc,'|' as Pipe6
      ,px.PROVIDERID,'|' as Pipe7
      ,px.PROCEDURESID,'|' as Pipe8
	  ,cast(to_char(px.PX_DATE,'YYYY') as INTEGER) as PX_YEAR,'|' as Pipe9
	  ,cast(to_char(px.PX_DATE,'MM') as INTEGER) as  PX_MONTH,'|' as Pipe10
	  ,round(px.PX_DATE - fst.FirstVisit) as PX_Days_from_FirstEnc,'|' as Pipe11
      ,px.PX,'|' as Pipe12
      ,px.PX_TYPE,'|' as Pipe13
      ,px.PX_SOURCE,'|' as Pipe14
	  ,px.PPX
      ,'ENDALONAEND' as ENDOFLINE
from NEXTD_ENCOUNTER enc
join "&&PCORNET_CDM".PROCEDURES px on enc.ENCOUNTERID = px.ENCOUNTERID       
join FinalStatsTable1_local fst on enc.PATID = fst.PATID  
; 

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----- 1. Download table NEXTD_PROCEDURES as .csv file for final delivery                                 ------
---------------------------------------------------------------------------------------------------------------
