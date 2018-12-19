/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - require: 1. FinalStatTable1_local: the local version where dates neither shifted nor masked                  */
/*            2. date_unshifts: an intermediate table for recovering real dates                                   */
/*            3. NEXTD_ENCOUNTER: NextD Encounter table                                                           */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C5R2   */
/******************************************************************************************************************/


/****************************************************************************/
/***********************Table 8 -- Procedures*******************************/
/****************************************************************************/
/*for better efficiency*/
create index NextD_ENC_PAT_IDX on NEXTD_ENCOUNTER(ENCOUNTERID);

create table NEXTD_PROCEDURES as
select enc.PATID,'|' as Pipe1
      ,enc.ENCOUNTERID,'|' as Pipe2
      ,enc.ENC_TYPE,'|' as Pipe3
      ,enc.ADMIT_YEAR,'|' as Pipe4
      ,enc.ADMIT_MONTH,'|' as Pipe5
      ,enc.ADMIT_Days_from_FirstEnc,'|' as Pipe6
      ,px.PROVIDERID,'|' as Pipe7
      ,px.PROCEDURESID,'|' as Pipe8
	  ,cast(to_char(px.PX_DATE + ds.days_shift,'YYYY') as INTEGER) as PX_YEAR,'|' as Pipe9
	  ,cast(to_char(px.PX_DATE + ds.days_shift,'MM') as INTEGER) as  PX_MONTH,'|' as Pipe10
	  ,round((px.PX_DATE + ds.days_shift) - fst.FirstVisit) as PX_Days_from_FirstEnc,'|' as Pipe11
      ,px.PX,'|' as Pipe12
      ,px.PX_TYPE,'|' as Pipe13
      ,px.PX_SOURCE,'|' as Pipe14
	  ,px.PPX,'ENDALONAEND' as ENDOFLINE
from NEXTD_ENCOUNTER enc
join /*provide current PCORNET_CDM.Procedures table here*/ "&&PCORNET_CDM".PROCEDURES px
on enc.ENCOUNTERID = px.ENCOUNTERID       
left join date_unshifts ds on enc.PATID = ds.PATID 
left join FinalStatTable1_local fst on enc.PATID = fst.PATID  
; 
