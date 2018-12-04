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
/*                                                                                                                */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C4R1   */
/******************************************************************************************************************/

/*Note: 'KUMC specific' issue are marked as such*/

/*This script takes about 300 seconds to complete*/

/**********************************************************************/
/***********************Table 6 -- Labs *******************************/
/**********************************************************************/
create table nextd_labs_loinc as
select column_value lab_loinc, 'CHOLESTEROL' lab_name
from table(sys.ODCIVarchar2List('2093-3','14647-2'))
union all
select column_value lab_loinc, 'HDL' lab_name
from table(sys.ODCIVarchar2List('14646-4','18263-4','2085-9'))
union all
select column_value lab_loinc, 'TRIGLYCERIDE' lab_name
from table(sys.ODCIVarchar2List('12951-0','14927-8','2571-8','47210-0'))
union all
select column_value lab_loinc, 'LDL' lab_name
from table(sys.ODCIVarchar2List('12773-8','13457-7','18261-8','18262-6','2089-1','22748-8','39469-2','49132-4','55440-2'))
union all
select column_value lab_loinc, 'A1C' lab_name
from table(sys.ODCIVarchar2List('17855-8', '4548-4','4549-2','17856-6','41995-2','59261-8','62388-4','71875-9','54039-3'))
union all
select column_value lab_loinc, 'CREATININE' lab_name
from table(sys.ODCIVarchar2List('2160-0','38483-4'))  /*KUMC specific*/
union all
select column_value lab_loinc, 'HGB' lab_name
from table(sys.ODCIVarchar2List('718-7','20509-6','30313-1'))  /*KUMC specific*/
union all
select column_value lab_loinc, 'RANDOM GLUCOSE' lab_name
from table(sys.ODCIVarchar2List('2345-7', '2339-0','10450-5','17865-7','1554-5','6777-7','54246-4','2344-0','41652-9'))
union all
select column_value lab_loinc, 'FASTING GLUCOSE' lab_name
from table(sys.ODCIVarchar2List('1558-6', '10450-5','1554-5','17865-7','35184-1'))
union all
select column_value lab_loinc, 'MICROALBUMIN' lab_name
from table(sys.ODCIVarchar2List('14957-5','57369-1','53530-2','30003-8','43605-5','53531-0','11218-5','43607-1',
                                '63474-1','53532-8','14956-7','43606-3','56553-1','49023-5','58448-2','44292-1',
                                '14958-3','14959-1','59159-4','30000-4','30001-2','47558-2','13705-9','14585-4',
                                '1753-3','1754-1','1755-8','1757-4','20621-9','21059-1','9318-7','50949-7','32294-1'))
union all
select column_value lab_loinc, 'C-PEPTIDE' lab_name
from table(sys.ODCIVarchar2List('13032-8','13033-6','13034-4','13035-1','13036-9','13037-7','13038-5','13039-3',
                                '13040-1','13041-9','13042-7','13043-5','13044-3','13045-0','13859-4','13860-2',
                                '13861-0','14633-2','16501-9','16502-7','1986-9','25568-7','25569-5','25570-3',
                                '25571-1','25572-9','25573-7','25574-5','25575-2','25576-0','25577-8','25578-6',
                                '25579-4','25580-2','25581-0','25582-8','27408-4','27421-7','27839-0','35195-7',
                                '38249-9','38421-4','38422-2','38423-0','38424-8','38425-5','38426-3','42180-0',
                                '47583-0','47584-8','47585-5','47586-3','47587-1','47588-9','47589-7','47590-5',
                                '47591-3','47592-1','47593-9','47594-7','47595-4','47832-1','47833-9','47834-7',
                                '50461-3','50462-1','50463-9','50464-7','50465-4','50466-2','50467-0','50468-8',
                                '55918-7','55919-5','56516-8','56582-0','56583-8','56584-6','57376-6','57645-4',
                                '57646-2','57647-0','57648-8','57649-6','57650-4','57651-2','57894-8','58494-6',
                                '58495-3','58496-1','58497-9','58498-7','58499-5','58500-0','58501-8','58502-6',
                                '58503-4','58504-2','58505-9','58506-7','58507-5','58508-3','58509-1','58510-9',
                                '58511-7','58512-5','58513-3','58514-1','58515-8','58516-6','58517-4','58518-2',
                                '58519-0','58520-8','58521-6','58522-4','58686-7','58816-0','58841-8','58896-2',
                                '77610-4','77611-2','77612-0','77651-8','77652-6'))
union all
select column_value lab_loinc, 'BLOOD KETONE' lab_name
from table(sys.ODCIVarchar2List('53061-8'))
union all
select column_value lab_loinc, 'URINE KETONE' lab_name
from table(sys.ODCIVarchar2List('49779-2','33043-1','33903-6','2514-8','50557-8','5797-6','2514-8','33903-6','57734-6'))
union all
select column_value lab_loinc, 'AUTOANTIBODIES' lab_name
from table(sys.ODCIVarchar2List('45225-0','45171-6','5265-4','63571-4','56687-7','8086-1','31547-3','34652-8',
                                '13927-9','33563-8','31209-0','56718-0','81155-4','32636-3','70253-0','70252-2', /*Islet Cell Antibody*/
                                '42501-7','13926-1','56540-8','58451-6','81725-4','72523-4','30347-9','83004-2','82660-2', /*Glutamic Acid Decarboxylase (GAD65) Antibody*/
                                '31209-0','56718-0','81155-4','32636-3','70253-0','70252-2', /*Insulinoma-Associated-2 Autoantibodies (IA-2A)*/
                                '76651-9' /*Zinc Transporter 8 (ZnT8) Antibody*/))
;


