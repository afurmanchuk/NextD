/*********************************************************************/
This repository is meant to be used for the second nextD extraction round.

Description of Next-D project and all relevant details on data extraction beyond sql codes and this README file could be found at:
https://www.dropbox.com/home/diabetes%20project%20(working%20docs)/Definitions_StudySamples%26Variables?preview=Definitions_Part1-2018-12-06-af.docx
https://www.dropbox.com/home/diabetes%20project%20(working%20docs)/Definitions_StudySamples%26Variables?preview=Definitions_Part2-2018-12-06-af.docx
https://www.dropbox.com/home/diabetes%20project%20(working%20docs)/Definitions_StudySamples%26Variables?preview=Definitions_Appendix_A-2018-11-27-af.docx
https://www.dropbox.com/home/diabetes%20project%20(working%20docs)/Definitions_StudySamples%26Variables?preview=Definitions_Apendix_B-2018-12-14-AF.docx

<Intellectual credit: The sql codes ending with XS are oracle adaptation of the code and description was kindly performed by KUMC team. Codes eneding up with AF are modifications or earlier vesions of oracle codes.>
/*********************************************************************/
The data extraction is separated into two parts with deadlines provided accordingly: 

Part 1 extraction (deadline -2018-01-05). Tables to be extracted are: 
FinalStatsFinal1, NextD_Demographic, NextD_Encounter, NextD_Prescribing, NextD_Dispensing, NextD_Vital, NextD_Labs, NextD_Diagnosis, NextD_Procedure.
Part 2 extraction (deadline -2018-02-15). Tables to be extracted are: 
NextD_Provider, NextD_Enrollement, NextD_SES.

Note: The proposed order of execution could be used with following exceptions:
*There is no particular execution orders among 3.1 - 3.5, as long as tables at step 1 and 2 are collected
**There is not particular execution order between 4.1 and 4.2, as long as tables of step 1,2 and 3 are collected
/*********************************************************************/

Script name: NextD_Date_Recovery-2018-12-05-SX.sql
Execution order: 1
Tables required: 
+PCORNET_CDM.DEMOGRAPHIC;
+local patient_dimension (or any equivalent table) with patients' real birth_date; 
+local visit_dimension (or any equivalent table) with visits and their real start_dates;
Table produced: 
+date_unshifts
Comments: collect date shifts, first_enc_date (for identifyin established patient later) and marital_status in advance.
Update date: 12/5/2018

Script name: SQLTable1_GPCsites_oracle-2018-12-07-SX.sql
Execution order: 2
Tables required: 
+date_unshifts;
+PCORNET_CDM.DEMOGRAPHIC;
+PCORNET_CDM.ENCOUNTER;
+PCORNET_CDM.DIAGNOSIS;
+PCORNET_CDM.PROCEDURES;
+PCORNET_CDM.LAB_RESULT_CM;
+PCORNET_CDM.PRESCRIBING;
Table produced:
+FinalStatsFinal1_local;
+FinalStatsFinal1;
Comments: FinalStatsFinal1_local should include full real dates for future reference; FinalStatsFinal1 is date-blinded
Update date: 12/5/2018

Script name: NextD_Demographic_GPCsites-2018-12-05-SX.sql
Execution order: 3.1*
Tables required: 
+PCORNET_CDM.DEMOGRAPHIC
Table produced:
+NextD_Demographic
Comments: Demograhic table. Variable PAT_PREF_LANGUAGE_SPOKEN is no longer collected from source system.
Update date: 12/5/2018

Script name: NextD_Encounter_GPCsites-2018-12-14-SX.sql
Execution order: 3.2*
Tables required: 
+FinalStatsFinal1_local;
+date_unshifts;
+PCORNET_CDM.ENCOUNTER;
+PCORNET_CDM.DEMOGRAPHIC;
Table produced:
+NextD_Encounter
Comments: Encounter table 
Update date: 12/14/2018

