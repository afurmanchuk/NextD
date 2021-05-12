---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----                             Part 3: Encounters for the study sample                                 -----  
--------------------------------------------------------------------------------------------------------------- 
/* Tables for this eaxtraction: 
1. Table 1 (named here #FinalStatTable1) with Next-D study sample IDs. See separate SQL code for producing this table.
2. PCORI ENCOUNTER table*/
--------------------------------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------------------------------- 
----  Declare study time frame variables:
-----                             Specify age limits                                       -----
--set age restrictions:
define UpperAge=89 
define LowerAge=18
---------------------------------------------------------------------------------------------------------------
/* Steps for insurance remap (omit if not remapping):

1. Load provided by NU team remapping table named MasterReMap. It has following columns:
[RAW_financial_class_dsc],[RAW_cdf_meaning],[RAW_BENEFIT_PLAN_NAME],[RAW_PRODUCT_TYPE],[RAW_PAYOR_NAME],[RAW_EPM_ALT_IDFR],[RAW_SHORT_NAME],[NewCategory]
2. Load table (named here #RawNPIValuesTable) with coresponding NPI values for each encounter of interest.
3. Remap raw values into new insurance and provider categories :*/
---------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------------------------------- 

whenever sqlerror continue;
drop table NextD_ENCOUNTER_FINAL; 
whenever sqlerror exit;

create table NextD_ENCOUNTER_FINAL as 
select c.PATID, '|' as Pipe1,
		a.ENCOUNTERID, '|' as Pipe2,
		a.PROVIDERID, '|' as Pipe3,
        EXTRACT(year FROM a.ADMIT_DATE) as ADMIT_DATE_YEAR, '|' as Pipe4,
        EXTRACT(month FROM a.ADMIT_DATE) as ADMIT_DATE_MONTH, '|' as Pipe5,
		a.ADMIT_DATE - c.FirstVisit as DAYS_from_FirstEncounter_Date1, '|' as Pipe6,
        EXTRACT(year FROM a.DISCHARGE_DATE) as DISCHARGE_DATE_YEAR, '|' as Pipe7,
        EXTRACT(month FROM a.DISCHARGE_DATE) as DISCHARGE_DATE_MONTH, '|' as Pipe8,
		a.DISCHARGE_DATE - c.FirstVisit as DAYS_from_FirstEncounter_Date2, '|' as Pipe9,
		a.ENC_TYPE, '|' as Pipe10,
		a.FACILITYID, '|' as Pipe11,
		a.FACILITY_TYPE, '|' as Pipe12,
		a.DISCHARGE_DISPOSITION, '|' as Pipe13,
		a.DISCHARGE_STATUS, '|' as Pipe14,
		a.ADMITTING_SOURCE, '|' as Pipe15,
		a.PAYER_TYPE_PRIMARY, '|' as Pipe16,
		a.PAYER_TYPE_SECONDARY
from FinalTable1 c 
join "&&PCORNET_CDM".ENCOUNTER a on c.PATID=a.PATID     -- provide here the name of PCORI databas
join "&&PCORNET_CDM".DEMOGRAPHIC d on c.PATID=d.PATID	-- provide here the name of PCORI databas	
where cast((a.ADMIT_DATE-d.BIRTH_DATE) as numeric(18,6))/365.25 between &LowerAge and &UpperAge 
and  a.ADMIT_DATE between TO_DATE('2010-01-01', 'YYYY-MM-DD') and TO_DATE('2020-12-31', 'YYYY-MM-DD') ; --Set extraction time frame 
--------------------------------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------------------------------- 
 /* Save #NextD_ENCOUNTER_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
--------------------------------------------------------------------------------------------------------------- 
