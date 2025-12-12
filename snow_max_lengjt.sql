
SELECT Employee_ID, 
    TRIM(
        CASE WHEN LENGTH("Employee_ID") > 30 THEN 'Employee_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Full_Legal_Name") > 255 THEN 'Full_Legal_Name, ' ELSE '' END ||
        CASE WHEN LENGTH("Gender") > 30 THEN 'Gender, ' ELSE '' END ||
        CASE WHEN LENGTH("Worker_Type") > 30 THEN 'Worker_Type, ' ELSE '' END ||
        CASE WHEN LENGTH("Employee_Type") > 30 THEN 'Employee_Type, ' ELSE '' END ||
        CASE WHEN LENGTH("Contingent_Worker_Type") > 40 THEN 'Contingent_Worker_Type, ' ELSE '' END ||
        CASE WHEN LENGTH("Company_ID") > 20 THEN 'Company_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Company") > 255 THEN 'Company, ' ELSE '' END ||
        CASE WHEN LENGTH("Hire_Reason_ID") > 255 THEN 'Hire_Reason_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Hire_Reason") > 255 THEN 'Hire_Reason, ' ELSE '' END ||
        CASE WHEN LENGTH("Termination_Reason_ID") > 255 THEN 'Termination_Reason_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Termination_Reason") > 255 THEN 'Termination_Reason, ' ELSE '' END ||
        CASE WHEN LENGTH("Termination_Reason_Local_ID") > 255 THEN 'Termination_Reason_Local_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Termination_Reason_Local") > 255 THEN 'Termination_Reason_Local, ' ELSE '' END ||
        CASE WHEN LENGTH("Position_ID") > 20 THEN 'Position_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Position") > 255 THEN 'Position, ' ELSE '' END ||
        CASE WHEN LENGTH("Job_Profile") > 255 THEN 'Job_Profile, ' ELSE '' END ||
        CASE WHEN LENGTH("Management_Level_ID") > 30 THEN 'Management_Level_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Management_Level") > 255 THEN 'Management_Level, ' ELSE '' END ||
        CASE WHEN LENGTH("Job_Title") > 255 THEN 'Job_Title, ' ELSE '' END ||
        CASE WHEN LENGTH("Job_Classification_ID") > 30 THEN 'Job_Classification_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Job_Classification") > 255 THEN 'Job_Classification, ' ELSE '' END ||
        CASE WHEN LENGTH("Job_ClassificationAdditional_ID") > 255 THEN 'Job_ClassificationAdditional_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Job_Classification_Finance") > 255 THEN 'Job_Classification_Finance, ' ELSE '' END ||
        CASE WHEN LENGTH("Job_Classification_HR") > 255 THEN 'Job_Classification_HR, ' ELSE '' END ||
        CASE WHEN LENGTH("Change_Reason_ID") > 255 THEN 'Change_Reason_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Change_Reason") > 255 THEN 'Change_Reason, ' ELSE '' END ||
        CASE WHEN LENGTH("Collective_Agreement_Profesional_Position") > 100 THEN 'Collective_Agreement_Profesional_Position, ' ELSE '' END ||
        CASE WHEN LENGTH("Collective_Agreement_Professional_Category") > 100 THEN 'Collective_Agreement_Professional_Category, ' ELSE '' END ||
        CASE WHEN LENGTH("Collective_Agreement_Group") > 100 THEN 'Collective_Agreement_Group, ' ELSE '' END ||
        CASE WHEN LENGTH("Collective_Agreement_Level") > 100 THEN 'Collective_Agreement_Level, ' ELSE '' END ||
        CASE WHEN LENGTH("Cost_Type") > 100 THEN 'Cost_Type, ' ELSE '' END ||
        CASE WHEN LENGTH("Work_Shift") > 100 THEN 'Work_Shift, ' ELSE '' END ||
        CASE WHEN LENGTH("Legal_Guard") > 1 THEN 'Legal_Guard, ' ELSE '' END ||
        CASE WHEN LENGTH("Contract_Type_ID") > 100 THEN 'Contract_Type_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Contract_Type") > 100 THEN 'Contract_Type, ' ELSE '' END ||
        CASE WHEN LENGTH("Cost_Center_ID") > 20 THEN 'Cost_Center_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Cost_Center") > 255 THEN 'Cost_Center, ' ELSE '' END ||
        CASE WHEN LENGTH("Supervisory_Organization_ID") > 30 THEN 'Supervisory_Organization_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Supervisory_Organization") > 100 THEN 'Supervisory_Organization, ' ELSE '' END ||
        CASE WHEN LENGTH("Level_from_Top") > 30 THEN 'Level_from_Top, ' ELSE '' END ||
        CASE WHEN LENGTH("Level_04_FromTop_ID") > 20 THEN 'Level_04_FromTop_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Level_04_FromTop") > 255 THEN 'Level_04_FromTop, ' ELSE '' END ||
        CASE WHEN LENGTH("Level_05_FromTop_ID") > 20 THEN 'Level_05_FromTop_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Level_05_FromTop") > 255 THEN 'Level_05_FromTop, ' ELSE '' END ||
        CASE WHEN LENGTH("Level_06_FromTop_ID") > 20 THEN 'Level_06_FromTop_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Level_06_FromTop") > 255 THEN 'Level_06_FromTop, ' ELSE '' END ||
        CASE WHEN LENGTH("Level_07_FromTop_ID") > 20 THEN 'Level_07_FromTop_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Level_07_FromTop") > 255 THEN 'Level_07_FromTop, ' ELSE '' END ||
        CASE WHEN LENGTH("Level_08_FromTop_ID") > 20 THEN 'Level_08_FromTop_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Level_08_FromTop") > 255 THEN 'Level_08_FromTop, ' ELSE '' END ||
        CASE WHEN LENGTH("Level_09_FromTop_ID") > 20 THEN 'Level_09_FromTop_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Level_09_FromTop") > 255 THEN 'Level_09_FromTop, ' ELSE '' END ||
        CASE WHEN LENGTH("Level_10_FromTop_ID") > 20 THEN 'Level_10_FromTop_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Level_10_FromTop") > 255 THEN 'Level_10_FromTop, ' ELSE '' END ||
        CASE WHEN LENGTH("Job_Family_Group_ID") > 20 THEN 'Job_Family_Group_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Job_Family_Group") > 255 THEN 'Job_Family_Group, ' ELSE '' END ||
        CASE WHEN LENGTH("Job_Family_ID") > 20 THEN 'Job_Family_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Job_Family") > 255 THEN 'Job_Family, ' ELSE '' END ||
        CASE WHEN LENGTH("Location_ID") > 30 THEN 'Location_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Location") > 255 THEN 'Location, ' ELSE '' END ||
        CASE WHEN LENGTH("Manager_ID") > 20 THEN 'Manager_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Team_Leader_ID") > 20 THEN 'Team_Leader_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Supervisory_Organization_Has_Team_Leader") > 10 THEN 'Supervisory_Organization_Has_Team_Leader, ' ELSE '' END ||
        CASE WHEN LENGTH("International_Mobility_Type") > 50 THEN 'International_Mobility_Type, ' ELSE '' END ||
        CASE WHEN LENGTH("Source_Category") > 300 THEN 'Source_Category, ' ELSE '' END ||
        CASE WHEN LENGTH("Source") > 100 THEN 'Source, ' ELSE '' END ||
        CASE WHEN LENGTH("Sales_equipment_box") > 100 THEN 'Sales_equipment_box, ' ELSE '' END ||
        CASE WHEN LENGTH("TShirt_Size") > 10 THEN 'TShirt_Size, ' ELSE '' END ||
        CASE WHEN LENGTH("Email") > 100 THEN 'Email, ' ELSE '' END ||
        CASE WHEN LENGTH("Custom_Country_ISO_2") > 20 THEN 'Custom_Country_ISO_2, ' ELSE '' END ||
        CASE WHEN LENGTH("DirectManagerID") > 255 THEN 'DirectManagerID, ' ELSE '' END ||
        CASE WHEN LENGTH("Nationality") > 200 THEN 'Nationality, ' ELSE '' END ||
        CASE WHEN LENGTH("Disability") > 200 THEN 'Disability, ' ELSE '' END ||
        CASE WHEN LENGTH("Contracted_from_Competitor") > 200 THEN 'Contracted_from_Competitor, ' ELSE '' END ||
        CASE WHEN LENGTH("ZCF_Supplier_ID") > 200 THEN 'ZCF_Supplier_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("Contingent_Worker_Supplier") > 200 THEN 'Contingent_Worker_Supplier, ' ELSE '' END ||
        CASE WHEN LENGTH("Candidate_ID") > 36 THEN 'Candidate_ID, ' ELSE '' END ||
        CASE WHEN LENGTH("User_Name") > 255 THEN 'User_Name, ' ELSE '' END ||
        CASE WHEN LENGTH("Role") > 100 THEN 'Role, ' ELSE '' END ||
        CASE WHEN LENGTH("Portfolio") > 100 THEN 'Portfolio, ' ELSE '' END ||
        CASE WHEN LENGTH("Business_Line") > 100 THEN 'Business_Line, ' ELSE '' END ||
        CASE WHEN LENGTH("ZipCode") > 20 THEN 'ZipCode, ' ELSE '' END ||
        CASE WHEN LENGTH("City") > 100 THEN 'City, ' ELSE '' END ||
        CASE WHEN LENGTH("Street") > 200 THEN 'Street, ' ELSE '' END ||
        CASE WHEN LENGTH("Teams") > 2000 THEN 'Teams, ' ELSE '' END ||
        CASE WHEN LENGTH("Fut_CA_Position") > 100 THEN 'Fut_CA_Position, ' ELSE '' END ||
        CASE WHEN LENGTH("Fut_Cost_Center") > 150 THEN 'Fut_Cost_Center, ' ELSE '' END ||
        CASE WHEN LENGTH("Fut_Bus_Line") > 70 THEN 'Fut_Bus_Line, ' ELSE '' END ||
        CASE WHEN LENGTH("Fut_Manager_ID") > 15 THEN 'Fut_Manager_ID, ' ELSE '' END
    ) AS "FIELDS_EXCEEDING_LIMIT", *
