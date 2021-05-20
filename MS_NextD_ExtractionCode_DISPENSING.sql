---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----                    Part 6: Dispensing medications for the study sample                              -----  
--------------------------------------------------------------------------------------------------------------- 
/* Tables for this eaxtraction: 
1. Table 1 (named here #FinalTable1) with Next-D study sample IDs. See separate SQL code for producing this table.
2. DISPENSING and DEMOGRAPHIC table from PCORNET.*/
---------------------------------------------------------------------------------------------------------------
use /*provide here the name of PCORI database here: */PCORI_SAS;
---------------------------------------------------------------------------------------------------------------
-----                            Declare study time frame variables:                                      -----
DECLARE @studyTimeRestriction int;declare @UpperTimeFrame int; declare @LowerTimeFrame int;
-----                             Specify time frame and age limits                                       -----
--Set extraction time frame below. If time frames not set, the code will use the whole time frame available from the database
set @LowerTimeFrame='2010-01-01';
set @UpperTimeFrame='2020-12-31';
--set age restrictions:
declare @UpperAge int; declare @LowerAge int;set @UpperAge=89; set @LowerAge=18;
---------------------------------------------------------------------------------------------------------------
select c.PATID, '|' as Pipe1,
		b.DISPENSINGID, '|' as Pipe2,
		b.NDC, '|' as Pipe3,
		year(b.DISPENSE_DATE) as DISPENSE_DATE_YEAR, '|' as Pipe4,
		month(b.DISPENSE_DATE) as DISPENSE_DATE_MONTH, '|' as Pipe5,
		datediff(d,c.FirstVisit, b.DISPENSE_DATE)  as DAYS_from_FirstEncounter_Date, '|' as Pipe6,
		b.DISPENSE_SUP, '|' as Pipe7,
		b.DISPENSE_AMT, '|' as Pipe8,
		b.RAW_NDC,'ENDALONAEND' as lineEND
into #NextD_DISPENSING_FINAL
from /* provide name of table 1 here: */ #FinalTable1 c 
join [dbo].[DISPENSING] b on c.PATID=b.PATID 
join dbo.DEMOGRAPHIC d on c.PATID=d.PATID
where datediff(yy,d.BIRTH_DATE,b.DISPENSE_DATE) between @LowerAge and @UpperAge  
	and b.DISPENSE_DATE between @LowerTimeFrame and  @UpperTimeFrame;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/* Save #NextD_DISPENSING_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
---------------------------------------------------------------------------------------------------------------
