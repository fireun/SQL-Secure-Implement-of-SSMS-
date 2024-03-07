USE MedicalInfoSystem_Grp23; -- Replace 'YourDatabaseName' with your database name


-- check Authorization Matrix Table
SELECT 
    p.name AS RoleName,
    o.name AS TableName,
    CASE 
        WHEN pe.state_desc = 'GRANT_WITH_GRANT_OPTION' THEN 'GRANT WITH GRANT OPTION'
        WHEN pe.state_desc = 'DENY' THEN 'DENY'
        ELSE pe.state_desc
    END AS Permission
FROM sys.database_principals p
JOIN sys.database_permissions pe ON p.principal_id = pe.grantee_principal_id
JOIN sys.objects o ON pe.major_id = o.object_id
WHERE pe.class_desc = 'OBJECT_OR_COLUMN' AND o.type = 'U' -- Adjust the type if you're interested in other object types
ORDER BY p.name, o.name, pe.permission_name;
