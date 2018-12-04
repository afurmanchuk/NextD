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

/*This script takes about 900 seconds to complete*/

/*****************************************************************************************/
/***********************Table 4a -- Prescription Medicines *******************************/
/*****************************************************************************************/
/*for better efficiency*/
create index FinalStatTable1_PAT_IDX on FinalStatTable1(PATID);

drop table cdm_prescribing PURGE;
create table cdm_prescribing as
select /*+index(fst FinalStatTable1_PAT_IDX)*/
       pmed.PATID
      ,pmed.ENCOUNTERID
      ,pmed.PRESCRIBINGID
      ,pmed.RXNORM_CUI
      ,pmed.RX_ORDER_DATE
	  ,pmed.RX_START_DATE
	  ,pmed.RX_END_DATE
      ,pmed.RX_PROVIDERID
      ,pmed.RX_DAYS_SUPPLY
      ,pmed.RX_REFILLS
      ,pmed.RX_BASIS
      ,pmed.RAW_RX_MED_NAME /*optional -- comment out if not having it*/
from /*provide current PCORNET_CDM.Prescribing table here*/"&&PCORNET_CDM".PRESCRIBING pmed
where exists (select 1 from FinalStatTable1 fst
              where fst.PATID = pmed.PATID)
;

drop table cdm_demographic PURGE;
create table cdm_demographic as
select pat.PATID
      ,pat.BIRTH_DATE
from /*provide current PCORNET_CDM.Demographic table here*/"&&PCORNET_CDM".DEMOGRAPHIC pat
where exists (select 1 from FinalStatTable1 fst
              where fst.PATID = pat.PATID)
;

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

drop table pmed_with_age_realdate PURGE;
create table pmed_with_age_realdate as
select pmed.PATID
      ,pmed.ENCOUNTERID
      ,pmed.PRESCRIBINGID
      ,pmed.RXNORM_CUI
      ,pmed.RX_ORDER_DATE + ds.days_shift as REAL_RX_ORDER_DATE
	  ,pmed.RX_START_DATE + ds.days_shift as REAL_RX_START_DATE
	  ,pmed.RX_END_DATE + ds.days_shift as REAL_RX_END_DATE
      ,pmed.RX_PROVIDERID /*the same as Encounter ProviderID?*/
      ,pmed.RX_DAYS_SUPPLY
      ,pmed.RX_REFILLS
      ,pmed.RX_BASIS
      ,pmed.RAW_RX_MED_NAME /*optional -- comment out if not having it*/
      ,round((pmed.RX_ORDER_DATE - pat.BIRTH_DATE)/365.25,2) as age_at_event
from cdm_prescribing pmed
join cdm_demographic pat
on pmed.PATID = pat.PATID
join date_unshifts ds
on pmed.PATID = ds.PATID
;

/*for better efficiency*/
create index pmed_w_age_realdate_PATDT_IDX on pmed_with_age_realdate(PATID,REAL_RX_ORDER_DATE);


drop table eligible_prx PURGE;
create table eligible_prx as
with pregn_exclud as (
select pmedrd.PRESCRIBINGID
from pmed_with_age_realdate pmedrd
where pmedrd.age_at_event between 18 and 89 and                                
      pmedrd.REAL_RX_ORDER_DATE between Date '2010-01-01' and CURRENT_DATE and 
      exists (select 1 from pregn_dates pd                                 
                  where pd.PATID = pmedrd.PATID and
                        (abs(pmedrd.REAL_RX_ORDER_DATE - pd.PREGNANCY_DATE) <= 365))
)
select pmedrd.PATID
      ,pmedrd.ENCOUNTERID
      ,pmedrd.PRESCRIBINGID
      ,pmedrd.RXNORM_CUI
      ,pmedrd.REAL_RX_ORDER_DATE
	  ,pmedrd.REAL_RX_START_DATE
	  ,pmedrd.REAL_RX_END_DATE
      ,pmedrd.RX_PROVIDERID
      ,pmedrd.RX_DAYS_SUPPLY
      ,pmedrd.RX_REFILLS
      ,pmedrd.RX_BASIS
      ,pmedrd.RAW_RX_MED_NAME /*optional -- comment out if not having it*/
