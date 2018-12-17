/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - require: 1. FinalStatsTable1_local: the local version where dates neither shifted nor masked                 */
/*            2. date_unshifts: an intermediate table for recovering real dates                                   */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C5R2   */
/******************************************************************************************************************/

/*Note: 'KUMC specific' issue are marked as such*/

/**************************************************************************/
/***********************Table 7 -- Vital Signs*****************************/
/**************************************************************************/
/*for better efficiency*/
create index FinalStatTable1_PAT_IDX on FinalStatTable1_local(PATID);

create table NEXTD_VITAL_local as 
with vital_with_age_realdate as (
select v.PATID
      ,v.ENCOUNTERID
      ,v.MEASURE_DATE+ds.days_shift as REAL_MEASURE_DATE
      ,v.VITALID
      ,v.VITAL_SOURCE
      ,v.HT
      ,v.WT
      ,v.SYSTOLIC
      ,v.DIASTOLIC
      ,v.SMOKING
      ,round((v.MEASURE_DATE+ds.days_shift-fst.BIRTH_DATE)/365.25,2) AS age_at_event
from /*provide current PCORNET_CDM.Vital table here*/"&&PCORNET_CDM".VITAL v
join FinalStatTable1_local fst on fst.PATID = v.PATID
join date_unshifts ds on ds.PATID = v.PATID
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
select vard.VITALID
from vital_with_age_realdate vard
where vard.age_at_event between 18 and 89 and                                
      vard.REAL_MEASURE_DATE between Date '2010-01-01' and CURRENT_DATE and 
      exists (select 1 from pregn_dates pd                                 
                  where pd.PATID = vard.PATID and
                        (abs(vard.REAL_MEASURE_DATE - pd.PREGNANCY_DATE) <= 365))
)
select vrd.PATID
      ,vrd.ENCOUNTERID
      ,vrd.REAL_MEASURE_DATE
      ,vrd.VITALID
      ,vrd.VITAL_SOURCE
      ,vrd.HT
      ,vrd.WT
      ,vrd.SYSTOLIC
      ,vrd.DIASTOLIC
      ,vrd.SMOKING
from vital_with_age_realdate vrd
where vrd.age_at_event between 18 and 89 and                               /*age restriction*/
      vrd.REAL_MEASURE_DATE between Date '2010-01-01' and CURRENT_DATE and /*time restriction*/
      vrd.VITALID not in (select VITALID from pregn_exclud)                /*pregenancy exclusion*/               
;


create table NEXTD_VITAL as
select fst.PATID,'|' as Pipe1
      ,vt.ENCOUNTERID,'|' as Pipe2
      ,cast(to_char(vt.REAL_MEASURE_DATE,'YYYY') as INTEGER) MEASURE_YEAR,'|' as Pipe3
      ,cast(to_char(vt.REAL_MEASURE_DATE,'MM') as INTEGER) MEASURE_MONTH,'|' as Pipe4
      ,vt.REAL_MEASURE_DATE - fst.FirstVisit as MEAS_Days_from_FirstEncounter,'|' as Pipe5
      ,vt.VITALID,'|' as Pipe6
      ,vt.VITAL_SOURCE,'|' as Pipe7
      ,vt.HT,'|' as Pipe8
      ,vt.WT,'|' as Pipe9
      ,vt.SYSTOLIC,'|' as Pipe10
      ,vt.DIASTOLIC,'|' as Pipe11
      ,vt.SMOKING,'ENDALONAEND' as ENDOFLINE
from FinalStatTable1_local fst
left join  NEXTD_VITAL_local vt
on vt.PATID = fst.PATID
; 
