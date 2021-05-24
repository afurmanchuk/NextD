---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----                             Part 7: Procedures for the study sample                                 -----  
--------------------------------------------------------------------------------------------------------------- 
---------------------------------------------------------------------------------------------------------------
/* Tables for this extraction: 
1. Table 1 (named here #FinalTable1) with Next-D study sample IDs. See separate SQL code for producing this table.
2. PROCEDURES and DEMOGRAPHIC table from PCORNET. */
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----  Declare study time frame variables:
--Set your time frame below between '2010-01-01' and '2020-12-31'. If time frames not set, the code will use the whole time frame available from the database;
define LowerTimeFrame= TO_DATE('2010-01-01' , 'YYYY-MM-DD') 
define UpperTimeFrame= TO_DATE('2020-12-31', 'YYYY-MM-DD')
--set age restrictions:
define UpperAge=89 
define LowerAge=18
--------------------------
---------------------------------------------------------------------------------------------------------------

whenever sqlerror continue;
drop table NextD_PROCEDURES_FINAL; 
whenever sqlerror exit;

create table NextD_PROCEDURES_FINAL as 
    select c.PATID, '|' as Pipe1,
	b.ENCOUNTERID, '|' as Pipe2,
	b.PROCEDURESID, '|' as Pipe3,
	b.ENC_TYPE, '|' as Pipe4,
	EXTRACT(year FROM b.ADMIT_DATE) as ADMIT_DATE_YEAR, '|' as Pipe5,
	EXTRACT(month FROM b.ADMIT_DATE) as ADMIT_DATE_MONTH, '|' as Pipe6,
	b.ADMIT_DATE - c.FirstVisit as DAYS_from_FirstEncounter_Date1, '|' as Pipe7,
	b.PROVIDERID, '|' as Pipe8,
	EXTRACT(year FROM b.PX_DATE) as PX_DATE_YEAR, '|' as Pipe9,
	EXTRACT(month FROM b.PX_DATE) as PX_DATE_MONTH, '|' as Pipe10,
	b.PX_DATE - c.FirstVisit as DAYS_from_FirstEncounter_Date2, '|' as Pipe11,
	b.PX, '|' as Pipe12,
	b.PPX, '|' as Pipe13,
	b.PX_TYPE, '|' as Pipe14,
	b.PX_SOURCE
from FinalTable1 c 
join "&&PCORNET_CDM".PROCEDURES b on c.PATID=b.PATID   -- provide here the name of PCORI databas
join "&&PCORNET_CDM".DEMOGRAPHIC d on c.PATID=d.PATID  -- provide here the name of PCORI databas
where cast((b.ADMIT_DATE - d.BIRTH_DATE) as numeric(18,6))/365.25 between &LowerAge and &UpperAge 
	and b.ADMIT_DATE between &LowerTimeFrame and &UpperTimeFrame ; --Set extraction time frame 
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/* Save #NextD_PROCEDURES_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
---------------------------------------------------------------------------------------------------------------
