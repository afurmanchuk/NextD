/*********************************************************************/
Content of this folder:
codes for Next-D data extraction in MS SQL server (file names start with MS) and Oracle SQL (file names start with PLSQL) formats.
/*********************************************************************/
Execution plan:
1. Run NextD_ExtractionCode_Table1.sql
    It will produce FinalTable1 with relevant patient’s IDs that will be utilized in other provided codes.

2. The remaining 12 codes could be run in any order after the FinalTable1 is generated.
    Codes NextD_ExtractionCode_PROVIDER.sql will need extra mapping with provided along with this set files NPI2ToxonomycodeCorssWalk_2018-01-01_AF.zip 

3. Archive each output table as a separate pipeline delimited file with 'ENDALONAEND' as line terminator. 
    Field separators and line terminators where added to codes for those who would liket to use codes as is.  
    
/*********************************************************************/
/*********************************************************************/
Study period: 2010-01-01 - 2020-12-31 
CDM version: >= v6.0, without date shifting
/*********************************************************************/

Script name: MS_NextD_ExtractionCode_Table1.sql or PLSQL_NextD_ExtractionCode_Table1.sql
Execution order: 1
Tables required: 
+PCORNET_CDM.DEMOGRAPHIC
+PCORNET_CDM.ENCOUNTER

Table produced:
+FinalTable1;

/*********************************************************************/

Script name: MS_NextD_ExtractionCode_DEMOGRAPHIC.sql or PLSQL_NextD_ExtractionCode_DEMOGRAPHIC.sql
Execution order: 2.*
Tables required: 
+FinalsTable1
+PCORNET_CDM.DEMOGRAPHIC

Table produced:
+NextD_DEMOGRAPHIC_FINAL

/*********************************************************************/

Script name: MS_NextD_ExtractionCode_ENCOUNTER.sql or PLSQL_NextD_ExtractionCode_ENCOUNTER.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+PCORNET_CDM.ENCOUNTER
+NEXT_OriginalNPIFROMBaseTaxonomy

Table produced:
+NextD_ENCOUNTER_FINAL

/*********************************************************************/

Script name: MS_NextD_ExtractionCode_PRESCRIBING.sql or PLSQL_NextD_ExtractionCode_PRESCRIBING.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+PCORNET_CDM.DEMOGRAPHIC
+PCORNET_CDM.PRESCRIBING
+PCORNET_CDM.ENCOUNTER

Table produced:
+NextD_PRESCRIBING_FINAL

/*********************************************************************/

Script name: MS_NextD_ExtractionCode_DISPENSING.sql or PLSQL_NextD_ExtractionCode_DISPENSING.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+PCORNET_CDM.DISPENSING
+PCORNET_CDM.DEMOGRAPHIC

Table produced:
+NextD_DISPENSING_FINAL

/*********************************************************************/

Script name: MS_NextD_ExtractionCode_VITAL.sql or PLSQL_NextD_ExtractionCode_VITAL.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+PCORNET_CDM.DEMOGRAPHIC
+PCORNET_CDM.VITAL

Table produced:
+NextD_VITAL_FINAL

/*********************************************************************/

Script name: MS_NextD_ExtractionCode_LABS.sql or PLSQL_NextD_ExtractionCode_LABS.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+PCORNET_CDM.DEMOGRAPHIC
+PCORNET_CDM.LAB_RESULT_CM

Table produced:
+NextD_LABS_FINAL

/*********************************************************************/

Script name: MS_NextD_ExtractionCode_DIAGNOSIS.sql or PLSQL_NextD_ExtractionCode_DIAGNOSIS.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+PCORNET_CDM.DEMOGRAPHIC
+PCORNET_CDM.DIAGNOSIS

Table produced:
+NextD_DIAGNOSIS_FINAL

/*********************************************************************/

Script name: MS_NextD_ExtractionCode_PROCEDURES.sql or PLSQL_NextD_ExtractionCode_PROCEDURES.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+PCORNET_CDM.DEMOGRAPHIC
+PCORNET_CDM.PROCEDURES;

Table produced:
+NextD_PROCEDURES_FINAL

/*********************************************************************/

Script name: MS_NextD_ExtractionCode_PROVIDER.sql or PLSQL_NextD_ExtractionCode_PROVIDER.sql
Execution order: 2.*
Tables required: 
+NEXT_OriginalNPIFROMBaseTaxonomy
+PCORNET_CDM.PROVIDER

Table produced:
+NextD_PROVIDER_FINAL

/*********************************************************************/

Script name: MS_NextD_ExtractionCode_SES.sql or PLSQL_NextD_ExtractionCode_SES.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+Local table with information on geocoding accuracy, and GEOIIDs

Table produced:
+NextD_SES_FINAL

/*********************************************************************/

Script name: MS_NextD_ExtractionCode_DEATH.sql or PLSQL_NextD_ExtractionCode_DEATH.sql
Execution order: 2.*
Tables required: 
+FinalTable1
++PCORNET_CDM.DEATH

Table produced:
+NextD_DEATH_FINAL

/*********************************************************************/

Script name: MS_NextD_ExtractionCode_DEATH_CAUSE.sql or PLSQL_NextD_ExtractionCode_DEATH_CAUSE.sql
Execution order: 2.*
Tables required: 
+FinalTable1
++PCORNET_CDM.DEATH_CAUSE

Table produced:
+NextD_DEATH_CAUSE_FINAL

/*********************************************************************/
Script name: MS_NextD_ExtractionCode_DISPENSING.sql or PLSQL_NextD_ExtractionCode_DISPENSING.sql
Execution order: 2.*
Tables required: 
+FinalTable1
+DISPENSING
+DEMOGRAPHIC

Table produced:
+NextD_DISPENSING_FINAL

