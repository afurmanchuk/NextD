---------------------------------------------------------------------------------------------------------------
-----                    Part 5: Prescibed medications for the study sample                               -----  
--------------------------------------------------------------------------------------------------------------- 
/* Tables for this eaxtraction: 
1.  PRESCRIBING, DEMOGRAPHIC, ENCOUNTER tables from PCORNET.
*/
---------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------- 
----  Declare study time frame variables:
-----                             Specify age limits                                       -----
--set age restrictions:
define UpperAge=89 
define LowerAge=18
--------------------------------------------------------------------------------------------------------------

whenever sqlerror continue;
drop table NextD_PRESCRIBING_FINAL; 
whenever sqlerror exit;

create table NextD_PRESCRIBING_FINAL as 
 select c.PATID, '|' as Pipe1,
		a.ENCOUNTERID, '|' as Pipe2,
		b.PRESCRIBINGID, '|' as Pipe3,
		b.RXNORM_CUI, '|' as Pipe4,
		EXTRACT(year FROM b.RX_ORDER_DATE) as PX_ORDER_DATE_YEAR, '|' as Pipe5,
		EXTRACT(month FROM b.RX_ORDER_DATE) as PX_ORDER_DATE_MONTH, '|' as Pipe6,
		b.RX_ORDER_DATE - c.FirstVisit as DAYS_from_FirstEncounter_Date1, '|' as Pipe7,
		EXTRACT(year FROM b.RX_START_DATE) as RX_START_DATE_YEAR, '|' as Pipe8,
		EXTRACT(month FROM b.RX_START_DATE) as PX_START_DATE_MONTH, '|' as Pipe9,
		b.RX_START_DATE - c.FirstVisit as DAYS_from_FirstEncounter_Date2, '|' as Pipe10,
		b.RX_PROVIDERID, '|' as Pipe11,
		b.RX_DAYS_SUPPLY, '|' as Pipe12,
		b.RX_REFILLS , '|' as Pipe13,
		b.RX_BASIS, '|' as Pipe14,
		b.RAW_RX_MED_NAME,'ENDALONAEND' as lineEND
from FinalTable1 c 
join "&&PCORNET_CDM".ENCOUNTER a on c.PATID=a.PATID             -- provide here the name of PCORI databas
join  "&&PCORNET_CDM".PRESCRIBING b on a.ENCOUNTERID=b.ENCOUNTERID  -- provide here the name of PCORI databas
join  "&&PCORNET_CDM".DEMOGRAPHIC d on c.PATID=d.PATID          -- provide here the name of PCORI databas
where cast((b.RX_ORDER_DATE-d.BIRTH_DATE) as numeric(18,6))/365.25 between &LowerAge and &UpperAge 
	and b.RX_ORDER_DATE between TO_DATE('2010-01-01', 'YYYY-MM-DD') and TO_DATE('2020-12-31', 'YYYY-MM-DD') ; --Set extraction time frame 
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/* Save #NextD_PRESCRIBING_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
---------------------------------------------------------------------------------------------------------------
