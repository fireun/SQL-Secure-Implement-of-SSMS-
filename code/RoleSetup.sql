USE MedicalInfoSystem_Grp23
GO

--Implement RBAC | Role Group
--1.Create Doctor, Nurse, Admin, Patient RoleGroup
--2.Grant Permission
--3.Add Member [loginUserName]
--4.Create AuthorizationMatrix
--5.Print AuthorizationMatrix (SQL Table Verify.sql)


--Select * from Staff
--GO

-- Create roles (table -> security -> roles -> create new role )
CREATE ROLE DoctorRole; --Department Name
CREATE ROLE NurseRole;
CREATE ROLE AdminRole;

-- Grant permissions to roles
-- DoctorRole Permissions
GRANT SELECT ON dbo.Patient TO DoctorRole;
GRANT INSERT, UPDATE ON dbo.Prescription TO DoctorRole;
-- NurseRole Permissions
GRANT SELECT ON dbo.Patient TO NurseRole;
GRANT INSERT, UPDATE ON dbo.Prescription TO NurseRole;
-- AdminRole Permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Patient TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Prescription TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Medicine TO AdminRole;



-- add userid to the role, Do it in RLS
--ALTER ROLE DoctorRole ADD MEMBER Dave
--GO


-- Create an Authorization Matrix table
CREATE TABLE AuthorizationMatrix (
    RoleName VARCHAR(20),
    TableName VARCHAR(50),
    PermissionType VARCHAR(50)
);
GO

-- Populate the Authorization Matrix
INSERT INTO AuthorizationMatrix (RoleName, TableName, PermissionType)
VALUES
    ('DoctorRole', 'Patient', 'SELECT'),
    ('DoctorRole', 'Prescription', 'INSERT,UPDATE'),
    ('NurseRole', 'Patient', 'SELECT'),
    ('NurseRole', 'Prescription', 'INSERT,UPDATE'),
    ('AdminRole', 'Patient', 'SELECT,INSERT,UPDATE,DELETE'),
    ('AdminRole', 'Prescription', 'SELECT,INSERT,UPDATE,DELETE'),
    ('AdminRole', 'Medicine', 'SELECT,INSERT,UPDATE,DELETE');
GO


--check role
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name = 'DoctorRole'

