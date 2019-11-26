/*********************************************************************/
This repository is meant to be used for the third nextD extraction round.

Description of Next-D project and all relevant details on data extraction beyond sql codes and this README file could be found at:
https://www.dropbox.com/home/diabetes%20project%20(working%20docs)/Definitions_StudySamples%26Variables?preview=Definitions_Part1_CAPRICORNversion-2019-11-13-AF.docx
https://www.dropbox.com/home/diabetes%20project%20(working%20docs)/Definitions_StudySamples%26Variables?preview=Definitions_Part2-2019-11-13-AF.docx
https://www.dropbox.com/home/diabetes%20project%20(working%20docs)/Definitions_StudySamples%26Variables?preview=Definitions_Appendix_A-2018-11-27-af.docx
https://www.dropbox.com/home/diabetes%20project%20(working%20docs)/Definitions_StudySamples%26Variables?preview=Definitions_Apendix_B-2018-12-14-AF.docx

copy if current bundle is also can be found at https://www.dropbox.com/home/diabetes%20project%20(working%20docs)/NU_data%26codes/Codes/DataExtractionCodes_2019-11-26

<Intellectual credit: The sql codes ending with XS are oracle adaptation of the code and description was kindly performed by KUMC team. Codes eneding up with AF are modifications or earlier vesions of oracle codes.>
/*********************************************************************/
The data extraction deadline is 2019-12-18. 
Study period: 2010-01-01 - 2019-11-31 (or current date)
CDM version: >= v5.1, without date shifts

Note: The proposed order of execution could be used with following exceptions:
*There is no particular execution orders among 2.1 - 2.6, as long as tables at step 1 iscollected
**There is not particular execution order between 3.1, 3.2, 4, 5.1, 5.2, 6, 7 as long as tables of step 1 and 2 are collected

Table numbering inside of sql codes corresponds to numbering in NextD data dictionary and might be different from proposed below order of execution.
/*********************************************************************/
File name: Execution Plan.xlsx
Comments: contains tabulated format of readme file with less detailed information on other links
Update date: 11/26/2019

Script name: SQLTable1_GPCsites_oracle-2019-11-25-SX.sql
Execution order: 1
Tables required: 
+PCORNET_CDM.DEMOGRAPHIC;
+PCORNET_CDM.ENCOUNTER;
+PCORNET_CDM.DIAGNOSIS;
+PCORNET_CDM.PROCEDURES;
+PCORNET_CDM.LAB_RESULT_CM;
+PCORNET_CDM.PRESCRIBING;
+I2B2_ID.visit_dimension;
Table produced:
+NextD_distinct_preg_events; (intermediate);
+NextD_preg_masked_encounters (intermediate);
+FinalStatsTable1_local;
+FinalStatsTable1;
Comments: FinalStatsTable1_local should include full real dates for future reference; FinalStatsTable1 is date-blinded
Update date: 11/26/2019

/*********************************************************************/

Script name: NextD_Demographic_GPCsites-2018-12-05-SX.sql
Execution order: 2.1*
Tables required: 
+FinalStatsTable1_local;
+PCORNET_CDM.DEMOGRAPHIC
+I2B2_ID.patient_dimension
Table produced:
+NextD_Demographic
Comments: Demograhic table. Variable PAT_PREF_LANGUAGE_SPOKEN is no longer collected from source system.
Update date: 11/26/2019

/*********************************************************************/

Script name: NextD_Encounter_GPCsites-2019-11-25-SX.sql
Execution order: 2.2*
Tables required: 
+FinalStatsTable1_local;
+PCORNET_CDM.ENCOUNTER;
Table produced:
+NextD_Encounter
Comments: Encounter table (include pregnancy)
Update date: 11/26/2019

/*********************************************************************/

Script name: NextD_PrescribedMed_GPCsites-2019-11-25-SX.sql
Execution order: 2.3*
Tables required: 
+FinalStatsTable1_local;
+NextD_distinct_preg_events;
+PCORNET_CDM.PRESCRIBING;
Table produced:
+NextD_Prescribing
Comments: Prescribing table (exclude pregancy)
Update date: 11/26/2019

/*********************************************************************/

Script name: NextD_DispensedMed_GPCsites-2019-11-25-SX.sql
Execution order: 2.4*
Tables required: 
+FinalStatsTable1_local;
+NextD_distinct_preg_events;
+PCORNET_CDM.DISPENSING;
Table produced:
+NextD_Dispensing
Comments: Dispensing table (exclude pregancy)
Update date: 11/26/2019