Script name: NextD_PrescribedMed_GPCsites-2018-12-14-SX.sql
Execution order: 3.3*
Tables required: 
+FinalStatsFinal1_local;
+date_unshifts;
+PCORNET_CDM.PRESCRIBING;
Table produced:
+NextD_Prescribing
Comments: Prescribing table (exclude pregancy)
Update date: 12/14/2018

Script name: NextD_DispensedMed_GPCsites-2018-12-14-SX.sql
Execution order: 3.4*
Tables required: 
+FinalStatsFinal1_local;
+date_unshifts;
+PCORNET_CDM.DISPENSING;
Table produced:
Comments: NextD_Dispensing
Update date: 12/14/2018

Script name: NextD_Vital_GPCsites-2018-12-14-SX.sql
Execution order: 3.5*
Tables required: 
+FinalStatsFinal1_local;
+date_unshifts;
+PCORNET_CDM.VITAL_SIGN;
Table produced:NextD_Vital
Comments: Vital table (exclude pregancy)
Update date: 12/14/2018

Script name: NextD_Labs_GPCsites-2018-12-15-SX.sql
Execution order: 3.6*
Tables required: 
+FinalStatsFinal1_local;
+date_unshifts;
+PCORNET_CDM.LAB_RESULT_CM;
Table produced:
+NextD_Labs
Comments: Lab table (exclude pregancy)
Update date: 12/15/2018

Script name: NextD_Diagnosis_GPCsites-2018-12-15-SX.sql
Execution order: 4.1**
Tables required: 
+NextD_Encounter
Table produced:
+NextD_Diagnosis
Comments: Diagnosis table (exclude pregancy)
Update date: 12/15/2018

Script name: NextD_Procedures_GPCsites-2018-12-15-SX.sql
Execution order: 4.2**
Tables required: 
+FinalStatsFinal1_local;
+date_unshifts;
+PCORNET_CDM.ENCOUNTER;
+PCORNET_CDM.PROCEDURES;
Table produced:
+NextD_Procedure
Comments: Procedure table
Update date: 12/15/2018

Script name: NextD_Provider_GPCsites-2018-12-17-SX.sql
Execution order: 5
Tables required: 
+PCORNET_CDM.PROVIDER
Table produced:
+NextD_Provider
Comments: Provider table
Update date: 12/17/2018

Script name: NextD_DeathCause_GPCsites-2018-12-18-SX.sql
Execution order: 6
Tables required: 
+FinalStatFinal1_local;
+PCORNET_CDM.DEATH_CAUSE;
Table produced:
+NextD_Death_Cause
Comments: Death Cause Table
Update date: 12/18/2018

Script name: NextD_Epic_InsuranceCoveragePerPatient_pro-ENROLLMENTtable-2018-12-17-SX.sql
Execution order: 7
Tables required: 
+FinalStatsFinal1_local;
+date_unshifts;
+PCORNET_CDM.ENROLLEMENT
Table produced:
+NextD_Enrollement
Comments: This code is not actual code meant to be used by sites. This is rather prototype proposed to be adopted by sites according tro internal structure. The adopted code is expected to produce Enrollement table. 
Please, make sure you return table with insurance mapped into following categories:
1.Medicare
2.Medicaid
3.Other Governm  ent 
4.Department of corrections
5.Private health insurance
6.Blue cross/Blue shield
7.Managed care, unspecified
8.No payment
9.Miscellaneous/Other
9999.Unavailable/No payer specified/blank
NI.No information
UN.Unknown
OT.Other
Update date: 12/7/2018

Script name: NextD_SES_GPCsites-2018-12-17-AF.sql
Execution order: 8
Tables required: 
+FinalStatsFinal1_local;
+Local table with information on geocoding accuracy, and GEOIIDs
Table produced:
+NextD_SES
Comments: SES table
Update date: 12/17/2018
