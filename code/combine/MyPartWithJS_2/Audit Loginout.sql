-- To get LOGINOUT Audit Files
SELECT DATEADD(MINUTE, DATEDIFF(MINUTE, GETUTCDATE(), CURRENT_TIMESTAMP), event_time) AS event_time_afterconvert
	,getdate() 'Current_system_time', event_time, server_principal_name, action_id, session_server_principal_name, server_principal_name, statement, server_principal_sid
FROM sys.fn_get_audit_file('C:\SQLServerAudits\LOGINOUT%5Audit*', DEFAULT, DEFAULT)
ORDER BY event_time DESC;