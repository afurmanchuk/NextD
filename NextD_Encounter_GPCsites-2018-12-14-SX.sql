/****************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                          */
/* - require: 1. FinalStatTable1_local version where dates are nor masked                                       */
/*            2. date_unshifts generated from either NextD_Date_Recovery.sql or site-specific approaches        */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C5R2 */
/****************************************************************************************************************/


/**************************************************************************/
/************************Table 3 - Encounter Table*************************/
/**************************************************************************/

create table Eligible_Encounters as
with enc_with_age_at_visit as (
select enc.PATID
      ,enc.ENCOUNTERID
      ,enc.PROVIDERID
      ,enc.ADMIT_DATE+ds.days_shift as REAL_ADMIT_DATE
      ,enc.ADMIT_DATE-sc.FirstVisit as ADMIT_Days_from_FirstEncounter
	  ,enc.ADMITTING_SOURCE 
	  ,enc.DISCHARGE_DATE+ds.days_shift as REAL_DISCHARGE_DATE
      ,enc.DISCHARGE_DATE-sc.FirstVisit as DISCHARGE_Days_from_FirstEncounter
	  ,enc.DISCHARGE_STATUS 
      ,enc.ENC_TYPE
      ,enc.FACILITYID
	  ,enc.FACILITY_TYPE 
      ,round((enc.ADMIT_DATE - pat.BIRTH_DATE)/365.25,2) AS age_at_visit
from /*provide current PCORNET_CDM.Encounter table here*/ "&&PCORNET_CDM".ENCOUNTER enc
join /*provide current PCORNET_CDM.Demographic table here*/ "&&PCORNET_CDM".DEMOGRAPHIC pat on enc.PATID = pat.PATID
join date_unshifts ds on enc.PATID = ds.PATID 
join FinalStatTable1_local sc on sc.PATID = enc.PATID
)
select distinct
       PATID,'|' as Pipe1
      ,ENCOUNTERID,'|' as Pipe2
      ,PROVIDERID,'|' as Pipe3
      ,cast(to_char(enc.REAL_ADMIT_DATE,'YYYY') as INTEGER) ADMIT_YEAR,'|' as Pipe4
      ,cast(to_char(enc.REAL_ADMIT_DATE,'MM') as INTEGER) ADMIT_MONTH,'|' as Pipe5
      ,ADMIT_Days_from_FirstEncounter,'|' as Pipe6
      ,DISCHARGE_YEAR,'|' as Pipe7
      ,DISCHARGE_MONTH,'|' as Pipe8
	  ,DISCHARGE_Days_from_FirstEncounter,'|' as Pipe9
      ,ENC_TYPE,'|' as Pipe10
      ,FACILITYID,'|' as Pipe11
      ,DISCHARGE_DISPOSITION,'|' as Pipe12
      ,DISCHARGE_STATUS,'|' as Pipe13
	  ,ADMITTING_SOURCE,'|' as Pipe14
      ,FACILITY_TYPE,'ENDALONAEND' as ENDOFLINE
from enc_with_age_at_visit
where age_at_visit between 18 and 89
;
