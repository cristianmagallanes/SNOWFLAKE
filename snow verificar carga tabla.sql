CALL DB_ODIN.SH_STAGING.SP_COPY_TABLE_CSV_INIT_END( 'DB_ODIN', 'SH_STAGING', 'SP_COPY_TABLE_CSV_MKTV_MAESTRO_ACDS_MARKETING' , 'SRC_ALTITUDE8_MKTV_MAESTROS_ACDS', '@DB_ODIN.SH_STAGING.STG_AZ_IMPORT_AZURE_BLOB_MARKETING_ALTITUDE8/transform/mktv_Maestro ACDS_Marketing.csv',0);




--select table
select * from DB_ODIN.SH_STAGING.SRC_ALTITUDE8_MKTV_MAESTROS_ACDS;
;


--log
SELECT * FROM DB_METADATA.SH_MAIN.FACT_DWH_PROCESS_LOG
WHERE ID_LOAD_PROCESS  in (select ID_LOAD_PROCESS from DB_METADATA.SH_MAIN.D_DWH_LOAD_PROCESS
WHERE DS_LOAD_PROCESS_NAME ILIKE  '%ACD%');



--table history
SELECT table_name, last_load_time,*
  FROM information_schema.load_history
  WHERE schema_name=current_schema() AND
  table_name='SRC_ALTITUDE8_MKTV_MAESTROS_ACDS' AND
  last_load_time > '2024-09-16 06:45:56.494 -0700'
  order by row_parsed desc;

-- task 

select * from table (information_schema.TASK_HISTORY(TASK_NAME => 'TASK_EXEC_SP_COPY_TABLE_CSV_mktv_Maestro_ACDS_Marketing'));

