/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - require: 1. FinalStatTable1_local: the local version where dates neither shifted nor masked                  */
/*            2. date_unshifts: an intermediate table for recovering real dates                                   */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C5R2   */
/******************************************************************************************************************/

/*Note: 'KUMC specific' issue are marked as such*/

/*****************************************************************************************/
/***********************Table 4a -- Prescription Medicines *******************************/
/*****************************************************************************************/
/*for better efficiency*/
create index FinalStatTable1_PAT_IDX on FinalStatTable1_local(PATID);

create table NEXTD_PRESCRIBING_local as
--collect all prescribing medications and shift the dates back
with pmed_with_age_realdate as (
select pmed.PATID
      ,pmed.ENCOUNTERID
      ,pmed.PRESCRIBINGID
      ,pmed.RXNORM_CUI
      ,pmed.RX_ORDER_DATE + ds.days_shift as REAL_RX_ORDER_DATE
	  ,pmed.RX_START_DATE + ds.days_shift as REAL_RX_START_DATE
	  ,pmed.RX_END_DATE + ds.days_shift as REAL_RX_END_DATE
      ,pmed.RX_PROVIDERID /*not the same as PROVIDERID in ENCOUNTER table*/
      ,pmed.RX_DAYS_SUPPLY
      ,pmed.RX_REFILLS
      ,pmed.RX_BASIS
      ,pmed.RAW_RX_MED_NAME /*optional -- comment out if not having it*/
      ,round((pmed.RX_ORDER_DATE+ds.days_shift-fst.BIRTH_DATE)/365.25,2) as age_at_event
from /*provide current PCORNET_CDM.Prescribing table here*/"&&PCORNET_CDM".PRESCRIBING pmed
join FinalStatTable1_local fst on fst.PATID = pmed.PATID
join date_unshifts ds on ds.PATID = pmed.PATID
)
--collect pregancy dates
   ,pregn_dates as (
select PATID
      ,PREGNANCY_DATE
from FinalStatTable1_local
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
)
--identify prescribing medications related to pregancy events
    ,pregn_exclud as (
select pmedrd.PRESCRIBINGID
from pmed_with_age_realdate pmedrd
where pmedrd.age_at_event between 18 and 89 and                                
      pmedrd.REAL_RX_ORDER_DATE between Date '2010-01-01' and CURRENT_DATE and 
      exists (select 1 from pregn_dates pd                                 
                  where pd.PATID = pmedrd.PATID and
                        (abs(pmedrd.REAL_RX_ORDER_DATE - pd.PREGNANCY_DATE) <= 365))
)
--perform exclusions
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


create table NEXTD_PRESCRIBING as
--time blinding
select fst.PATID,'|' as Pipe1
      ,erx.ENCOUNTERID,'|' as Pipe2
      ,erx.PRESCRIBINGID,'|' as Pipe3
      ,erx.RXNORM_CUI,'|' as Pipe4
      ,cast(to_char(erx.REAL_RX_ORDER_DATE,'YYYY') as INTEGER) RX_ORDER_YEAR,'|' as Pipe5
      ,cast(to_char(erx.REAL_RX_ORDER_DATE,'MM') as INTEGER) RX_ORDER_MONTH,'|' as Pipe6
      ,erx.REAL_RX_ORDER_DATE - fst.FirstVisit as RX_ORDER_Days_from_FirstEnc,'|' as Pipe7
      ,erx.RX_PROVIDERID,'|' as Pipe8
      ,cast(to_char(erx.REAL_RX_START_DATE,'YYYY') as INTEGER) RX_START_YEAR,'|' as Pipe9
      ,cast(to_char(erx.REAL_RX_START_DATE,'MM') as INTEGER) RX_START_MONTH,'|' as Pipe10
      ,erx.REAL_RX_START_DATE - fst.FirstVisit as RX_START_Days_from_FirstEnc,'|' as Pipe11
      ,cast(to_char(erx.REAL_RX_END_DATE,'YYYY') as INTEGER) RX_END_YEAR,'|' as Pipe12
      ,cast(to_char(erx.REAL_RX_END_DATE,'MM') as INTEGER) RX_END_MONTH,'|' as Pipe13
      ,erx.REAL_RX_END_DATE - fst.FirstVisit as RX_END_Days_from_FirstEnc,'|' as Pipe14
      ,erx.RX_DAYS_SUPPLY,'|' as Pipe15
      ,erx.RX_REFILLS,'|' as Pipe16
      ,erx.RX_BASIS,'|' as Pipe17
      ,erx.RAW_RX_MED_NAME,'ENDALONAEND' as ENDOFLINE
from FinalStatTable1_local fst
left join NEXTD_PRESCRIBING_local erx
on erx.PATID = fst.PATID          
;
