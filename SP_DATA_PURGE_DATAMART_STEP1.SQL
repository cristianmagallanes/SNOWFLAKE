

CREATE OR REPLACE PROCEDURE DB_WORKDAY.SH_STAGING.SP_DATA_PURGE_DATAMART_STEP1() 
RETURNS VARCHAR(250)
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$


DECLARE
    FILE_NAME STRING;



BEGIN

---------------- STEP 1 -----------------------


-- Truncate table
TRUNCATE TABLE DB_WORKDAY.SH_RAW.SRC_PURGE_ALLDATA;

-- load 5 files to RAW

COPY INTO DB_WORKDAY.SH_RAW.SRC_PURGE_ALLDATA 
FROM '@DB_WORKDAY.SH_RAW.STG_AWS_S3_WORKDAY/landing_Purge/' 
PATTERN = '.*landing_Purge/[^/]+\.csv$'
FILE_FORMAT = ( TYPE = CSV COMPRESSION = AUTO
FIELD_DELIMITER = ','
ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
SKIP_HEADER =2) 
ON_ERROR = 'ABORT_STATEMENT';


-- Fix email
UPDATE DB_WORKDAY.SH_RAW.SRC_PURGE_ALLDATA
SET Email = upper(Email)
WHERE Email IS NOT NULL;

--Data Purge LATAM


-- LATAM:
CREATE OR REPLACE TEMP TABLE temp_purga_latam AS 
WITH americaIni AS (
SELECT *,
CASE WHEN DATEDIFF(DAY, Added_Date, GETDATE()) > 365
THEN 0
ELSE 1
END AS AddedDateDifference,
CASE WHEN Rejection_Date IS NULL OR Rejection_Date = '' THEN 1
ELSE 0
END AS RejectionDateDifference
--INTO tempdb.guest.temp_latam_x
FROM DB_WORKDAY.SH_RAW.SRC_PURGE_ALLDATA 
WHERE COUNTRY IN ('Argentina','Chile', 'Peru', 'Brazil')
--.[Purge_Latam]
),
americaGroup AS (
SELECT *,
CASE WHEN Count_of_Active_Job_Applications > 0 OR AddedDateDifference > 0 OR RejectionDateDifference > 0
THEN 1
ELSE 0
END AS PurgeStatus
--INTO tempdb.guest.temp_Cluster_america
FROM americaIni
),
americaGroup_2 AS (
SELECT Email,
  SUM(PurgeStatus) AS TotalDateDifference,
  COUNT(*) AS Count_of_Active_Job_Applications,
  MAX(Candidate_ID) AS  Candidate_ID,
  MAX(Added_Date) AS Added_Date, 
  MAX(Country) AS Country, 
  MAX(Reference_ID) AS Reference_ID, 
  MAX(Masked_Job_Application_ID) AS Masked_Job_Application_ID, 
  MAX(Rejection_Date) AS Rejection_Date
--into tempdb.guest.temp_latam_p
FROM americaGroup
GROUP BY Email
--ORDER BY Email DESC
),
americaWithoutDiff AS (
SELECT Email
 ,TotalDateDifference
--INTO ##temp_Cluster_UK_aux2
FROM americaGroup_2
WHERE TotalDateDifference = 0
)
SELECT a.*
 ,b.Reference_ID
--INTO  tempdb.guest.temp_purga_latam
FROM americaWithoutDiff AS a
LEFT JOIN americaIni AS b ON a.Email= b.Email
ORDER BY a.Email DESC;



 ----Data Purge Europe