FROM "DB_WORKDAY"."SH_RAW"."SRC_WD_HCM"
WHERE
    LENGTH("Employee_ID") > 30 OR
    LENGTH("Full_Legal_Name") > 255 OR
    LENGTH("Gender") > 30 OR
    LENGTH("Worker_Type") > 30 OR
    LENGTH("Employee_Type") > 30 OR
    LENGTH("Contingent_Worker_Type") > 40 OR
    LENGTH("Company_ID") > 20 OR
    LENGTH("Company") > 255 OR
    LENGTH("Hire_Reason_ID") > 255 OR
    LENGTH("Hire_Reason") > 255 OR
    LENGTH("Termination_Reason_ID") > 255 OR
    LENGTH("Termination_Reason") > 255 OR
    LENGTH("Termination_Reason_Local_ID") > 255 OR
    LENGTH("Termination_Reason_Local") > 255 OR
    LENGTH("Position_ID") > 20 OR
    LENGTH("Position") > 255 OR
    LENGTH("Job_Profile") > 255 OR
    LENGTH("Management_Level_ID") > 30 OR
    LENGTH("Management_Level") > 255 OR
    LENGTH("Job_Title") > 255 OR
    LENGTH("Job_Classification_ID") > 30 OR
    LENGTH("Job_Classification") > 255 OR
    LENGTH("Job_ClassificationAdditional_ID") > 255 OR
    LENGTH("Job_Classification_Finance") > 255 OR
    LENGTH("Job_Classification_HR") > 255 OR
    LENGTH("Change_Reason_ID") > 255 OR
    LENGTH("Change_Reason") > 255 OR
    LENGTH("Collective_Agreement_Profesional_Position") > 100 OR
    LENGTH("Collective_Agreement_Professional_Category") > 100 OR
    LENGTH("Collective_Agreement_Group") > 100 OR
    LENGTH("Collective_Agreement_Level") > 100 OR
    LENGTH("Cost_Type") > 100 OR
    LENGTH("Work_Shift") > 100 OR
    LENGTH("Legal_Guard") > 1 OR
    LENGTH("Contract_Type_ID") > 100 OR
    LENGTH("Contract_Type") > 100 OR
    LENGTH("Cost_Center_ID") > 20 OR
    LENGTH("Cost_Center") > 255 OR
    LENGTH("Supervisory_Organization_ID") > 30 OR
    LENGTH("Supervisory_Organization") > 100 OR
    LENGTH("Level_from_Top") > 30 OR
    LENGTH("Level_04_FromTop_ID") > 20 OR
    LENGTH("Level_04_FromTop") > 255 OR
    LENGTH("Level_05_FromTop_ID") > 20 OR
    LENGTH("Level_05_FromTop") > 255 OR
    LENGTH("Level_06_FromTop_ID") > 20 OR
    LENGTH("Level_06_FromTop") > 255 OR
    LENGTH("Level_07_FromTop_ID") > 20 OR
    LENGTH("Level_07_FromTop") > 255 OR
    LENGTH("Level_08_FromTop_ID") > 20 OR
    LENGTH("Level_08_FromTop") > 255 OR
    LENGTH("Level_09_FromTop_ID") > 20 OR
    LENGTH("Level_09_FromTop") > 255 OR
    LENGTH("Level_10_FromTop_ID") > 20 OR
    LENGTH("Level_10_FromTop") > 255 OR
    LENGTH("Job_Family_Group_ID") > 20 OR
    LENGTH("Job_Family_Group") > 255 OR
    LENGTH("Job_Family_ID") > 20 OR
    LENGTH("Job_Family") > 255 OR
    LENGTH("Location_ID") > 30 OR
    LENGTH("Location") > 255 OR
    LENGTH("Manager_ID") > 20 OR
    LENGTH("Team_Leader_ID") > 20 OR
    LENGTH("Supervisory_Organization_Has_Team_Leader") > 10 OR
    LENGTH("International_Mobility_Type") > 50 OR
    LENGTH("Source_Category") > 300 OR
    LENGTH("Source") > 100 OR
    LENGTH("Sales_equipment_box") > 100 OR
    LENGTH("TShirt_Size") > 10 OR
    LENGTH("Email") > 100 OR
    LENGTH("Custom_Country_ISO_2") > 20 OR
    LENGTH("DirectManagerID") > 255 OR
    LENGTH("Nationality") > 200 OR
    LENGTH("Disability") > 200 OR
    LENGTH("Contracted_from_Competitor") > 200 OR
    LENGTH("ZCF_Supplier_ID") > 200 OR
    LENGTH("Contingent_Worker_Supplier") > 200 OR
    LENGTH("Candidate_ID") > 36 OR
    LENGTH("User_Name") > 255 OR
    LENGTH("Role") > 100 OR
    LENGTH("Portfolio") > 100 OR
    LENGTH("Business_Line") > 100 OR
    LENGTH("ZipCode") > 20 OR
    LENGTH("City") > 100 OR
    LENGTH("Street") > 200 OR
    LENGTH("Teams") > 2000 OR
    LENGTH("Fut_CA_Position") > 100 OR
    LENGTH("Fut_Cost_Center") > 150 OR
    LENGTH("Fut_Bus_Line") > 70 OR
    LENGTH("Fut_Manager_ID") > 15
    