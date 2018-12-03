/*********************************************************************************************************************/
/* NextD Clinical Variable Extractions Preparation: date_unshifts                                                    */
/* - require: 1. FinalStatsTable1: the local version of Table1 where dates are not masked                            */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C4R1      */
/*********************************************************************************************************************/

/*Note: 'KUMC specific' issue are marked as such*/

/***************************************************************************/
/***********************Table 0 -- date_unshifts****************************/
/*output columns: PATID: CDM patient ID
                  PATIENT_IDE: patient IDE
                  CDM_BIRTH_DATE: shifted birth date in CDM
                  REAL_BIRTH_DATE: real birth date in local HERON
                  days_shift: days shifted                                 */
/***************************************************************************/

/**********************************************************************************/
/*when CDM and I2B2 are of the same release (matchable by PATIENT_NUM = PATID)    */
/**********************************************************************************/
create table date_unshifts as
--get PCORNET_CDM patient ID and shifted birth_date
with PATID_CDM as (
select distinct pat.PATID, 
                pat.BIRTH_DATE CDM_BIRTH_DATE
from /*provide current PCORNET_CDM.Demogrphic table here*/ "&&PCORNET_CDM".DEMOGRAPHIC pat
where exists (select 1 from FinalStatsTable1 fst
              where fst.PATID = pat.PATID)
)
--get patient_ide
    ,patient_ide as (
select  cdm.PATID
       ,pm.PATIENT_NUM
       ,pm.PATIENT_IDE /*keep MRN for future reference*/
       ,cdm.CDM_BIRTH_DATE
from PATID_CDM cdm
join /*provide current patient_mapping table here*/ nightherondata.patient_mapping pm
on cdm.PATID = pm.PATIENT_NUM
where pm.PATIENT_IDE_SOURCE = 'SMS@kumed.com' /*EHR source--KUMC specific*/
)
--calculate date shifts
select  ide.PATID
       ,ide.PATIENT_IDE
       ,ide.CDM_BIRTH_DATE 
       ,pd.BIRTH_DATE REAL_BIRTH_DATE 
       ,round((pd.HIPPA_BIRTH_DATE-ide3.CDM_BIRTH_DATE),0) days_shift
from patient_ide ide
left join /*provide current patient_mapping table here*/ nightherondata.patient_dimension pd
on ide.PATIENT_NUM = pd.PATIENT_NUM /*PATIENT_NUM is de-id*/
;


/*****************************************************************************************/
/*when CDM and I2B2 are of different releases (NOT matchable by PATIENT_NUM = PATID)     */
/*****************************************************************************************/
/*I2B2_VERSION will give the I2B2 version corresponding to current PCORNET_CDM*/
create table I2B2_VERSION as
--get CDM version
/*require: PCORNET_CDM harvest table*/
with cdm_version as(
select * from /*provide PCORNET_CDM harvest table here -- KUMC specific*/"&&PCORNET_CDM".harvest
)
--get the most likely HERON release corresponding to PCORNET_CDM
/*require: HERON backup_info table*/
select  BACKUP_DATE 
       ,BACKUP_ID
       ,BACKUP_DESCRIPTION
       ,BACKUP_DB
       ,RELEASE_DATE
from (select rb.*, row_number() over (order by rb.backup_date desc) rn   
      from /*provide HERON backup_info table here -- KUMC specific */ nheron_backup.backup_info rb 
      where exists (select 1 from cdm_version cdm
                    where cdm.REFRESH_DEMOGRAPHIC_DATE >= rb.backup_date))
where rn = 1
;

create table date_unshifts as
--get all PCORNET_CDM patient ID and shifted birth_date
with PATID_CDM as (
select distinct PATID 
               ,pat.BIRTH_DATE CDM_BIRTH_DATE
from  /*provide current PCORNET_CDM.Demogrphic table here*/ "&&PCORNET_CDM".DEMOGRAPHIC pat
where exists (select 1 from FinalStatsTable1 fst
              where fst.PATID = pat.PATID)
)
--get patient_num crosswalk between PCORNET_CDM version and current I2B2 version
/*require: HERON patient_mapping_backup table*/
/*         NIGHTHERON patient_mapping (current release)*/
    ,cdm_i2b2_pat_cw as (
select  cdm.PATID
       ,pm.PATIENT_NUM
       ,pmb.PATIENT_IDE /*keep MRN for future reference*/
       ,cdm.CDM_BIRTH_DATE
       ,pmb.BACKUP_ID
from /*provide patient_mapping_backup table here*/ nheron_backup.patient_mapping_backup pmb 
join PATID_CDM cdm
on cdm.PATID = pmb.PATIENT_NUM
join /*provide current HERON patient_mapping table here*/ nightherondata.patient_mapping pm
on pmb.PATIENT_IDE = pm.PATIENT_IDE /*link on MRN*/
where exists (select 1 from I2B2_VERSION i2b2
              where pmb.backup_id = i2b2.backup_id and /*backup_id picks out the correct backup version*/
                    pmb.PATIENT_IDE_SOURCE = 'SMS@kumed.com') and /*EHR source -- KUMC specific*/
      pm.PATIENT_IDE_SOURCE = 'SMS@kumed.com' /*EHR source -- KUMC specific*/
)
--calculate date shifts
/*Note: - days shift are between 0 to -364 at KUMC, can be adjusted for local I2B2;*/
/*      - age >= 88 are HIPPA protected*/
select  PATID
       ,cdm.PATIENT_IDE
       ,cdm.CDM_BIRTH_DATE
       ,pd.BIRTH_DATE REAL_BIRTH_DATE
       ,round((pd.HIPPA_BIRTH_DATE-cdm.CDM_BIRTH_DATE),0) days_shift 
from cdm_i2b2_pat_cw cdm
left join /*provide current patient_mapping table here*/ nightherondata.patient_dimension pd
on cdm.PATIENT_NUM = pd.PATIENT_NUM
where pd.HIPPA_BIRTH_DATE - cdm.CDM_BIRTH_DATE between 0 and 364
; /*78.421 seconds*/



