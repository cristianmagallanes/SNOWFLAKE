

CREATE OR REPLACE PROCEDURE DB_WORKDAY.SH_STAGING.SP_DATA_PURGE_DATAMART_STEP2() 
RETURNS VARCHAR(250)
LANGUAGE SQL
EXECUTE AS OWNER
AS


BEGIN


------     STEP TWO  ------


-- Truncate tables 


TRUNCATE TABLE DB_WORKDAY.SH_STAGING.DATAPURGE_CANDIDATES;

TRUNCATE TABLE DB_WORKDAY.SH_STAGING.DATAPURGE_JOBAPPLICATION;


----- Candidates to purge in STG


INSERT INTO DB_WORKDAY.SH_STAGING.DataPurge_Candidates
WITH photoWD AS (
	SELECT Candidate_ID FROM DB_WORKDAY.SH_STAGING.WD_CANDIDATES_MASTER WHERE Candidate_ID <> ''
),
candidatesWD AS (
	/*Todos los candidatos que estan en STG pero no en WD de WD*/
	SELECT DISTINCT c.Candidate_ID candidateID_STG
	FROM photoWD t
	RIGHT JOIN DB_WORKDAY.SH_STAGING.WD_CANDIDATES c on t.Candidate_ID = c.candidate_ID
	WHERE t.Candidate_ID IS NULL 
),
candidatesDWH AS (
	/*Todos los candidatos que estan en STG pero no en WD del RPA*/
	SELECT DISTINCT t.Candidate_ID, dwh.IdCandidate candidateID_DWH, CandidateEmail
	FROM photoWD t
	RIGHT JOIN DB_WORKDAY.SH_MAIN.D_Candidate dwh ON t.Candidate_ID = dwh.IdCandidate
	WHERE t.Candidate_ID IS NULL 
			AND dwh.CandidateEmail IS NOT NULL
			AND dwh.CandidateEmail <> 'GDPR - Data purged'			
)

SELECT DISTINCT wd.candidateID_STG
    FROM candidatesWD wd 
UNION
SELECT DISTINCT candidateID_DWH
    FROM candidatesDWH dwh;



-- Apllications to Purge in STG


INSERT INTO  DB_WORKDAY.SH_STAGING.DataPurge_JobApplication
SELECT DISTINCT Job_Application_Reference_ID 
FROM (
  SELECT DISTINCT t.Job_Application_Reference_ID
  , 'Aplicacion a purgar' descripcion
  FROM (
    /*Todos las aplicaciones que estan en STG pero no en WD*/
    SELECT DISTINCT c.Candidate_ID candidateID_STG, c.Legal_Full_Name, c.Job_Application_Reference_ID, LEFT(c.Job_Requisition,CHARINDEX(' ',c.Job_Requisition)) JobRequisition_STG
    FROM (SELECT * FROM DB_WORKDAY.SH_STAGING.WD_CANDIDATES_MASTER WHERE Candidate_ID <> '') t
    RIGHT JOIN DB_WORKDAY.SH_STAGING.WD_CANDIDATES c on t.Candidate_ID = c.candidate_ID AND t.Job_Requisition_ID = LEFT(c.Job_Requisition,CHARINDEX(' ',c.Job_Requisition))  --AND t.Job_Application_ID = c.Job_Application_Reference_ID
    LEFT JOIN (SELECT * FROM DB_WORKDAY.SH_STAGING.WD_CANDIDATES_MASTER WHERE Candidate_ID <> '') t2 on c.Job_Application_Reference_ID = t2.Job_Application_ID
    WHERE t.Job_Application_ID IS NULL
    AND t2.Job_Application_ID IS NULL
    ) t
  --LEFT JOIN Purge_MasterFile o ON t.JobRequisition_STG = o.JobRequisition AND t.candidateID_STG = o.CandidateID
  UNION
  SELECT DISTINCT 
   t.Job_Application_Reference_ID
  , 'Aplicacion a purgar' descripcion
  FROM (
    /*Todos las aplicaciones que estan en STG pero no en WD*/
    SELECT DISTINCT c.Job_Application_Reference_ID
    FROM DB_WORKDAY.SH_STAGING.WD_CANDIDATES_MASTER t
    RIGHT JOIN DB_WORKDAY.SH_STAGING.WD_CANDIDATES c on t.Job_Application_ID = c.Job_Application_Reference_ID
    WHERE t.Job_Application_ID IS NULL 
    ) t
 ) x;



