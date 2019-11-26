/****************************************************************************************************************/
/* NextD Clinical Variable Extractions - Facility Table                                                         */
/****************************************************************************************************************/

/* Tables required in this code:                       
- 1. &&clarity.CLARITY_POS: raw clarity table with facility id, type and addresses   
- 2. &&clarity.ZC_STATE: decode state  
*/

/*global parameters:
 &&clarity: name of clarity schema (or equivalent local EMR schema)
 "KUMC specific" fields: may need to be adjusted with local EMR values
*/


drop table NEXTD_FACILITY purge;
create table NEXTD_FACILITY as
select distinct
       fac.POS_ID FACILITYID
	  ,fac.POS_TYPE FACILITY_TYPE 
      ,fac.POS_NAME FACILITY_NAME
      ,trim(both ' ' from (fac.ADDRESS_LINE_1 || ' ' || fac.ADDRESS_LINE_1)) FACILITY_ADDRESS
      ,fac.CITY FACILITY_CITY
      ,st.ABBR FACILITY_STATE
      ,fac.zip FACILITY_ZIP9
from clarity.CLARITY_POS fac
left join clarity.zc_state st on fac.state_c = st.state_c
;


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
----- 1. Download table NEXTD_FACILITY as .csv  file for final delivery                                 ------
---------------------------------------------------------------------------------------------------------------
