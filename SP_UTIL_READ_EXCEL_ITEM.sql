CREATE OR REPLACE PROCEDURE DB_ODIN.SH_STAGING.SP_UTIL_READ_EXCEL_ITEM("SOURCE_STAGE" VARCHAR(16777216), "TARGET_STAGE" VARCHAR(16777216), "FILE_ITEM" VARCHAR(16777216), "F_ASCII" NUMBER(38,0) DEFAULT 0)
RETURNS VARIANT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('snowflake-snowpark-python','pandas','openpyxl')
HANDLER = 'main'
EXECUTE AS OWNER
AS ' 
from snowflake.snowpark.files import SnowflakeFile 
from openpyxl import load_workbook 
import pandas as pd 
import os

def main(session, SOURCE_STAGE, TARGET_STAGE, FILE_ITEM, F_ASCII ):

    def get_scoped_file_url( SOURCE_STAGE, FILE_ITEM):
        sql_command = f"SELECT build_scoped_file_url(''{SOURCE_STAGE}'', ''{FILE_ITEM}'')"
        result = session.sql(sql_command).collect()
        return str(result[0][0])
        
    def skip_to_ascii(text):
        """Convierte caracteres especiales a ASCII."""
        if isinstance(text, str):  # Verificar que el tipo es str
            return text.encode(''ascii'', ''ignore'').decode(''ascii'')  # Convertir a ASCII, ignorando caracteres no ASCII
        return text  # Devolver el valor original si no es una cadena
    def convert_to_ascii(text):
        """Convierte caracteres especiales a caracteres ASCII similares."""
        if isinstance(text, str):  # Verificar que el tipo es str
            # Diccionario de reemplazo para caracteres especiales
            replacements = {
                ''á'': ''a'', ''é'': ''e'', ''í'': ''i'', ''ó'': ''o'', ''ú'': ''u'',
                ''ñ'': ''n'', ''Á'': ''A'', ''É'': ''E'', ''Í'': ''I'', ''Ó'': ''O'', ''Ú'': ''U'', ''º'':'' '',  ''\\xa0'': '''', ''â€“'': ''-'',  ''–'': ''-''
            }
            # Reemplazar los caracteres especiales
            for special_char, replacement in replacements.items():
                text = text.replace(special_char, replacement)
            return text  # Devolver el texto modificado
        return text  # Devolver el valor original si no es una cadena

    

    # Get the scoped file URL    
    file_path = get_scoped_file_url( SOURCE_STAGE, FILE_ITEM)
        
    with SnowflakeFile.open(file_path, ''rb'') as f: 
        workbook = load_workbook(f,  data_only=True) 
        
    base_name =  FILE_ITEM
        
    for sheet_name in workbook.sheetnames: 
        sheet = workbook[sheet_name] 
            
        # Verificar si la hoja está oculta
        if sheet.sheet_state == ''hidden'':
            continue
            
        header_row = next(sheet.iter_rows(values_only=True)) 
        #columns = header_row[0:] 
        #data = [row for row in sheet.iter_rows(min_row=2, values_only=True)]
                        
        #data = [
        #    [str(cell).encode(''utf-8'', ''replace'').decode(''utf-8'') if cell is not None else None for cell in row]
        #    for row in sheet.iter_rows(min_row=2, values_only=True)
        #]
        if F_ASCII == 1:
            columns = [convert_to_ascii(col) for col in header_row]
            data = [
                [convert_to_ascii(cell) if cell is not None else None for cell in row]
                for row in sheet.iter_rows(min_row=2, values_only=True)
            ]
        else:
            columns = [str(col).encode(''utf-8'', ''replace'').decode(''utf-8'') for col in header_row]
            data = [row for row in sheet.iter_rows(min_row=2, values_only=True)]

            
        df = pd.DataFrame(data, columns=columns)
      
        # Crear el nombre del archivo CSV workbook_sheet
        csv_file_name = f"{base_name}_{sheet_name}.csv"
        csv_file_name = skip_to_ascii(csv_file_name)
        csv_file_name = csv_file_name.replace(".xlsx","").replace(".xls", "")
        csv_file_path = f"/tmp/{csv_file_name}"
    
        
        # Guardar DataFrame en un archivo CSV temporal
        #df.to_csv(csv_file_path, index=False)
        df.to_csv(csv_file_path, index=False, encoding=''utf-8'')
              
        # Subir el archivo CSV al stage especificado
        session.file.put(csv_file_path, TARGET_STAGE, auto_compress=False)
            
        # Eliminar el archivo CSV temporal
        os.remove(csv_file_path)
    
    return "Procedure completed successfully" 
';
