---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----                             Part 11: DEATH_CAUSE for the study sample                               -----  
--------------------------------------------------------------------------------------------------------------- 
---------------------------------------------------------------------------------------------------------------
/* Tables for this eaxtraction: 
1. Table 1 (named here #FinalTable1) with Next-D study sample IDs. See separate SQL code for producing this table.
2. DEATH_CAUSE table from PCORNET. */
---------------------------------------------------------------------------------------------------------------

whenever sqlerror continue;
drop table NextD_DEATH_CAUSE_FINAL; 
whenever sqlerror exit;

create table NextD_DEATH_CAUSE_FINAL as 
    select c.PATID , '|' as PIPIE1,
		b.DEATH_CAUSE , '|' as PIPIE2,
		b.DEATH_CAUSE_CODE ,'|' as PIPIE3,
		b.DEATH_CAUSE_TYPE , '|' as PIPIE4,
		b.DEATH_CAUSE_SOURCE , '|' as PIPIE5,
		b.DEATH_CAUSE_CONFIDENCE 
from FinalTable1 c 
left join "&&PCORNET_CDM".DEATH_CAUSE b on c.PATID=b.PATID; -- provide here the name of PCORI databas
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/* Save #NextD_DEATH_CAUSE_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
---------------------------------------------------------------------------------------------------------------
