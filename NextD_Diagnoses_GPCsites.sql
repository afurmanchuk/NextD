/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - require: 1. FinalStatsTable1 local version where dates are nor masked                                        */
/*            2. date_unshifts generated from FinalStatsTable1 extraction                                         */
/*                                                                                                                */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C4R1   */
/******************************************************************************************************************/

/*Note: 'KUMC-specific' issue are marked as such*/

/**************************************************************************/
/***********************Table 9 -- Diagnoses*******************************/
/**************************************************************************/

/*Step 1 - Get all eligible encounters and apply date-unshifting
 - age restriction: between 18 and 89;
 - study period restriction: after 01-01-2010;
 - exclude pregancy encounters */

create table Eligible_ENC_DX as
with enc_with_age_realdate as (
select enc.*
      ,enc.ADMIT_DATE+ds.days_shift as REAL_ADMIT_DATE
      ,round((enc.ADMIT_DATE - pat.BIRTH_DATE)/365.25,2) AS age_at_visit
from /*provide current PCORNET_CDM.Encounter table here*/"&&PCORNET_CDM".ENCOUNTER enc
left join /*provide current PCORNET_CDM.Encounter table here*/"&&PCORNET_CDM".DEMOGRAPHIC pat
on enc.PATID = pat.PATID
left join date_unshifts ds
on enc.PATID = ds.PATID
where exists (select 1 from FinalStatTable1 fst
              where fst.PATID = enc.PATID)
)
   ,preg_dates as (
select distinct PATID
               ,PREGNANCY_DATE
from FinalStatTable1
unpivot
(
  PREGNANCY_DATE
  for PREGNANCY_NO
    in (Pregnancy1_date
       ,Pregnancy2_date
       ,Pregnancy3_date
       ,Pregnancy4_date
       ,Pregnancy5_date
       ,Pregnancy6_date
       ,Pregnancy7_date
       ,Pregnancy8_date
       ,Pregnancy9_date
       ,Pregnancy10_date
       )
)
)
select eenc.PATID
      ,eenc.ENC_TYPE
      ,eenc.ENCOUNTERID
      ,eenc.REAL_ADMIT_DATE
from enc_with_age_realdate eenc
where eenc.age_at_visit between 18 and 89 and                               /*age restriction*/
      eenc.REAL_MEASURE_DATE between Date '2010-01-01' and CURRENT_DATE and /*time restriction*/
      not exists (select 1 from preg_dates pd                          /*pregenancy exclusion*/
                  where pd.PATID = eenc.PATID and
                        (abs(eenc.REAL_MEASURE_DATE-pd.PREGNANCY_DATE) <= 365))   
;

/*for better efficiency*/
create index Eligible_DX_ENCID_IDX on Eligible_ENC_DX(ENCOUNTERID);

/*Step 2: get final Diagnoses table and apply date-bliding*/
create table NEXTD_DIAGNOSES as
with dx_orig as (
select enc.PATID 
      ,enc.ENCOUNTERID
      ,dx.DIAGNOSISID
      ,dx.DX
      ,dx.PDX
      ,dx.DX_TYPE
      ,dx.DX_SOURCE
      ,dx.DX_ORIGIN
      ,enc.ENC_TYPE
      ,enc.REAL_ADMIT_DATE
from Eligible_ENC_DX enc
left join /*provide current PCORNET_CDM.Diagnosis table here*/"&&PCORNET_CDM".DIAGNOSIS dx
on enc.ENCOUNTERID = dx.ENCOUNTERID
)
--time blinding
select dxo.PATID
      ,dxo.ENCOUNTERID
      ,dxo.DIAGNOSISID
      ,dxo.DX
      ,dxo.PDX
      ,dxo.DX_TYPE
      ,dxo.DX_SOURCE
      ,dxo.DX_ORIGIN
      ,dxo.ENC_TYPE
      ,cast(to_char(dxo.REAL_ADMIT_DATE,'YYYY') as INTEGER) ADMIT_YEAR
      ,cast(to_char(dxo.REAL_ADMIT_DATE,'MM') as INTEGER) ADMIT_MONTH
      ,dxo.REAL_ADMIT_DATE - fst.FirstVisit as ADMIT_Days_from_FirstEncounter
from FinalStatTable1 fst
left join dx_orig dxo
on dxo.PATID = fst.PATID
; 

------------------------------------------------
/* Save #NextD_DIAGNOSES as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
-------------------------------------------------

select PATID,'|' as Pipe1
      ,ENCOUNTERID,'|' as Pipe2
      ,DIAGNOSISID,'|' as Pipe3
      ,DX,'|' as Pipe4
      ,PDX,'|' as Pipe5
      ,DX_TYPE,'|' as Pipe6
      ,DX_SOURCE,'|' as Pipe7
      ,DX_ORIGIN,'|' as Pipe8
      ,ENC_TYPE,'|' as Pipe9
      ,ADMIT_YEAR,'|' as Pipe10
      ,ADMIT_MONTH,'|' as Pipe11
      ,ADMIT_Days_from_FirstEncounter,'ENDALONAEND' as ENDOFLINE
from NEXTD_DIAGNOSES
