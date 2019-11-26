/******************************************************************************************************************/
/* NextD Clinical Variable Extractions - Prescribing Table                                                        */
/******************************************************************************************************************/

/* Tables required in this code: 
- 1. FinalStatsTable1_local: the local version of FinalStatsTable1 (output of SQLTable1_GPCsites_orcale-2019-11-25-SX.sql)  
- 2. NextD_distinct_preg_events: an intermediate table with all pregnancy events
- 3. &&PCORNET_CDM.PRESCRIBING                                     
*/

/*global parameters:
 &&PCORNET_CDM: name of CDM schema (>v5.0)
 "KUMC specific" fields: may need to be adjusted with local EMR values
*/


create table NEXTD_PRESCRIBING as
--collect all prescribing medications and shift the dates back
with pmed_with_age_realdate as (
select pmed.PATID
      ,pmed.ENCOUNTERID
      ,pmed.PRESCRIBINGID
      ,pmed.RXNORM_CUI
      ,pmed.RX_ORDER_DATE
	  ,pmed.RX_START_DATE
	  ,pmed.RX_END_DATE
      ,pmed.RX_PROVIDERID /*not the same as PROVIDERID in ENCOUNTER table*/
      ,pmed.RX_DAYS_SUPPLY
      ,pmed.RX_REFILLS
      ,pmed.RX_BASIS
      ,pmed.RAW_RX_MED_NAME /*optional -- comment out if not having it*/
      ,round((pmed.RX_ORDER_DATE-fst.BIRTH_DATE)/365.25,2) as age_at_event
from PCORNET_CDM_C7R1.PRESCRIBING pmed
join FinalStatsTable1_local fst on fst.PATID = pmed.PATID
)
--perform exclusions
   ,pmed_exclud_pregn as (
select pmedrd.PATID
      ,pmedrd.ENCOUNTERID
      ,pmedrd.PRESCRIBINGID
      ,pmedrd.RXNORM_CUI
      ,pmedrd.RX_ORDER_DATE
	  ,pmedrd.RX_START_DATE
	  ,pmedrd.RX_END_DATE
      ,pmedrd.RX_PROVIDERID
      ,pmedrd.RX_DAYS_SUPPLY
      ,pmedrd.RX_REFILLS
      ,pmedrd.RX_BASIS
      ,pmedrd.RAW_RX_MED_NAME /*optional -- comment out if not having it*/
from pmed_with_age_realdate pmedrd
where pmedrd.age_at_event between 18 and 89 and                           /*age restriction*/
      pmedrd.RX_ORDER_DATE between Date '2010-01-01' and CURRENT_DATE and /*time restriction*/
      not exists (select 1 from NextD_distinct_preg_events pd             /*pregenancy exclusion*/                    
                  where pd.PATID = pmedrd.PATID and
                        (abs(pmedrd.RX_ORDER_DATE - pd.ADMIT_DATE) <= 365))     
)
--time blinding
select fst.PATID,'|' as Pipe1
      ,erx.ENCOUNTERID,'|' as Pipe2
      ,erx.PRESCRIBINGID,'|' as Pipe3
      ,erx.RXNORM_CUI,'|' as Pipe4
      ,cast(to_char(erx.RX_ORDER_DATE,'YYYY') as INTEGER) RX_ORDER_YEAR,'|' as Pipe5
      ,cast(to_char(erx.RX_ORDER_DATE,'MM') as INTEGER) RX_ORDER_MONTH,'|' as Pipe6
      ,erx.RX_ORDER_DATE - fst.FirstVisit as RX_ORDER_Days_from_FirstEnc,'|' as Pipe7
      ,erx.RX_PROVIDERID,'|' as Pipe8
      ,cast(to_char(erx.RX_START_DATE,'YYYY') as INTEGER) RX_START_YEAR,'|' as Pipe9
      ,cast(to_char(erx.RX_START_DATE,'MM') as INTEGER) RX_START_MONTH,'|' as Pipe10
      ,erx.RX_START_DATE - fst.FirstVisit as RX_START_Days_from_FirstEnc,'|' as Pipe11
      ,cast(to_char(erx.RX_END_DATE,'YYYY') as INTEGER) RX_END_YEAR,'|' as Pipe12
      ,cast(to_char(erx.RX_END_DATE,'MM') as INTEGER) RX_END_MONTH,'|' as Pipe13
      ,erx.RX_END_DATE - fst.FirstVisit as RX_END_Days_from_FirstEnc,'|' as Pipe14
      ,erx.RX_DAYS_SUPPLY,'|' as Pipe15
      ,erx.RX_REFILLS,'|' as Pipe16
      ,erx.RX_BASIS,'|' as Pipe17
      ,erx.RAW_RX_MED_NAME,'ENDALONAEND' as ENDOFLINE
from FinalStatsTable1_local fst
join pmed_exclud_pregn erx
on erx.PATID = fst.PATID 
;



---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----- 1. Download table NEXTD_PRESCRIBING as .csv file for final delivery                                ------
---------------------------------------------------------------------------------------------------------------


