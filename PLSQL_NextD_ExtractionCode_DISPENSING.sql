---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----                    Part 6: Dispensing medications for the study sample                              -----  
--------------------------------------------------------------------------------------------------------------- 
/* Tables for this eaxtraction: 
1. Table 1 (named here #FinalTable1) with Next-D study sample IDs. See separate SQL code for producing this table.
2. DISPENSING and DEMOGRAPHIC table from PCORNET.*/
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----  Declare study time frame variables:
-----                             Specify age limits                                       -----
--set age restrictions:
define UpperAge=89 
define LowerAge=18
---------------------------------------------------------------------------------------------------------------
whenever sqlerror continue;
drop table NextD_DISPENSING_FINAL; 
whenever sqlerror exit;

create table NextD_DISPENSING_FINAL as 
    select c.PATID, '|' as Pipe1,
		b.DISPENSINGID, '|' as Pipe2,
		b.NDC, '|' as Pipe3,
        EXTRACT(year FROM b.DISPENSE_DATE) as DISPENSE_DATE_YEAR, '|' as Pipe4,
		EXTRACT(month FROM b.DISPENSE_DATE) as DISPENSE_DATE_MONTH, '|' as Pipe5,
		b.DISPENSE_DATE - c.FirstVisit as DAYS_from_FirstEncounter_Date, '|' as Pipe6,
		b.DISPENSE_SUP, '|' as Pipe7,
        b.DISPENSE_AMT, '|' as Pipe8,
        b.RAW_NDC
from FinalTable1 c 
join "&&PCORNET_CDM".DISPENSING b on c.PATID=b.PATID    -- provide here the name of PCORI databas
join "&&PCORNET_CDM".DEMOGRAPHIC d on c.PATID=d.PATID       -- provide here the name of PCORI databas
where cast((b.DISPENSE_DATE -d.BIRTH_DATE) as numeric(18,6))/365.25 between &LowerAge and &UpperAge  
	and b.DISPENSE_DATE between TO_DATE('2010-01-01', 'YYYY-MM-DD') and TO_DATE('2020-12-31', 'YYYY-MM-DD') ; --Set extraction time frame 
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/* Save #NextD_DISPENSING_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
---------------------------------------------------------------------------------------------------------------
