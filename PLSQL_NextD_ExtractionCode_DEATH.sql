---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----                             Part 10: DEATH_CAUSE for the study sample                                -----  
--------------------------------------------------------------------------------------------------------------- 
---------------------------------------------------------------------------------------------------------------
/* Tables for this eaxtraction: 
1. Table 1 (named here #FinalTable1) with Next-D study sample IDs. See separate SQL code for producing this table.
2. DEATH_CAUSE table from PCORNET. */
---------------------------------------------------------------------------------------------------------------
whenever sqlerror continue;
drop table NextD_DEATH_FINAL; 
whenever sqlerror exit;

create table NextD_DEATH_FINAL as 
    select c.PATID, '|' as Pipe1,
			EXTRACT(year FROM b.DEATH_DATE) as DEATH_DATE_YEAR, '|' as Pipe2,
			EXTRACT(month FROM b.DEATH_DATE) as DEATH_DATE_MONTH, '|' as Pipe3,
			b.DEATH_DATE-c.FirstVisit as DAYS_from_FirstEncounter_Date, '|' as Pipe4,
			b.DEATH_SOURCE
from FinalTable1 c 
left join "&&PCORNET_CDM".DEATH b on c.PATID=b.PATID; -- provide here the name of PCORI databas
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/* Save #NextD_DEATH_CAUSE_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
---------------------------------------------------------------------------------------------------------------
