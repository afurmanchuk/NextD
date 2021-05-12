---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-----                      Part 12: Socio-economic status for the study sample                            -----  
--------------------------------------------------------------------------------------------------------------- 
---------------------------------------------------------------------------------------------------------------
/* Tables for this eaxtraction: 
1. Table 1 (named here #FinalTable1) with Next-D study sample IDs. See separate SQL code for producing this table.
2. Side table (named here #SES) 
							for GPC sites should use census track labels.
							for CAPRICORN sites will be asked to mapp their patient's census tract IDs into given list of SES variables  */
---------------------------------------------------------------------------------------------------------------
/*Note: 'KUMC-specific' issue are marked as such*/
--------------------------------------------------------------------------------------------------------------
/*use code below if you are member of GPC consortium:*/

whenever sqlerror continue;
drop table NextD_SES; 
whenever sqlerror exit;

create table NextD_SES as 
select 
    c.PATID, '|' as Pipe1,
    --amap.RAW_ADDRESS, '|' as Pipe2,
    amap.FIPS11 as GTRACT_ACS, '|' as Pipe3,
    amap.LOCATOR,  '|' as Pipe4,
    amap.SCORE,  '|' as Pipe5,
    1 as DeGAUSS,'ENDALONAEND' as lineEND
from  FinalTable1 c
left join /*provide patient_dimension table here - KUMC-specific*/ (select patient_num, to_char(mrn) as mrn_char from nightherondata.patient_dimension) pd on c.PATID = pd.patient_num
left join /* provide name of non-PCORNET table with SES data here: */ (select addm.*, to_char(mrn) as mrn_char from xsong.address_mapped addm) amap on amap.mrn_char = pd.mrn_char;

---------------------------------------------------------------------------------------------------------------
/* Save #NextD_SES as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
---------------------------------------------------------------------------------------------------------------
