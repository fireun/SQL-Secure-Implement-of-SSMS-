/* Login Result, Server Permission, Server Role */

/* Function Below are Used for Create and Enable Audit andn Audit Specification */

USE master;
GO

-- Create Server Audit
CREATE SERVER AUDIT Grp23ServerAudit
TO FILE (FILEPATH = 'C:\SQLServerAudits')
WITH (ON_FAILURE = CONTINUE);
GO

-- Create Database Audit
CREATE SERVER AUDIT Grp23DatabaseAudit
TO FILE (FILEPATH = 'C:\SQLServerAudits')
WITH (ON_FAILURE = CONTINUE);
GO

-- Enable Server Audit
ALTER SERVER AUDIT Grp23ServerAudit WITH (STATE = ON);
GO

-- Enable Database Audit
ALTER SERVER AUDIT Grp23DatabaseAudit WITH (STATE = ON);
GO

-- Enable Server Audit Specification
ALTER SERVER AUDIT Grp23ServerAudit WITH (STATE = ON);
GO

-- Create a server audit specification
CREATE SERVER AUDIT SPECIFICATION ServerStateAudit
FOR SERVER AUDIT Grp23ServerAudit
ADD (SUCCESSFUL_LOGIN_GROUP),
ADD (FAILED_LOGIN_GROUP),
ADD (SERVER_PERMISSION_CHANGE_GROUP),
ADD (DATABASE_CHANGE_GROUP),
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP);

-- Enable the server audit specification
ALTER SERVER AUDIT SPECIFICATION ServerStateAudit WITH (STATE = ON);
GO

-- Database Audit Start
USE MedicalInfoSystem_Grp23_Done;
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

/* Function Below are Used for Display Audit Tables*/

/* Display Server Audit Table */

-- Query the audit logs (Get Latest) with correct timestamp
SELECT DATEADD(MINUTE, DATEDIFF(MINUTE, GETUTCDATE(), CURRENT_TIMESTAMP), event_time) AS event_time_afterconvert
	,getdate() 'Current_system_time', *
FROM sys.fn_get_audit_file('C:\SQLServerAudits\Grp23ServerAudit*', DEFAULT, DEFAULT)
ORDER BY event_time DESC;



-- Query Server Audit Specification to Prove is Enabled
SELECT
    name AS 'Audit Specification Name',
    audit_guid AS 'Audit GUID',
    create_date AS 'Creation Date',
    modify_date AS 'Last Modified Date',
    is_state_enabled AS 'Is Enabled'
FROM sys.server_audit_specifications;

/* Display Database Audit Table */

/*-- Select specific object and column to show
select event_time, database_name, database_principal_name, object_name, statement
from sys.fn_get_audit_file('C:\SQLServerAudits\Grp23ServerAudit*', DEFAULT, DEFAULT)*/


--- Audit file with correct timestamp
SELECT DATEADD(MINUTE, DATEDIFF(MINUTE, GETUTCDATE(), CURRENT_TIMESTAMP), event_time) AS event_time_afterconvert
	,getdate() 'Current_system_time'
	,event_time, server_principal_name, action_id, succeeded, server_principal_name, object_name, statement
FROM sys.fn_get_audit_file('C:\SQLServerAudits\Grp23DatabaseAudit*', DEFAULT, DEFAULT)

/*  Display Logout Audit Table */

-- To get LOGINOUT Audit Files
SELECT DATEADD(MINUTE, DATEDIFF(MINUTE, GETUTCDATE(), CURRENT_TIMESTAMP), event_time) AS event_time_afterconvert
	,getdate() 'Current_system_time', event_time, server_principal_name, action_id, session_server_principal_name, server_principal_name, statement, server_principal_sid
FROM sys.fn_get_audit_file('C:\SQLServerAudits\LOGINOUT%5Audit*', DEFAULT, DEFAULT)
ORDER BY event_time DESC;