--REPORTS Pre-PURGE 


INSERT INTO  DB_WORKDAY.SH_STAGING.AUX_Cand_Pre_purge_CMOut 
SELECT DISTINCT --o.candidateID candidateID_Purged,
 t.candidateID_STG::VARCHAR candidateID_STG 
, t.Legal_Full_Name::VARCHAR Legal_Full_Name
, 'candidato a purgar' descripcion
,current_timestamp() LOAD_DATE
FROM (
  /*Todos los candidatos que estan en STG pero no en WD*/
  SELECT DISTINCT c.Candidate_ID candidateID_STG, c.Legal_Full_Name
  FROM (SELECT * FROM DB_WORKDAY.SH_STAGING.WD_CANDIDATES_MASTER WHERE Candidate_ID <> '') t
  RIGHT JOIN DB_WORKDAY.SH_STAGING.WD_CANDIDATES c on t.Candidate_ID = c.candidate_ID
  WHERE t.Candidate_ID IS NULL 
  ) t
  --LEFT JOIN Purge_MasterFile o ON t.candidateID_STG = o.candidateID 
  ;


INSERT INTO   DB_WORKDAY.SH_STAGING.AUX_JobApp_Pre_purge_CMOut 
SELECT DISTINCT Job_Application_Reference_ID, descripcion, current_timestamp() LOAD_DATE
FROM (
  SELECT DISTINCT t.Job_Application_Reference_ID
  , 'Aplicacion a purgar' descripcion
  FROM (
    /*Todos las aplicaciones que estan en STG pero no en WD*/
    SELECT DISTINCT c.Candidate_ID candidateID_STG, c.Legal_Full_Name, c.Job_Application_Reference_ID, LEFT(c.Job_Requisition,CHARINDEX(' ',c.Job_Requisition)) JobRequisition_STG
    FROM (SELECT * FROM DB_WORKDAY.SH_STAGING.WD_CANDIDATES_MASTER WHERE Candidate_ID <> '') t
    RIGHT JOIN DB_WORKDAY.SH_STAGING.WD_CANDIDATES c on t.Candidate_ID = c.candidate_ID AND t.Job_Requisition_ID = LEFT(c.Job_Requisition,CHARINDEX(' ',c.Job_Requisition)) 
    LEFT JOIN (SELECT * FROM DB_WORKDAY.SH_STAGING.WD_CANDIDATES_MASTER WHERE Candidate_ID <> '') t2 on c.Job_Application_Reference_ID = t2.Job_Application_ID
    WHERE t.Job_Application_ID IS NULL
    AND t2.Job_Application_ID IS NULL
    ) t
  --LEFT JOIN Purge_MasterFile o ON t.JobRequisition_STG = o.JobRequisition AND t.candidateID_STG = o.CandidateID
  UNION
  SELECT DISTINCT 
   t.Job_Application_Reference_ID
  , 'Aplicacion a purgar' descripcion
  FROM (
    /*Todos las aplicaciones que estan en STG pero no en WD*/
    SELECT DISTINCT c.Job_Application_Reference_ID
    FROM DB_WORKDAY.SH_STAGING.WD_CANDIDATES_MASTER t
    RIGHT JOIN DB_WORKDAY.SH_STAGING.WD_CANDIDATES c on t.Job_Application_ID = c.Job_Application_Reference_ID
    WHERE t.Job_Application_ID IS NULL 
    ) t
 ) x;


