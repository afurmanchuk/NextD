/******************************************************************************************************************/
/* NextD Clinical Variable Extractions                                                                            */
/* - require: 1. FinalStatsTable1 local version where dates are not masked                                        */
/*            2. date_unshifts generated from FinalStatsTable1 extraction                                         */
/*                                                                                                                */
/* - We assume PCORNET_CDM is set appropriate for your site; for example, define PCORNET_CDM = PCORNET_CDM_C4R1   */
/******************************************************************************************************************/

/*Note: 'KUMC-specific' issue are marked as such*/

/*TODO: match new addresses with external resources, when MPC geocoding file is out-of-date*/

/****************************************************************************************/
/************************Table 11 - Socio-Economics Status (SES)*************************/
/****************************************************************************************/

create table CLARITY_ID as
with i2b2_pat_num as (
select ds.PATID
      ,ds.PATIENT_IDE
      ,pmap.PATIENT_NUM 
from date_unshifts ds
left join /*provide patient_mapping table here - KUMC-specific*/ nightherondata.patient_mapping pmap
on ds.PATIENT_IDE = pmap.PATIENT_IDE
where pmap.patient_ide_source = 'SMS@kumed.com' /*EHR source - KUMC-specific*/
)
select i2b2.PATID
      ,pm.PATIENT_IDE PATIENT_EPIC
from i2b2_pat_num i2b2
left join /*provide patient_mapping table here - KUMC-specific*/ nightherondata.patient_mapping pmap
on i2b2.PATIENT_IDE = pmap.PATIENT_IDE
where pmap.patient_ide_source = 'Epic@kumed.com' /*EHR source - KUMC-specific*/


