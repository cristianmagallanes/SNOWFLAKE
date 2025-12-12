
CREATE OR REPLACE PROCEDURE DB_ODS_BILLING.SH_STAGING.SP_COPY_BULK_STAGE_PARQUET_INIT_END(
"P_STAGE" VARCHAR(250), 
"P_PROJECT" VARCHAR(250), 
"P_DATABASE" VARCHAR(250), 
"P_SCHEMA" VARCHAR(250), 
"P_PATTERN" VARCHAR(250) DEFAULT '', 
"P_ON_ERROR" VARCHAR(250) DEFAULT 'SKIP FILE', 
"P_CREATE_TABLE" NUMBER(38,0) DEFAULT 0, 
"P_DROP_PROJECT" NUMBER(38,0) DEFAULT 0)
RETURNS VARCHAR(250)
LANGUAGE SQL
EXECUTE AS OWNER
AS '
DECLARE
    P_FOLDERS ARRAY;
    item STRING;
    i INT;
    stage_name STRING;
    P_TABLE_EXIST INT := 0;
   
BEGIN
    -- Determinar el nombre del stage
    IF (POSITION(''/'' IN P_STAGE) > 0) THEN
        stage_name := SPLIT_PART(P_STAGE, ''/'', -2);
    ELSE
        stage_name := P_STAGE;
    END IF; 

    CREATE OR REPLACE FILE FORMAT parquet_format TYPE = parquet;

    IF (P_DROP_PROJECT = 1) THEN
       EXECUTE IMMEDIATE 
            ''CALL SP_UTIL_DROP_PROJECT('''''' || P_PROJECT || '''''','''''' || P_DATABASE || '''''','''''' || P_SCHEMA || '''''');'';
    END IF;

    EXECUTE IMMEDIATE
        ''CREATE OR REPLACE TEMPORARY TABLE stage_contents AS
        SELECT METADATA$FILENAME AS filename
        FROM @'' || P_STAGE || ''/  
           (FILE_FORMAT => parquet_format, PATTERN => '''''' || P_PATTERN || '''''');'';

    CREATE OR REPLACE TEMPORARY TABLE directories AS
    SELECT DISTINCT SPLIT_PART(filename, ''/'', -2) AS directory
    FROM stage_contents;

    SELECT ARRAY_AGG(directory) INTO :P_FOLDERS
    FROM directories;

    -- Loop through the array
    FOR i IN 0 TO ARRAY_SIZE(P_FOLDERS) - 1 DO
        item := P_FOLDERS[i];

        -- Verificar si la tabla ya existe sin usar EXECUTE IMMEDIATE ni RESULT_SCAN
        SELECT COUNT(*)
        INTO P_TABLE_EXIST
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_CATALOG = :P_DATABASE
          AND TABLE_SCHEMA = :P_SCHEMA
          AND TABLE_NAME = ''SRC_'' || :P_PROJECT || ''_'' || UPPER(:item);

        -- Crear la tabla solo si no existe o si se especifica P_CREATE_TABLE
        IF (P_CREATE_TABLE = 1 OR P_TABLE_EXIST = 0) THEN
            EXECUTE IMMEDIATE
                ''CREATE OR REPLACE TABLE '' || P_DATABASE || ''.'' || P_SCHEMA || ''.SRC_'' || P_PROJECT || ''_'' || UPPER(item) || ''
                    USING TEMPLATE (
                        SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
                        FROM TABLE(
                            INFER_SCHEMA(
                                LOCATION => ''''@'' || stage_name || ''/'' || item || ''/ '''',
                                IGNORE_CASE => TRUE,
                                FILE_FORMAT => ''''parquet_format''''
                            )
                        )
                    )'';

            EXECUTE IMMEDIATE
                ''ALTER TABLE '' || P_DATABASE || ''.'' || P_SCHEMA || ''.SRC_'' || P_PROJECT || ''_'' || item || '' ADD COLUMN DH_LOAD_FILE VARCHAR'';

            EXECUTE IMMEDIATE
                ''ALTER TABLE '' || P_DATABASE || ''.'' || P_SCHEMA || ''.SRC_'' || P_PROJECT || ''_'' || item || '' ADD COLUMN DH_LOAD_DATE DATE'';
        END IF;

        EXECUTE IMMEDIATE
            ''COPY INTO '' || P_DATABASE || ''.'' || P_SCHEMA || ''.SRC_'' || P_PROJECT || ''_'' || item || ''
                FROM @'' || stage_name || ''/'' || item || ''/ 
                    FILE_FORMAT = (TYPE = PARQUET)
                    MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
                    INCLUDE_METADATA = (DH_LOAD_FILE = METADATA$FILENAME,
                                DH_LOAD_DATE = METADATA$START_SCAN_TIME)
                    PATTERN = '''''' || P_PATTERN || ''''''
                    ON_ERROR = '''''' || P_ON_ERROR || ''''''
                    PURGE = FALSE
                    FORCE = FALSE'';
    END FOR;

    RETURN 0;
    

END;
';

