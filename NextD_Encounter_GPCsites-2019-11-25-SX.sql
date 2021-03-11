---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----                             Part 3: Encounters for the study sample                                 -----  
--------------------------------------------------------------------------------------------------------------- 
/* Tables for this eaxtraction: 
1. Table 1 (named here #FinalStatTable1) with Next-D study sample IDs. See separate SQL code for producing this table.
2. External to PCORNET table ([NextD].[dbo].[NEXT_OriginalNPIFROMBaseTaxonomy]) with NPI values on encounters of interest. 
Warning: current remapping utilizing toxonomy codes. Sites expected to map NPIs into taxonomy codes by using:
The full NPI online registry refreshed weekly could be found at https://npiregistry.cms.hhs.gov/
or complete download of this registry could be found at https://www.cms.gov/Regulations-and-Guidance/Administrative-Simplification/NationalProvIdentStand/DataDissemination.html
or use file https://www.dropbox.com/home/diabetes%20project%20(working%20docs)/Definitions_StudySamples%26Variables?preview=NPI2ToxonomycodeCorssWalk_2018-01-01_AF.zip (contains two columns: NPI and Taxonomy code)
due to extreme size of registry I suggest to (i) collect complete list of NPI codes for the site; (ii) map those into Taxonomy codes and save them localy ; (iii) use this subset for all extraction codes utilizing NPI information.
The table [NextD].[dbo].[NEXT_OriginalNPIFROMBaseTaxonomy] has two columns: [NPI] and [Healthcare Provider Taxonomy Code_1] 
*/
--------------------------------------------------------------------------------------------------------------- 
use /*provide here the name of PCORI database here: */PCORI_SAS;
--------------------------------------------------------------------------------------------------------------- 
----  Declare study time frame variables:
DECLARE @studyTimeRestriction int;declare @UpperTimeFrame int; declare @LowerTimeFrame int;
-----                             Specify time frame and age limits                                       -----
--Set extraction time frame below. If time frames not set, the code will use the whole time frame available from the database
set @LowerTimeFrame=18263;--'2010-01-01';
set @UpperTimeFrame=22280;--'2020-12-31';
--set age restrictions:
declare @UpperAge int; declare @LowerAge int;set @UpperAge=89; set @LowerAge=18;
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
select c.PATID,
		a.ENCOUNTERID,
		a.PROVIDERID,
		year(dateadd(dd,a.ADMIT_DATE,'1960-01-01')) as ADMIT_DATE_YEAR,
		month(dateadd(dd,a.ADMIT_DATE,'1960-01-01')) as ADMIT_DATE_MONTH,
		a.ADMIT_DATE - c.[FirstVisit] as DAYS_from_FirstEncounter_Date1,
		year(dateadd(dd,a.DISCHARGE_DATE,'1960-01-01')) as DISCHARGE_DATE_YEAR,
		month(dateadd(dd,a.DISCHARGE_DATE,'1960-01-01')) as DISCHARGE_DATE_MONTH,
		a.ADMIT_DATE - c.[FirstVisit] as DAYS_from_FirstEncounter_Date2,
		a.ENC_TYPE,
		a.FACILITYID,
		a.FACILITY_TYPE,
		a.DISCHARGE_DISPOSITION,
		a.DISCHARGE_STATUS,
		a.ADMITTING_SOURCE,
		a.PROVIDERID,
		a.[PAYER_TYPE_PRIMARY],
		a.[PAYER_TYPE_ SECONDARY]
into #NextD_ENCOUNTER_FINAL
from /* provide name of table 1 here: */ #FinalTable1 c 
join [dbo].[ENCOUNTER] a on c.PATID=a.PATID
join dbo.DEMOGRAPHIC d on c.PATID=d.PATID		
where convert(numeric(18,6),(a.ADMIT_DATE-d.BIRTH_DATE))/365.25 between @LowerAge and @UpperAge 
and a.ADMIT_DATE between @LowerTimeFrame and @UpperTimeFrame; 
--------------------------------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------------------------------- 
 /* Save #NextD_ENCOUNTER_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
--------------------------------------------------------------------------------------------------------------- 
