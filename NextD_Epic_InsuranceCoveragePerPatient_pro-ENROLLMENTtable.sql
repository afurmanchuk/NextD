alter session set NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS'; 
alter session set NLS_TIMESTAMP_FORMAT = 'DD-MM-YYYY HH24:MI:SS'; 

--Step 1: collect all requiered elements for Enrollment table:
create table PAYER_EPIC as
with payor_map_cur as (
select distinct
       epp.BENEFIT_PLAN_NAME
      ,epm.PAYOR_NAME
      ,fc.financial_class_name FINANCIAL_CLASS
      ,case when pm.CODE=81 then 81
            when pm.CODE=9 then 9
            when pm.CODE=99 then 99
            when pm.CODE=9999 then 9999
            else substr(pm.CODE,1,1)
       end as ENR_VALUE
from clarity.COVERAGE cvg
join clarity.COVERAGE_MEM_LIST list on list.COVERAGE_ID = cvg.COVERAGE_ID
left join clarity.CLARITY_EPP epp on epp.BENEFIT_PLAN_ID = cvg.PLAN_ID
left join clarity.CLARITY_EPM epm on epm.PAYOR_ID = cvg.PAYOR_ID
left join clarity.CLARITY_FC fc on epm.FINANCIAL_CLASS=fc.FINANCIAL_CLASS
left join payor_map pm on pm.PAYER_NAME=epm.PAYOR_NAME and pm.FINANCIAL_CLASS = fc.financial_class_name
)
select list.PAT_ID
      ,list.MEM_EFF_FROM_DATE
      ,list.MEM_EFF_TO_DATE
      ,'I' as ENR_BASIS
      ,pm.ENR_VALUE
from clarity.COVERAGE cvg
join clarity.COVERAGE_MEM_LIST list on list.COVERAGE_ID = cvg.COVERAGE_ID
left join clarity.CLARITY_EPP epp on epp.BENEFIT_PLAN_ID = cvg.PLAN_ID
left join clarity.clarity_epm epm on epm.PAYOR_ID = cvg.PAYOR_ID
left join clarity.clarity_fc fc on epm.FINANCIAL_CLASS =fc.FINANCIAL_CLASS
left join payor_map_cur pm on pm.BENEFIT_PLAN_NAME = epp.BENEFIT_PLAN_NAME and 
                              pm.PAYOR_NAME = epm.PAYOR_NAME and
                              pm.FINANCIAL_CLASS = fc.financial_class_name
order by ist.PAT_ID
; 

--Step2: de-identification should be properly applied before sending out the data:
--split  MEM_EFF_FROM_DATE and MEM_EFF_TO_DATE into year, month and delta_days_from_firts_encounter for  

/* Please, make sure you return table with insurance mapped into following categories:
1.Medicare
2.Medicaid
3.Other Government 
4.Department of corrections
5.Private health insurance
6.Blue cross/Blue shield
7.Managed care, unspecified
8.No payment
9.Miscellaneous/Other?
9999.Unavailable/No? payer specified/blank
NI.No information
UN.Unknown
OT.Other
*/

