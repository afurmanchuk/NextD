/******************************************************************************************************************/
/* NextD Clinical Variable Extractions - Dispensing Table                                                         */
/* exclude pregancy                                                                                               */
/******************************************************************************************************************/

/* Tables required in this code: 
- 1. FinalStatsTable1_local: the local version of FinalStatsTable1 (output of SQLTable1_GPCsites_orcale-2019-11-25-SX.sql)  
- 2. NextD_distinct_preg_events: an intermediate table with all pregnancy events
- 3. &&PCORNET_CDM.DISPENSING                                     
*/

/*global parameters:
 &&PCORNET_CDM: name of CDM schema (>v5.0)
 "KUMC specific" fields: may need to be adjusted with local EMR values
*/

create table NEXTD_DISPENSING as
with dmed_with_age_realdate as (
select dmed.PATID
      ,dmed.DISPENSINGID
      ,dmed.PRESCRIBINGID
      ,dmed.NDC
      ,dmed.DISPENSE_DATE
      ,dmed.DISPENSE_SUP
      ,dmed.DISPENSE_AMT
      ,dmed.RAW_NDC
      ,round((dmed.DISPENSE_DATE - fst.BIRTH_DATE)/365.25,2) as age_at_event
from "&&PCORNET_CDM".DISPENSING dmed
join FinalStatsTable1_local fst on fst.PATID = dmed.PATID
)
  ,dmed_pregn_exclud as (
select dmedrd.PATID
      ,dmedrd.DISPENSINGID
      ,dmedrd.PRESCRIBINGID
      ,dmedrd.NDC
      ,dmedrd.DISPENSE_DATE
      ,dmedrd.DISPENSE_SUP
      ,dmedrd.DISPENSE_AMT
      ,dmedrd.RAW_NDC
from dmed_with_age_realdate dmedrd
where dmedrd.age_at_event between 18 and 89 and                           /*age restriction*/
      dmedrd.DISPENSE_DATE between Date '2010-01-01' and CURRENT_DATE and /*time restriction*/
      not exists (select 1 from NextD_distinct_preg_events pd             /*pregenancy exclusion*/               
                  where pd.PATID = dmedrd.PATID and
                        (abs(dmedrd.DISPENSE_DATE - pd.ADMIT_DATE) <= 365))       
)
--time blinding
select fst.PATID,'|' as Pipe1
      ,erx.DISPENSINGID,'|' as Pipe2
      ,erx.PRESCRIBINGID,'|' as Pipe3
      ,erx.NDC,'|' as Pipe4
      ,cast(to_char(erx.DISPENSE_DATE,'YYYY') as INTEGER) DISPENSE_YEAR,'|' as Pipe5
      ,cast(to_char(erx.DISPENSE_DATE,'MM') as INTEGER) DISPENSE_MONTH,'|' as Pipe6
      ,erx.DISPENSE_DATE - fst.FirstVisit as DISPENSE_Days_from_FirstEnc,'|' as Pipe7
      ,erx.DISPENSE_SUP,'|' as Pipe8
      ,erx.DISPENSE_AMT,'|' as Pipe9
      ,erx.RAW_NDC
      ,'ENDALONAEND' as ENDOFLINE
from FinalStatsTable1_local fst
join dmed_pregn_exclud erx
on erx.PATID = fst.PATID          
; 

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----- 1. Download table NEXTD_DISPENSING as .csv file for final delivery                                 ------
---------------------------------------------------------------------------------------------------------------