--Data Purge Europe NEW:
---- UK, Denmark & Germany, Added Date > 6 meses(180 dias), Rejection Date > 6 meses(180 días), ActiveApplications: non active
CREATE OR REPLACE TEMP TABLE temp_Cluster_UK_final AS 
WITH ukIni AS (
SELECT *,
CASE WHEN DATEDIFF(DAY, ADDED_DATE, GETDATE()) > 180
THEN 0
ELSE 1
END AS AddedDateDifference,
CASE WHEN REJECTION_DATE IS NULL OR REJECTION_DATE = '' THEN 1
WHEN DATEDIFF(DAY, REJECTION_DATE, GETDATE()) < 180 THEN 1
ELSE 0
END AS RejectionDateDifference
--INTO tempdb.guest.temp_Cluster_UK
FROM DB_WORKDAY.SH_RAW.SRC_PURGE_ALLDATA
WHERE Country IN ('UK', 'Denmark', 'Germany','GB','IE')
),
uk2 AS (
SELECT *,
CASE WHEN Count_of_Active_Job_Applications > 0 OR AddedDateDifference > 0 OR RejectionDateDifference > 0
THEN 1
ELSE 0
END AS PurgeStatus
--INTO tempdb.guest.temp_Cluster_UK2
FROM ukIni
),
ukGroup AS (
SELECT Email,
  SUM(PurgeStatus) AS TotalDateDifference,
  COUNT(*) AS Count_of_Active_Job_Applications,
  MAX(Candidate_ID) AS Candidate_ID,
  MAX(Added_Date) AS Added_Date, 
  MAX(Country) AS Country, 
  MAX(Reference_ID) AS Reference_ID, 
  MAX(Masked_Job_Application_ID) AS Masked_Job_Application_ID, 
  MAX(Rejection_Date) AS Rejection_Date
--into tempdb.guest.temp_Cluster_UK_aux1
FROM uk2
GROUP BY Email
--ORDER BY Email DESC
),
ukWithoutDiff AS (
SELECT Email
,TotalDateDifference
--INTO ##temp_Cluster_UK_aux2
FROM ukgroup
WHERE TotalDateDifference = 0
)
SELECT a.*
,b.Reference_ID
--INTO tempdb.guest.temp_Cluster_UK_final
FROM ukWithoutDiff AS a
LEFT JOIN ukIni AS b ON a.Email= b.Email
ORDER BY a.Email DESC;

-- EUROPE CLUSTER To purge:  France, Sweden: Added Date > 2 años, Rejection Date > 2 años, ActiveApplications: non active
CREATE OR REPLACE TEMP TABLE temp_Cluster_EUR_final AS 
WITH EuropeClusterIni AS (
SELECT *,
   CASE WHEN DATEDIFF(DAY, Added_Date, GETDATE()) > 730
       THEN 0
       ELSE 1
   END AS AddedDateDifference,
CASE WHEN Rejection_Date IS NULL OR Rejection_Date = '' THEN 1
WHEN DATEDIFF(DAY, Rejection_Date, GETDATE()) < 730 THEN 1
ELSE 0
END AS RejectionDateDifference
--INTO ##temp_Cluster_EUR
FROM DB_WORKDAY.SH_RAW.SRC_PURGE_ALLDATA
WHERE Country IN ('France', 'Sweden')
),
europe2 AS (
SELECT *,
CASE WHEN Count_of_Active_Job_Applications > 0 OR AddedDateDifference > 0 OR RejectionDateDifference > 0
THEN 1
ELSE 0
END AS PurgeStatus
--INTO ##temp_Cluster_EUR2
FROM EuropeClusterIni
),
europeGroup AS (
SELECT Email,
  SUM(PurgeStatus) AS TotalDateDifference,
  COUNT(*) AS Count_of_Active_Job_Applications,
  MAX(Candidate_ID) AS Candidate_ID,
  MAX(Added_Date) AS Added_Date, 
  MAX(Country) AS Country, 
  MAX(Reference_ID) AS Reference_ID, 
  MAX(Masked_Job_Application_ID) AS Masked_Job_Application_ID, 
  MAX(Rejection_Date) AS Rejection_Date
--into ##temp_Cluster_EUR_aux1
FROM europe2
GROUP BY Email
--ORDER BY Email DESC
),
europeWihoutDiff AS (
SELECT Email, TotalDateDifference
--into ##temp_Cluster_EUR_aux2
FROM europeGroup
WHERE TotalDateDifference = 0
)
SELECT a.*
,b.Reference_ID
--INTO tempdb.guest.temp_Cluster_EUR_final
FROM europeWihoutDiff AS a
LEFT JOIN EuropeClusterIni AS b ON a.Email= b.Email
ORDER BY a.Email DESC;

