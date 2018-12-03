/************************************************/
/*NPI to NPPES Taxonomy to Provider_Category    */
/************************************************/

/*Note: 'KUMC specific' issue are marked as such*/

/*Step 1. Download and save two external files locally and rename them
     1.1 - download and unzip the file from https://www.dropbox.com/s/4pmfmi90bs7e8qa/NPI2ToxonomycodeCorssWalk_2018-01-01_AF.zip?dl=0
         - upload the NPI2ToxonomycodeCorssWalk_2018-01-01_AF.csv file as 'NPI2TAXONOMY'
         - rename the column 'Healthcare Provider Taxonomy Code_1' as 'TAXONOMY' due to oracle naming convention
         (15 mins)
     1.2 - download another file from https://www.dropbox.com/s/xjbekep4hudyld1/NPPES-taxonomy-code-counts-2017-07-07-bb.xlsx?dl=0
         - copy and save column A:G from the second tab 'taxonomy codes' as seperate .csv file, name it 'TAXONOMY_CAT' and upload it
         - rename the following columnes due to oracle naming convention 
              -- 'Taxonomy code' to 'TAXONOMY'
              -- 'individual taxonomy code' to 'INDIVIDUAL_TAXONOMY'
              -- 'Our Group Number' to 'GROUP_NUM'
              -- 'Our Proposed Classification' to 'PROVIDER_CATEGORY'

/*quick check on counts*/             
select count(distinct NPI) npi_cnt, /*5,440,880*/
       count(distinct TAXONOMY) taxonomy_cnt /*839*/
from NPI2TAXONOMY;

select count(distinct TAXONOMY) taxonomy_cnt, /*851*/
       count(distinct GROUPING) group_cnt /*29*/
from TAXONOMY_CAT;


/*Step 2. Combine 1.1 and 1.2 as NPI_TAXONOMY_PROVIDER_CAT for future use*/         
create index NPI_IDX on NPI2TAXONOMY(NPI);
create index NPI_TAXONOMY_IDX on NPI2TAXONOMY(TAXONOMY);

create table NPI_TAXONOMY_PROV_CAT as
select n2t.NPI, t2c.*
from NPI2TAXONOMY n2t
left join TAXONOMY_CAT t2c
on n2t.TAXONOMY = t2c.TAXONOMY
;/*6.149 seconds*/

/*drop the initial two tables to release memory*/
drop table NPI2TAXONOMY PURGE;
drop table TAXONOMY_CAT PURGE;

/*KUMC specific approach to correlating providers*/

/*adapt the NPI_TAXONOMY_PROVIDER_CAT mapping to local cases for better efficiency
 (there are many retired NPIs in the original file)*/
create table NPI_TAXONOMY_PROV_CAT_LOCAL as
with IDX_EPIC_NPI as (
select distinct IDX_PROVIDER_IDE NPI
from /*provide an intermediate provider mapping table from HERON ETL*/ HERON_ETL_1.prov_map /*KUMC specific*/
union
select distinct NPI
from /*provide source table clariry.CLARITY_SER_2 here*/ clarity.CLARITY_SER_2
)
    ,local_NPI as (
select distinct NPI
from IDX_EPIC_NPI
)
select nm.* from NPI_TAXONOMY_PROV_CAT nm
where exists (select 1 from local_NPI npi
              where npi.NPI = nm.NPI)
;

select count(distinct NPI) npi_cnt_local, /*33,838 -- KUMC specific*/
       count(distinct TAXONOMY) taxonomy_cnt_local /*342 -- KUMC specific*/
from NPI_TAXONOMY_PROV_CAT_LOCAL;

/*drop original mapping table if it takes too much space*/
drop table NPI_TAXONOMY_PROV_CAT PURGE;
