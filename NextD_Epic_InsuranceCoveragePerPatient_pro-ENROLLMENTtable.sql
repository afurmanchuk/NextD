/******************************************************************************************************************/
/* NextD Clinical Variable Extractions - Enrollment (Epic) Table                                                  */
/******************************************************************************************************************/

/* Tables required in this code: 
- 1. FinalStatsTable_local
- 2. &&I2B2_ID.patient_mapping
- 3. &&clarity.COVERAGE                              
- 4. &&clarity.COVERAGE_MEM_LIST    
- 5. &&clarity.CLARITY_EPP
- 6. &&clarity.CLARITY_EPM
- 7. &&clarity.CLARITY_FC
- 8. payor_map: mapping table between payor name and financial class to PCORnet CDM payor categories (usually manually curated)
*/

/*global parameters:
 &&PCORNET_CDM: name of CDM schema (>v5.0)
 &&I2B2_ID: name of local identified i2b2 schema
 &&clarity: name of clarity schema (or equivalent local EMR schema) 
 &&PATIENT_IDE_SOURCE: source name for real patid that can be mapped to epic tables
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

UNDEFINE PATIENT_IDE_SOURCE;

create table NEXTD_Enr_EPIC as
with payor_map_cur as (
select distinct
       epp.BENEFIT_PLAN_NAME
      ,epm.PAYOR_NAME
      ,fc.financial_class_name FINANCIAL_CLASS
      ,case when pm.CODE='81' then '81'
            when pm.CODE='9' then '9'
            when pm.CODE='9999' then '9999'
            when pm.CODE is null then 'NI'
            when pm.CODE in ('OT','NI','UN') then pm.CODE
            else substr(pm.CODE,1,1)
       end as ENR_VALUE
from clarity.COVERAGE cvg
join clarity.COVERAGE_MEM_LIST list on list.COVERAGE_ID = cvg.COVERAGE_ID
left join clarity.CLARITY_EPP epp on epp.BENEFIT_PLAN_ID = cvg.PLAN_ID
left join clarity.CLARITY_EPM epm on epm.PAYOR_ID = cvg.PAYOR_ID
left join clarity.CLARITY_FC fc on epm.FINANCIAL_CLASS=fc.FINANCIAL_CLASS
left join payor_map pm on pm.PAYER_NAME=epm.PAYOR_NAME -- KUMC specific
     and pm.FINANCIAL_CLASS = fc.financial_class_name
--where pm.CODE is null  /*for identifying new unmapped payor name*/
)
select pat.PATID,'|' as Pipe1
      ,cast(to_char(cast(list.MEM_EFF_FROM_DATE as date),'YYYY') as INTEGER) ENR_START_YEAR,'|' as Pipe2
      ,cast(to_char(cast(list.MEM_EFF_FROM_DATE as date),'MM') as INTEGER) ENR_START_MONTH,'|' as Pipe3
      ,round(cast(list.MEM_EFF_FROM_DATE as date)-pat.FirstVisit) as ENR_START_Days_from_FirstEnc,'|' as Pipe4
       ,cast(to_char(cast(list.MEM_EFF_TO_DATE as date),'YYYY') as INTEGER) ENR_END_YEAR,'|' as Pipe5
      ,cast(to_char(cast(list.MEM_EFF_TO_DATE as date),'MM') as INTEGER) ENR_END_MONTH,'|' as Pipe6
      ,round(cast(list.MEM_EFF_TO_DATE as date)-pat.FirstVisit) as ENR_END_Days_from_FirstEnc,'|' as Pipe7
      ,'I' as ENR_BASIS,'|' as Pipe8
      ,payor.ENR_VALUE,'|' as Pipe9
      ,epm.PAYOR_NAME RAW_PAYER_TYPE_PRIMARY
      ,fc.FINANCIAL_CLASS
      ,'ENDALONAEND' as ENDOFLINE
from FinalStatsTable1_local pat
join nightherondata.patient_mapping pm on pat.PATID = pm.PATIENT_NUM   -- KUMC specific
     and pm.PATIENT_IDE_SOURCE = '&&PATIENT_IDE_SOURCE'   -- KUMC specific
join clarity.COVERAGE_MEM_LIST list on pm.PATIENT_IDE = list.PAT_ID
     and list.MEM_EFF_FROM_DATE is not null /*null exists*/
     and list.MEM_COVERED_YN = 'Y' /*validated*/
join clarity.COVERAGE cvg on list.COVERAGE_ID = cvg.COVERAGE_ID  
left join clarity.CLARITY_EPP epp on epp.BENEFIT_PLAN_ID = cvg.PLAN_ID
left join clarity.clarity_epm epm on epm.PAYOR_ID = cvg.PAYOR_ID
left join clarity.clarity_fc fc on epm.FINANCIAL_CLASS =fc.FINANCIAL_CLASS
left join payor_map_cur payor on payor.PAYOR_NAME = epm.PAYOR_NAME 
     and payor.FINANCIAL_CLASS = fc.financial_class_name
order by PATID, MEM_EFF_FROM_DATE
; 

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----- 1. Download table NEXTD_ENR_EPIC as .csv  file for final delivery                                     ------
---------------------------------------------------------------------------------------------------------------

