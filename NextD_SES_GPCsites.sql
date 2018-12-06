/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - require: 1. FinalStatsTable1 local version where dates are not masked                                        */
/*            2. date_unshifts generated from FinalStatsTable1 extraction                                         */
/*                                                                                                                */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C4R1   */
/******************************************************************************************************************/

/*Note: 'KUMC-specific' issue are marked as such*/

/*TODO: match new addresses with external resources, when MPC geocoding file is out-of-date*/

/****************************************************************************************/
/************************Table 11 - Socio-Economics Status (SES)*************************/
/****************************************************************************************/

create table CLARITY_ID as
with i2b2_pat_num as (
select ds.PATID
      ,ds.PATIENT_IDE
      ,pmap.PATIENT_NUM 
from date_unshifts ds
left join /*provide patient_mapping table here - KUMC-specific*/ nightherondata.patient_mapping pmap
on ds.PATIENT_IDE = pmap.PATIENT_IDE
where pmap.patient_ide_source = 'SMS@kumed.com' /*EHR source - KUMC-specific*/
)
select i2b2.PATID
      ,pm.PATIENT_IDE PATIENT_EPIC
from i2b2_pat_num i2b2
left join /*provide patient_mapping table here - KUMC-specific*/ nightherondata.patient_mapping pmap
on i2b2.PATIENT_IDE = pmap.PATIENT_IDE
where pmap.patient_ide_source = 'Epic@kumed.com' /*EHR source - KUMC-specific*/


create table NEXTD2_SES as
-- get current patient address in in clarity, state is coded
with clarity_addr_state_c as (
select cid.*
      ,cpat.ADD_LINE_1
      ,cpat.ADD_LINE_2
      ,cpat.CITY
      ,cpat.STATE_C
      ,cpat.ZIP
from clarity_id cid
left join /*provide clarity patient table here*/ clarity.patient cpat
on cid.PATIENT_EPIC = cpat.PAT_ID
)
-- decode state
     ,clarity_addr as (
select sc.*, 
       zs.name STATE 
from clarity_addr_state_c sc
left join /*provide clarity zc_state table here*/ clarity.zc_state zs
    on sc.state_c = zs.state_c
)
-- in MPC geocoding file, heading zeros in a zip could be missing
   ,geocode_zip_patch as (
select distinct ADDRESS
      ,CITY
      ,STATE
      ,case when length(zip) < 5 then LPAD(zip,5,'0')
            else zip
       end as ZIP
      ,FIPSST
      ,FIPSCO
      ,TRACT_ID 
from mpc.geocoded_kumc /*MPC geocoding - KUMC-specific*/
)

select cadd.PATID
      ,(gk.fipsst || gk.fipsco || gk.tract_id) as GTRACT_ACS
from clarity_addr cadd
left join geocode_zip_patch gk
on (UPPER(cadd.add_line_1) || ' ' || UPPER(cadd.add_line_2)) = UPPER(gk.address) and
    UPPER(cadd.city) = UPPER(gk.city) and
    UPPER(cadd.state) = UPPER(gk.state)
;

------------------------------------------------
/* Save #NextD_SES as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
-------------------------------------------------
