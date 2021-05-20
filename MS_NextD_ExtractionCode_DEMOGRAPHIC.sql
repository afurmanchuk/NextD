---------------------------------------------------------------------------------------------------------------
-----                            Part 1: Demographics for the study sample                                -----  
--------------------------------------------------------------------------------------------------------------- 
/* Tables for this eaxtraction: 
1. Table 1 (named here [NextD].[dbo].[FinalTable1]) with Next-D study sample IDs. See separate SQL code for producing this table.
2. Demographics table from PCORNET.*/
--------------------------------------------------------------------------------------------------------------- 
use /*provide here the name of PCORI database here: */PCORI_SAS;
select c.PATID, '|' as Pipe1,
		year(a.BIRTH_DATE) as BIRTH_DATE_YEAR, '|' as Pipe2,
		month(a.BIRTH_DATE) as BIRTH_DATE_MONTH, '|' as Pipe3,
		datediff(d,c.FirstVisit,a.BIRTH_DATE) as DAYS_from_FirstEncounter_Date, '|' as Pipe4,
		a.SEX, '|' as Pipe5,
		a.RACE, '|' as Pipe6,
		a.HISPANIC ,'ENDALONAEND' as lineEND
into #NextD_DEMOGRAPHIC_FINAL
from /* provide name of table 1 here: */ #FinalTable1 c 
left join [dbo].[DEMOGRAPHIC] a on c.PATID =a.PATID ;
--------------------------------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------------------------------- 
/* Save #NextD_DEMOGRAPHIC_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
--------------------------------------------------------------------------------------------------------------- 
