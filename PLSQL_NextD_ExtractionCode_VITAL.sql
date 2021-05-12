---------------------------------------------------------------------------------------------------------------
-----                    Part 9: Vital signs for the study sample                              -----  
---------------------------------------------------------------------------------------------------------------
/* Tables for this eaxtraction: 
1. Table 1 (named here #FinalTable1) with Next-D study sample IDs. See separate SQL code for producing this table.
2. VITAL and DEMOGRAPHIC table from PCORNET.*/
---------------------------------------------------------------------------------------------------------------
----  Declare study time frame variables:
-----                             Specify age limits                                       -----
--set age restrictions:
define UpperAge=89 
define LowerAge=18
--------------------------
---------------------------------------------------------------------------------------------------------------
whenever sqlerror continue;
drop table NextD_VITAL_FINAL; 
whenever sqlerror exit;

create table NextD_VITAL_FINAL as 
    select c.PATID,b.VITALID,b.ENCOUNTERID,		
			b.VITAL_SOURCE,
			b.HT,
			b.WT,
			b.DIASTOLIC,
			b.SYSTOLIC,
			b.SMOKING,
			EXTRACT(year FROM b.MEASURE_DATE) as MEASURE_DATE_YEAR,
			EXTRACT(month FROM b.MEASURE_DATE) as MEASURE_DATE_MONTH,
			b.MEASURE_DATE-c.FirstVisit as DAYS_from_FirstEncounter_Date,'ENDALONAEND' as lineEND
from FinalTable1 c 
join "&&PCORNET_CDM".VITAL b on c.PATID=b.PATID -- provide here the name of PCORI databas
join "&&PCORNET_CDM".DEMOGRAPHIC d on c.PATID=d.PATID  -- provide here the name of PCORI databas
where cast((b.MEASURE_DATE-d.BIRTH_DATE) as numeric(18,6))/365.25 between &LowerAge and &UpperAge 
	and b.MEASURE_DATE between TO_DATE('2010-01-01', 'YYYY-MM-DD') and TO_DATE('2020-12-31', 'YYYY-MM-DD') ; --Set extraction time frame
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/* Save #NextD_VITAL_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
---------------------------------------------------------------------------------------------------------------
