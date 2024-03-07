/* Login Result, Server Permission, Server Role */

USE master;
GO

-- Create Server Audit
CREATE SERVER AUDIT Grp23ServerAudit
TO FILE (FILEPATH = 'C:\SQLServerAudits')
WITH (ON_FAILURE = CONTINUE);
GO

-- Enable Server Audit
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

-- Remove Audit Condition
/*ALTER SERVER AUDIT SPECIFICATION ServerStateAudit WITH (STATE = OFF)
ALTER SERVER AUDIT SPECIFICATION ServerStateAudit
DROP (FAILED_LOGIN_GROUP);*/