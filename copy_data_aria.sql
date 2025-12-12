



DECLARE
    ARIA_FOLDERS ARRAY;
    item STRING;
    i INT;
    
BEGIN
    CREATE OR REPLACE FILE FORMAT my_parquet_format TYPE = parquet;
    

    CREATE OR REPLACE TEMPORARY TABLE stage_contents AS
    SELECT
        METADATA$FILENAME AS filename
    FROM '@AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/';
    
     
    CREATE OR REPLACE TEMPORARY TABLE directories AS
    SELECT DISTINCT
        replace(REGEXP_REPLACE(filename, '/[^/]*$', ''), 'BILLING_ARIA/','') AS directory
    FROM
        stage_contents;
    
   
    SELECT
        ARRAY_AGG(directory) into :ARIA_FOLDERS
    FROM
        directories;

  
    -- Loop through the array
    FOR i IN 0 to ARRAY_SIZE(ARIA_FOLDERS)-1 DO
        -- Get the current item
        item := ARIA_FOLDERS[i];
        
        -- Insert the item into the table
        EXECUTE IMMEDIATE
        'CREATE or replace TABLE SRC_ARIA_' || item || '
      USING TEMPLATE (
        SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
          FROM TABLE(
            INFER_SCHEMA(
              LOCATION=>''@AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/' || item || '/ '',
              FILE_FORMAT=>''my_parquet_format''
            )
          )
      )';
        
        EXECUTE IMMEDIATE
        'COPY INTO SRC_ARIA_' || item ||  ' 
        FROM @AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/' || item || 
        '/ FILE_FORMAT = (TYPE = PARQUET)  
            MATCH_BY_COLUMN_NAME= CASE_SENSITIVE 
            PATTERN = ''.*/.*/*.*[.]parquet''
            ON_ERROR =''SKIP_FILE'' 
            PURGE = FALSE 
            FORCE = TRUE' ; 

    END FOR;
END;