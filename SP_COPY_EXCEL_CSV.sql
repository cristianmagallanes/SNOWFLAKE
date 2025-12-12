
CREATE OR REPLACE PROCEDURE DB_ODIN.SH_STAGING.SP_COPY_EXCEL_CSV(
    SOURCE_STAGE STRING,
    TARGET_STAGE STRING,
    F_ASCII INT  DEFAULT 0
)
RETURNS INT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    item STRING;  -- Variable para almacenar el nombre del archivo actual
    sql_command STRING;  -- Variable para almacenar el comando SQL dinámico
    excel_cursor CURSOR FOR  -- Definir un cursor que seleccione los archivos Excel desde la tabla temporal
        SELECT fichero AS stage_contents
        FROM stage_contents;

BEGIN
    -- Crear el comando SQL dinámico para seleccionar los archivos Excel y llenar la tabla temporal
    sql_command := 'CREATE OR REPLACE TEMPORARY TABLE stage_contents AS
                    SELECT DISTINCT METADATA$FILENAME AS fichero
                    FROM ' || SOURCE_STAGE || '
                    WHERE UPPER(METADATA$FILENAME) LIKE ''%.XLSX%'' 
                       OR UPPER(METADATA$FILENAME) LIKE ''%.XLS%''';

    -- Ejecutar el comando SQL dinámico
    EXECUTE IMMEDIATE sql_command;

    -- Abrir el cursor y recorrer cada archivo Excel
    FOR record IN excel_cursor DO
        -- Obtener el nombre del archivo actual
        item := record.stage_contents;
        
        -- Ejecutar el procedimiento read_excel_file para procesar cada archivo
        EXECUTE IMMEDIATE 'CALL SP_UTIL_READ_EXCEL_ITEM(''' || SOURCE_STAGE || ''', ''' || TARGET_STAGE || ''', ''' || item || ''',' || F_ASCII || ')';
    END FOR;

    -- Retornar un mensaje de éxito
    RETURN 0;

END;
$$;
