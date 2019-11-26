/****************************************************************************************************************/
/* NextD Clinical Variable Extractions - Encounter Table                                                        */
/* no pregnancy exclusion                                                                                       */
/****************************************************************************************************************/

/* Tables required in this code: 
- 1. FinalStatsTable1_local: the local version of FinalStatsTable1 (output of SQLTable1_GPCsites_orcale-2019-11-25-SX.sql)                             
- 2. &&PCORNET_CDM.ENCOUNTER                                   
*/

/*global parameters:
 &&PCORNET_CDM: name of CDM schema (>v5.0)
 "KUMC specific" fields: may need to be adjusted with local EMR values
*/

create table NEXTD_ENCOUNTER as
with enc_with_age_at_visit as (
select enc.PATID
      ,enc.ENCOUNTERID
      ,enc.PROVIDERID
      ,enc.ADMIT_DATE
      ,enc.ADMIT_DATE - fst.FirstVisit as ADMIT_Days_from_FirstEnc
	  ,enc.ADMITTING_SOURCE 
	  ,enc.DISCHARGE_DATE
      ,enc.DISCHARGE_DATE - fst.FirstVisit as DISCHARGE_Days_from_FirstEnc
      ,enc.DISCHARGE_DISPOSITION
	  ,enc.DISCHARGE_STATUS 
      ,enc.ENC_TYPE
      ,enc.FACILITYID
	  ,enc.FACILITY_TYPE 
      ,round((enc.ADMIT_DATE - fst.BIRTH_DATE)/365.25,2) AS age_at_visit
from "&&PCORNET_CDM".ENCOUNTER enc
join FinalStatsTable1_local fst on fst.PATID = enc.PATID
)
select distinct
       PATID,'|' as Pipe1
      ,ENCOUNTERID,'|' as Pipe2
      ,PROVIDERID,'|' as Pipe3
      ,cast(to_char(ADMIT_DATE,'YYYY') as INTEGER) ADMIT_YEAR,'|' as Pipe4
      ,cast(to_char(ADMIT_DATE,'MM') as INTEGER) ADMIT_MONTH,'|' as Pipe5
      ,ADMIT_Days_from_FirstEnc,'|' as Pipe6
      ,cast(to_char(DISCHARGE_DATE,'YYYY') as INTEGER) DISCHARGE_YEAR,'|' as Pipe7
      ,cast(to_char(DISCHARGE_DATE,'MM') as INTEGER) DISCHARGE_MONTH,'|' as Pipe8
	  ,DISCHARGE_Days_from_FirstEnc,'|' as Pipe9
      ,ENC_TYPE,'|' as Pipe10
      ,FACILITYID,'|' as Pipe11
      ,DISCHARGE_DISPOSITION,'|' as Pipe12
      ,DISCHARGE_STATUS,'|' as Pipe13
	  ,ADMITTING_SOURCE,'|' as Pipe14
      ,FACILITY_TYPE
      ,'ENDALONAEND' as ENDOFLINE
from enc_with_age_at_visit
where age_at_visit between 18 and 89
;


/*for better efficiency*/
create index NextD_ENC_PAT_IDX on NEXTD_ENCOUNTER(ENCOUNTERID);

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----- 1. Download table NEXTD_ENCOUNTER as .csv  file for final delivery                                 ------
---------------------------------------------------------------------------------------------------------------