-- NORWAY To purge: Norway: Added Date > 4 meses(120 dias), Rejection Date > 4 meses(120 días), ActiveApplications: non active
CREATE OR REPLACE TEMP TABLE temp_NO_final AS 
WITH noIni AS (
SELECT *,
CASE WHEN DATEDIFF(DAY, Added_Date, GETDATE()) > 120
THEN 0
ELSE 1
END AS AddedDateDifference,
CASE WHEN Rejection_Date IS NULL OR Rejection_Date = '' THEN 1
WHEN DATEDIFF(DAY, Rejection_Date, GETDATE()) < 120 THEN 1
ELSE 0
END AS RejectionDateDifference
--INTO ##temp_NO
FROM DB_WORKDAY.SH_RAW.SRC_PURGE_ALLDATA
WHERE Country IN ('Norway')
),
no2 AS (
SELECT *,
CASE WHEN Count_of_Active_Job_Applications > 0 OR AddedDateDifference > 0 OR RejectionDateDifference > 0
THEN 1
ELSE 0
END AS PurgeStatus
--INTO ##temp_NO2
FROM noIni
),
noGroup AS (
SELECT Email,
  SUM(PurgeStatus) AS TotalDateDifference,
  COUNT(*) AS Count_of_Active_Job_Applications,
  MAX(Candidate_ID) AS Candidate_ID,
  MAX(Added_Date) AS Added_Date, 
  MAX(Country) AS Country, 
  MAX(Reference_ID) AS Reference_ID, 
  MAX(Masked_Job_Application_ID) AS Masked_Job_Application_ID, 
  MAX(Rejection_Date) AS Rejection_Date
--INTO ##temp_NO_aux1
FROM no2
GROUP BY Email
--ORDER BY Email DESC
),
noWihoutDiff AS (
SELECT Email
     ,TotalDateDifference
--INTO ##temp_NO_aux2
FROM noGroup
WHERE TotalDateDifference = 0
)
SELECT a.*
     ,b.Reference_ID
--INTO tempdb.guest.temp_NO_final
FROM noWihoutDiff AS a
LEFT JOIN noIni AS b ON a.Email= b.Email
ORDER BY a.Email DESC;

-- ITALY CLUSTER To purge: Italy, Potugal, Switzerland, Finland, Belgium: Added Date > 1 año(365 dias), Rejection Date > 1 año(365 días), ActiveApplications: non active
CREATE OR REPLACE TEMP TABLE temp_Cluster_IT_final AS 
WITH itClusterIni AS (
SELECT *,
CASE WHEN DATEDIFF(DAY, Added_Date, GETDATE()) > 365
THEN 0
ELSE 1
END AS AddedDateDifference,
CASE WHEN Rejection_Date IS NULL OR Rejection_Date = '' THEN 1
WHEN DATEDIFF(DAY, Rejection_Date, GETDATE()) < 365 THEN 1
ELSE 0
END AS RejectionDateDifference
--INTO ##temp_Cluster_IT
FROM DB_WORKDAY.SH_RAW.SRC_PURGE_ALLDATA
WHERE Country IN ('Italy', 'Switzerland', 'Finland', 'Belgium', 'Portugal')
),
itCluster2 AS (
SELECT *,
CASE WHEN Count_of_Active_Job_Applications > 0 OR AddedDateDifference > 0 OR RejectionDateDifference > 0
THEN 1
ELSE 0
END AS PurgeStatus
--INTO ##temp_Cluster_IT2
FROM itClusterIni
),
itClusterGroup AS (
SELECT Email,
  SUM(PurgeStatus) AS TotalDateDifference,
  COUNT(*) AS Count_of_Active_Job_Applications,
  MAX(Candidate_ID) AS Candidate_ID,
  MAX(Added_Date) AS Added_Date, 
  MAX(Country) AS Country, 
  MAX(Reference_ID) AS Reference_ID, 
  MAX(Masked_Job_Application_ID) AS Masked_Job_Application_ID, 
  MAX(Rejection_Date) AS Rejection_Date
--INTO ##temp_Cluster_IT_aux1
FROM itCluster2
GROUP BY Email
--ORDER BY Email DESC
),
itClusterWihoutDiff AS (
SELECT Email
,TotalDateDifference
--INTO ##temp_Cluster_IT_aux2
FROM itClusterGroup
WHERE TotalDateDifference = 0
)
SELECT a.*
,b.Reference_ID
--INTO tempdb.guest.temp_Cluster_IT_final
FROM itClusterWihoutDiff AS a
LEFT JOIN itClusterIni AS b ON a.Email= b.Email
ORDER BY a.Email DESC;

