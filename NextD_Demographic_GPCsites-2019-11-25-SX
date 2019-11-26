/******************************************************************************************************************/
/* NextD Clinical Variable Extractions - Demographic Table                                                       */
/******************************************************************************************************************/

/* Tables required in this code: 
- 1. FinalStatsTable1_local: the local version of FinalStatsTable1 (output of SQLTable1_GPCsites_orcale-2019-11-25-SX.sql)                             
- 2. &&PCORNET_CDM.DEMOGRAPHIC                       
- 3. &&I2B2_ID.patient_dimension               
*/

/*global parameters:
 &&PCORNET_CDM: name of CDM schema (>v5.0)
 &&I2B2_ID: name of local identified i2b2 schema
 "KUMC specific" fields: may need to be adjusted with local EMR values
*/

/*MARITAL_STATUS categories (KUMC-specific):
 --S - Single
 --D - Divorced
 --P - Partner
 --W - Widowed
 --X - Separated
 --M - Married
 --NI - Unknown
*/

create table NEXTD_DEMOGRAPHIC as
select pat.PATID,'|' as Pipe1
      ,cast(to_char(demo.BIRTH_DATE,'YYYY') as INTEGER) BIRTH_YEAR,'|' as Pipe2
      ,cast(to_char(demo.BIRTH_DATE,'MM') as INTEGER) BIRTH_MONTH,'|' as Pipe3
      ,demo.BIRTH_DATE-pat.FirstVisit as BIRTH_DELTA_DAYS,'|' as Pipe4
      ,demo.SEX,'|' as Pipe5
      ,demo.RACE,'|' as Pipe6
      ,demo.HISPANIC,'|' as Pipe7
      ,demo.PAT_PREF_LANGUAGE_SPOKEN,'|' as Pipe8
      ,case when i2b2.MARITAL_STATUS_CD in ('u','@') or i2b2.MARITAL_STATUS_CD is null then 'NI'
            else upper(i2b2.MARITAL_STATUS_CD) end as MARITAL_STATUS   -- KUMC specific
      ,'ENDALONAEND' as ENDOFLINE
from FinalStatsTable1_local pat
left join "&&PCORNET_CDM".DEMOGRAPHIC demo
on pat.PATID = demo.PATID
left join "&&I2B2_ID".patient_dimension i2b2
on i2b2.patient_num = pat.PATID
; 

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----- 1. Download table NEXTD_DEMOGRAPHIC as .csv  file for final delivery                               ------
---------------------------------------------------------------------------------------------------------------