from pmed_with_age_realdate pmedrd
where pmedrd.age_at_event between 18 and 89 and                                /*age restriction*/
      pmedrd.REAL_RX_ORDER_DATE between Date '2010-01-01' and CURRENT_DATE and /*time restriction*/
      pmedrd.PRESCRIBINGID not in (select PRESCRIBINGID from pregn_exclud)     /*pregenancy exclusion*/
;

drop table NEXTD_PRECSRIBING PURGE;
create table NEXTD_PRECSRIBING as
--time blinding
select fst.PATID
      ,erx.ENCOUNTERID
      ,erx.PRESCRIBINGID
      ,erx.RXNORM_CUI
      ,cast(to_char(erx.REAL_RX_ORDER_DATE,'YYYY') as INTEGER) RX_ORDER_YEAR
      ,cast(to_char(erx.REAL_RX_ORDER_DATE,'MM') as INTEGER) RX_ORDER_MONTH
      ,erx.REAL_RX_ORDER_DATE - fst.FirstVisit as RX_ORDER_Days_from_FirstEnc
      ,cast(to_char(erx.REAL_RX_START_DATE,'YYYY') as INTEGER) RX_START_YEAR
      ,cast(to_char(erx.REAL_RX_START_DATE,'MM') as INTEGER) RX_START_MONTH
      ,erx.REAL_RX_START_DATE - fst.FirstVisit as RX_START_Days_from_FirstEnc
      ,cast(to_char(erx.REAL_RX__END_DATE,'YYYY') as INTEGER) RX_END_YEAR
      ,cast(to_char(erx.REAL_RX__ENDR_DATE,'MM') as INTEGER) RX_END_MONTH
      ,erx.REAL_RX__END_DATE - fst.FirstVisit as RX_END_Days_from_FirstEnc
      ,erx.RX_PROVIDERID
      ,erx.RX_DAYS_SUPPLY
      ,erx.RX_REFILLS
      ,erx.RX_BASIS
      ,erx.RAW_RX_MED_NAME /*optional -- comment out if not having it*/
from FinalStatTable1 fst
left join eligible_prx erx
on erx.PATID = fst.PATID          
;

/*save local NEXTD_PRECSRIBING.csv file
 Use "|" symbol as field terminator and
 "ENDALONAEND" as row terminator. */
 
 select PATID,'|' as Pipe1
      ,ENCOUNTERID,'|' as Pipe2
      ,PRESCRIBINGID,'|' as Pipe3
      ,RXNORM_CUI,'|' as Pipe4
      ,RX_ORDER_YEAR,'|' as Pipe5
      ,RX_ORDER_MONTH,'|' as Pipe6
      ,RX_ORDER_Days_from_FirstEnc,'|' as Pipe7
      ,RX_START_YEAR,'|' as Pipe8
      ,RX_START_MONTH,'|' as Pipe9
      ,RX_START_Days_from_FirstEnc,'|' as Pipe10
      ,RX_END_YEAR,'|' as Pipe11
      ,RX_END_MONTH,'|' as Pipe12
      ,RX_END_Days_from_FirstEnc,'|' as Pipe13
      ,RX_PROVIDERID,'|' as Pipe14
      ,RX_DAYS_SUPPLY,'|' as Pipe15
      ,RX_REFILLS,'|' as Pipe16
      ,RX_BASIS,'|' as Pipe17
      ,RAW_RX_MED_NAME,'ENDALONAEND' as ENDOFLINE 
from NEXTD_PRECSRIBING


 /*purge intermediate tables*/
drop table cdm_prescribing purge;
drop table cdm_demographic purge;
drop table pregn_dates purge;
drop table pmed_with_age_realdate purge;
drop table eligible_rx purge;
drop table cdm_encounter purge;
drop table provider_enc_rx purge;
