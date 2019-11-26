/******************************************************************************************************************/
/* NextD Clinical Variable Extractions - Vital Table                                                              */
/* exclude pregancy                                                                                               */
/******************************************************************************************************************/

/* Tables required in this code: 
- 1. FinalStatsTable1_local: the local version of FinalStatsTable1 (output of SQLTable1_GPCsites_orcale-2019-11-25-SX.sql)  
- 2. NextD_distinct_preg_events: an intermediate table with all pregnancy events
- 3. &&PCORNET_CDM.VITAL                                     
*/

/*global parameters:
 &&PCORNET_CDM: name of CDM schema (>v5.0)
 "KUMC specific" fields: may need to be adjusted with local EMR values
*/


create table NEXTD_VITAL as 
with vital_with_age_realdate as (
select v.PATID
      ,v.ENCOUNTERID
      ,v.MEASURE_DATE
      ,v.VITALID
      ,v.VITAL_SOURCE
      ,v.HT
      ,v.WT
      ,v.SYSTOLIC
      ,v.DIASTOLIC
      ,v.SMOKING
      ,round((v.MEASURE_DATE-fst.BIRTH_DATE)/365.25,2) AS age_at_event
from "&&PCORNET_CDM".VITAL v
join FinalStatsTable1_local fst on fst.PATID = v.PATID
)
    ,vital_preg_exclud as (
select vrd.PATID
      ,vrd.ENCOUNTERID
      ,vrd.MEASURE_DATE
      ,vrd.VITALID
      ,vrd.VITAL_SOURCE
      ,vrd.HT
      ,vrd.WT
      ,vrd.SYSTOLIC
      ,vrd.DIASTOLIC
      ,vrd.SMOKING
from vital_with_age_realdate vrd
where vrd.age_at_event between 18 and 89 and                               /*age restriction*/
      vrd.MEASURE_DATE between Date '2010-01-01' and CURRENT_DATE and /*time restriction*/
      not exists (select 1 from NextD_distinct_preg_events pd              /*pregenancy exclusion*/                     
                  where pd.PATID = vrd.PATID and
                        (abs(vrd.MEASURE_DATE - pd.ADMIT_DATE) <= 365))                               
)
--time blinding
select fst.PATID,'|' as Pipe1
      ,vt.ENCOUNTERID,'|' as Pipe2
      ,cast(to_char(vt.MEASURE_DATE,'YYYY') as INTEGER) MEASURE_YEAR,'|' as Pipe3
      ,cast(to_char(vt.MEASURE_DATE,'MM') as INTEGER) MEASURE_MONTH,'|' as Pipe4
      ,vt.MEASURE_DATE - fst.FirstVisit as MEAS_Days_from_FirstEncounter,'|' as Pipe5
      ,vt.VITALID,'|' as Pipe6
      ,vt.VITAL_SOURCE,'|' as Pipe7
      ,vt.HT,'|' as Pipe8
      ,vt.WT,'|' as Pipe9
      ,vt.SYSTOLIC,'|' as Pipe10
      ,vt.DIASTOLIC,'|' as Pipe11
      ,vt.SMOKING
      ,'ENDALONAEND' as ENDOFLINE
from FinalStatsTable1_local fst
join vital_preg_exclud vt
on vt.PATID = fst.PATID
; 


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----- 1. Download table NEXTD_VITAL as .csv  file for final delivery                                     ------
---------------------------------------------------------------------------------------------------------------


