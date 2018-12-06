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

/*

/**************************************************************************/
/***********************Table 9 -- Demographics****************************/
/**************************************************************************/
create table NEXTD_DEATH_CAUSE as
select pat.PATID
      ,demo.DEATH_CAUSE
	  ,demo.DEATH_CAUSE_CODE 
	  ,demo.DEATH_CAUSE_TYPE 
	  ,demo.DEATH_CAUSE_SOURCE 
	  ,demo.DEATH_CAUSE_CONFIDENCE 

from FinalStatTable1 pat
left join /*provide current PCORNET_CDM.Demogrphic table here*/ "&&PCORNET_CDM".DEATH_CAUSE demo
on ds.PATID = demo.PATID
; 
/*16.291 seconds*/

/*eyeball final table and make sure the format is IRB-approved*/
select PATID,'|' as Pipe1
		,demo.DEATH_CAUSE,'|' as Pipe2
	  ,demo.DEATH_CAUSE_CODE ,'|' as Pipe3
	  ,demo.DEATH_CAUSE_TYPE ,'|' as Pipe4
	  ,demo.DEATH_CAUSE_SOURCE ,'|' as Pipe5
	  ,demo.DEATH_CAUSE_CONFIDENCE ,'ENDALONAEND' as ENDOFLINE
from NEXTD_DEATH_CAUSE;

/*save local NEXTD_DEATH_CAUSE.csv file*/
