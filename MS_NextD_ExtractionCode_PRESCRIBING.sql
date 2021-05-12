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
set @LowerTimeFrame=18263;--'2010-01-01';
set @UpperTimeFrame=22280;--'2020-12-31';
--set age restrictions:
declare @UpperAge int; declare @LowerAge int;set @UpperAge=89; set @LowerAge=18;
---------------------------------------------------------------------------------------------------------------
select c.PATID,
		a.ENCOUNTERID,
		b.PRESCRIBINGID,
		b.RXNORM_CUI,
		year(dateadd(dd,b.RX_ORDER_DATE,'1960-01-01')) as PX_ORDER_DATE_YEAR,
		month(dateadd(dd,b.RX_ORDER_DATE,'1960-01-01')) as PX_ORDER_DATE_MONTH,
		b.RX_ORDER_DATE - c.FirstVisit as DAYS_from_FirstEncounter_Date1,
		year(dateadd(dd,b.RX_START_DATE,'1960-01-01')) as RX_START_DATE_YEAR,
		month(dateadd(dd,b.RX_START_DATE,'1960-01-01')) as PX_START_DATE_MONTH,
		b.RX_START_DATE - c.FirstVisit as DAYS_from_FirstEncounter_Date2,
		b.RX_PROVIDERID,
		b.RX_DAYS_SUPPLY,
		b.RX_REFILLS ,
		b.RX_BASIS,
		b.RAW_RX_MED_NAME
into #NextD_PRESCRIBING_FINAL
from /* provide name of table 1 here: */ #FinalTable1 c 
join dbo.[ENCOUNTER] a on c.PATID=a.PATID
join  dbo.[PRESCRIBING] b on a.ENCOUNTERID=b.ENCOUNTERID 
join  [dbo].[DEMOGRAPHIC] d on c.PATID=d.PATID
where convert(numeric(18,6),(b.RX_ORDER_DATE-d.BIRTH_DATE))/365.25 between @LowerAge and @UpperAge 
	and b.RX_ORDER_DATE between @LowerTimeFrame and @UpperTimeFrame;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/* Save #NextD_PRESCRIBING_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
---------------------------------------------------------------------------------------------------------------
