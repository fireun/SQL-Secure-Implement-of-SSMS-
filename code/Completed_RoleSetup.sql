USE MedicalInfoSystem_Grp23
GO

CREATE ROLE DoctorRole; --Department Name
CREATE ROLE NurseRole;
CREATE ROLE AdminRole;
CREATE ROLE PatientRole;



-- Grant permissions to roles
-- DoctorRole Permissions
GRANT SELECT ON dbo.Patient TO DoctorRole; --except sensitive details, not change or delete patient personal info
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Prescription TO DoctorRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.PrescriptionMedicine TO DoctorRole; --select, insert, update, and delete medicine detail for him's patient, but cant update and delete other doctor's patient
GRANT SELECT, UPDATE ON dbo.Staff TO DoctorRole; -- only able update passport & phone
GRANT SELECT ON dbo.Medicine TO DoctorRole;

-- NurseRole Permissions
GRANT SELECT, UPDATE ON dbo.Patient TO NurseRole;
GRANT SELECT ON dbo.Staff TO NurseRole; --only able updata passport & phone
GRANT SELECT ON dbo.Medicine TO NurseRole;
GRANT SELECT ON dbo.Prescription TO NurseRole;
GRANT SELECT ON dbo.PrescriptionMedicine TO NurseRole;

-- AdminRole Permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Patient TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Prescription TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Medicine TO AdminRole;

GO
-- Patient Permissions
CREATE VIEW PatientDetailsView
AS
SELECT
    PID,
    PName,
    PPassportNumber,
    PPHONE,
    [PaymentCardNumber],
	[PaymentCardPinCode]
FROM
    Patient
WHERE
	[SystemUserID] = SYSTEM_USER;
GO


GRANT SELECT ON PatientDetailsView TO PatientRole;
GRANT SELECT, UPDATE ON dbo.Patient TO PatientRole; --only able upload passport, phone, payment detail
GRANT SELECT ON dbo.Prescription TO PatientRole;
GRANT SELECT ON dbo.Prescription TO PatientRole;
GRANT SELECT ON dbo.Medicine TO PatientRole;


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
    ('DoctorRole', 'Prescription', 'SELECT, INSERT, UPDATE, DELETE'),
	('DoctorRole', 'PrescriptionMedicine', 'SELECT, INSERT, UPDATE, DELETE'),
	('DoctorRole', 'Medicine', 'SELECT'),
	('DoctorRole', 'Staff', 'SELECT, UPDATE'),
    ('NurseRole', 'Patient', 'SELECT, UPDATE'),
	('NurseRole', 'Staff', 'SELECT, UPDATE'),
	('NurseRole', 'Prescription', 'SELECT'),
    ('NurseRole', 'PrescriptionMedicine', 'SELECT'),
	('NurseRole', 'Medicine', 'SELECT'),
	('PatientRole','Patient','SELECT,UPDATE'),
	('PatientRole','Prescription','SELECT'),
	('PatientRole','PrescriptionMedicine','SELECT'),
	('PatientRole','Medicine','SELECT'),
    ('AdminRole', 'Patient', 'SELECT,INSERT,UPDATE,DELETE'),
    ('AdminRole', 'Prescription', 'SELECT,INSERT,UPDATE,DELETE'),
    ('AdminRole', 'Medicine', 'SELECT,INSERT,UPDATE,DELETE');
GO


--Print Authrization Matrix Table
SELECT * FROM dbo.AuthorizationMatrix


--CALL VIEW
SELECT * FROM PatientDetailsView WHERE system_user = 'user101';


--check role
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name = 'Patient'


-- check role permission to which table
SELECT 
    princ.name AS [Role_Group],
    princ.type_desc AS [User_Type],
    perm.permission_name,
    perm.state_desc AS [Permission_State]
FROM sys.database_permissions perm
INNER JOIN sys.database_principals princ ON perm.grantee_principal_id = princ.principal_id
WHERE object_name(perm.major_id) = 'Patient' AND princ.name = 'PatientRole'; -- Replace 'YourUserOrRole' with the actual user or role name


-- Check users in the specified role
SELECT 
    U.name AS UserName,
    R.name AS RoleName
FROM sys.database_role_members RM
JOIN sys.database_principals U ON RM.member_principal_id = U.principal_id
JOIN sys.database_principals R ON RM.role_principal_id = R.principal_id
WHERE R.name = 'DoctorRole'; -- Replace 'YourRole' with the actual role name




-------------------------------------------------------
/*
1. Patient can check him's doctor own medicine, NOT change or delete
2. Patient can't access other Patient info or medicine info
3. Nurses & Doctor can check patient personal info EXCEPT sensitive details
4. Nurses can check patient medicine details BUT NOT insert, update, or delete
5. Doctor can insert new medicine details for their patient
6. Doctor can update and delete thier medicine details
7. Doctor can check all patient's medicine details INCLUDE medication given by other details
8. Doctor CAN'T update or delete other doctor medicine details
*/