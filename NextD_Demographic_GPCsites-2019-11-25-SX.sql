---------------------------------------------------------------------------------------------------------------
-----                            Part 1: Demographics for the study sample                                -----  
--------------------------------------------------------------------------------------------------------------- 
/* Tables for this eaxtraction: 
1. Table 1 (named here [NextD].[dbo].[FinalTable1]) with Next-D study sample IDs. See separate SQL code for producing this table.
2. Demographics table from PCORNET.*/
--------------------------------------------------------------------------------------------------------------- 
use /*provide here the name of PCORI database here: */PCORI_SAS;
select c.PATID,
		year(dateadd(dd,a.BIRTH_DATE,'1960-01-01')) as BIRTH_DATE_YEAR,
		month(dateadd(dd,a.BIRTH_DATE,'1960-01-01')) as BIRTH_DATE_MONTH,
		a.BIRTH_DATE-c.FirstVisit as DAYS_from_FirstEncounter_Date,
		a.SEX,
		a.RACE,
		a.HISPANIC 
into #NextD_DEMOGRAPHIC_FINAL
from /* provide name of table 1 here: */ #FinalTable1 c 
left join [dbo].[DEMOGRAPHIC] a on c.PATID =a.PATID ;
--------------------------------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------------------------------- 
/* Save #NextD_DEMOGRAPHIC_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
--------------------------------------------------------------------------------------------------------------- 
