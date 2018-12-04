/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - require: 1. FinalStatFinal1 table                                                                            */
/*            2. date_unshift table                                                                               */
/*            2. NextD_Encounter table (optional)                                                                 */
/*                                                                                                                */
/* - We assume                                                                                                    */
/*        - PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C4R1      */
/*        - NextD Encounter table is saved locally and can be uploaded for use                                    */
/******************************************************************************************************************/

/*Note: 'KUMC specific' issue are marked as such*/

/****************************************************************************/
/***********************Table 10 -- Procedures*******************************/
/****************************************************************************/

/*If you need to re-create NextD_Encounter table, otherwise, just use the one saved previously*/
create table NEXTD_ENCOUNTER as
with enc_with_age_at_visit as (
select enc.PATID
      ,enc.ENCOUNTERID
      ,enc.ADMIT_DATE
      ,enc.ENC_TYPE
      ,round((enc.ADMIT_DATE - pat.BIRTH_DATE)/365.25,2) AS age_at_visit
from /*provide current PCORNET_CDM.Encounter table here*/ "&&PCORNET_CDM".ENCOUNTER enc
join /*provide current PCORNET_CDM.Demographic table here*/"&&PCORNET_CDM".DEMOGRAPHIC pat
on enc.PATID = pat.PATID
where exists (select 1 from FinalStatTable1 fst
              where fst.PATID = enc.PATID)
)
    ,enc_with_real_dates as (
select distinct enc2.PATID 
               ,enc2.ENCOUNTERID
               ,enc2.ADMIT_DATE + ds.days_shift REAL_ADMIT_DATE
               ,enc2.ENC_TYPE
from enc_with_age_at_visit enc2
left join /*date_unshifts table - created by NextD_Date_Recovery.sql*/ date_unshifts ds
on eenc.PATID = ds.PATID
where enc2.age_at_visit between 18 and 89
)

select enc3.PATID
      ,enc3.ENCOUNTERID
      ,cast(to_char(enc3.REAL_ADMIT_DATE,'YYYY') as INTEGER) ADMIT_YEAR
      ,cast(to_char(enc3.REAL_ADMIT_DATE,'MM') as INTEGER) ADMIT_MONTH
      ,enc3.REAL_ADMIT_DATE - pat.FirstVisit as ADMIT_Days_from_FirstEncounter
from enc_with_real_dates enc3
left join FinalStatTable1 fst
on enc3.PATID = fst.PATID
;

/*get precedures for encounters identified in the NextD_Encounter table*/
create table NEXTD_PROCEDURES as
select enc4.PATID
      ,enc4.ENCOUNTERID
      ,px.PROCEDURESID
      ,px.PX
      ,px.PX_TYPE
      ,px.PX_SOURCE
      ,enc4.ENC_TYPE
      ,enc4.ADMIT_YEAR
      ,enc4.ADMIT_MONTH
      ,enc4.ADMIT_Days_from_FirstEncounter
from NEXTD_ENCOUNTER enc4
join /*provide current PCORNET_CDM.Procedures table here*/ "&&PCORNET_CDM".PROCEDURES px
on enc4.ENCOUNTERID = px.ENCOUNTERID           
; 

------------------------------------------------
/* Save #NextD_PROCEDURES as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
-------------------------------------------------