/*********************************************************************/

Script name: NextD_Vital_GPCsites-2019-11-25-SX.sql
Execution order: 2.5*
Tables required: 
+FinalStatsTable1_local;
+NextD_distinct_preg_events;
+PCORNET_CDM.VITAL;
Table produced:
+NextD_Vital
Comments: Vital table (exclude pregancy)
Update date: 11/26/2019

/*********************************************************************/

Script name: NextD_Labs_GPCsites-2019-11-25-SX.sql
Execution order: 2.6*
Tables required: 
+FinalStatsTable1_local;
+NextD_distinct_preg_events;
+PCORNET_CDM.LAB_RESULT_CM;
Table produced:
+NextD_Labs
Comments: Lab table (exclude pregancy)
Update date: 11/26/2019

/*********************************************************************/

Script name: NextD_Diagnosis_GPCsites-2019-11-25-SX.sql
Execution order: 3.1**
Tables required: 
+NextD_Encounter
+NextD_preg_masked_encounters 
+PCORNET_CDM.DIAGNOSIS
Table produced:
+NextD_Diagnosis
Comments: Diagnosis table (exclude pregancy)
Update date: 11/26/2019

/*********************************************************************/

Script name: NextD_Procedures_GPCsites-2019-11-25-SX.sql
Execution order: 3.2**
Tables required: 
+FinalStatsTable1_local;
+NextD_Encounter
+PCORNET_CDM.ENCOUNTER;
+PCORNET_CDM.PROCEDURES;
Table produced:
+NextD_Procedure
Comments: Procedure table (include pregnancy)
Update date: 11/26/2019

/*********************************************************************/

Script name: NextD_Provider_GPCsites-2019-11-25-SX.sql
Execution order: 4**
Tables required: 
+NEXTD_ENCOUNTER
+NEXTD_PRESCRIBING
+PCORNET_CDM.PROVIDER;
+PROVIDER_CATEGORY (optional)
Table produced:
+NextD_Provider
Comments: Provider table
Update date: 11/26/2019

/*********************************************************************/

Script name: NextD_Epic_InsuranceCoveragePerPatient_pro-ENROLLMENTtable-2019-11-26-SX
Execution order: 5.1**
Tables required: 
+FinalStatsTable1_local;
+I2B2_ID.patient_mapping (KUMC specific);
+clarity.COVERAGE;
+clarity.COVERAGE_MEM_LIST;
+clarity.CLARITY_EPP;
+clarity.CLARITY_EPM;
+clarity.CLARITY_FC;
+payor_map: mapping table between payor name and financial class to PCORnet CDM payor categories (usually manually curated, KUMC specific)
Table produced:
+NEXTD_Enr_EPIC
Comments: This code is not actual code meant to be used by sites. This is rather prototype proposed to be adopted by sites according tro internal structure. The adopted code is expected to produce Enrollement table based on Epic tables. 
Update date: 11/26/2019


/*********************************************************************/

Script name: NextD_IDX_InsuranceCoveragePerPatient_pro-ENROLLMENTtable-2019-11-26-SX.sql
Execution order: 5.2**
Tables required: 
+NEXTD_ENCOUNTER;
+I2B2_ID.encounter_mapping (KUMC specific); 
+kupi.idx_table: IDX table (KUMC specific);
+payor_map: mapping table between payor name and financial class to PCORnet CDM payor categories (usually manually curated, KUMC specific)
Table produced:
+NEXTD_Enr_IDX
Comments: This code is not actual code meant to be used by sites. This is rather prototype proposed to be adopted by sites according tro internal structure. The adopted code is expected to produce Enrollement table based on IDX tables.
Update date: 11/26/2019

/*********************************************************************/

Script name: NextD_SES_GPCsites-2018-12-17-AF.sql
Execution order: 6**
Tables required: 
+FinalStatsTable1_local;
+Local table with information on geocoding accuracy, and GEOIIDs
Table produced:
+NextD_SES
Comments: SES table
Update date: 12/17/2018

/*********************************************************************/

Script name: NextD_Facility_GPCsites-2019-11-25-SX.sql
Execution order: 7**
Tables required:
+NEXTD_ENCOUNTER
+Internal source table with FACILITY addresses (e.g. clarity.CLARITY_POS)
Table produced:
+NextD_FACILITY
Comments: 
Update date: 11/26/2019

/*********************************************************************/
