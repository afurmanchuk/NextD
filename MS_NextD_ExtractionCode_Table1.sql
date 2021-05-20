---------------------------------------------------------------------------------------------------------------
-----                                    Code producing Table 1:                                          -----  
-----           Study sample, flag for established patient, T2DM sample, Pregnancy events                 -----  
--------------------------------------------------------------------------------------------------------------- 
/* Tables for this eaxtraction: 
1. ENCOUNTER and DEMOGRAPHIC tables from PCORNET.
2. Tabel with mapping (named here #GlobalIDtable) between PCORNET IDs and Global patient IDs provided by MRAIA. */
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----                          Part 0: Defining Time farme for this study                               -----  
--------------------------------------------------------------------------------------------------------------- 
---------------------------------------------------------------------------------------------------------------
use /*provide here the name of PCORI database here: */PCORI_SAS;
--declare study time frame variables:
DECLARE @studyTimeRestriction int;declare @UpperTimeFrame int; declare @LowerTimeFrame int;
---------------------------------------------------------------------------------------------------------------
-----              In this section User must provide time frame limits    
---------------------------------------------------------------------------------------------------------------
--Set your time frame below. If time frames not set, the code will use the whole time frame available from the database;
set @LowerTimeFrame='2010-01-01';
set @UpperTimeFrame='2020-12-31';
--set age restrictions:
declare @UpperAge int; declare @LowerAge int;set @UpperAge=89; set @LowerAge=18;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----                          Part 1: Defining Denominator or Study Sample                               -----  
--------------------------------------------------------------------------------------------------------------- 
---------------------------------------------------------------------------------------------------------------
-----                            People with at least 1 encounter                                         -----
-----                                                                                                     -----            
-----                       Encounter should meet the following requerements:                             -----
-----    Patient must be 18 years old >= age <= 89 years old during the encounter day.                    -----
-----                                                                                                     -----
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-- Get all encounters for each patient sorted by date:
select a.PATID, '|' as Pipe1,
	a.ADMIT_DATE as FirstVisit, '|' as Pipe2,	
	year(a.ADMIT_DATE) as ADMIT_DATE_YEAR, '|' as Pipe3,
	month(a.ADMIT_DATE) as ADMIT_DATE_MONTH,'ENDALONAEND' as lineEND
into #FinalTable1
from(select e.PATID,e.ADMIT_DATE,row_number() over (partition by e.PATID order by e.ADMIT_DATE asc) rn 
	from dbo.ENCOUNTER e 
	join dbo.DEMOGRAPHIC d on e.PATID=d.PATID
	where d.BIRTH_DATE is not NULL 
		and e.ENC_TYPE in ('IP','ED','EI','TH','OS','AV','IS')
		and datediff(yy,d.BIRTH_DATE,e.ADMIT_DATE) between @LowerAge and @UpperAge 
		and e.ADMIT_DATE between @LowerTimeFrame and  @UpperTimeFrame
	) a
where a.rn=1;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----  For CAPRICORN sites: remap PATIDs into GLOBALIDs created specifically for this project by MRAIA    -----
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
