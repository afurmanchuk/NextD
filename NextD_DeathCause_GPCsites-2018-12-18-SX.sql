---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----                             Part 11: DEATH_CAUSE for the study sample                               -----  
--------------------------------------------------------------------------------------------------------------- 
---------------------------------------------------------------------------------------------------------------
/* Tables for this eaxtraction: 
1. Table 1 (named here #FinalTable1) with Next-D study sample IDs. See separate SQL code for producing this table.
2. DEATH_CAUSE table from PCORNET. */
---------------------------------------------------------------------------------------------------------------
use /*provide here the name of PCORI database here: */PCORI_SAS;
select c.PATID,'|' as PIPIE1,
		b.DEATH_CAUSE, '|' as PIPIE2,
		b.DEATH_CAUSE_CODE,'|' as PIPIE3,
		b.DEATH_CAUSE_TYPE ,'|' as PIPIE4,
		b.DEATH_CAUSE_SOURCE ,'|' as PIPIE5,
		b.DEATH_CAUSE_CONFIDENCE , 'ENDALONAEND' as ENDLINE
into #NextD_DEATH_CAUSE_FINAL
from /* provide name of table 1 here: */ #FinalTable1 c 
left join [dbo].[DEATH_CAUSE] b on c.PATID=b.PATID;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/* Save #NextD_DEATH_CAUSE_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
---------------------------------------------------------------------------------------------------------------