create table cdm_labs as
select /*+leading(c,l,fst)*/
       l.PATID
      ,l.ENCOUNTERID
      ,l.LAB_RESULT_CM_ID
      ,l.LAB_ORDER_DATE
      ,l.SPECIMEN_DATE
      ,l.LAB_LOINC
      ,l.LAB_PX_TYPE
      ,l.RESULT_NUM
      ,l.RESULT_UNIT
      ,l.RESULT_MODIFIER
      ,l.RESULT_LOC
      ,l.RAW_RESULT
      ,l.RAW_LAB_NAME
      ,c.LAB_NAME
from /*provide current PCORNET_CDM.Lab_Result_CM table here*/"&&PCORNET_CDM".LAB_RESULT_CM l
join nextd_labs_loinc c
on l.LAB_LOINC = c.LAB_LOINC
where exists (select 1 from FinalStatTable1 fst
              where fst.PATID = l.PATID)
;

create table cdm_demographic as
select pat.PATID
      ,pat.BIRTH_DATE
from /*provide current PCORNET_CDM.Demographic table here*/"&&PCORNET_CDM"..DEMOGRAPHIC pat
where exists (select 1 from FinalStatTable1 fst
              where fst.PATID = pat.PATID)
;

create table pregn_dates as 
select PATID
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
;

create table lab_with_age_realdate as
select l.PATID
      ,l.ENCOUNTERID
      ,l.LAB_RESULT_CM_ID
      ,l.LAB_ORDER_DATE + ds.days_shift as REAL_LAB_ORDER_DATE
      ,l.SPECIMEN_DATE + ds.days_shift as REAL_SPECIMEN_DATE 
      ,l.LAB_LOINC
      ,l.LAB_PX_TYPE
      ,l.RESULT_NUM
      ,l.RESULT_UNIT
      ,l.RESULT_MODIFIER
      ,l.RESULT_LOC
      ,l.RAW_RESULT
      ,l.RAW_LAB_NAME
      ,l.LAB_NAME
      ,round((l.LAB_ORDER_DATE - pat.BIRTH_DATE)/365.25,2) as age_at_event
from cdm_labs l
join cdm_demographic pat
on l.PATID = pat.PATID
join date_unshifts ds
on l.PATID = ds.PATID
;
/*note specimen_date is the same as order_date   -- KUMC specific*/

/*for better efficiency*/
create index lab_w_age_realdate_PATDT_IDX on lab_with_age_realdate(PATID,REAL_LAB_ORDER_DATE);


create table eligible_lab as
with pregn_exclud as (
select lrd.LAB_RESULT_CM_ID
from lab_with_age_realdate lrd
where lrd.age_at_event between 18 and 89 and                                
      lrd.REAL_LAB_ORDER_DATE between Date '2010-01-01' and CURRENT_DATE and 
      exists (select 1 from pregn_dates pd                                 
                  where pd.PATID = lrd.PATID and
                        (abs(lrd.REAL_LAB_ORDER_DATE - pd.PREGNANCY_DATE) <= 365))
)
select lrd.PATID
      ,lrd.ENCOUNTERID
      ,lrd.LAB_RESULT_CM_ID
      ,lrd.REAL_LAB_ORDER_DATE
      ,lrd.REAL_SPECIMEN_DATE 
      ,lrd.LAB_LOINC
      ,lrd.LAB_PX_TYPE
      ,lrd.RESULT_NUM
      ,lrd.RESULT_UNIT
      ,lrd.RESULT_MODIFIER
      ,lrd.RESULT_LOC
      ,lrd.RAW_RESULT
      ,lrd.RAW_LAB_NAME
      ,lrd.LAB_NAME
from lab_with_age_realdate lrd
where lrd.age_at_event between 18 and 89 and                                  /*age restriction*/
      lrd.REAL_LAB_ORDER_DATE between Date '2010-01-01' and CURRENT_DATE and  /*time restriction*/
      lrd.LAB_RESULT_CM_ID not in (select LAB_RESULT_CM_ID from pregn_exclud) /*pregenancy exclusion*/
;

create table NEXTD_LABS as
--time blinding
select fst.PATID
      ,el.ENCOUNTERID
      ,el.LAB_RESULT_CM_ID
      ,cast(to_char(el.REAL_LAB_ORDER_DATE,'YYYY') as INTEGER) LAB_ORDER_YEAR
      ,cast(to_char(el.REAL_LAB_ORDER_DATE,'MM') as INTEGER) LAB_ORDER_MONTH
      ,el.REAL_LAB_ORDER_DATE - fst.FirstVisit as LAB_ORDER_Days_from_FirstEnc
      ,cast(to_char(el.REAL_SPECIMEN_DATE ,'YYYY') as INTEGER) SPECIMEN_YEAR
      ,cast(to_char(el.REAL_SPECIMEN_DATE ,'MM') as INTEGER) SPECIMEN_MONTH
      ,el.REAL_SPECIMEN_DATE  - fst.FirstVisit as SPECIMEN_Days_from_FirstEnc
      ,el.LAB_LOINC
      ,el.LAB_PX_TYPE
      ,el.RESULT_NUM
      ,el.RESULT_UNIT
      ,el.RESULT_MODIFIER
      ,el.RESULT_LOC
      ,el.RAW_RESULT
      ,el.RAW_LAB_NAME
      ,el.LAB_NAME
from FinalStatTable1 fst
left join eligible_lab el
on el.PATID = fst.PATID          
; 


/*save local NEXTD_LABS.csv file
 Use "|" symbol as field terminator and
 "ENDALONAEND" as row terminator. */
 
/*purge intermediate tables*/
drop table cdm_labs purge;
drop table cdm_demographic purge;
drop table pregn_dates purge;
drop table lab_with_age_realdate purge;
drop table eligible_lab purge;