create table NEXTD2_SES as
-- get current patient address in in clarity, state is coded
with clarity_addr_state_c as (
select cid.*
      ,cpat.ADD_LINE_1
      ,cpat.ADD_LINE_2
      ,cpat.CITY
      ,cpat.STATE_C
      ,cpat.ZIP
	--USA address:
	,case when (patient_country in ('USA','United States of America','US')
				or
				cpat.STATE_C  in ('ALABAMA','ALASKA','ARIZONA','ARKANSAS','CALIFORNIA','COLORADO','CONNECTICUT','DELAWARE','DISTRICT OF COLUMBIA','FLORIDA','GEORGIA','HAWAII','IDAHO','ILLINOIS','INDIANA','IOWA','KANSAS','KENTUCKY','LOUISIANA','MAINE','MARYLAND','MASSACHUSETTS','MICHIGAN','MINNESOTA','MISSISSIPPI','MISSOURI','MONTANA','NEBRASKA','NEVADA','NEW HAMPSHIRE','NEW JERSEY','NEW MEXICO','NEW YORK','NORTH CAROLINA','NORTH DAKOTA','OHIO','OKLAHOMA','OREGON','PENNSYLVANIA','RHODE ISLAND','SOUTH CAROLINA','SOUTH DAKOTA','TENNESSEE','TEXAS','UTAH','VERMONT','VIRGINIA','WASHINGTON','WEST VIRGINIA','WISCONSIN','WYOMING',
								'AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY',
								'AMERICAN SAMOA','GUAM','NORTHERN MARIANA ISLANDS','PUERTO RICO','U.S. VIRGIN ISLANDS','VIRGIN ISLANDS','MINOR OUTLYING ISLANDS','BAJO NUEVO BANK','BAKER ISLAND','HOWLAND ISLAND','JARVIS ISLAND','JOHNSTON ATOLL','KINGMAN REEF','MIDWAY ISLANDS','NAVASSA ISLAND','PALMYRA ATOLL','SERRANILLA BANK','WAKE ISLAND'
								)
				or
				(cpat.STATE_C is NULL
						and
						(cpat.CITY like '%ALABAMA' or cpat.CITY like '%ALASKA' or cpat.CITY like '%ARIZONA' or cpat.CITY like '%ARKANSAS' or cpat.CITY like '%CALIFORNIA' or cpat.CITY like '%COLORADO' or cpat.CITY like '%CONNECTICUT' or cpat.CITY like '%DELAWARE' or cpat.CITY like '%DISTRICT OF COLUMBIA' or cpat.CITY like '%FLORIDA' or cpat.CITY like '%GEORGIA' or cpat.CITY like '%HAWAII' or cpat.CITY like '%IDAHO' or cpat.CITY like '%ILLINOIS' or cpat.CITY like '%INDIANA' or cpat.CITY like '%IOWA' or cpat.CITY like '%KANSAS' or cpat.CITY like '%KENTUCKY' or cpat.CITY like '%LOUISIANA' or cpat.CITY like '%MAINE' or cpat.CITY like '%MARYLAND' or cpat.CITY like '%MASSACHUSETTS' or cpat.CITY like '%MICHIGAN' or cpat.CITY like '%MINNESOTA' or cpat.CITY like '%MISSISSIPPI' or cpat.CITY like '%MISSOURI' or cpat.CITY like '%MONTANA' or cpat.CITY like '%NEBRASKA' or cpat.CITY like '%NEVADA' or cpat.CITY like '%NEW HAMPSHIRE' or cpat.CITY like '%NEW JERSEY' or cpat.CITY like '%NEW MEXICO' or cpat.CITY like '%NEW YORK' or cpat.CITY like '%NORTH CAROLINA' or cpat.CITY like '%NORTH DAKOTA' or cpat.CITY like '%OHIO' or cpat.CITY like '%OKLAHOMA' or cpat.CITY like '%OREGON' or cpat.CITY like '%PENNSYLVANIA' or cpat.CITY like '%RHODE ISLAND' or cpat.CITY like '%SOUTH CAROLINA' or cpat.CITY like '%SOUTH DAKOTA' or cpat.CITY like '%TENNESSEE' or cpat.CITY like '%TEXAS' or cpat.CITY like '%UTAH' or cpat.CITY like '%VERMONT' or cpat.CITY like '%VIRGINIA' or cpat.CITY like '%WASHINGTON' or cpat.CITY like '%WEST VIRGINIA' or cpat.CITY like '%WISCONSIN' or cpat.CITY like '%WYOMING' or cpat.CITY like '% AL' or cpat.CITY like '% AK' or cpat.CITY like '% AZ' or cpat.CITY like '% AR' or cpat.CITY like '% CA' or cpat.CITY like '% CO' or cpat.CITY like '% CT' or cpat.CITY like '% DE' or cpat.CITY like '% FL' or cpat.CITY like '% GA' or cpat.CITY like '% HI' or cpat.CITY like '% ID' or cpat.CITY like '% IL' or cpat.CITY like '% IN' or cpat.CITY like '% IA' or cpat.CITY like '% KS' or cpat.CITY like '% KY' or cpat.CITY like '% LA' or cpat.CITY like '% ME' or cpat.CITY like '% MD' or cpat.CITY like '% MA' or cpat.CITY like '% MI' or cpat.CITY like '% MN' or cpat.CITY like '% MS' or cpat.CITY like '% MO' or cpat.CITY like '% MT' or cpat.CITY like '% NE' or cpat.CITY like '% NV' or cpat.CITY like '% NH' or cpat.CITY like '% NJ' or cpat.CITY like '% NM' or cpat.CITY like '% NY' or cpat.CITY like '% NC' or cpat.CITY like '% ND' or cpat.CITY like '% OH' or cpat.CITY like '% OK' or cpat.CITY like '% OR' or cpat.CITY like '% PA' or cpat.CITY like '% RI' or cpat.CITY like '% SC' or cpat.CITY like '% SD' or cpat.CITY like '% TN' or cpat.CITY like '% TX' or cpat.CITY like '% UT' or cpat.CITY like '% VT' or cpat.CITY like '% VA' or cpat.CITY like '% WA' or cpat.CITY like '% WV' or cpat.CITY like '% WI' or cpat.CITY like '% WY' or cpat.CITY like '%AMERICAN SAMOA' or cpat.CITY like '%GUAM' or cpat.CITY like '%NORTHERN MARIANA ISLANDS' or cpat.CITY like '%PUERTO RICO' or cpat.CITY like '%U.S. VIRGIN ISLANDS' or cpat.CITY like '%VIRGIN ISLANDS' or cpat.CITY like '%MINOR OUTLYING ISLANDS' or cpat.CITY like '%BAJO NUEVO BANK' or cpat.CITY like '%BAKER ISLAND' or cpat.CITY like '%HOWLAND ISLAND' or cpat.CITY like '%JARVIS ISLAND' or cpat.CITY like '%JOHNSTON ATOLL' or cpat.CITY like '%KINGMAN REEF' or cpat.CITY like '%MIDWAY ISLANDS' or cpat.CITY like '%NAVASSA ISLAND' or cpat.CITY like '%PALMYRA ATOLL' or cpat.CITY like '%SERRANILLA BANK' or cpat.CITY like '%WAKE ISLAND'
						)
				)
				)
	then 1 else 0 end as USA_ADDRESS,
	--Military PO Box:
	case when (cpat.CITY like 'APO' or cpat.CITY  like 'FPO' or cpat.CITY  like 'DPO' or cpat.CITY  like '% APO %' or cpat.CITY  like '% FPO %' or cpat.CITY  like '% DPO %' or cpat.CITY  like '% APO' or cpat.CITY  like '% FPO' or cpat.CITY  like '% DPO' or cpat.CITY  like 'APO %' or cpat.CITY  like 'FPO %' or cpat.CITY  like '% DPO' or cpat.ADD_LINE_1  like 'APO' or cpat.ADD_LINE_1  like 'FPO' or cpat.ADD_LINE_1  like 'DPO' or cpat.ADD_LINE_2  like 'APO' or cpat.ADD_LINE_2  like 'FPO'  or cpat.ADD_LINE_2  like 'DPO' or cpat.ADD_LINE_1  like '% APO %' or cpat.ADD_LINE_1  like '% FPO %' or cpat.ADD_LINE_1  like '% DPO %' or cpat.ADD_LINE_2  like '% APO %' or cpat.ADD_LINE_2  like '% FPO %' or cpat.ADD_LINE_2  like '% DPO %' or cpat.ADD_LINE_1  like '% APO' or cpat.ADD_LINE_1  like '% FPO' or cpat.ADD_LINE_1  like '% DPO' or cpat.ADD_LINE_2  like '% APO' or cpat.ADD_LINE_2  like '% FPO' or cpat.ADD_LINE_2  like '% DPO' or cpat.ADD_LINE_1  like 'APO[ ,]%' or cpat.ADD_LINE_1  like 'FPO[ ,]%' or cpat.ADD_LINE_1  like 'DPO[ ,]%' or cpat.ADD_LINE_2  like 'APO[ ,]%' or cpat.ADD_LINE_2  like 'FPO[ ,]%' or cpat.ADD_LINE_2  like 'DPO[ ,]%' or cpat.ADD_LINE_1  like '%[ ,]APO[ ,]%' or cpat.ADD_LINE_1  like '%[ ,]FPO[ ,]%' or cpat.ADD_LINE_1  like '%[ ,]DPO[ ,]%' or cpat.ADD_LINE_2  like '%[ ,]APO[ ,]%' or cpat.ADD_LINE_2  like '%[ ,]FPO[ ,]%' or cpat.ADD_LINE_2  like '%[ ,]DPO[ ,]%' or cpat.ADD_LINE_1  like '%[ ,]APO[ ,]%' or cpat.ADD_LINE_1 like '%[ ,]FPO[ ,]%' or cpat.ADD_LINE_1 like '%[ ,]DPO[ ,]%' or cpat.ADD_LINE_2 like '%[ ,]APO[ ,]%' or cpat.ADD_LINE_2 like '%[ ,]FPO[ ,]%' or cpat.ADD_LINE_2  like '%[ ,]DPO[ ,]%' or cpat.ADD_LINE_1 like 'APOAA%' or cpat.ADD_LINE_1 like '%[ ,]APOAA%' or cpat.ADD_LINE_1 like 'APOAE%' or cpat.ADD_LINE_1 like '%[ ,]APOAE%' or cpat.ADD_LINE_1 like 'APOAP%' or cpat.ADD_LINE_1  like '%[ ,]APOAP%' or cpat.ADD_LINE_2  like 'APOAA%' or cpat.ADD_LINE_2  like '%[ ,]APOAA%' or cpat.ADD_LINE_2  like 'APOAE%' or cpat.ADD_LINE_2  like '%[ ,]APOAE%' or cpat.ADD_LINE_2  like 'APOAP%' or cpat.ADD_LINE_2  like '%[ ,]APOAP%' or cpat.ADD_LINE_1  like 'APOAA%' or cpat.ADD_LINE_1  like '%[ ,]APOAA%' or cpat.ADD_LINE_1  like 'APOAE%' or cpat.ADD_LINE_1  like '%[ ,]APOAE%' or cpat.ADD_LINE_1  like 'APOAP%' or cpat.ADD_LINE_1  like '%[ ,]APOAP%' or cpat.ADD_LINE_2  like 'APOAA%' or cpat.ADD_LINE_2  like '%[ ,]APOAA%' or cpat.ADD_LINE_2  like 'APOAE%' or cpat.ADD_LINE_2  like '%[ ,]APOAE%' or cpat.ADD_LINE_2  like 'APOAP%' or cpat.ADD_LINE_2  like '%[ ,]APOAP%' or cpat.ADD_LINE_1  like 'FPOAA%' or cpat.ADD_LINE_1  like '%[ ,]FPOAA%' or cpat.ADD_LINE_1  like 'FPOAE%' or cpat.ADD_LINE_1  like '%[ ,]FPOAE%' or cpat.ADD_LINE_1  like 'FPOAP%' or cpat.ADD_LINE_1  like '%[ ,]FPOAP%' or cpat.ADD_LINE_2  like 'FPOAA%' or cpat.ADD_LINE_2  like '%[ ,]FPOAA%' or cpat.ADD_LINE_2  like 'FPOAE%' or cpat.ADD_LINE_2  like '%[ ,]FPOAE%' or cpat.ADD_LINE_2  like 'FPOAP%' or cpat.ADD_LINE_2  like '%[ ,]FPOAP%' or cpat.ADD_LINE_1  like 'DPOAA%' or cpat.ADD_LINE_1  like '%[ ,]DPOAA%' or  cpat.ADD_LINE_1  like 'DPOAE%' or cpat.ADD_LINE_1  like '%[ ,]DPOAE%' or cpat.ADD_LINE_1  like 'DPOAP%' or cpat.ADD_LINE_1  like '%[ ,]DPOAP%' or cpat.ADD_LINE_2  like 'DPOAA%' or  cpat.ADD_LINE_2  like '%[ ,]DPOAA%' or cpat.ADD_LINE_2  like 'DPOAE%' or cpat.ADD_LINE_2  like '%[ ,]DPOAE%' or cpat.ADD_LINE_2  like 'DPOAP%' or cpat.ADD_LINE_2  like '%[ ,]DPOAP%'
			  )
	then 1 else 0 end as MILITARY_ADDRESS,
	--College/Campus PO Box office:
	case when (cpat.ADD_LINE_1  like '%CPO%' or cpat.ADD_LINE_2  like '%CPO%' or cpat.ADD_LINE_1  like '%C[. ]P[. ]O[. ]%' or cpat.ADD_LINE_2  like '%C[. ]P[. ]O[. ]%' or cpat.ADD_LINE_1  like 'CPO%' or cpat.ADD_LINE_2  like 'CPO%' or cpat.ADD_LINE_1  like 'C[. ]P[. ]O[. ]%' or cpat.ADD_LINE_2  like 'C[. ]P[. ]O[. ]%'
			  )
	then 1 else 0 end as COLLEGE_ADDRESS,
	--Rural Route & Hiyway contract Route Addresses:
	case when (     (UPPER(cpat.ADD_LINE_1)  like '%[ -]RR%' or UPPER(cpat.ADD_LINE_1)  like 'RR%' or UPPER(cpat.ADD_LINE_1)  like '%[ -]HC[ #]%' or UPPER(cpat.ADD_LINE_1)  like '%[ -]HC[0-9]%' or UPPER(cpat.ADD_LINE_1)  like 'HC[# ]%' or UPPER(cpat.ADD_LINE_1)  like 'HC[0-9]%'
							)
							and
							(UPPER(cpat.ADD_LINE_1)  like '%[ .,]BOX[ #]%' or UPPER(cpat.ADD_LINE_1)  like 'BOX%' or UPPER(cpat.ADD_LINE_1)  like '%[ .,]BOX[0-9]%' or UPPER(cpat.ADD_LINE_1)  like '%[ .,]BOX' or UPPER(cpat.ADD_LINE_1)  like '%[0-9]BOX'
							)
							and
							(UPPER(cpat.ADD_LINE_1) not like '%P[O,0]BOX %' and UPPER(cpat.ADD_LINE_1) not like '%P[O,0][., ]BOX%' and      UPPER(cpat.ADD_LINE_1) not like '%P[.,/] [O,0] BOX%' and UPPER(cpat.ADD_LINE_1) not like '%P[.,/ ][O,0][., ]BOX%' and UPPER(cpat.ADD_LINE_1) not like '%P[.,/ ][O,0][., ] BOX%' and UPPER(cpat.ADD_LINE_1) not like '%P[.,/] [O,0][.,] BOX%' and  UPPER(cpat.ADD_LINE_1) not like '%P[.,/] [O,0][.,] BOX%' and UPPER(cpat.ADD_LINE_1) not like '%UPS BOX%' and UPPER(cpat.ADD_LINE_1) not like '%UNIT%'
							)
					  )
			 or
			 (      (UPPER(cpat.ADD_LINE_2)  like '%[ -]RR%' or UPPER(cpat.ADD_LINE_2)  like 'RR%' or UPPER(cpat.ADD_LINE_2)  like '%[ -]HC[ #]%' or UPPER(cpat.ADD_LINE_2)  like '%[ -]HC[0-9]%' or UPPER(cpat.ADD_LINE_2)  like 'HC[# ]%' or UPPER(cpat.ADD_LINE_2)  like 'HC[0-9]%')
					and
					(UPPER(cpat.ADD_LINE_2)  like '%[ .,]BOX[ #]%' or UPPER(cpat.ADD_LINE_2)  like 'BOX%' or UPPER(cpat.ADD_LINE_2)  like '%[ .,]BOX[0-9]%' or UPPER(cpat.ADD_LINE_2)  like '%[ .,]BOX' or UPPER(cpat.ADD_LINE_2)  like '%[0-9]BOX')
					and
					(UPPER(cpat.ADD_LINE_2) not like '%P[O,0]BOX %' and UPPER(cpat.ADD_LINE_2) not like '%P[O,0][., ]BOX%' and      UPPER(cpat.ADD_LINE_2) not like '%P[.,/] [O,0] BOX%' and UPPER(cpat.ADD_LINE_2) not like '%P[.,/ ][O,0][., ]BOX%' and UPPER(cpat.ADD_LINE_2) not like '%P[.,/ ][O,0][., ] BOX%' and UPPER(cpat.ADD_LINE_2) not like '%P[.,/] [O,0][.,] BOX%' and  UPPER(cpat.ADD_LINE_2) not like '%P[.,/] [O,0][.,] BOX%' and UPPER(cpat.ADD_LINE_2) not like '%UPS BOX%' and UPPER(cpat.ADD_LINE_2) not like '%UNIT%')
			 )
			or
			 (      (UPPER(cpat.ADD_LINE_1)  like '%[ -]RR%' or UPPER(cpat.ADD_LINE_1)  like 'RR%' or UPPER(cpat.ADD_LINE_1)  like '%[ -]HC[ #]%' or UPPER(cpat.ADD_LINE_1)  like '%[ -]HC[0-9]%' or UPPER(cpat.ADD_LINE_1)  like 'HC[# ]%' or UPPER(cpat.ADD_LINE_1)  like 'HC[0-9]%')
					and
					(UPPER(cpat.ADD_LINE_2)  like '%[ .,]BOX[ #]%' or UPPER(cpat.ADD_LINE_2)  like 'BOX%' or UPPER(cpat.ADD_LINE_2)  like '%[ .,]BOX[0-9]%' or UPPER(cpat.ADD_LINE_2)  like '%[ .,]BOX' or UPPER(cpat.ADD_LINE_2)  like '%[0-9]BOX')
					and
					(UPPER(cpat.ADD_LINE_2) not like '%P[O,0]BOX %' and UPPER(cpat.ADD_LINE_2) not like '%P[O,0][., ]BOX%' and      UPPER(cpat.ADD_LINE_2) not like '%P[.,/] [O,0] BOX%' and UPPER(cpat.ADD_LINE_2) not like '%P[.,/ ][O,0][., ]BOX%' and UPPER(cpat.ADD_LINE_2) not like '%P[.,/ ][O,0][., ] BOX%' and UPPER(cpat.ADD_LINE_2) not like '%P[.,/] [O,0][.,] BOX%' and  UPPER(cpat.ADD_LINE_2) not like '%P[.,/] [O,0][.,] BOX%' and UPPER(cpat.ADD_LINE_2) not like '%UPS BOX%' and UPPER(cpat.ADD_LINE_1) not like '%UNIT%' and UPPER(cpat.ADD_LINE_2) not like '%UNIT%')
			 )
			 or
			 (      (UPPER(cpat.ADD_LINE_2)  like '%[ -]RR%' or UPPER(cpat.ADD_LINE_2)  like 'RR%' or UPPER(cpat.ADD_LINE_2)  like '%[ -]HC[ #]%' or UPPER(cpat.ADD_LINE_2)  like '%[ -]HC[0-9]%' or UPPER(cpat.ADD_LINE_2)  like 'HC[# ]%' or UPPER(cpat.ADD_LINE_2)  like 'HC[0-9]%')
					and
					(UPPER(cpat.ADD_LINE_1)  like '%[ .,]BOX[ #]%' or UPPER(cpat.ADD_LINE_1)  like 'BOX%' or UPPER(cpat.ADD_LINE_1)  like '%[ .,]BOX[0-9]%' or UPPER(cpat.ADD_LINE_1)  like '%[ .,]BOX' or UPPER(cpat.ADD_LINE_1)  like '%[0-9]BOX')
					and
					(UPPER(cpat.ADD_LINE_1) not like '%P[O,0]BOX %' and UPPER(cpat.ADD_LINE_1) not like '%P[O,0][., ]BOX%' and      UPPER(cpat.ADD_LINE_1) not like '%P[.,/] [O,0] BOX%' and UPPER(cpat.ADD_LINE_1) not like '%P[.,/ ][O,0][., ]BOX%' and UPPER(cpat.ADD_LINE_1) not like '%P[.,/ ][O,0][., ] BOX%' and UPPER(cpat.ADD_LINE_1) not like '%P[.,/] [O,0][.,] BOX%' and  UPPER(cpat.ADD_LINE_1) not like '%P[.,/] [O,0][.,] BOX%' and UPPER(cpat.ADD_LINE_1) not like '%UPS BOX%' and UPPER(cpat.ADD_LINE_1) not like '%UNIT%'  and UPPER(cpat.ADD_LINE_1) not like '%UNIT%')
			 )
	then 1 else 0 end as RRHC_ADDRESS,
	--Private mail box /private PO Box:
	case when (UPPER(cpat.ADD_LINE_1) like '%MAILBOX%' or UPPER(cpat.ADD_LINE_1) like '%MAIL BOX%' or UPPER(cpat.ADD_LINE_1) like 'PMB[0-9]%' or  UPPER(cpat.ADD_LINE_1) like 'PMB %' or UPPER(cpat.ADD_LINE_1) like '%[0-9]PMB' or UPPER(cpat.ADD_LINE_1)  like '%[0-9] PMB' or UPPER(cpat.ADD_LINE_1)  like 'PMB[-#]%' or UPPER(cpat.ADD_LINE_1)  like 'PMB' or UPPER(cpat.ADD_LINE_1)  like '% PMB %' or UPPER(cpat.ADD_LINE_1)  like '%[,/-]PMB[0-9]%' or UPPER(cpat.ADD_LINE_1)  like '%[,/-]PMB [0-9]%' or UPPER(cpat.ADD_LINE_1)  like '%[,/-]PMB' or UPPER(cpat.ADD_LINE_1)  like '% PMB[0-9]%' or UPPER(cpat.ADD_LINE_1)  like '%[,/] PMB[0-9]%' or UPPER(cpat.ADD_LINE_1)  like '%[,/] PMB [0-9]%' or UPPER(cpat.ADD_LINE_1)  like '% PMB' or UPPER(cpat.ADD_LINE_2)  like 'PMB[0-9]%' or UPPER(cpat.ADD_LINE_2)  like 'PMB %' or UPPER(cpat.ADD_LINE_2)  like '%[0-9]PMB' or UPPER(cpat.ADD_LINE_2)  like '%[0-9]PMB' or UPPER(cpat.ADD_LINE_2)  like 'PMB[-#]%' or UPPER(cpat.ADD_LINE_2)  like 'PMB' or UPPER(cpat.ADD_LINE_2)  like '% PMB %' or UPPER(cpat.ADD_LINE_2)  like '%[,/-]PMB[0-9]%' or UPPER(cpat.ADD_LINE_2)  like '%[,/-]PMB [0-9]%' or UPPER(cpat.ADD_LINE_2)  like '%[,/-]PMB' or UPPER(cpat.ADD_LINE_2)  like '% PMB[0-9]%' or UPPER(cpat.ADD_LINE_2)  like '%[,/] PMB[0-9]%' or  UPPER(cpat.ADD_LINE_2)  like '%[,/] PMB [0-9]%' or UPPER(cpat.ADD_LINE_2)  like '% PMB'
					  )
	then 1 else 0 end as PMB_ADDRESS,
	--USPS PO Box:
	case when (UPPER(cpat.ADD_LINE_1)  like '%P[O,0]BOX %' or UPPER(cpat.ADD_LINE_2)  like '%P[O,0]BOX %' or UPPER(cpat.ADD_LINE_1)  like '%P[O,0][., ]BOX%' or UPPER(cpat.ADD_LINE_2)  like '%P[O,0][., ]BOX%' or UPPER(cpat.ADD_LINE_1)  like '%P[.,/] [O,0] BOX%' or UPPER(cpat.ADD_LINE_2)  like '%P[.,/] [O,0] BOX%' or UPPER(cpat.ADD_LINE_1)  like '%P[.,/ ][O,0][., ]BOX%' or UPPER(cpat.ADD_LINE_2)  like '%P[.,/ ][O,0][., ]BOX%' or UPPER(cpat.ADD_LINE_1)  like '%P[.,/ ][O,0][., ] BOX%' or UPPER(cpat.ADD_LINE_2)  like '%P[.,/ ][O,0][., ] BOX%' or UPPER(cpat.ADD_LINE_1)  like '%P[.,/] [O,0][.,] BOX%' or UPPER(cpat.ADD_LINE_2)  like '%P[.,/] [O,0][.,] BOX%' or UPPER(cpat.ADD_LINE_1)  like '%P[.,/] [O,0][.,] BOX%' or UPPER(cpat.ADD_LINE_2)  like '%P[.,/] [O,0][.,] BOX%' or UPPER(cpat.ADD_LINE_1)  like '%UPS BOX%' or UPPER(cpat.ADD_LINE_2)  like '%UPS BOX%'
					  )
					  and
					  (UPPER(cpat.ADD_LINE_1) not like '% APT%' and UPPER(cpat.ADD_LINE_2) not like '% APT%' and UPPER(cpat.ADD_LINE_1) not like 'APT%' and UPPER(cpat.ADD_LINE_2) not like 'APT%'
					  )
					  and
					  (cpat.STATE_C  in ('ALABAMA','ALASKA','ARIZONA','ARKANSAS','CALIFORNIA','COLORADO','CONNECTICUT','DELAWARE','DISTRICT OF COLUMBIA','FLORIDA','GEORGIA','HAWAII','IDAHO','ILLINOIS','INDIANA','IOWA','KANSAS','KENTUCKY','LOUISIANA','MAINE','MARYLAND','MASSACHUSETTS','MICHIGAN','MINNESOTA','MISSISSIPPI','MISSOURI','MONTANA','NEBRASKA','NEVADA','NEW HAMPSHIRE','NEW JERSEY','NEW MEXICO','NEW YORK','NORTH CAROLINA','NORTH DAKOTA','OHIO','OKLAHOMA','OREGON','PENNSYLVANIA','RHODE ISLAND','SOUTH CAROLINA','SOUTH DAKOTA','TENNESSEE','TEXAS','UTAH','VERMONT','VIRGINIA','WASHINGTON','WEST VIRGINIA','WISCONSIN','WYOMING',
																	'AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY',
																	'AMERICAN SAMOA','GUAM','NORTHERN MARIANA ISLANDS','PUERTO RICO','U.S. VIRGIN ISLANDS','VIRGIN ISLANDS','MINOR OUTLYING ISLANDS','BAJO NUEVO BANK','BAKER ISLAND','HOWLAND ISLAND','JARVIS ISLAND','JOHNSTON ATOLL','KINGMAN REEF','MIDWAY ISLANDS','NAVASSA ISLAND','PALMYRA ATOLL','SERRANILLA BANK','WAKE ISLAND'
																	)
					  or
							(cpat.STATE_C is NULL
							and
							(cpat.CITY like '%ALABAMA' or cpat.CITY like '%ALASKA' or cpat.CITY like '%ARIZONA' or cpat.CITY like '%ARKANSAS' or cpat.CITY like '%CALIFORNIA' or cpat.CITY like '%COLORADO' or cpat.CITY like '%CONNECTICUT' or cpat.CITY like '%DELAWARE' or cpat.CITY like '%DISTRICT OF COLUMBIA' or cpat.CITY like '%FLORIDA' or cpat.CITY like '%GEORGIA' or cpat.CITY like '%HAWAII' or cpat.CITY like '%IDAHO' or cpat.CITY like '%ILLINOIS' or cpat.CITY like '%INDIANA' or cpat.CITY like '%IOWA' or cpat.CITY like '%KANSAS' or cpat.CITY like '%KENTUCKY' or cpat.CITY like '%LOUISIANA' or cpat.CITY like '%MAINE' or cpat.CITY like '%MARYLAND' or cpat.CITY like '%MASSACHUSETTS' or cpat.CITY like '%MICHIGAN' or cpat.CITY like '%MINNESOTA' or cpat.CITY like '%MISSISSIPPI' or cpat.CITY like '%MISSOURI' or cpat.CITY like '%MONTANA' or cpat.CITY like '%NEBRASKA' or cpat.CITY like '%NEVADA' or cpat.CITY like '%NEW HAMPSHIRE' or cpat.CITY like '%NEW JERSEY' or cpat.CITY like '%NEW MEXICO' or cpat.CITY like '%NEW YORK' or cpat.CITY like '%NORTH CAROLINA' or cpat.CITY like '%NORTH DAKOTA' or cpat.CITY like '%OHIO' or cpat.CITY like '%OKLAHOMA' or cpat.CITY like '%OREGON' or cpat.CITY like '%PENNSYLVANIA' or cpat.CITY like '%RHODE ISLAND' or cpat.CITY like '%SOUTH CAROLINA' or cpat.CITY like '%SOUTH DAKOTA' or cpat.CITY like '%TENNESSEE' or cpat.CITY like '%TEXAS' or cpat.CITY like '%UTAH' or cpat.CITY like '%VERMONT' or cpat.CITY like '%VIRGINIA' or cpat.CITY like '%WASHINGTON' or cpat.CITY like '%WEST VIRGINIA' or cpat.CITY like '%WISCONSIN' or cpat.CITY like '%WYOMING' or
							cpat.CITY like '% AL' or cpat.CITY like '% AK' or cpat.CITY like '% AZ' or cpat.CITY like '% AR' or cpat.CITY like '% CA' or cpat.CITY like '% CO' or cpat.CITY like '% CT' or cpat.CITY like '% DE' or cpat.CITY like '% FL' or cpat.CITY like '% GA' or cpat.CITY like '% HI' or cpat.CITY like '% ID' or cpat.CITY like '% IL' or cpat.CITY like '% IN' or cpat.CITY like '% IA' or cpat.CITY like '% KS' or cpat.CITY like '% KY' or cpat.CITY like '% LA' or cpat.CITY like '% ME' or cpat.CITY like '% MD' or cpat.CITY like '% MA' or cpat.CITY like '% MI' or cpat.CITY like '% MN' or cpat.CITY like '% MS' or cpat.CITY like '% MO' or cpat.CITY like '% MT' or cpat.CITY like '% NE' or cpat.CITY like '% NV' or cpat.CITY like '% NH' or cpat.CITY like '% NJ' or cpat.CITY like '% NM' or cpat.CITY like '% NY' or cpat.CITY like '% NC' or cpat.CITY like '% ND' or cpat.CITY like '% OH' or cpat.CITY like '% OK' or cpat.CITY like '% OR' or cpat.CITY like '% PA' or cpat.CITY like '% RI' or cpat.CITY like '% SC' or cpat.CITY like '% SD' or cpat.CITY like '% TN' or cpat.CITY like '% TX' or cpat.CITY like '% UT' or cpat.CITY like '% VT' or cpat.CITY like '% VA' or cpat.CITY like '% WA' or cpat.CITY like '% WV' or cpat.CITY like '% WI' or cpat.CITY like '% WY' or
							cpat.CITY like '%AMERICAN SAMOA' or cpat.CITY like '%GUAM' or cpat.CITY like '%NORTHERN MARIANA ISLANDS' or cpat.CITY like '%PUERTO RICO' or cpat.CITY like '%U.S. VIRGIN ISLANDS' or cpat.CITY like '%VIRGIN ISLANDS' or cpat.CITY like '%MINOR OUTLYING ISLANDS' or cpat.CITY like '%BAJO NUEVO BANK' or cpat.CITY like '%BAKER ISLAND' or cpat.CITY like '%HOWLAND ISLAND' or cpat.CITY like '%JARVIS ISLAND' or cpat.CITY like '%JOHNSTON ATOLL' or cpat.CITY like '%KINGMAN REEF' or cpat.CITY like '%MIDWAY ISLANDS' or cpat.CITY like '%NAVASSA ISLAND' or cpat.CITY like '%PALMYRA ATOLL' or cpat.CITY like '%SERRANILLA BANK' or cpat.CITY like '%WAKE ISLAND'
							)
						)
					  )
					  and
		   --Military po box:
					  (cpat.CITY not like 'APO' and cpat.CITY not like 'FPO' and cpat.CITY not like 'DPO' and cpat.CITY not like '% APO %' and cpat.CITY not like '% FPO %' and cpat.CITY not like '% DPO %' and cpat.CITY not like '% APO' and cpat.CITY not like '% FPO' and cpat.CITY not like '% DPO' and cpat.CITY not like 'APO %' and cpat.CITY not like 'FPO %' and cpat.CITY not like '% DPO' and cpat.ADD_LINE_1 not like 'APO' and cpat.ADD_LINE_1 not like 'FPO' and cpat.ADD_LINE_1 not like 'DPO' and cpat.ADD_LINE_2 not like 'APO' and cpat.ADD_LINE_2 not like 'FPO'  and cpat.ADD_LINE_2 not like 'DPO' and cpat.ADD_LINE_1 not like '% APO %' and cpat.ADD_LINE_1 not like '% FPO %' and cpat.ADD_LINE_1 not like '% DPO %' and cpat.ADD_LINE_2 not like '% APO %' and cpat.ADD_LINE_2 not like '% FPO %' and cpat.ADD_LINE_2 not like '% DPO %' and cpat.ADD_LINE_1 not like '% APO' and cpat.ADD_LINE_1 not like '% FPO' and cpat.ADD_LINE_1 not like '% DPO' and cpat.ADD_LINE_2 not like '% APO' and cpat.ADD_LINE_2 not like '% FPO' and cpat.ADD_LINE_2 not like '% DPO' and cpat.ADD_LINE_1 not like 'APO[ ,]%' and cpat.ADD_LINE_1 not like 'FPO[ ,]%' and cpat.ADD_LINE_1 not like 'DPO[ ,]%' and cpat.ADD_LINE_2 not like 'APO[ ,]%' and cpat.ADD_LINE_2 not like 'FPO[ ,]%' and cpat.ADD_LINE_2 not like 'DPO[ ,]%' and cpat.ADD_LINE_1 not like '%[ ,]APO[ ,]%' and cpat.ADD_LINE_1 not like '%[ ,]FPO[ ,]%' and cpat.ADD_LINE_1 not like '%[ ,]DPO[ ,]%' and cpat.ADD_LINE_2 not like '%[ ,]APO[ ,]%' and cpat.ADD_LINE_2 not like '%[ ,]FPO[ ,]%' and cpat.ADD_LINE_2 not like '%[ ,]DPO[ ,]%' and cpat.ADD_LINE_1 not like '%[ ,]APO[ ,]%' and cpat.ADD_LINE_1 not like '%[ ,]FPO[ ,]%' and cpat.ADD_LINE_1 not like '%[ ,]DPO[ ,]%' and cpat.ADD_LINE_2 not like '%[ ,]APO[ ,]%' and cpat.ADD_LINE_2 not like '%[ ,]FPO[ ,]%' and cpat.ADD_LINE_2 not like '%[ ,]DPO[ ,]%' and cpat.ADD_LINE_1 not like 'APOAA%' and cpat.ADD_LINE_1 not like '%[ ,]APOAA%' and cpat.ADD_LINE_1 not like 'APOAE%' and cpat.ADD_LINE_1 not like '%[ ,]APOAE%' and cpat.ADD_LINE_1 not like 'APOAP%' and cpat.ADD_LINE_1 not like '%[ ,]APOAP%' and cpat.ADD_LINE_2 not like 'APOAA%' and cpat.ADD_LINE_2 not like '%[ ,]APOAA%' and cpat.ADD_LINE_2 not like 'APOAE%' and cpat.ADD_LINE_2 not like '%[ ,]APOAE%' and cpat.ADD_LINE_2 not like 'APOAP%' and cpat.ADD_LINE_2 not like '%[ ,]APOAP%' and cpat.ADD_LINE_1 not like 'APOAA%' and cpat.ADD_LINE_1 not like '%[ ,]APOAA%' and cpat.ADD_LINE_1 not like 'APOAE%' and cpat.ADD_LINE_1 not like '%[ ,]APOAE%' and cpat.ADD_LINE_1 not like 'APOAP%' and cpat.ADD_LINE_1 not like '%[ ,]APOAP%' and cpat.ADD_LINE_2 not like 'APOAA%' and cpat.ADD_LINE_2 not like '%[ ,]APOAA%' and cpat.ADD_LINE_2 not like 'APOAE%' and cpat.ADD_LINE_2 not like '%[ ,]APOAE%' and cpat.ADD_LINE_2 not like 'APOAP%' and cpat.ADD_LINE_2 not like '%[ ,]APOAP%' and cpat.ADD_LINE_1 not like 'FPOAA%' and cpat.ADD_LINE_1 not like '%[ ,]FPOAA%' and cpat.ADD_LINE_1 not like 'FPOAE%' and cpat.ADD_LINE_1 not like '%[ ,]FPOAE%' and cpat.ADD_LINE_1 not like 'FPOAP%' and cpat.ADD_LINE_1 not like '%[ ,]FPOAP%' and cpat.ADD_LINE_2 not like 'FPOAA%' and cpat.ADD_LINE_2 not like '%[ ,]FPOAA%' and cpat.ADD_LINE_2 not like 'FPOAE%' and cpat.ADD_LINE_2 not like '%[ ,]FPOAE%' and cpat.ADD_LINE_2 not like 'FPOAP%' and cpat.ADD_LINE_2 not like '%[ ,]FPOAP%' and cpat.ADD_LINE_1 not like 'DPOAA%' and cpat.ADD_LINE_1 not like '%[ ,]DPOAA%' and cpat.ADD_LINE_1 not like 'DPOAE%' and cpat.ADD_LINE_1 not like '%[ ,]DPOAE%' and cpat.ADD_LINE_1 not like 'DPOAP%' and cpat.ADD_LINE_1 not like '%[ ,]DPOAP%' and cpat.ADD_LINE_2 not like 'DPOAA%' and cpat.ADD_LINE_2 not like '%[ ,]DPOAA%' and cpat.ADD_LINE_2 not like 'DPOAE%' and cpat.ADD_LINE_2 not like '%[ ,]DPOAE%' and cpat.ADD_LINE_2 not like 'DPOAP%' and cpat.ADD_LINE_2 not like '%[ ,]DPOAP%'
					  )
					  and
			--College post office:
					  (cpat.ADD_LINE_1 not like '%CPO%' and cpat.ADD_LINE_2 not like '%CPO%' and cpat.ADD_LINE_1 not like '%C[. ]P[. ]O[. ]%' and cpat.ADD_LINE_2 not like '%C[. ]P[. ]O[. ]%' and cpat.ADD_LINE_1 not like 'CPO%' and cpat.ADD_LINE_2 not like 'CPO%' and cpat.ADD_LINE_1 not like 'C[. ]P[. ]O[. ]%' and cpat.ADD_LINE_2 not like 'C[. ]P[. ]O[. ]%'
					  )
					  and
					  (UPPER(cpat.ADD_LINE_1) not like 'PMB[0-9]%' and  UPPER(cpat.ADD_LINE_1) not like 'PMB %' and UPPER(cpat.ADD_LINE_1) not like '%[0-9]PMB' and UPPER(cpat.ADD_LINE_1) not like '%[0-9] PMB' and UPPER(cpat.ADD_LINE_1) not like 'PMB[-#]%' and UPPER(cpat.ADD_LINE_1) not like 'PMB' and UPPER(cpat.ADD_LINE_1) not like '% PMB %' and UPPER(cpat.ADD_LINE_1) not like '%[,/-]PMB[0-9]%' and UPPER(cpat.ADD_LINE_1) not like '%[,/-]PMB [0-9]%' and UPPER(cpat.ADD_LINE_1) not like '%[,/-]PMB' and UPPER(cpat.ADD_LINE_1) not like '% PMB[0-9]%' and UPPER(cpat.ADD_LINE_1) not like '%[,/] PMB[0-9]%' and UPPER(cpat.ADD_LINE_1) not like '%[,/] PMB [0-9]%' and UPPER(cpat.ADD_LINE_1) not like '% PMB' and UPPER(cpat.ADD_LINE_2) not like 'PMB[0-9]%' and UPPER(cpat.ADD_LINE_2) not like 'PMB %' and UPPER(cpat.ADD_LINE_2) not like '%[0-9]PMB' and UPPER(cpat.ADD_LINE_2) not like '%[0-9]PMB' and UPPER(cpat.ADD_LINE_2) not like 'PMB[-#]%' and UPPER(cpat.ADD_LINE_2) not like 'PMB' and UPPER(cpat.ADD_LINE_2) not like '% PMB %' and UPPER(cpat.ADD_LINE_2) not like '%[,/-]PMB[0-9]%' and UPPER(cpat.ADD_LINE_2) not like '%[,/-]PMB [0-9]%' and UPPER(cpat.ADD_LINE_2) not like '%[,/-]PMB' and UPPER(cpat.ADD_LINE_2) not like '% PMB[0-9]%' and UPPER(cpat.ADD_LINE_2) not like '%[,/] PMB[0-9]%' and  UPPER(cpat.ADD_LINE_2) not like '%[,/] PMB [0-9]%' and UPPER(cpat.ADD_LINE_2) not like '% PMB'
					  )
	then 1 else 0 end as POBOX_ADDRESS
from clarity_id cid
left join /*provide clarity patient table here*/ clarity.patient cpat
on cid.PATIENT_EPIC = cpat.PAT_ID
)
-- decode state
     ,clarity_addr as (
select sc.*, 
       zs.name STATE 
from clarity_addr_state_c sc
left join /*provide clarity zc_state table here*/ clarity.zc_state zs
    on sc.state_c = zs.state_c
)
-- in MPC geocoding file, heading zeros in a zip could be missing
   ,geocode_zip_patch as (
select distinct ADDRESS
      ,CITY
      ,STATE
      ,case when length(zip) < 5 then LPAD(zip,5,'0')
            else zip
       end as ZIP
      ,FIPSST
      ,FIPSCO
      ,TRACT_ID 
	  ,SCORE /* specify here name of variable in your systemdefining value for geocoding score */
	  ,LOCATOR /* specify here name of variable in your system defining value for Locator. See possible values for Locator at the end of thios code */
from mpc.geocoded_kumc /*MPC geocoding - KUMC-specific*/
)

