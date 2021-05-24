---------------------------------------------------------------------------------------------------------------
-----                                    Code producing Table 1:                                          -----  
-----           Study sample, flag for established patient, T2DM sample, Pregnancy events                 -----  
--------------------------------------------------------------------------------------------------------------- 
/* Tables for this eaxtraction: 
1. ENCOUNTER and DEMOGRAPHIC tables from PCORNET.
2. Tabel with mapping (named here #GlobalIDtable) between PCORNET IDs and Global patient IDs provided by MRAIA. */
---------------------------------------------------------------------------------------------------------------
/*
 global parameters:
 &&PCORNET_CDM: name of CDM schema (>=v6.0)
 "KUMC specific" fields: may need to be adjusted with local EMR values  */
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----                          Part 0: Defining Time farme for this study                               -----  
--------------------------------------------------------------------------------------------------------------- 
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----              In this section User must provide time frame limits    
---------------------------------------------------------------------------------------------------------------
--Set your time frame below between '2010-01-01' and '2020-12-31'. If time frames not set, the code will use the whole time frame available from the database;
define LowerTimeFrame= TO_DATE('2010-01-01' , 'YYYY-MM-DD') 
define UpperTimeFrame= TO_DATE('2020-12-31', 'YYYY-MM-DD')
--set age restrictions:
define UpperAge=89 
define LowerAge=18
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

whenever sqlerror continue;
drop table FinalTable1; 
whenever sqlerror exit;

create table FinalTable1 as 
select 
    a.PATID, '|' as Pipe1,
	a.ADMIT_DATE as FirstVisit, '|' as Pipe2,
    EXTRACT(year FROM a.ADMIT_DATE) as ADMIT_DATE_YEAR, '|' as Pipe3,
    EXTRACT(month FROM a.ADMIT_DATE) as ADMIT_DATE_MONTH
    from
    (
    select e.PATID,
    e.ADMIT_DATE,	
    row_number() over (partition by e.PATID order by e.ADMIT_DATE asc) rn 
	from "&&PCORNET_CDM".ENCOUNTER e  -- provide here the name of PCORI databas
	join "&&PCORNET_CDM".DEMOGRAPHIC d on e.PATID=d.PATID  -- provide here the name of PCORI databas
	where d.BIRTH_DATE is not NULL 
		and e.ENC_TYPE in ('IP','ED','EI','TH','OS','AV','IS')
		and cast((e.ADMIT_DATE - d.BIRTH_DATE) as numeric(18,6))/365.25 between &LowerAge and &UpperAge 
		and e.ADMIT_DATE between &LowerTimeFrame and &UpperTimeFrame
	) a
where a.rn=1;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----  For CAPRICORN sites: remap PATIDs into GLOBALIDs created specifically for this project by MRAIA    -----
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
