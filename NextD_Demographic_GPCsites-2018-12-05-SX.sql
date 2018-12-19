/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - require: 1. FinalStatTable1: the local version where dates are unshifted                                     */
/*            2. date_unshifts: an intermediate table for recovering real dates                                   */
/*               columns:        PATID: CDM patient ID                                                            */
/*                               days_shift: days shifted                                                         */
/*                               first_enc_date: the real dates of first encounter                                */                                                 */
/*                               MARITAL_STATUS_CD: marital status (only available in local i2b2)                 */
/*               - if such intermediate table alread saved locally for table1 extraction, then just use that one; */
/*                 if not, the NextD_Date_Recovery.sql will do the work                                           */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C5R2   */
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
--modified: re-numbered 'Pipe' and included in the output table
create table NEXTD_DEMOGRAPHIC as
select pat.PATID,'|' as Pipe1
      ,cast(to_char(demo.BIRTH_DATE+ds.days_shift,'YYYY') as INTEGER) BIRTH_YEAR,'|' as Pipe2
      ,cast(to_char(demo.BIRTH_DATE+ds.days_shift ,'MM') as INTEGER) BIRTH_MONTH,'|' as Pipe3
      ,demo.BIRTH_DATE+ds.days_shift-pat.FirstVisit as BIRTH_DELTA_DAYS,'|' as Pipe4
      ,demo.SEX,'|' as Pipe5
      ,demo.RACE,'|' as Pipe6
      ,demo.HISPANIC,'|' as Pipe7
      ,demo.PAT_PREF_LANGUAGE_SPOKEN,'|' as Pipe8
      ,case when ds.MARITAL_STATUS_CD in ('u','@') or ds.MARITAL_STATUS_CD is null then 'NI'
            else upper(ds.MARITAL_STATUS_CD) end as MARITAL_STATUS
      ,'ENDALONAEND' as ENDOFLINE
from date_unshifts ds 
join FinalStatTable1 pat
on ds.PATID = pat.PATID
left join /*provide current PCORNET_CDM.Demogrphic table here*/ "&&PCORNET_CDM".DEMOGRAPHIC demo
on ds.PATID = demo.PATID
left join date_unshifts ds
on ds.PATIENT_NUM_I2B2 = ds.PATIENT_NUM
; 

/*save local NEXTD_DEMOGRAPHIC.csv file*/