-- NETHERLANDS To purge: Netherlands: Added Date > 1 mes, Rejection Date > 1 mes(30 días), ActiveApplications: non active
CREATE OR REPLACE TEMP TABLE temp_NL_final AS 
WITH nlIni AS (
SELECT *,
CASE WHEN DATEDIFF(DAY, Added_Date, GETDATE()) > 30
THEN 0
ELSE 1
END AS AddedDateDifference,
CASE WHEN Rejection_Date IS NULL OR Rejection_Date = '' THEN 1
WHEN DATEDIFF(DAY, Rejection_Date, GETDATE()) < 30 THEN 1
ELSE 0
END AS RejectionDateDifference
--INTO ##temp_NL
FROM DB_WORKDAY.SH_RAW.SRC_PURGE_ALLDATA
WHERE Country IN ('Netherlands', 'NL')
),
nl2 AS (
SELECT *,
CASE WHEN Count_of_Active_Job_Applications > 0 OR AddedDateDifference > 0 OR RejectionDateDifference > 0
THEN 1
ELSE 0
END AS PurgeStatus
--INTO ##temp_NL2
FROM nlIni
),
nlGroup AS (
SELECT Email,
  SUM(PurgeStatus) AS TotalDateDifference,
  COUNT(*) AS Count_of_Active_Job_Applications,
  MAX(Candidate_ID) AS Candidate_ID,
  MAX(Added_Date) AS Added_Date, 
  MAX(Country) AS Country, 
  MAX(Reference_ID) AS Reference_ID, 
  MAX(Masked_Job_Application_ID) AS Masked_Job_Application_ID, 
  MAX(Rejection_Date) AS Rejection_Date
--INTO ##temp_NL_aux1
FROM nl2
GROUP BY Email
--ORDER BY Email DESC
),
nlWihoutDiff AS (
SELECT Email
,TotalDateDifference
--INTO ##temp_NL_aux2
FROM nlGroup
WHERE TotalDateDifference = 0
)
SELECT a.*
,b.Reference_ID
--INTO tempdb.guest.temp_NL_final
FROM nlWihoutDiff AS a
LEFT JOIN nlIni AS b ON a.Email= b.Email
ORDER BY a.Email DESC;

