---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----                             Part 8: Labs for the study sample                                       -----  
--------------------------------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------------------------------- 
/* Tables for this eaxtraction: 
1. Table 1 (named here #FinalTable1) with Next-D study sample IDs. See separate SQL code for producing this table.
2. LAB_RESULT_CM and DEMOGRAPHIC table from PCORNET.
3. External to PCORNET table CAP_LABS with the labs of interest.*/
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----  Declare study time frame variables:
-----                             Specify age limits                                       -----
--set age restrictions:
define UpperAge=89 
define LowerAge=18
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
whenever sqlerror continue;
drop table NextD_LABS_FINAL; 
whenever sqlerror exit;

create table NextD_LABS_FINAL as 
    select c.PATID, '|' as Pipe1,
		b.LAB_RESULT_CM_ID, '|' as Pipe2,
		b.ENCOUNTERID, '|' as Pipe3,
		EXTRACT(year FROM b.LAB_ORDER_DATE) as LAB_ORDER_DATE_YEAR, '|' as Pipe4,
		EXTRACT(month FROM b.LAB_ORDER_DATE) as LAB_ORDER_DATE_MONTH, '|' as Pipe5,
		b.LAB_ORDER_DATE - c.FirstVisit as DAYS_from_FirstEncounter_Date1, '|' as Pipe6,
		EXTRACT(year FROM b.SPECIMEN_DATE) as SPECIMEN_DATE_YEAR, '|' as Pipe7,
		EXTRACT(month FROM b.SPECIMEN_DATE) as SPECIMEN_DATE_MONTH, '|' as Pipe8,
		b.SPECIMEN_DATE - c.FirstVisit as DAYS_from_FirstEncounter_Date2, '|' as Pipe9,
        b.RESULT_NUM as RESULT_NUM, '|' as Pipe10,
		b.RESULT_UNIT, '|' as Pipe11,
		b.RESULT_QUAL, '|' as Pipe12,
		b.LAB_LOINC, '|' as Pipe13,
		b.LAB_PX, '|' as Pipe14,
		b.LAB_PX_TYPE, '|' as Pipe15,
		b.RESULT_LOC, '|' as Pipe16,
		b.RESULT_MODIFIER, '|' as Pipe17,
		b.NORM_RANGE_LOW, '|' as Pipe18,
		b.NORM_MODIFIER_LOW, '|' as Pipe19,
		b.NORM_RANGE_HIGH, '|' as Pipe20,
		b.NORM_MODIFIER_HIGH, '|' as Pipe21,
		b.RAW_LAB_NAME,'ENDALONAEND' as lineEND
from FinalTable1 c 
join "&&PCORNET_CDM".LAB_RESULT_CM b on c.PATID=b.PATID   -- provide here the name of PCORI databas
join "&&PCORNET_CDM".DEMOGRAPHIC d on c.PATID=d.PATID   -- provide here the name of PCORI databas
where 
b.RESULT_NUM is not NULL and
		 (b.LAB_LOINC in ('14647-2','2093-3',
							'14646-4','18263-4','2085-9',
							'12951-0','14927-8','2571-8','47210-0',
							'12773-8','13457-7','18261-8','18262-6','2089-1','22748-8','39469-2','49132-4','55440-2',
							'17855-8','4548-4','4549-2','17856-6','41995-2','59261-8','62388-4','71875-9','54039-3',
                            '21232-4','38483-4','2160-0','44784-7','40248-7',
                            '718-7','20509-6','30313-1','30350-3','30313-1','14775-1','30352-9','75928-2','20509-6','55782-7','59260-0',
                            '2345-7','2339-0','10450-5','17865-7','1554-5','6777-7','54246-4','2344-0','41652-9',
                            '1558-6','10450-5', '1554-5', '17865-7', '35184-1',
                            '14957-5','57369-1','53530-2','30003-8','43605-5','53531-0','11218-5','43607-1','63474-1','53532-8','14956-7','43606-3','56553-1','49023-5','58448-2','44292-1','14958-3',
                            '14959-1','59159-4','30000-4','30001-2','47558-2','13705-9','14585-4','1753-3','1754-1','1755-8','1757-4','20621-9','21059-1','9318-7','50949-7','32294-1',
                            '13032-8','13033-6','13034-4','13035-1','13036-9','13037-7','13038-5',
                            '13039-3','13040-1','13041-9','13042-7','13043-5','13044-3','13045-0','13859-4','13860-2','13861-0','14633-2','16501-9','16502-7','1986-9','25568-7','25569-5','25570-3','25571-1',
                            '25572-9','25573-7','25574-5','25575-2','25576-0','25577-8','25578-6','25579-4','25580-2','25581-0','25582-8','27408-4','27421-7','27839-0','35195-7','38249-9','38421-4','38422-2',
                            '38423-0','38424-8','38425-5','38426-3','42180-0','47583-0','47584-8','47585-5','47586-3','47587-1','47588-9','47589-7','47590-5','47591-3','47592-1','47593-9','47594-7','47595-4',
                            '47832-1','47833-9','47834-7','50461-3','50462-1','50463-9','50464-7','50465-4','50466-2','50467-0','50468-8','55918-7','55919-5','56516-8','56582-0','56583-8','56584-6','57376-6',
							'57645-4','57646-2','57647-0','57648-8','57649-6','57650-4','57651-2','57894-8','58494-6','58495-3','58496-1','58497-9','58498-7','58499-5','58500-0','58501-8','58502-6','58503-4',
                            '58504-2','58505-9','58506-7','58507-5','58508-3','58509-1','58510-9','58511-7','58512-5','58513-3','58514-1','58515-8','58516-6','58517-4','58518-2','58519-0','58520-8','58521-6',
							'58522-4','58686-7','58816-0','58841-8','58896-2','77610-4','77611-2','77612-0','77651-8','77652-6',
							'53061-8',
							'49779-2','33043-1','33903-6','2514-8','50557-8','5797-6','2514-8','33903-6',
							'45225-0','45171-6','5265-4','63571-4','56687-7','8086-1','31547-3','34652-8','13927-9','33563-8','31209-0','56718-0','81155-4','32636-3','70253-0','70252-2',
							'42501-7','13926-1','56540-8','58451-6','81725-4','72523-4','30347-9','83004-2','82660-2',
							'31209-0','56718-0','81155-4','32636-3','70253-0','70252-2',
							'76651-9') 
		or b.RAW_LAB_NAME in ('A1C','LDL','CREATININE','HGB')
		)
		and cast((b.LAB_ORDER_DATE - d.BIRTH_DATE) as numeric(18,6))/365.25 between &LowerAge and &UpperAge 
		and b.LAB_ORDER_DATE between TO_DATE('2010-01-01', 'YYYY-MM-DD') and TO_DATE('2020-12-31', 'YYYY-MM-DD') ; --Set extraction time frame 
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/* Save #NextD_LABS_FINAL as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
---------------------------------------------------------------------------------------------------------------
