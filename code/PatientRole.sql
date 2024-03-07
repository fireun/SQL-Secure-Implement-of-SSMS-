


--** After need combine with RoleSetup.sql


USE MedicalInfoSystem_Grp23
GO

-----------------------------User Account Register-----------------------------------
--Patient login by unique userID
--1. create a device login the server level
--2. create a username(patienttest = P001 user) for (PatientTest = connect SQL username) each patient/user need a account
CREATE USER patienttestPID001 FOR LOGIN PatientTest 
GO

--When setup done role group, then can add the USER to role group (DoctorRole = role group, docktortest = username)
ALTER ROLE PatientRole ADD MEMBER patienttestPID001
GO

--Also can remove from the role group
ALTER ROLE PatientRole DROP MEMBER patienttestPID001 
GO

--FOR TESTING before & after add to the group
SELECT * FROM Patient
GO








-----------------------------Patient Role-----------------------------------



-- Create roles (table -> security -> roles -> create new role )
CREATE ROLE PatientRole; --Department Name
GO 

-- Create a view that includes patient details
CREATE VIEW PatientDetailsView
AS
SELECT
    PID,
    PName,
    PassportNumber,
    PPHONE,
    [PaymentCardNumber],
	[PaymentCardPinCode]
FROM
    Patient
WHERE
	[SystemUserID] = SYSTEM_USER; --SYSTEM_USER means current login username

-- Grant permissions to roles
-- PatientRole Permissions
GRANT SELECT ON PatientDetailsView TO PatientRole;
GRANT UPDATE ON dbo.Patient TO PatientRole;





-- Create an Authorization Matrix table
--CREATE TABLE AuthorizationMatrix (
--    RoleName VARCHAR(20),
--    TableName VARCHAR(50),
--    PermissionType VARCHAR(50)
--);
--GO

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
	('PatientRole','Patient','SELECT,UPDATE')
GO