-- SPAIN CLUSTER To purge: Spain with Candidate Consent; Added Date > 1 año, Rejection Date > 1 año, ActiveApplications: non active and Candidate Consent = 0
CREATE OR REPLACE TEMP TABLE temp_Cluster_ESP_final AS 
WITH SpainClusterIni AS (
SELECT *,
   CASE WHEN DATEDIFF(DAY, Added_Date, GETDATE()) > 365
       THEN 0
       ELSE 1
   END AS AddedDateDifference,
CASE WHEN Rejection_Date IS NULL OR Rejection_Date = '' THEN 1
WHEN DATEDIFF(DAY, Rejection_Date, GETDATE()) < 365 THEN 1
ELSE 0
END AS RejectionDateDifference,
CASE WHEN Candidate_Consent IS NULL OR Candidate_Consent = ''
	THEN 0
	ELSE 1
   END AS CandidateConsent
--INTO ##temp_Cluster_ESP
FROM DB_WORKDAY.SH_RAW.SRC_PURGE_ALLDATA
WHERE Country IN ('Spain')
),
spain2 AS (
SELECT *,
CASE WHEN Count_of_Active_Job_Applications > 0 OR AddedDateDifference > 0 OR RejectionDateDifference > 0 OR CandidateConsent > 0
THEN 1
ELSE 0
END AS PurgeStatus
--INTO ##temp_Cluster_ESP2
FROM SpainClusterIni
),
spainGroup AS (
SELECT Email,
  SUM(PurgeStatus) AS TotalDateDifference,
  COUNT(*) AS Count_of_Active_Job_Applications,
  MAX(Candidate_ID) AS Candidate_ID,
  MAX(Added_Date) AS Added_Date, 
  MAX(Country) AS Country, 
  MAX(Reference_ID) AS Reference_ID, 
  MAX(Masked_Job_Application_ID) AS Masked_Job_Application_ID, 
  MAX(Rejection_Date) AS Rejection_Date,
  MAX(CandidateConsent) AS CandidateConsent
--into ##temp_Cluster_ESP_aux1
FROM spain2
GROUP BY Email
--ORDER BY Email DESC
),
spainWihoutDiff AS (
SELECT Email, TotalDateDifference
--into ##temp_Cluster_ESP_aux2
FROM spainGroup
WHERE TotalDateDifference = 0 
)
SELECT a.*
,b.Reference_ID
--INTO tempdb.guest.temp_Cluster_ESP_final
FROM spainWihoutDiff AS a
LEFT JOIN SpainClusterIni AS b ON a.Email= b.Email
ORDER BY a.Email DESC;


-- SPAIN CLUSTER To purge: Spain with Candidate Consent; Added Date > 2 años, Rejection Date > 2 años, ActiveApplications: non active and Candidate Consent = 1
CREATE OR REPLACE TEMP TABLE temp_Cluster_ESP_finalC AS 
WITH SpainClusterIniC AS (
SELECT *,
   CASE WHEN DATEDIFF(DAY, Added_Date, GETDATE()) > 730
       THEN 0
       ELSE 1
   END AS AddedDateDifference,
CASE WHEN Rejection_Date IS NULL OR Rejection_Date = '' THEN 1
WHEN DATEDIFF(DAY, Rejection_Date, GETDATE()) < 730 THEN 1
ELSE 0
END AS RejectionDateDifference,
CASE WHEN Candidate_Consent IS NULL OR Candidate_Consent = ''
	THEN 0
	ELSE 1
   END AS CandidateConsent
--INTO ##temp_Cluster_ESP_C
FROM DB_WORKDAY.SH_RAW.SRC_PURGE_ALLDATA
WHERE Country IN ('Spain')
),
spain2C AS (
SELECT *,
CASE WHEN Count_of_Active_Job_Applications > 0 OR AddedDateDifference > 0 OR RejectionDateDifference > 0 OR CandidateConsent = 0
THEN 1
ELSE 0
END AS PurgeStatus
--INTO ##temp_Cluster_ESP2C
FROM SpainClusterIniC
),
spainGroupC AS (
SELECT Email,
  SUM(PurgeStatus) AS TotalDateDifference,
  COUNT(*) AS Count_of_Active_Job_Applications,
  MAX(Candidate_ID) AS Candidate_ID,
  MAX(Added_Date) AS Added_Date, 
  MAX(Country) AS Country, 
  MAX(Reference_ID) AS Reference_ID, 
  MAX(Masked_Job_Application_ID) AS Masked_Job_Application_ID, 
  MAX(Rejection_Date) AS Rejection_Date,
  MAX(CandidateConsent) AS CandidateConsent
--into ##temp_Cluster_ESP_aux1C
FROM spain2C
GROUP BY Email
--ORDER BY Email DESC
),
spainWihoutDiffC AS (
SELECT Email, TotalDateDifference
--into ##temp_Cluster_ESP_aux2C
FROM spainGroupC
WHERE TotalDateDifference = 0 
)
SELECT a.*
,b.Reference_ID
--INTO tempdb.guest.temp_Cluster_ESP_finalC
FROM spainWihoutDiffC AS a
LEFT JOIN SpainClusterIniC AS b ON a.Email= b.Email
ORDER BY a.Email DESC;






 FILE_NAME := 'Purge_Output/Data_Purge_America_' || TO_VARCHAR(CURRENT_DATE(), 'YYYYMMDD') || '.csv';

