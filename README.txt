/*********************************************************************/
Run SQLTable1_CAPRICORNsites-2021-03-02_AF.sql. It will produce FinalTable 1 with relevant patient’s IDs that will be utilized in other provided codes.

The remaining 12 codes could be run in any order after the FinalTable1 is generated.
Codes for producing NextD_PROVIDER and NextD_SES tables will need extra mapping with provided along with this set files NPI2ToxonomycodeCorssWalk_2018-01-01_AF.zip and nhgis0561_20155_2015_tract_final_label_csv_2017-7-24-AF.zip, correspondingly

Save each output table as a separate pipeline delimited file. Use “ALONAENDALONA” as line terminator. Produced files should then be archived
/*********************************************************************/
Study period: 2010-01-01 - 2020-12-31 (or current date)
CDM version: >= v6.1, without date shifts

/*********************************************************************/

Script name: SQLTable1_GPCsites_oracle-2021-02-22.sql
Execution order: 1
Tables required: 
+PCORNET_CDM.DEMOGRAPHIC
+PCORNET_CDM.ENCOUNTER

Table produced:
+FinalTable1;

/*********************************************************************/

Script name: NextD_ExtractionCode_DEMOGRAPHICS-2021-02-03.sql
Execution order: 2.*
Tables required: 
+FinalsTable1
+PCORNET_CDM.DEMOGRAPHIC

Table produced:
+NextD_DEMOGRAPHIC_FINAL

/*********************************************************************/

Script name: NextD_ExtractionCode_ENCOUNTER-2021-03-02.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+PCORNET_CDM.ENCOUNTER
+NEXT_OriginalNPIFROMBaseTaxonomy

Table produced:
+NextD_ENCOUNTER_FINAL

/*********************************************************************/

Script name: NextD_ExtractionCode_PRESCRIBING-2021-02-03.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+PCORNET_CDM.DEMOGRAPHIC
+PCORNET_CDM.PRESCRIBING
+PCORNET_CDM.ENCOUNTER

Table produced:
+NextD_PRESCRIBING_FINAL

/*********************************************************************/

Script name: NextD_ExtractionCode_DISPENSING-2021-02-03.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+PCORNET_CDM.DISPENSING
+PCORNET_CDM.DEMOGRAPHIC

Table produced:
+NextD_DISPENSING_FINAL

/*********************************************************************/

Script name: NextD_ExtractionCode_VITAL-2021-02-03.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+PCORNET_CDM.DEMOGRAPHIC
+PCORNET_CDM.VITAL

Table produced:
+NextD_VITAL_FINAL

/*********************************************************************/

Script name: NextD_ExtractionCode_LABS_GPCsites-2021-02-03.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+PCORNET_CDM.DEMOGRAPHIC
+PCORNET_CDM.LAB_RESULT_CM

Table produced:
+NextD_LABS_FINAL

/*********************************************************************/

Script name: NextD_ExtractionCode_DIAGNOSIS-2021-02-03.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+PCORNET_CDM.DEMOGRAPHIC
+PCORNET_CDM.DIAGNOSIS

Table produced:
+NextD_DIAGNOSIS_FINAL

/*********************************************************************/

Script name: NextD_ExtractionCode_PROCEDURES-2021-02-03.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+PCORNET_CDM.DEMOGRAPHIC
+PCORNET_CDM.PROCEDURES;

Table produced:
+NextD_PROCEDURES_FINAL

/*********************************************************************/

Script name: NextD_ExtractionCode_PROVIDER-2021-02-03.sql
Execution order: 2.*
Tables required: 
+NEXT_OriginalNPIFROMBaseTaxonomy
+PCORNET_CDM.PROVIDER

Table produced:
+NextD_PROVIDER_FINAL

/*********************************************************************/

Script name: NextD_ExtractionCode_SES_2021-02-03.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+Local table with information on geocoding accuracy, and GEOIIDs

Table produced:
+NextD_SES_FINAL

/*********************************************************************/

Script name: NextD_ExtractionCode_DEATH_2021-02-03.sql
Execution order: 2.*
Tables required: 
+FinalTable1
++PCORNET_CDM.DEATH

Table produced:
+NextD_DEATH_FINAL

/*********************************************************************/


Script name: NextD_ExtractionCode_DEATH_2021-02-03.sql
Execution order: 2.*
Tables required: 
+FinalTable1
++PCORNET_CDM.DEATH_CAUSE

Table produced:
+NextD_DEATH_CAUSE_FINAL

/*********************************************************************/


Script name: NextD_ExtractionCode_Epic_InsuranceCoveragePerPatient_pro-ENROLLMENTtable-2021-02-03
Execution order: 2.*
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
