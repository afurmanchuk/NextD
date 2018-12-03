/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - require: 1. FinalStatsTable1 local version where dates are nor masked                                        */
/*            2. date_unshifts generated from FinalStatsTable1 extraction                                         */
/*                                                                                                                */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C4R1   */
/******************************************************************************************************************/

/*Note: 'KUMC specific' issue are marked as such*/

/**************************************************************************/
/***********************Table 7 -- Vital Signs*****************************/
/**************************************************************************/

/*Step 1 - Get all eligible encounters and apply date-unshifting
 - age restriction: between 18 and 89;
 - study period restriction: after 01-01-2010;
 - exclude pregancy encounters */

create table Eligible_VITAL as
with vital_with_age_realdate as (
select v.*
      ,v.MEASURE_DATE+ds.days_shift as REAL_MEASURE_DATE
      ,round((v.MEASURE_DATE - pat.BIRTH_DATE)/365.25,2) AS age_at_visit
from /*provide current PCORNET_CDM.Vital table here*/"&&PCORNET_CDM".VITAL v
left join /*provide current PCORNET_CDM.Demographic table here*/"&&PCORNET_CDM".DEMOGRAPHIC pat
on v.PATID = pat.PATID
left join date_unshifts ds
on v.PATID = ds.PATID
where exists (select 1 from FinalStatTable1 fst
              where fst.PATID = v.PATID)
)
    ,preg_dates as (
select distinct PATID
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
)
select vrd.PATID
      ,vrd.ENCOUNTERID
      ,vrd.VITALID
      ,vrd.REAL_MEASURE_DATE
      ,vrd.HT
      ,vrd.WT
      ,vrd.SYSTOLIC
      ,vrd.DIASTOLIC
      ,vrd.SMOKING
from vital_with_age_realdate vrd
where vrd.age_at_visit between 18 and 89 and                               /*age restriction*/
      vrd.REAL_MEASURE_DATE between Date '2010-01-01' and CURRENT_DATE and /*time restriction*/
      not exists (select 1 from preg_dates pd                          /*pregenancy exclusion*/
                  where pd.PATID = vrd.PATID and
                        (abs(vrd.REAL_MEASURE_DATE-pd.PREGNANCY_DATE) <= 365))                         
;

/*for better efficiency*/
create index Eligible_VITAL_PATID_IDX on Eligible_VITAL(PATID);

/*Step 2: get final Vital table and apply date-bliding*/
drop table NEXTD_VITAL PURGE;
create table NEXTD_VITAL as
with vital_orig as (
select fst.PATID
      ,v.ENCOUNTERID
      ,v.VITALID
      ,v.REAL_MEASURE_DATE
      ,v.HT
      ,v.WT
      ,v.SYSTOLIC
      ,v.DIASTOLIC
      ,v.SMOKING
from FinalStatTable1 fst
left join Eligible_VITAL v
on fst.PATID = v.PATID         
)
--time blinding
select vo.PATID
      ,vo.ENCOUNTERID
      ,vo.VITALID
      ,cast(to_char(vo.REAL_MEASURE_DATE,'YYYY') as INTEGER) MEASURE_YEAR
      ,cast(to_char(vo.REAL_MEASURE_DATE,'MM') as INTEGER) MEASURE_MONTH
      ,vo.REAL_MEASURE_DATE - fst.FirstVisit as MEAS_Days_from_FirstEncounter
      ,vo.HT
      ,vo.WT
      ,vo.SYSTOLIC
      ,vo.DIASTOLIC
      ,vo.SMOKING
from FinalStatTable1 fst
left join vital_orig vo
on vo.PATID = fst.PATID
; 

------------------------------------------------
/* Save #NextD_VITAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
-------------------------------------------------
