CREATE OR REPLACE PROCEDURE DB_WORKDAY.SH_STAGING.SP_EMAIL_HTML_DATAMART(
    VAR_QUERY VARCHAR,
    VAR_ASUNTO VARCHAR,
    VAR_TEXTO_HEADER VARCHAR,
    VAR_TEXTO_FOOTER VARCHAR,
    VAR_EMAILS VARCHAR,
    VAR_INTEGRATION VARCHAR DEFAULT 'NOTIF_EMAIL_WORKDAY_PURGE'
)
RETURNS VARCHAR(250)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS
$$
    // Función para escapar HTML
    function escapeHtml(text) {
        if (text === null || text === undefined) return '';
        return String(text)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    try {
        // Validar query
        if (!VAR_QUERY || VAR_QUERY.trim() === '') {
            throw 'ERROR: La query no puede estar vacía.';
        }

        // Ejecutar la consulta dinámica
        var sql_create = "CREATE OR REPLACE TEMP TABLE TMP_EMAIL_RESULT AS " + VAR_QUERY;
        snowflake.execute({sqlText: sql_create});

        // Obtener los nombres de las columnas
        var sql_desc = "DESCRIBE TABLE TMP_EMAIL_RESULT";
        var stmt_desc = snowflake.execute({sqlText: sql_desc});
        
        var columns = [];
        while (stmt_desc.next()) {
            columns.push(stmt_desc.getColumnValue(1));
        }

        // Obtener los datos
        var sql_data = "SELECT * FROM TMP_EMAIL_RESULT";
        var stmt_data = snowflake.execute({sqlText: sql_data});
        
        var rowCount = 0;
        var html_rows = '';
        while (stmt_data.next()) {
            rowCount++;
            html_rows += '<tr>';
            for (var j = 0; j < columns.length; j++) {
                var value = stmt_data.getColumnValue(j + 1);
                html_rows += '<td style="white-space:nowrap;">' + escapeHtml(value) + '</td>';
            }
            html_rows += '</tr>';
        }

        // Si no hay datos, notificar
        if (rowCount === 0) {
            return 'NO HAY DATOS PARA ENVIAR. La consulta no devolvió resultados.';
        }

        // Construir cabeceras HTML
        var html_header = '<html><body>' +
            '<div style="font-size:9pt; color:#000000;">' + VAR_TEXTO_HEADER.replace(/\n/g, '<br>') + '</div>' +
            '<br>' +
            '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse:collapse;">' +
            '<thead><tr style="background-color:#f2f2f2;">';
        
        for (var i = 0; i < columns.length; i++) {
            html_header += '<th style="white-space:nowrap;">' + escapeHtml(columns[i]) + '</th>';
        }
        html_header += '</tr></thead><tbody>';

        var html_footer = '</tbody></table>' +
            '<br>' +
            '<div style="font-size:9pt; color:#000000;">' + VAR_TEXTO_FOOTER.replace(/\n/g, '<br>') + '</div>' +
            '<div style="font-size:8pt; color:#888888;">Total registros: ' + rowCount + '</div>' +
            '</body></html>';

        var v_html_body = html_header + html_rows + html_footer;

        // Parsear lista de emails
        var emailList = VAR_EMAILS.split(',').map(function(e) { return e.trim(); }).filter(function(e) { return e !== ''; });
        var validEmails = [];
        var invalidEmails = [];
        
        // Intentar enviar a todos primero
        var sql_email_all = `CALL SYSTEM$SEND_EMAIL(
            '` + VAR_INTEGRATION + `',
            '` + VAR_EMAILS + `',
            '` + VAR_ASUNTO.replace(/'/g, "''") + `',
            '` + v_html_body.replace(/'/g, "''") + `',
            'text/html'
        )`;
        
        try {
            snowflake.execute({sqlText: sql_email_all});
            return 'REPORTE ENVIADO (' + rowCount + ' registros) A TODOS LOS DESTINATARIOS.';
        } catch (err) {
            // Si falla, intentar email por email
            for (var k = 0; k < emailList.length; k++) {
                var sql_email_single = `CALL SYSTEM$SEND_EMAIL(
                    '` + VAR_INTEGRATION + `',
                    '` + emailList[k] + `',
                    '` + VAR_ASUNTO.replace(/'/g, "''") + `',
                    '` + v_html_body.replace(/'/g, "''") + `',
                    'text/html'
                )`;
                try {
                    snowflake.execute({sqlText: sql_email_single});
                    validEmails.push(emailList[k]);
                } catch (e) {
                    invalidEmails.push(emailList[k]);
                }
            }
            
            if (validEmails.length === 0) {
                throw 'No se pudo enviar a ningún destinatario. Emails inválidos: ' + invalidEmails.join(', ');
            }
            
            return 'REPORTE ENVIADO (' + rowCount + ' registros) A: ' + validEmails.join(', ') + 
                   (invalidEmails.length > 0 ? '. EMAILS NO VALIDADOS: ' + invalidEmails.join(', ') : '');
        }
    } finally {
        // Limpiar tabla temporal
        try {
            snowflake.execute({sqlText: "DROP TABLE IF EXISTS TMP_EMAIL_RESULT"});
        } catch (e) {}
    }
$$;
