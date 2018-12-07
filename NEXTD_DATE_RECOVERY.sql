/*********************************************************************************************************************/
/* NextD Clinical Variable Extractions Preparation: date_unshifts                                                    */
/* -- Due to date shifts and requests for some variable that only available in local I2B2, we construct this table to*/
/*    collect necessary information in advance. Sites may have different implementation adapting to their local I2B2,*/
/*    as long as the final output date_unshifts table contains the following columns:                                */
/*    - PATID: CDM patient ID                                                                                        */
/*    - days_shift: days shifted                                                                                     */
/*    - first_enc_date: the real dates of first encounter (will be used for identifying established patients),       */
/*                      which can be obtained from visit_dimension                                                   */
/*    - MARITAL_STATUS_CD: marital status (will be used for identifying established patients),                       */
/*                         usually available in patient_dimension                                                    */
/*                                                                                                                   */
/* KUMC provided solutions based on their local I2B2 for references                                                  */
/*********************************************************************************************************************/

/*Note: 'KUMC specific' issue are marked as such*/


/******************************************************************************************/
/*Case I: when CDM and I2B2 are of the same release (matchable by PATIENT_NUM = PATID)    */
/******************************************************************************************/
create table date_unshifts as
--get PCORNET_CDM patient ID and shifted birth_date
with PATID_CDM as (
select distinct pat.PATID, 
                pat.BIRTH_DATE CDM_BIRTH_DATE
from /*provide current PCORNET_CDM.Demogrphic table here*/ "&&PCORNET_CDM".DEMOGRAPHIC pat
)
--calculate date shifts and collect first_enc_date
select  cdm.PATID
       ,round((pd.BIRTH_DATE_HIPAA-cdm.CDM_BIRTH_DATE),0) days_shift
       ,min(vd.START_DATE) first_enc_date
       ,pd.MARITAL_STATUS_CD
from PATID_CDM cdm
left join /*provide current patient_dimension table here*/ "&&i2b2_ide".patient_dimension pd --KUMC specific
on cdm.PATID = pd.PATIENT_NUM
left join /*provide current visit_dimension table here (with real dates)*/ "&&i2b2_ide".visit_dimension vd --KUMC specific
on cdm.PATID = vd.PATIENT_NUM
group by cdm.PATID,pd.MARITAL_STATUS_CD,round((pd.BIRTH_DATE_HIPAA-cdm.CDM_BIRTH_DATE),0)
;


/*****************************************************************************************/
/*when CDM and I2B2 are of different releases (NOT matchable by PATIENT_NUM = PATID)     */
/*****************************************************************************************/
create table date_unshifts as
with PATID_CDM as (
select distinct pat.PATID, 
                pat.BIRTH_DATE CDM_BIRTH_DATE
from /*provide current PCORNET_CDM.Demogrphic table here*/ "&&PCORNET_CDM".DEMOGRAPHIC pat
)
     ,cdm_i2b2_pat_cw as (
select cdm.PATID,
       pmb.PATIENT_IDE, 
       pm.PATIENT_NUM I2B2_PATIENT_NUM,  
       cdm.BIRTH_DATE CDM_BIRTH_DATE 
from /*provide current patient mapping backup table here*/ "&&i2b2_ide".patient_mapping_backup pmb --KUMC specific
join PATID_CDM cdm
on cdm.PATID = pmb.PATIENT_NUM and
   pmb.PATIENT_IDE_SOURCE = &&patient_ide_source and --KUMC specific
   pmb.backup_id = &&backup_id -- identify the i2b2 version that is compatiable with CDM --KUMC specific
join /*provide current patient_mapping table here*/ "&&i2b2_ide".patient_mapping pm --KUMC specific
on pmb.PATIENT_IDE = pm.PATIENT_IDE
where pm.PATIENT_IDE_SOURCE = &&patient_ide_source --KUMC specific
)
--calculate date shifts
/*Note: - days shift are between 0 to 364 at KUMC, can be adjusted for local I2B2;*/
/*      - for protected age group (>=88), the days shift don't follow the rule*/
select cdm2.PATID, 
       round((pd.BIRTH_DATE_HIPAA-cdm2.CDM_BIRTH_DATE),0) days_shift,
       min(vd.START_DATE) first_enc_date,
       pd.MARITAL_STATUS_CD
from cdm_i2b2_pat_cw cdm2
left join /*provide current patient_dimension table here*/ "&&i2b2_ide".patient_dimension pd --KUMC specific
on cdm2.I2B2_PATIENT_NUM = pd.PATIENT_NUM
left join /*provide current visit_dimension table here (with real dates)*/ "&&i2b2_ide".visit_dimension vd --KUMC specific
on cdm2.I2B2_PATIENT_NUM = vd.PATIENT_NUM
group by cdm2.PATID, cdm2.I2B2_PATIENT_NUM,
         cdm2.PATIENT_IDE, cdm2.CDM_BIRTH_DATE, 
         pd.BIRTH_DATE,pd.MARITAL_STATUS_CD,
         round((pd.BIRTH_DATE_HIPAA-cdm2.CDM_BIRTH_DATE),0)
; 

/*sanity check*/
/*date shifts are supposed to between 0 and 364*/
select round(avg(correct_shift),8) correct_shift_rate from
(select case when days_shift between 0 and 364 then 1 else 0 end as correct_shift 
 from date_unshifts
 where days_shift is not null); /*0.98*/ -- double check backup_id if this proportion is less than 10%
 

