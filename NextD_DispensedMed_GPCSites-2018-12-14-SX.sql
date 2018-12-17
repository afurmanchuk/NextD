/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - require: 1. FinalStatsTable1_local: the local version where dates neither shifted nor masked                 */
/*            2. date_unshifts: an intermediate table for recovering real dates                                   */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C5R2   */
/******************************************************************************************************************/

/*Note: 'KUMC specific' issue are marked as such*/

/**************************************************************************************/
/***********************Table 4b -- Dispensed Medicines *******************************/
/**************************************************************************************/
/*for better efficiency*/
create index FinalStatTable1_PAT_IDX on FinalStatTable1_local(PATID);

create table NEXTD_DISPENSING_local as
with dmed_with_age_realdate as (
select dmed.PATID
      ,dmed.DISPENSINGID
      ,dmed.PRESCRIBINGID
      ,dmed.NDC
      ,dmed.DISPENSE_DATE + ds.days_shift as REAL_DISPENSE_DATE
      ,dmed.DISPENSE_SUP
      ,dmed.DISPENSE_AMT
      ,dmed.RAW_NDC
      ,round((dmed.DISPENSE_DATE+ds.days_shift-fst.BIRTH_DATE)/365.25,2) as age_at_event
from /*provide current PCORNET_CDM.Dispensing table here*/ "&&PCORNET_CDM".DISPENSING dmed
join FinalStatTable1_local fst on fst.PATID = dmed.PATID
join date_unshifts ds on ds.PATID = dmed.PATID
)
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
  ,pregn_exclud as (
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
      ,dmedrd.RAW_NDC
from dmed_with_age_realdate dmedrd
where dmedrd.age_at_event between 18 and 89 and                                /*age restriction*/
      dmedrd.REAL_DISPENSE_DATE between Date '2010-01-01' and CURRENT_DATE and /*time restriction*/
      dmedrd.DISPENSINGID not in (select DISPENSINGID from pregn_exclud)       /*pregenancy exclusion*/
;


create table NEXTD_DISPENSING as
--time blinding
select fst.PATID,'|' as Pipe1
      ,erx.DISPENSINGID,'|' as Pipe2
      ,erx.PRESCRIBINGID,'|' as Pipe3
      ,erx.NDC,'|' as Pipe4
      ,cast(to_char(erx.REAL_DISPENSE_DATE,'YYYY') as INTEGER) DISPENSE_YEAR,'|' as Pipe5
      ,cast(to_char(erx.REAL_DISPENSE_DATE,'MM') as INTEGER) DISPENSE_MONTH,'|' as Pipe6
      ,erx.REAL_DISPENSE_DATE - fst.FirstVisit as DISPENSE_Days_from_FirstEnc,'|' as Pipe7
      ,erx.DISPENSE_SUP,'|' as Pipe8
      ,erx.DISPENSE_AMT,'|' as Pipe9
      ,erx.RAW_NDC, 'ENDALONAEND' as ENDOFLINE
from FinalStatTable1_local fst
left join NEXTD_DISPENSING_local erx
on erx.PATID = fst.PATID          
; 
