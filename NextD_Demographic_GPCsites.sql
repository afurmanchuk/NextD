/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - require: 1. FinalStatsTable1: the local version where dates are unshifted                                    */
/*            2. date_unshifts: an intermediate table for recovering real dates                                   */
/*               columns:        PATID: CDM patient ID                                                            */
/*                               PATIENT_IDE: patient IDE                                                         */
/*                               CDM_BIRTH_DATE: shifted birth date in CDM                                        */
/*                               REAL_BIRTH_DATE: real birth date in local HERON                                  */
/*                               days_shift: days shifted                                                         */
/*               - if such intermediate table alread saved locally for table1 extraction, then just use that one; */
/*                 if not, the NextD_Date_Recovery.sql will do the work                                           */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C4R1   */
/******************************************************************************************************************/

/*Note: 'KUMC-specific' issue are marked as such*/

/*MARITAL_STATUS categories (KUMC-specific):
 --S - Single
 --D - Divorced
 --P - Partner
 --W - Widowed
 --X - Separated
 --M - Married
 --NI - Unknown
*/

/**************************************************************************/
/***********************Table 2 -- Demographics****************************/
/**************************************************************************/
create table NEXTD_DEMOGRAPHIC as
select pat.PATID
      ,cast(to_char(ds.REAL_BIRTH_DATE,'YYYY') as INTEGER) BIRTH_YEAR
      ,cast(to_char(ds.REAL_BIRTH_DATE ,'MM') as INTEGER) BIRTH_MONTH
      ,ds.REAL_BIRTH_DATE - pat.FirstVisit as BIRTH_Days_from_FirstEncounter
      ,demo.SEX
      ,demo.RACE
      ,demo.HISPANIC
      ,case when i2b2.MARITAL_STATUS_CD in ('u','@') or i2b2.MARITAL_STATUS_CD is null then 'NI' /*combine the unknown category*/
            else upper(i2b2.MARITAL_STATUS_CD) end as MARITAL_STATUS /*KUMC - specific*/
from date_unshifts ds 
join FinalStatTable1 pat
on ds.PATID = pat.PATID
left join /*provide current PCORNET_CDM.Demogrphic table here*/ "&&PCORNET_CDM".DEMOGRAPHIC demo
on ds.PATID = demo.PATID
left join /*provide current HERON patient_mapping table here*/ nightherondata.patient_dimension i2b2
on ds.PATIENT_NUM_I2B2 = i2b2.PATIENT_NUM
; 
/*16.291 seconds*/

/*eyeball final table and make sure the format is IRB-approved*/
select * from NEXTD_DEMOGRAPHIC;

/*save local NEXTD_DEMOGRAPHIC.csv file*/