select cadd.PATID, '|' as Pipe1
      ,(gk.fipsst || gk.fipsco || gk.tract_id) as GTRACT_ACS, '|' as Pipe2
	  ,cadd.USA_ADDRESS, '|' as Pipe3
	  ,cadd.MILITARY_ADDRESS, '|' as Pipe4
	  ,cadd.COLLEGE_ADDRESS, '|' as Pipe5
	  ,cadd.RRHC_ADDRESS, '|' as Pipe6
	  ,cadd.PMB_ADDRESS, '|' as Pipe7
	  ,cadd.POBOX_ADDRESS, '|' as Pipe8
	  ,gk.SCORE, '|' as Pipe9
	  ,LOCATOR, '|' as Pipe10
	  ,'place value here' as DeGAUSS /* place 1 if DeGAUSS was used for geocoding; or 0 if MPC was hired to perform geocoding*/
	  ,'ENDALONAEND'
from clarity_addr cadd
left join geocode_zip_patch gk
on (UPPER(cadd.add_line_1) || ' ' || UPPER(cadd.add_line_2)) = UPPER(gk.address) and
    UPPER(cadd.city) = UPPER(gk.city) and
    UPPER(cadd.state) = UPPER(gk.state)
;


------------------------------------------------
/* Save #NextD_SES as csv file. 
Use "|" symbol as field terminator and 
"ENDALONAEND" as row terminator. */ 
-------------------------------------------------


