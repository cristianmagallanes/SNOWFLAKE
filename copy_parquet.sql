



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
        'COPY INTO SRC  _ARIA_' || item ||  ' 
        FROM @AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/' || item || 
        '/ FILE_FORMAT = (TYPE = PARQUET)  
            MATCH_BY_COLUMN_NAME= CASE_SENSITIVE 
            PATTERN = ''.*/.*/*.*[.]parquet''
            ON_ERROR =''SKIP_FILE'' 
            PURGE = FALSE 
            FORCE = TRUE' ; 

    END FOR;
END;

--TEST
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME ILIKE 'SRC_ARIA%'
ORDER BY TABLE_SCHEMA, TABLE_NAME;







show stages IN ACCOUNT;
CREATE OR REPLACE FILE FORMAT my_parquet_format TYPE = parquet;





CREATE TABLE SRC_ARIA_acct
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
      FROM TABLE(
        INFER_SCHEMA(
          LOCATION=>'@AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/acct/',
          FILE_FORMAT=>'my_parquet_format'
        )
      ));


COPY INTO SRC_ARIA_acct
FROM @AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/acct/
FILE_FORMAT = (TYPE = PARQUET)  
MATCH_BY_COLUMN_NAME= CASE_SENSITIVE
FORCE = TRUE
PURGE = FALSE
PATTERN = '.*/.*/*1714474154233.*[.]parquet'
;

select *
--delete  
FROM SRC_ARIA_acct

select "acct_no", count(*)
FROM SRC_ARIA_acct
group by "acct_no"
having count(*)> 1


select  * from SRC_ARIA_acct
where "acct_no" = 51453203

---------------------------------------------------------





CREATE TABLE SRC_ARIA_all_invoices
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
      FROM TABLE(
        INFER_SCHEMA(
          LOCATION=>'@AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/all_invoices',
          FILE_FORMAT=>'my_parquet_format'
        )
      ));


COPY INTO SRC_ARIA_all_invoices
FROM @AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/all_invoices
FILE_FORMAT = (TYPE = PARQUET)  
MATCH_BY_COLUMN_NAME= CASE_SENSITIVE  
FORCE = TRUE
PURGE = FALSE
--PATTERN = '.*/.*/*1714474154233.*[.]parquet'
;

select count(*)
--delete  
FROM SRC_ARIA_all_invoices

-------------------------------------


CREATE TABLE SRC_ARIA_all_invoice_details
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
      FROM TABLE(
        INFER_SCHEMA(
          LOCATION=>'@AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/all_invoice_details',
          FILE_FORMAT=>'my_parquet_format'
        )
      ));




COPY INTO SRC_ARIA_all_invoice_details
FROM @AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/all_invoice_details
FILE_FORMAT = (TYPE = PARQUET)  
MATCH_BY_COLUMN_NAME= CASE_SENSITIVE  
FORCE = TRUE
PURGE = FALSE
PATTERN = '.*/.*/*17144.*[.]parquet';

select *--count(*)
--delete  
FROM all_invoice_details





-------------------------------------


CREATE TABLE SRC_ARIA_all_payments
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
      FROM TABLE(
        INFER_SCHEMA(
          LOCATION=>'@AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/all_payments',
          FILE_FORMAT=>'my_parquet_format'
        )
      ));




COPY INTO SRC_ARIA_all_payments
FROM @AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/all_payments
FILE_FORMAT = (TYPE = PARQUET)  
MATCH_BY_COLUMN_NAME= CASE_SENSITIVE  
FORCE = TRUE
PURGE = FALSE
PATTERN = '.*/.*/*17144.*[.]parquet';






-------------------------------------


CREATE TABLE SRC_ARIA_orders
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
      FROM TABLE(
        INFER_SCHEMA(
          LOCATION=>'@AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/orders',
          FILE_FORMAT=>'my_parquet_format'
        )
      ));




COPY INTO SRC_ARIA_orders
FROM @AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/orders
FILE_FORMAT = (TYPE = PARQUET)  
MATCH_BY_COLUMN_NAME= CASE_SENSITIVE  
FORCE = TRUE
PURGE = FALSE
PATTERN = '.*/.*/*17144.*[.]parquet';





-------------------------------------


CREATE TABLE SRC_ARIA_acct_transaction
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
      FROM TABLE(
        INFER_SCHEMA(
          LOCATION=>'@AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/acct_transaction',
          FILE_FORMAT=>'my_parquet_format'
        )
      ));




COPY INTO SRC_ARIA_acct_transaction
FROM @AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/acct_transaction
FILE_FORMAT = (TYPE = PARQUET)  
MATCH_BY_COLUMN_NAME= CASE_SENSITIVE  
FORCE = TRUE
PURGE = FALSE
PATTERN = '.*/.*/*17144.*[.]parquet';

-------------------------




CREATE TABLE SRC_ARIA_order_items
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
      FROM TABLE(
        INFER_SCHEMA(
          LOCATION=>'@AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/order_items/',
          FILE_FORMAT=>'my_parquet_format'
        )
      ));


COPY INTO SRC_ARIA_order_items
FROM @AWS_STAGE_IMPORT_S3_SDMT_MASTER_PRE/BILLING_ARIA/order_items/
FILE_FORMAT = (TYPE = PARQUET)  
MATCH_BY_COLUMN_NAME= CASE_SENSITIVE
--FORCE = TRUE
PURGE = FALSE
PATTERN = '.*/.*/*1714474154233.*[.]parquet'
;