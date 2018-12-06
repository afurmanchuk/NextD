Changes made to files for current refresh:


SQLTable1_GPCsites_oracle-2018-01-10-AF.sql: 
-search for A1c lab
-RXNOM_CUI codes & regular expressions for medications
-added lines at very end of the code specifying desired format for this table extraction

NextD_Demographic_GPCsites.sql:
-Minor changes in namings of BDAY variables
-added pat_pref_Language_spoken
-added lines at very end of the code specifying desired format for this table extraction

NextD_Encounter_Provider_GPCsites.sql:
-added lines at very end of the code specifying desired format for this table extraction

NextD_Encounter_ProviderCustom_GPCsites:
-added lines at very end of the code specifying desired format for this table extraction


NPI2NPPESTaxonomy_GPCsites.sql:
-no changes

NextD_Date_Recovery.sql:
-No changes

NextD_Diagnoses_GPCsites.sql:
-added lines at very end of the code specifying desired format for this table extraction

NextD_Procedure_GPCsites.sql:
-added lines for PX_DATE variable
-added lines at very end of the code specifying desired format for this table extraction

NextD_Vital_GPCsites.sql:
-Minor correction to variable name. Misspeling.
-added lines at very end of the code specifying desired format for this table extraction

NextD_DispensedMed_GPCSites.sql:
-added to code PRESCRIBINGID variable
-added lines at very end of the code specifying desired format for this table extraction

NextD_Labs_GPCsites.sql:
-added to code lines for SPECIMEN_SOURCE & RESULT_QUAL variables
-added lines at very end of the code specifying desired format for this table extraction

NextD_PrescribedMed_GPCsites.sql:
-added to code line for RX_START_DATE & RX_END_DATE
-added lines at very end of the code specifying desired format for this table extraction


NextD_SES_GPCsites.sql:
-added variable LOCATOR,SCORE,DeGAUSS, USA_ADDRESS,MILITARY_ADDRESS,COLLEGE_ADDRESS,RRHC_ADDRESS,PMB_ADDRESS,POBOX_ADDRESS
-added lines at very end of the code specifying desired format for this table extraction

NextD_Provider_GPCsites_2018_12_06.sql:
-code is modified from the one earlier oracle version of ENCOUNTER_PROVIDER code kindly provided by KUMC.

NextD_Epic_InsuranceCoveragePerPatient_pro-ENROLLMENTtable.sql:
-This code is prototype for actual code sites will use. Sites are expected to adopt it to the internal features of their Epic system.

-Please, make sure you return table with insurance mapped into following categories:
1.Medicare
2.Medicaid
3.Other Government 
4.Department of corrections
5.Private health insurance
6.Blue cross/Blue shield
7.Managed care, unspecified
8.No payment
9.Miscellaneous/Other?
9999.Unavailable/No? payer specified/blank
NI.No information
UN.Unknown
OT.Other
