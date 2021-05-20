---------------------------------------------------------------------------------------------------------------
-----                    Part 5: Prescibed medications for the study sample                               -----  
--------------------------------------------------------------------------------------------------------------- 
/* Tables for this eaxtraction: 
1.  PRESCRIBING, DEMOGRAPHIC, ENCOUNTER tables from PCORNET.
*/
---------------------------------------------------------------------------------------------------------------
use /*provide here the name of PCORI database here: */PCORI_SAS;
---------------------------------------------------------------------------------------------------------------
-----                            Declare study time frame variables:
DECLARE @studyTimeRestriction int;declare @UpperTimeFrame int; declare @LowerTimeFrame int;
-----                             Specify time frame and age limits                                       -----
--Set extraction time frame below. If time frames not set, the code will use the whole time frame available from the database
set @LowerTimeFrame='2010-01-01';
set @UpperTimeFrame='2020-12-31';
--set age restrictions:
declare @UpperAge int; declare @LowerAge int;set @UpperAge=89; set @LowerAge=18;
---------------------------------------------------------------------------------------------------------------
select c.PATID, '|' as Pipe1,
		a.ENCOUNTERID, '|' as Pipe2,
		b.PRESCRIBINGID, '|' as Pipe3,
		b.RXNORM_CUI, '|' as Pipe4,
		year(b.RX_ORDER_DATE) as PX_ORDER_DATE_YEAR, '|' as Pipe5,
		month(b.RX_ORDER_DATE) as PX_ORDER_DATE_MONTH, '|' as Pipe6,
		datediff(d,c.FirstVisit,b.RX_ORDER_DATE) as DAYS_from_FirstEncounter_Date1, '|' as Pipe7,
		year(b.RX_START_DATE) as RX_START_DATE_YEAR, '|' as Pipe8,
		month(b.RX_START_DATE) as PX_START_DATE_MONTH, '|' as Pipe9,
		datediff(d,c.FirstVisit,b.RX_START_DATE) as DAYS_from_FirstEncounter_Date2, '|' as Pipe10,
		b.RX_PROVIDERID, '|' as Pipe11,
		b.RX_DAYS_SUPPLY, '|' as Pipe12,
		b.RX_REFILLS , '|' as Pipe13,
		b.RX_BASIS, '|' as Pipe14,
		b.RAW_RX_MED_NAME,'ENDALONAEND' as lineEND
into #NextD_PRESCRIBING_FINAL
from /* provide name of table 1 here: */ #FinalTable1 c 
join dbo.[ENCOUNTER] a on c.PATID=a.PATID
join  dbo.[PRESCRIBING] b on a.ENCOUNTERID=b.ENCOUNTERID 
join  [dbo].[DEMOGRAPHIC] d on c.PATID=d.PATID
where datediff(yy,d.BIRTH_DATE,b.RX_ORDER_DATE) between @LowerAge and @UpperAge 
	and b.RX_ORDER_DATE between @LowerTimeFrame and @UpperTimeFrame;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/* Save #NextD_PRESCRIBING_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
---------------------------------------------------------------------------------------------------------------