-- Export America csv Out

EXECUTE IMMEDIATE
        'COPY INTO @DB_WORKDAY.SH_RAW.STG_AWS_S3_WORKDAY/' || :FILE_NAME || '
  FROM ( SELECT email, totaldatedifference, reference_id FROM temp_purga_latam
            ORDER BY Email DESC)
FILE_FORMAT = (TYPE = ''CSV'' FIELD_OPTIONALLY_ENCLOSED_BY = ''"'' COMPRESSION = ''NONE'')
HEADER = TRUE
SINGLE = TRUE
OVERWRITE = TRUE';


 FILE_NAME := 'Purge_Output/Data_Purge_Europe_' || TO_VARCHAR(CURRENT_DATE(), 'YYYYMMDD') || '.csv';


    EXECUTE IMMEDIATE
        'COPY INTO @DB_WORKDAY.SH_RAW.STG_AWS_S3_WORKDAY/' || :FILE_NAME || '
        FROM (
            SELECT * FROM (
                SELECT * FROM TEMP_CLUSTER_UK_FINAL
                UNION ALL
                SELECT * FROM TEMP_CLUSTER_EUR_FINAL
                UNION ALL
                SELECT * FROM TEMP_NO_FINAL
                UNION ALL
                SELECT * FROM TEMP_CLUSTER_IT_FINAL
                UNION ALL
                SELECT * FROM TEMP_NL_FINAL
                UNION ALL
                SELECT * FROM TEMP_CLUSTER_ESP_FINAL
                UNION ALL
                SELECT * FROM TEMP_CLUSTER_ESP_FINALC
            ) A
            ORDER BY EMAIL DESC
        )
        FILE_FORMAT = (TYPE = ''CSV'' FIELD_OPTIONALLY_ENCLOSED_BY = ''"'' COMPRESSION = ''NONE'')
        HEADER = TRUE
        SINGLE = TRUE
        OVERWRITE = TRUE';







/*cris:*/
---  ENVIAR CORREO

CALL SYSTEM$SEND_EMAIL(
    'NOTIF_EMAIL_WORKDAY_PURGE',
    'cristian.magallanes@external.securitasdirect.es',
    'Reporte Maestro Actualizado para Revision',
    'Hola 
     Se ha generado un fichero Maestro para su revision.
     Europe_csv_out.csv

     s3://sd-grp-workday-pre/Purge_Output/Data_Purge_Europe.csv.
    
     Por favor no responda a este coreo.
     Un saludo'
      );


CALL SYSTEM$SEND_EMAIL(
    'NOTIF_EMAIL_WORKDAY_PURGE',
    'cristian.magallanes@external.securitasdirect.es',
    'Reporte Maestro Actualizado para Revision',
    'Hola 
     Se ha generado un fichero Maestro para su revision.
     America_csv_out.csv

     s3://sd-grp-workday-pre/Purge_Output/Data_Purge_America.csv.
    
     Por favor no responda a este coreo.
     Un saludo'
      );



RETURN 'FINISHED';
    

EXCEPTION
    WHEN OTHER THEN
    
       
        RETURN 'ERROR ' || SQLERRM;

END;
$$


