
CREATE OR REPLACE PROCEDURE DB_WORKDAY.SH_STAGING.SP_EMAIL_HTML_PURGE_DATAMART(
    VAR_QUERY VARCHAR,
    VAR_ASUNTO VARCHAR,
    VAR_TEXTO_HEADER VARCHAR,
    VAR_TEXTO_FOOTER VARCHAR
)
RETURNS VARCHAR(250)
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    V_HTML_BODY VARCHAR;
    V_SQL TEXT;
BEGIN
    -- Ejecutar la consulta dinámica y guardar el resultado en una tabla temporal
    V_SQL := 'CREATE OR REPLACE TEMP TABLE TMP_RESULT AS ' || VAR_QUERY;
    EXECUTE IMMEDIATE V_SQL;

    -- Construir el cuerpo del correo en HTML
    SELECT
        '<html><body>' ||
        '<div style="font-size:9pt; color:#000000;">' || REPLACE(:VAR_TEXTO_HEADER, CHR(10), '<br>') || '</div>' ||
        '<br>' ||
        '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse:collapse;">' ||
        '<thead><tr style="background-color:#f2f2f2;"><th>Descripcion</th><th>Total</th><th>Fichero</th></tr></thead>' ||
        '<tbody>' ||
        LISTAGG(
            CONCAT('<tr><td>', DESCRIPCION, '</td><td>', TOTAL, '</td><td>', FICHERO, '</td></tr>'),
            ''
        ) WITHIN GROUP (ORDER BY DESCRIPCION) ||
        '</tbody></table>' ||
        '<br>' ||
        '<div style="font-size:9pt; color:#000000;">' || REPLACE(:VAR_TEXTO_FOOTER, CHR(10), '<br>') || '</div>' ||
        '</body></html>'
    INTO :V_HTML_BODY
    FROM TMP_RESULT;

    -- Enviar el correo con formato HTML
    CALL SYSTEM$SEND_EMAIL(
        'NOTIF_EMAIL_WORKDAY_PURGE',
        'cristian.magallanes@external.securitasdirect.es',
        :VAR_ASUNTO,
        :V_HTML_BODY,
        'text/html'
    );

    RETURN 'REPORTE ENVIADO CON ÉXITO.';
END;
$$;