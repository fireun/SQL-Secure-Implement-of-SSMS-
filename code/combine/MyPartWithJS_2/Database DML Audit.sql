/* Database Audit */

USE master;
GO

-- Create Server Audit
CREATE SERVER AUDIT Grp23DatabaseAudit
TO FILE (FILEPATH = 'C:\SQLServerAudits')
WITH (ON_FAILURE = CONTINUE);
GO

-- Enable Server Audit
ALTER SERVER AUDIT Grp23DatabaseAudit WITH (STATE = ON);
GO

-- Database Audit Start
USE MedicalInfoSystem_Grp23;
GO

-- Create Database Audit DML Specification (Data Level)
CREATE DATABASE AUDIT SPECIFICATION Grp23DatabaseDMLSpec
FOR SERVER AUDIT Grp23DatabaseAudit
ADD (SELECT, INSERT, UPDATE, DELETE ON DATABASE::MedicalInfoSystem_Grp23_Done BY public),
ADD (SELECT, INSERT, UPDATE, DELETE ON DATABASE::MedicalInfoSystem_Grp23_Done BY DoctorRole),
ADD (SELECT, INSERT, UPDATE, DELETE ON DATABASE::MedicalInfoSystem_Grp23_Done BY NurseRole),
ADD (SELECT, INSERT, UPDATE, DELETE ON DATABASE::MedicalInfoSystem_Grp23_Done BY PatientRole),
ADD (SELECT, INSERT, UPDATE, DELETE ON DATABASE::MedicalInfoSystem_Grp23_Done BY AdminRole)
WITH (STATE = ON);

-- Create Database Level Audit with event group (DDL)
CREATE DATABASE AUDIT SPECIFICATION Grp23DatabaseDDLSpec 
FOR SERVER AUDIT Grp23DatabaseAudit
ADD (DATABASE_OBJECT_CHANGE_GROUP), 
ADD (DATABASE_PERMISSION_CHANGE_GROUP),
ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP), 
ADD (SCHEMA_OBJECT_CHANGE_GROUP),
ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP),
ADD (DATABASE_PRINCIPAL_CHANGE_GROUP)
WITH (STATE=ON)
Go

/*-- Select specific object and column to show
select event_time, database_name, database_principal_name, object_name, statement
from sys.fn_get_audit_file('C:\SQLServerAudits\Grp23ServerAudit*', DEFAULT, DEFAULT)*/


--- Audit file with correct timestamp
SELECT DATEADD(MINUTE, DATEDIFF(MINUTE, GETUTCDATE(), CURRENT_TIMESTAMP), event_time) AS event_time_afterconvert
	,getdate() 'Current_system_time'
	,event_time, server_principal_name, action_id, succeeded, server_principal_name, object_name, statement
FROM sys.fn_get_audit_file('C:\SQLServerAudits\Grp23DatabaseAudit*', DEFAULT, DEFAULT)