/*
Values and explicit notations for Locator variable:

AddrPoint—Point address, such as 783 Rolling Meadows Lane, that can be a roof-top address or a point near to the exact location. It is usually a precise location of the address.
StreetAddr—Street address, such as 320 Madison St, that represents an interpolated location along a street given the house number within an address range.
BldgName—Building name, such as CN Tower.
StreetName—Street name only, such as Orchard Road. The street name feature may be a feature of many street segments chained together based on the name. The geocoded location is usually placed on the middle of the street feature.
Admin—A high level administrative area, such as a State or Province.
DepAdmin—A secondary administrative area, such as a county within a State.
SubAdmin—A local administrative area, such as a city.
Locality—A local residential settlement, such as a colonia in Mexico or a block (chochomoku) in Japan.
Zone—An alternative name of a locality, or a subdivision within a locality, such as a sub-block (gaiku chiban) in Japan.
PostLoc—A city or locality representing a postal administrative area.
Postal—Basic postal code, such as 60610.
PostalExt—Full postal code including its extension, such as a ZIP+4 code—91765-4383.
Place—A place-name in a gazetteer.
POI—A point of interest or landmark.
Intersection—Intersection address that contains an intersection connector, such as Union St & Carson Rd.
Coordinates—Geographic coordinates, such as -84.392 32.722.
SpatialOperator—The location that contains an offset distance from the found address, for example, 30 yards South from 342 Main St.
MGRS—A Military Grid Reference System (MGRS) location, such as 46VFM5319397841.
NULL
Range—interpolated based on address ranges from street segments
Street—center of the matched street
Intersection—intersection of two streets
Zip—centroid of the matched zip code
City—centroid of the matched city
*/
