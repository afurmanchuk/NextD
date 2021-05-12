---------------------------------------------------------------------------------------------------------------
-----                    Part 9: Vital signs for the study sample                              -----  
---------------------------------------------------------------------------------------------------------------
/* Tables for this eaxtraction: 
1. Table 1 (named here #FinalTable1) with Next-D study sample IDs. See separate SQL code for producing this table.
2. VITAL and DEMOGRAPHIC table from PCORNET.*/
---------------------------------------------------------------------------------------------------------------
use /*provide here the name of PCORI database here: */PCORI_SAS;
-----  Declare study time frame variables:
DECLARE @studyTimeRestriction int;declare @UpperTimeFrame int; declare @LowerTimeFrame int;
-----                             Specify time frame and age limits                                       -----
--Set extraction time frame below. If time frames not set, the code will use the whole time frame available from the database
set @LowerTimeFrame=18263;--'2010-01-01';
set @UpperTimeFrame=22280;--'2020-12-31';
--set age restrictions:
declare @UpperAge int; declare @LowerAge int;set @UpperAge=89; set @LowerAge=18;
---------------------------------------------------------------------------------------------------------------
select c.[PATID],b.[VITALID],b.[ENCOUNTERID],		
			b.VITAL_SOURCE,
			b.HT,
			b.WT,
			b.DIASTOLIC,
			b.SYSTOLIC,
			b.SMOKING,
			year(dateadd(dd,b.MEASURE_DATE,'1960-01-01')) as MEASURE_DATE_YEAR,
			month(dateadd(dd,b.MEASURE_DATE,'1960-01-01')) as MEASURE_DATE_MONTH,
			b.MEASURE_DATE-c.FirstVisit as DAYS_from_FirstEncounter_Date
into #NextD_VITAL_FINAL
from /* provide name of table 1 here: */ #FinalTable1 c 
join /* provide name of PCORNET table VITAL here: */  [dbo].[VITAL] b on c.PATID=b.PATID
join /* provide name of PCORNET table DEMOGRAPPHIC here: */ [dbo].[DEMOGRAPHIC] d on c.PATID=d.PATID 
where  convert(numeric(18,6),(b.MEASURE_DATE-d.BIRTH_DATE))/365.25 between @LowerAge and @UpperAge 
	and b.MEASURE_DATE between @LowerTimeFrame and @UpperTimeFrame;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/* Save #NextD_VITAL_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
---------------------------------------------------------------------------------------------------------------
