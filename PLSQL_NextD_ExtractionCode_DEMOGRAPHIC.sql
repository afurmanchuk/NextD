---------------------------------------------------------------------------------------------------------------
-----                            Part 1: Demographics for the study sample                                -----  
--------------------------------------------------------------------------------------------------------------- 
/* Tables for this eaxtraction: 
1. Table 1 (named here [NextD].[dbo].[FinalTable1]) with Next-D study sample IDs. See separate SQL code for producing this table.
2. Demographics table from PCORNET.*/
--------------------------------------------------------------------------------------------------------------- 
whenever sqlerror continue;
drop table NextD_DEMOGRAPHIC_FINAL; 
whenever sqlerror exit;

create table NextD_DEMOGRAPHIC_FINAL as 
    select c.PATID, '|' as PIPIE1,
        EXTRACT(year FROM a.BIRTH_DATE) as BIRTH_DATE_YEAR, '|' as PIPIE2,
		EXTRACT(month FROM a.BIRTH_DATE) as BIRTH_DATE_MONTH, '|' as PIPIE3,
		a.BIRTH_DATE-c.FirstVisit as DAYS_from_FirstEncounter_Date, '|' as PIPIE4,
		a.SEX, '|' as PIPIE5,
		a.RACE, '|' as PIPIE6,
		a.HISPANIC
from FinalTable1 c 
left join "&&PCORNET_CDM".DEMOGRAPHIC a on c.PATID =a.PATID ;
--------------------------------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------------------------------- 
/* Save #NextD_DEMOGRAPHIC_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
--------------------------------------------------------------------------------------------------------------- 
