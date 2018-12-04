/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - require: 1. FinalStatsTable1: the local version where dates are unshifted                                    */
/*            2. date_unshifts: an intermediate table for recovering real dates                                   */
/*               columns:        PATID: CDM patient ID                                                            */
/*                               PATIENT_IDE: patient IDE                                                         */
/*                               CDM_BIRTH_DATE: shifted birth date in CDM                                        */
/*                               REAL_BIRTH_DATE: real birth date in local HERON                                  */
/*                               days_shift: days shifted                                                         */
/*               - if such intermediate table alread saved locally for table1 extraction, then just use that one; */
/*                 if not, the NextD_Date_Recovery.sql will do the work                                           */
/*                                                                                                                */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C4R1   */
/******************************************************************************************************************/
/*Note: 'KUMC specific' issue are marked as such*/

/*This script takes about 300 seconds to complete*/

/**************************************************************************************/
/***********************Table 4b -- Dispensed Medicines *******************************/
/**************************************************************************************/
/*for better efficiency*/
create index FinalStatTable1_PAT_IDX on FinalStatTable1(PATID);

create table cdm_dispensing as
select /*+index(fst FinalStatTable1_PAT_IDX)*/
       dmed.PATID
      ,dmed.DISPENSINGID
	  ,dmed.PRESCRIBINGID
      ,dmed.NDC
      ,dmed.DISPENSE_DATE
      ,dmed.DISPENSE_SUP
      ,dmed.DISPENSE_AMT
      ,dmed.RAW_NDC /*optional -- comment out if not having it*/
from /*provide current PCORNET_CDM.Dispensing table here*/"&&PCORNET_CDM".DISPENSING dmed
where exists (select 1 from FinalStatTable1 fst
              where fst.PATID = dmed.PATID)
;


create table cdm_demographic as
select pat.PATID
      ,pat.BIRTH_DATE
from /*provide current PCORNET_CDM.Demographic table here*/"&&PCORNET_CDM".DEMOGRAPHIC pat
where exists (select 1 from FinalStatTable1 fst
              where fst.PATID = pat.PATID)
;
select count(*) from cdm_demographic;

drop table pregn_dates PURGE;
create table pregn_dates as 
select PATID
      ,PREGNANCY_DATE
from FinalStatTable1
unpivot 
(
  PREGNANCY_DATE
  for PREGNANCY_NO
    in (Pregnancy1_date
       ,Pregnancy2_date
       ,Pregnancy3_date
       ,Pregnancy4_date
       ,Pregnancy5_date
       ,Pregnancy6_date
       ,Pregnancy7_date
       ,Pregnancy8_date
       ,Pregnancy9_date
       ,Pregnancy10_date
       )
)
;

create table dmed_with_age_realdate as
select dmed.PATID
      ,dmed.DISPENSINGID
	  ,dmed.PRESCRIBINGID
      ,dmed.NDC
      ,dmed.DISPENSE_DATE + ds.days_shift as REAL_DISPENSE_DATE
      ,dmed.DISPENSE_SUP
      ,dmed.DISPENSE_AMT
      ,dmed.RAW_NDC /*optional -- comment out if not having it*/
      ,round((dmed.DISPENSE_DATE - pat.BIRTH_DATE)/365.25,2) as age_at_event
from cdm_dispensing dmed
join cdm_demographic pat
on dmed.PATID = pat.PATID
join date_unshifts ds
on dmed.PATID = ds.PATID
;

/*for better efficiency*/
create index dmed_w_age_realdate_PATDT_IDX on dmed_with_age_realdate(PATID,REAL_DISPENSE_DATE);


drop table eligible_drx PURGE;
create table eligible_drx as
with pregn_exclud as (
select dmedrd.DISPENSINGID
from dmed_with_age_realdate dmedrd
where dmedrd.age_at_event between 18 and 89 and                                
      dmedrd.REAL_DISPENSE_DATE between Date '2010-01-01' and CURRENT_DATE and 
      exists (select 1 from pregn_dates pd                                 
                  where pd.PATID = dmedrd.PATID and
                        (abs(dmedrd.REAL_DISPENSE_DATE - pd.PREGNANCY_DATE) <= 365))
)
select dmedrd.PATID
      ,dmedrd.DISPENSINGID
	  ,dmedrd.PRESCRIBINGID
      ,dmedrd.NDC
      ,dmedrd.REAL_DISPENSE_DATE
      ,dmedrd.DISPENSE_SUP
      ,dmedrd.DISPENSE_AMT
      ,dmedrd.RAW_NDC /*optional -- comment out if not having it*/
from dmed_with_age_realdate dmedrd
where dmedrd.age_at_event between 18 and 89 and                                /*age restriction*/
      dmedrd.REAL_DISPENSE_DATE between Date '2010-01-01' and CURRENT_DATE and /*time restriction*/
      dmedrd.DISPENSINGID not in (select DISPENSINGID from pregn_exclud)       /*pregenancy exclusion*/
;


drop table NEXTD_DISPENSING PURGE;
create table NEXTD_DISPENSING as
--time blinding
select fst.PATID
      ,erx.DISPENSINGID
	  ,erx.PRESCRIBINGID
      ,erx.NDC
      ,cast(to_char(erx.REAL_DISPENSE_DATE,'YYYY') as INTEGER) DISPENSE_YEAR
      ,cast(to_char(erx.REAL_DISPENSE_DATE,'MM') as INTEGER) DISPENSE_MONTH
      ,erx.REAL_DISPENSE_DATE - fst.FirstVisit as DISPENSE_Days_from_FirstEnc
      ,erx.DISPENSE_SUP
      ,erx.DISPENSE_AMT
      ,erx.RAW_NDC /*optional -- comment out if not having it*/
from FinalStatTable1 fst
left join eligible_drx erx
on erx.PATID = fst.PATID          
; 

/*save local NEXTD_DISPENSING.csv file
 Use "|" symbol as field terminator and
 "ENDALONAEND" as row terminator. */
 select PATID,'|' as Pipe1
      ,DISPENSINGID,'|' as Pipe2
	  ,PRESCRIBINGID,'|' as Pipe3
      ,NDC,'|' as Pipe4
      ,DISPENSE_YEAR,'|' as Pipe5
      ,DISPENSE_MONTH,'|' as Pipe6
      ,DISPENSE_Days_from_FirstEnc,'|' as Pipe7
      ,DISPENSE_SUP,'|' as Pipe8
      ,DISPENSE_AMT,'|' as Pipe9
      ,RAW_NDC,'ENDALONAEND' as ENDOFLINE
from NEXTD_DISPENSING



/*purge intermediate tables*/
drop table cdm_dispensing purge;
drop table cdm_demographic purge;
drop table pregn_dates purge;
drop table dmed_with_age_realdate purge;
drop table eligible_drx purge;
