
create or replace view DB_WORKDAY.SH_STAGING.VW_WD_CONTROL_ERRORS(
	
    SCHEMA_NAME, 
    TABLE_NAME,
    --FAMIILY_NAME, 
	STATUS,
    START_LOAD,
    LAST_LOAD,
    DURATION,
	QTY_FILES,
	--IS_SUCCESS,
	--ROW_TOTAL,
	ROW_LOADED,
	ROW_UPDATED,
    ERROR_COUNT, 
	ERROR_MESSAGE,
    ID
	
) as 
/*
SELECT  
    SCHEMA_NAME ,
    table_name, 
    REGEXP_REPLACE(TABLE_NAME , 'SRC_', '')FAMIILY_NAME,
    REPLACE(status , 'LOADED', 'FINISH')status, 
    last_load_time last_load , 
    count(FILE_NAME) QTY_FILES ,  
    --IFF(ERROR_COUNT = 0 AND STATUS = 'LOADED', TRUE, FALSE) IS_SUCCESS, 
    --SUM(row_parsed) ROW_TOTAL , 
    SUM(row_count) ROW_LOADED, 
    0 ROW_UPDATED, 
    SUM(row_parsed - row_count) ERROR_COUNT, 
    LEFT(COALESCE(first_error_message,''),100) error_message
  FROM information_schema.load_history
  WHERE schema_name='SH_RAW'
  AND table_name ilike 'SRC_%'
GROUP BY ALL
--order by last_load_time

UNION

*/


SELECT 
'RAW' ds_source_object_schema, 
ds_target_table_name table_name, 
--REGEXP_REPLACE(ds_target_table_name , 'SRC_', '')FAMIILY_NAME,
ds_status, 
DT_START_TIME start_load,
DT_END_TIME last_load, 
DATEDIFF(SECONDS,  DT_START_TIME, DT_END_TIME) duration,
0 QTY_FILES,
NVL(QT_INSERTED ,0) ROW_LOADED, 
NVL(QT_UPDATED ,0) ROW_UPDATED, 
0 ERROR_COUNT, 
LEFT(COALESCE(DS_MESSAGE, ''),500) error_message    ,
ID
from DB_WORKDAY.SH_RAW.AUX_CONTROL_LOAD_INFO
--where ds_target_table_name ILIKE  'SRC_%' 
--AND ds_status <>  'STARTED'

UNION


SELECT 
'STAGING'ds_source_object_schema, 
ds_target_table_name table_name, 
--REGEXP_REPLACE(ds_target_table_name , 'FACT_', '')FAMIILY_NAME,
ds_status, 
DT_START_TIME start_load,
DT_END_TIME last_load, 
DATEDIFF(SECONDS,  DT_START_TIME, DT_END_TIME) duration,
0 QTY_FILES,
NVL(QT_INSERTED ,0) ROW_LOADED, 
NVL(QT_UPDATED ,0) ROW_UPDATED, 
0 ERROR_COUNT, 
LEFT(COALESCE(DS_MESSAGE, ''),500) error_message,
ID
from DB_WORKDAY.SH_STAGING.AUX_CONTROL_LOAD_INFO
--where ds_target_table_name ILIKE  'FACT_%' 
--AND ds_status <>  'STARTED'
--ORDER BY dt_start_time::DATE, ds_source_object_schema, ds_target_table_name 

UNION

/*
SELECT 
ds_source_object_schema, 
ds_target_table_name table_name, 
--REGEXP_REPLACE(ds_target_table_name , 'DIM_', '')FAMIILY_NAME,
ds_status, 
DT_END_TIME last_load, 
DATEDIFF(SECONDS,  DT_START_TIME, DT_END_TIME) duration,
DT_START_TIME, DT_END_TIME,
0 QTY_FILES,
NVL(QT_INSERTED ,0) ROW_LOADED, 
NVL(QT_UPDATED ,0) ROW_UPDATED, 
0 ERROR_COUNT, 
LEFT(COALESCE(DS_MESSAGE, ''),100) error_message
from DB_WORKDAY.SH_MAIN.AUX_CONTROL_LOAD_INFO
where ds_target_table_name ILIKE  'DIM_%' 
--AND ds_status <>  'STARTED'
--ORDER BY dt_start_time::DATE, ds_source_object_schema, ds_target_table_name 

UNION
*/

SELECT 
'MAIN'ds_source_object_schema, 
ds_target_table_name table_name, 
--REGEXP_REPLACE(ds_target_table_name , 'WD_', '')FAMIILY_NAME,
ds_status, 
DT_START_TIME start_load,
DT_END_TIME last_load, 
DATEDIFF(SECONDS,  DT_START_TIME, DT_END_TIME) duration,
0 QTY_FILES,
NVL(QT_INSERTED ,0) ROW_LOADED, 
NVL(QT_UPDATED ,0) ROW_UPDATED, 
0 ERROR_COUNT, 
LEFT(COALESCE(DS_MESSAGE, ''),500) error_message,
ID
from DB_WORKDAY.SH_MAIN.AUX_CONTROL_LOAD_INFO
--where ds_target_table_name ILIKE  'WD_%' 
--AND ds_status <>  'STARTED'


UNION


SELECT 
'OUTPUT' ds_source_object_schema, 
ds_target_table_name table_name, 
--REGEXP_REPLACE(ds_target_table_name , 'SP_EXPORT_', '')FAMIILY_NAME,
ds_status, 
DT_START_TIME start_load,
DT_END_TIME last_load, 
DATEDIFF(SECONDS,  DT_START_TIME, DT_END_TIME) duration,
0 QTY_FILES,
NVL(QT_INSERTED ,0) ROW_LOADED, 
NVL(QT_UPDATED ,0) ROW_UPDATED, 
0 ERROR_COUNT, 
LEFT(COALESCE(DS_MESSAGE, ''),500) error_message,
ID
from DB_WORKDAY.SH_OUTPUT.AUX_CONTROL_LOAD_INFO
--where ds_target_table_name ILIKE  'SP_EXPORT_%' 
--AND ds_status <>  'STARTED'

;