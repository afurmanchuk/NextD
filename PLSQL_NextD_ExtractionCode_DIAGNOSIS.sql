---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----                             Part 4: Diagnoses for the study sample                                  -----  
--------------------------------------------------------------------------------------------------------------- 
---------------------------------------------------------------------------------------------------------------
/* Tables for this eaxtraction: 
1. Table 1 (named here #FinalTable1) with Next-D study sample IDs. See separate SQL code for producing this table.
2. DIAGNOSIS and DEMOGRAPHIC table from PCORNET. */
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----                            Declare study time frame variables:                                      -----
---------------------------------------------------------------------------------------------------------------
--Set your time frame below between '2010-01-01' and '2020-12-31'. If time frames not set, the code will use the whole time frame available from the database;
define LowerTimeFrame=18263 
define UpperTimeFrame=22280 
--set age restrictions:
define UpperAge=89 
define LowerAge=18
---------------------------------------------------------------------------------------------------------------
whenever sqlerror continue;
drop table NextD_DIAGNOSIS_FINAL; 
whenever sqlerror exit;

create table NextD_DIAGNOSIS_FINAL as 
    select c.PATID, '|' as Pipe1,
		b.ENCOUNTERID, '|' as Pipe2,
		b.DIAGNOSISID, '|' as Pipe3,
		b.DX, '|' as Pipe4,
		b.PDX, '|' as Pipe5,
		b.DX_POA, '|' as Pipe6,
		b.DX_TYPE, '|' as Pipe7,
		b.DX_SOURCE, '|' as Pipe8,
		b.DX_ORIGIN, '|' as Pipe9,
		b.ENC_TYPE, '|' as Pipe10,
		EXTRACT(year FROM b.ADMIT_DATE) as ADMIT_DATE_DATE_YEAR, '|' as Pipe11,
		EXTRACT(month FROM b.ADMIT_DATE) as ADMIT_DATE_DATE_MONTH, '|' as Pipe12,
		b.ADMIT_DATE - c.FirstVisit as DAYS_from_FirstEncounter_Date,'ENDALONAEND' as lineEND
from  FinalTable1 c 
join  "&&PCORNET_CDM".DIAGNOSIS b on c.PATID=b.PATID    -- provide here the name of PCORI databas
join  "&&PCORNET_CDM".DEMOGRAPHIC d on c.PATID=d.PATID  -- provide here the name of PCORI databas
where cast((b.ADMIT_DATE-d.BIRTH_DATE) as numeric(18,6))/365.25 between &LowerAge and &UpperAge 
	and b.ADMIT_DATE - TO_DATE('1960/01/01', 'YYYY/MM/DD') between &LowerTimeFrame and &UpperTimeFrame;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/* Save #NextD_DIAGNOSIS_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
---------------------------------------------------------------------------------------------------------------