-- Creates Summary for Email
CREATE OR REPLACE TEMP TABLE AUX_TEMP_RESUME_TABLE_FOR_EMAIL AS
SELECT descripcion, total, fichero
FROM (

    /*Consultar de resumen de candidatos a purgar*/
    SELECT DISTINCT COUNT(*) total, 'Candidate to pruge' descripcion, 'Candidate_PrePurge' fichero
    FROM (  
    SELECT DISTINCT c.Candidate_ID candidateID_STG, c.Legal_Full_Name
    FROM (SELECT * FROM DB_WORKDAY.SH_STAGING.WD_CANDIDATES_MASTER WHERE Candidate_ID <> '') t
    RIGHT JOIN DB_WORKDAY.SH_STAGING.WD_CANDIDATES c on t.Candidate_ID = c.candidate_ID
    WHERE t.Candidate_ID IS NULL 
    ) t
    --LEFT JOIN Purge_MasterFile o ON t.candidateID_STG = o.candidateID
    UNION ALL
    /*Consulta de resumen de aplicaciones a purgar*/
    SELECT DISTINCT COUNT(*) total, 'JobApplication to purge' descripcion, 'JobApplications_PrePurge' fichero
    FROM (
    SELECT DISTINCT t.Job_Application_Reference_ID
    , 'Aplicacion a purgar' descripcion
    FROM (
        /*Todos las aplicaciones que estan en STG pero no en WD*/
        SELECT DISTINCT c.Candidate_ID candidateID_STG, c.Legal_Full_Name, c.Job_Application_Reference_ID, LEFT(c.Job_Requisition,CHARINDEX(' ',c.Job_Requisition)) JobRequisition_STG
        FROM (SELECT * FROM DB_WORKDAY.SH_STAGING.WD_CANDIDATES_MASTER WHERE Candidate_ID <> '') t
        RIGHT JOIN DB_WORKDAY.SH_STAGING.WD_CANDIDATES c on t.Candidate_ID = c.candidate_ID AND t.Job_Requisition_ID = LEFT(c.Job_Requisition,CHARINDEX(' ',c.Job_Requisition))  --AND t.Job_Application_ID = c.Job_Application_Reference_ID
        LEFT JOIN (SELECT * FROM DB_WORKDAY.SH_STAGING.WD_CANDIDATES_MASTER WHERE Candidate_ID <> '') t2 on c.Job_Application_Reference_ID = t2.Job_Application_ID
        WHERE t.Job_Application_ID IS NULL
        AND t2.Job_Application_ID IS NULL
        ) t
    --LEFT JOIN Purge_MasterFile o ON t.JobRequisition_STG = o.JobRequisition AND t.candidateID_STG = o.CandidateID
    UNION
    SELECT DISTINCT 
    t.Job_Application_Reference_ID
    , 'Aplicacion a purgar' descripcion
    FROM (
        /*Todos las aplicaciones que estan en STG pero no en WD*/
        SELECT DISTINCT c.Job_Application_Reference_ID
        FROM DB_WORKDAY.SH_STAGING.WD_CANDIDATES_MASTER t
        RIGHT JOIN DB_WORKDAY.SH_STAGING.WD_CANDIDATES c on t.Job_Application_ID = c.Job_Application_Reference_ID
        WHERE t.Job_Application_ID IS NULL 
        ) t
    ) x
) T;

/*cris:*/
--ENVIAR CORREO


CALL DB_WORKDAY.SH_STAGING.SP_EMAIL_HTML_PURGE_DATAMART(
    'SELECT DESCRIPCION, TOTAL, FICHERO FROM AUX_TEMP_RESUME_TABLE_FOR_EMAIL',
    'Hay documentos disponibles de la purga de datos para revision.',
    'Se ha generado un fichero maestro para su revision.',
    'Los ficheros para revision se encuentran  en el siguiente enlace \ns3://sd-grp-workday-pre/Purge_Output/\nPor favor no responda a este correo\nUn Saludo'
);




RETURN 'FINISHED';
    

EXCEPTION
    WHEN OTHER THEN
    
       
        RETURN 'ERROR ' || SQLERRM;

END;



