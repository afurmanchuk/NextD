/******************************************************************************************************************/
/* NextD Clinical Variable Extractions - Enrollment (Epic) Table                                                  */
/******************************************************************************************************************/

/* Tables required in this code:
- 1. NEXTD_ENCOUNTER
- 2. &&I2B2_ID.encounter_mapping
- 3. &&kupi.idx_table -- KUMC specific                              
- 4. payor_map: mapping table between payor name and financial class to PCORnet CDM payor categories (usually manually curated)

*/

/*global parameters:
 &&I2B2_ID: name of local identified i2b2 schema 
 &&kupi: name of schema where raw IDX tables are saved
 &&ENCOUNTER_IDE_SOURCE: source name for real encounterid that can be mapped to idx table
 "KUMC specific" fields: may need to be adjusted with local EMR values
*/

/* ENR_VALUE takes the following values:
- 1.Medicare
- 2.Medicaid
- 3.Other Governm  ent 
- 4.Department of corrections
- 5.Private health insurance
- 6.Blue cross/Blue shield
- 7.Managed care, unspecified
- 8.No payment
- 81.Self Pay
- 9.Miscellaneous/Other
- 9999.Unavailable/No payer specified/blank
- NI.No information
- UN.Unknown
- OT.Other
*/

UNDEFINE ENCOUNTER_IDE_SOURCE;

create table NEXTD_Enr_IDX as
with payor_map_cur as (
select distinct
       idx.FSCNUMBER
      ,idx.FSCNAME
      ,case when pm.CODE='81' then '81'
            when pm.CODE='9' then '9'
            when pm.CODE='9999' then '9999'
            when pm.CODE is null then 'NI'
            when pm.CODE in ('OT','NI','UN') then pm.CODE
            else substr(pm.CODE,1,1)
       end as ENR_VALUE
from "&&kupi".idx_table idx
left join payor_map pm on pm.PAYER_NAME=idx.FSCNAME -- KUMC specific
--where pm.CODE is null  /*for identifying new unmapped payor name, if any, modify payor_map*/
)
select distinct
       enc.PATID,'|' as Pipe1
      ,enc.ENCOUNTERID,'|' as Pipe2
      ,enc.ADMIT_YEAR,'|' as Pipe3
      ,enc.ADMIT_MONTH,'|' as Pipe4
      ,enc.ADMIT_Days_from_FirstEnc,'|' as Pipe5
      ,payor.ENR_VALUE, '|' as Pipe6
      ,idx.FSCNAME RAW_PAYER_TYPE_PRIMARY  -- KUMC specific
      ,'ENDALONAEND' as ENDOFLINE
from NEXTD_ENCOUNTER enc
join "&&I2B2_ID".encounter_mapping em on enc.ENCOUNTERID = em.ENCOUNTER_NUM
     and em.ENCOUNTER_IDE_SOURCE = '&&ENCOUNTER_IDE_SOURCE'
join kupi.idx_table idx on em.encounter_ide = idx.BILL_INV_NUMBER --IDX info is at encounter level (ref: https://github.com/kumc-bmi/heron/blob/5072746bf1070ce73042b3138f0accd0e5ce87d7/heron_load/idx_i2b2_transform.sql#L92)
left join payor_map_cur payor on payor.FSCNUMBER = idx.FSCNUMBER
;

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----- 1. Download table NEXTD_ENR_IDX as .csv  file for final delivery                                     ------
---------------------------------------------------------------------------------------------------------------

