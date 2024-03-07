--Database Structure
--Group 23

-- Create Database
CREATE DATABASE MedicalInfoSystem_Test2;
GO

-- Use Database
USE MedicalInfoSystem_Test2;
GO

-- Create Staff Table with Enhanced Security
CREATE TABLE Staff (
    StaffID VARCHAR(6) PRIMARY KEY,
    SName VARCHAR(100) NOT NULL,
    SPassportNumber VARCHAR(50) NOT NULL,
    SPhone VARCHAR(20),
    SystemUserID VARCHAR(10) UNIQUE NOT NULL, -- Adding UNIQUE constraint for SystemUserID
    Position VARCHAR(20) CHECK (Position IN ('Doctor', 'Nurse'))
);

-- Create Patient Table with Enhanced Security
CREATE TABLE Patient (
    PID VARCHAR(6) PRIMARY KEY,
    PName VARCHAR(100) NOT NULL,
    PPassportNumber VARCHAR(50) NOT NULL,
    PPhone VARCHAR(20),
    SystemUserID VARCHAR(10) UNIQUE NOT NULL, -- Adding UNIQUE constraint for SystemUserID
    PaymentCardNumber VARCHAR(20),
    PaymentCardPinCode VARCHAR(20),
    CONSTRAINT CHK_CardPin CHECK (PaymentCardPinCode IS NULL OR LEN(PaymentCardPinCode) = 3) -- Adding a CHECK constraint for PIN code
);

-- Create Medicine Table
CREATE TABLE Medicine (
    MID VARCHAR(10) PRIMARY KEY,
    MName VARCHAR(50) NOT NULL
);

-- Create Prescription Table
CREATE TABLE Prescription (
    PresID INT IDENTITY(1, 1) PRIMARY KEY,
    PatientID VARCHAR(6) REFERENCES Patient(PID),
    DoctorID VARCHAR(6) REFERENCES Staff(StaffID),
    PharmacistID VARCHAR(6) REFERENCES Staff(StaffID),
    PresDateTime DATETIME NOT NULL
);


-- Create PrescriptionMedicine Table
CREATE TABLE PrescriptionMedicine (
    PresID INT REFERENCES Prescription(PresID),
    MedID VARCHAR(10) REFERENCES Medicine(MID),
    PRIMARY KEY (PresID, MedID)
);



--Data Population

-- Insert sample data into the Staff table
INSERT INTO Staff (StaffID, SName, SPassportNumber, SPhone, SystemUserID, Position)
VALUES
    ('S001', 'Dr. Koa', '111456', '012-345-6789', 'user001', 'Doctor'),
    ('S002', 'Nurse Thomas', '789012', '013-456-7890', 'user002', 'Nurse'),
	('S003', 'Nurse Jerry', '123332', '014-567-8901', 'user003', 'Nurse'),
	('S004', 'Dr. Sam', '766812', '015-678-9012', 'user004', 'Doctor'),
	('S005', 'Nurse Johnson', '589012', '016-789-0123', 'user005', 'Nurse'),
	('S006', 'Nurse Samon', '111012', '017-890-1234', 'user006', 'Nurse'),
	('S007', 'Dr. Tom', '333012', '018-901-2345', 'user007', 'Doctor');

-- Insert sample data into the Patient table
INSERT INTO Patient (PID, PName, PPassportNumber, PPhone, SystemUserID, PaymentCardNumber, PaymentCardPinCode)
VALUES
    ('P001', 'John Doe', '456789', '019-012-3456', 'user101', '1234567812345678', '124'),
    ('P002', 'Jane Smith', '987654', '010-123-4567', 'user102', '8777432187654321', '508'),
	('P003', 'Wade', '707789', '011-234-5678', 'user103', '5732149856123478', '546'),
	('P004', 'Dave', '455489', '012-345-6780', 'user104', '8901234567890123', '121'),
	('P005', 'Seth', '889609', '013-456-7891', 'user105', '4567123987654321', '315'),
	('P006', 'Ivan', '796061', '014-567-8902', 'user106', '6543217890123456', '723');

-- Insert sample data into the Medicine table
INSERT INTO Medicine (MID, MName)
VALUES
    ('M001', 'Medicine A'),
    ('M002', 'Medicine B'),
	('M003', 'Medicine C'),
	('M004', 'Medicine D'),
	('M005', 'Medicine E'),
	('M006', 'Medicine F'),
	('M007', 'Medicine G'),
	('M008', 'Medicine H'),
	('M009', 'Medicine I'),
	('M010', 'Medicine J');

-- Insert sample data into the Prescription table
INSERT INTO Prescription (PatientID, DoctorID, PharmacistID, PresDateTime)
VALUES
    ('P001', 'S001', 'S002', '2023-10-09 10:20:00'),
	('P002', 'S004', 'S003', '2023-10-10 15:00:00'),
	('P003', 'S001', 'S003', '2023-10-10 11:45:00'),
	('P004', 'S001', 'S005', '2023-10-11 09:20:00'),
	('P005', 'S007', 'S006', '2023-10-12 10:00:00'),
    ('P006', 'S004', 'S002', '2023-10-13 11:00:00');

-- Insert sample data into the PrescriptionMedicine table
INSERT INTO PrescriptionMedicine (PresID, MedID)
VALUES
    (1, 'M001'),
	(1, 'M003'),
	(1, 'M007'),
	(2, 'M002'),
	(2, 'M003'),
	(3, 'M004'),
	(3, 'M005'),
	(3, 'M006'),
	(3, 'M007'),
	(4, 'M001'),
	(4, 'M002'),
	(5, 'M007'),
	(5, 'M008'),
	(5, 'M009'),
	(6, 'M005'),
	(6, 'M008'),
    (6, 'M009'),
    (6, 'M010');








----------------------Role Setup--------------------------------



CREATE ROLE DoctorRole; --Department Name
CREATE ROLE NurseRole;
CREATE ROLE AdminRole;
CREATE ROLE PatientRole;
-- Create a new role for update
CREATE ROLE PatientUpdatePersonalDetailRole; --patient update thier own personal details
CREATE ROLE NursesUpdatePatientPersonalDetailRole; --nurses update patient's personal details
CREATE ROLE StaffUpdatePersonalDetailRole; --nurses and doctors update their own personal details
CREATE ROLE StaffSelectPatientNonSensitiveRole; --nurses access patient data with nonsensitive data


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
GRANT SELECT, INSERT, UPDATE ON dbo.Prescription TO NurseRole;
GRANT SELECT ON dbo.PrescriptionMedicine TO NurseRole; 

-- AdminRole Permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Patient TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Prescription TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Medicine TO AdminRole;

-- Patient Permissions
GRANT SELECT, UPDATE ON dbo.Patient TO PatientRole; --only able upload passport, phone, payment detail
GRANT SELECT ON dbo.Prescription TO PatientRole;
GRANT SELECT ON dbo.PrescriptionMedicine TO PatientRole;
GRANT SELECT ON dbo.Medicine TO PatientRole;


		/*	UPDATE data Permission Setup */
-- patient update personal details rule
GRANT UPDATE ([PPassportNumber], [PPhone],[PaymentCardNumber],[PaymentCardPinCode]) ON Patient TO PatientUpdatePersonalDetailRole;
DENY UPDATE ([PID],[PName],[SystemUserID]) ON Patient TO PatientUpdatePersonalDetailRole;
--REVOKE SELECT ([PName],[PPassportNumber], [PPhone],[PaymentCardNumber],[PaymentCardPinCode]) ON Patient TO PatientUpdatePersonalDetailRole;
--REVOKE SELECT ([PID],[SystemUserID]) ON Patient TO PatientUpdatePersonalDetailRole;
-- Add the user to the role, with system_login_user_ID
EXEC sp_addrolemember 'PatientUpdatePersonalDetailRole', 'user101';


-- nurses update patient personal details rule
GRANT UPDATE ([PName],[PPhone]) ON Patient TO NursesUpdatePatientPersonalDetailRole;
DENY UPDATE ([PPassportNumber], [PaymentCardNumber],[PaymentCardPinCode],[SystemUserID]) ON Patient TO NursesUpdatePatientPersonalDetailRole;
-- Add the user to the role, with system_login_user_ID
EXEC sp_addrolemember 'NursesUpdatePatientPersonalDetailRole', 'user002';


--nurse and doctor update personal details
GRANT UPDATE ([SName],[SPassportNumber],[SPhone]) ON Staff TO StaffUpdatePersonalDetailRole;
DENY UPDATE ([StaffID], [SystemUserID],[Position]) ON Staff TO StaffUpdatePersonalDetailRole;
-- Add the user to the role, with system_login_user_ID
EXEC sp_addrolemember 'StaffUpdatePersonalDetailRole', 'user001';
EXEC sp_addrolemember 'StaffUpdatePersonalDetailRole', 'user002';




										/*	SELECT data Permission Setup */
-- nurses select patient permission
GRANT SELECT ON dbo.Patient (PID, PName,PPassportNumber,PPhone) TO StaffSelectPatientNonSensitiveRole;
DENY SELECT ON dbo.Patient ([SystemUserID], [PaymentCardNumber],[PaymentCardPinCode]) TO StaffSelectPatientNonSensitiveRole;
EXEC sp_addrolemember 'StaffSelectPatientNonSensitiveRole', 'user001';
EXEC sp_addrolemember 'StaffSelectPatientNonSensitiveRole', 'user002';


--REVOKE SELECT ON dbo.Medicine TO PatientRole;
/*

---	CHECK ROLE MEMBER --- 

--check member inside role group
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name = 'DoctorRole'


--or

-- Check users in the specified role
SELECT 
    U.name AS UserName,
    R.name AS RoleName
FROM sys.database_role_members RM
JOIN sys.database_principals U ON RM.member_principal_id = U.principal_id
JOIN sys.database_principals R ON RM.role_principal_id = R.principal_id
WHERE R.name = 'DoctorRole'; -- Replace 'YourRole' with the actual role name





-- PRINT ALL Permission and connection ---

--check each member or role permission in which table
SELECT dp.NAME      AS SubjectName,
       dp.TYPE_DESC AS SubjectType,
       o.NAME       AS ObjectName,
       o.type_desc as ObjectType,
       p.PERMISSION_NAME as Permission,
       p.STATE_DESC AS PermissionType
FROM sys.database_permissions p
     LEFT OUTER JOIN sys.all_objects o
          ON p.MAJOR_ID = o.OBJECT_ID
     INNER JOIN sys.database_principals dp
          ON p.GRANTEE_PRINCIPAL_ID = dp.PRINCIPAL_ID
and dp.is_fixed_role=0
and dp.Name NOT in ('public','dbo')

*/





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


/*

-- check special role permission in spicial table

SELECT 
    princ.name AS [Role_Group],
    princ.type_desc AS [User_Type],
	object_name(perm.major_id) AS [Table],
    perm.permission_name,
    perm.state_desc AS [Permission_State]
FROM sys.database_permissions perm
INNER JOIN sys.database_principals princ ON perm.grantee_principal_id = princ.principal_id
WHERE object_name(perm.major_id) = 'Staff' AND princ.name = 'DoctorRole'; -- Replace 'YourUserOrRole' with the actual user or role name

*/



--------------------Add User Login --------------------------
--Doctor Account - SystemUserID: user001
CREATE USER user001 FOR LOGIN user001 
--add to role group [which role] ADD who
ALTER ROLE DoctorRole ADD member user001 
--ALTER ROLE DoctorRole DROP member user001; --Delect user001 from DoctorRole

--Nurse Account - SystemUserID: user002
CREATE USER user002 FOR LOGIN user002
ALTER ROLE NurseRole ADD member user002


--Patient Account - SystemUserID: user101
CREATE USER user101 FOR LOGIN user101
ALTER ROLE PatientRole ADD member user101
GO






--- Implement Row Level Security (RLS) ------------------------------------------------------------------------------------
CREATE SCHEMA Security;
GO

--create user-defined function (It functions return single column named 'fn_securitypredicate_result' if 1 = match the username OR the owner is 'dbo' database owner)
CREATE FUNCTION Security.fn_securitypredicate_staff(@SystemUserID AS nvarchar(100))
RETURNS TABLE
WITH SCHEMABINDING
AS
   RETURN SELECT 1 AS fn_securitypredicate_result
   WHERE @SystemUserID = USER_NAME() OR USER_NAME() = 'dbo';
GO

CREATE FUNCTION Security.fn_securitypredicate_patient(@SystemUserID AS nvarchar(100))
RETURNS TABLE
WITH SCHEMABINDING
AS
   RETURN SELECT 1 AS fn_securitypredicate_result
   WHERE @SystemUserID = USER_NAME() OR USER_NAME() = 'dbo';
GO

-- Create security policy for the Staff table
CREATE SECURITY POLICY [SMS_StaffSecurityPolicy]
ADD FILTER PREDICATE [Security].[fn_securitypredicate_staff]([SystemUserID])
ON [dbo].[Staff]
WITH (STATE = ON);



--create security policy (It function applied to the [dbo].[Customer] table, uses the function to filtering the column 'Customer' table
CREATE SECURITY POLICY [SMS_PatientSecurityPolicy]
ADD FILTER PREDICATE [Security].[fn_securitypredicate_patient]([SystemUserID]) --([ColumnName])
ON [dbo].[Patient] --[dbo].[TableName/ ObjectName]
WITH (STATE = ON);
GO


/*
--Drop policies

DROP SECURITY POLICY [SMS_StaffSecurityPolicy];
DROP SECURITY POLICY [SMS_PatientSecurityPolicy];

-- Check if the object exists
SELECT * FROM sys.security_policies WHERE name = 'SMS_PatientSecurityPolicy';
SELECT * FROM sys.security_policies WHERE name = 'SMS_StaffSecurityPolicy';


*/

-- Create the ComparePatientAndStaffData procedure with input and output parameters
CREATE PROCEDURE ComparePatientAndStaffData
    @UserRole NVARCHAR(50) OUTPUT
AS
BEGIN
	DECLARE @UserName NVARCHAR(100) = Current_User;
    -- Check if the current user is a patient
    IF EXISTS (SELECT 1 FROM Patient WHERE [SystemUserID] = @UserName)
    BEGIN
        -- User is a patient
        SET @UserRole = 'Patient';
        SELECT
            @UserRole AS UserType,
            P.[PID],
            P.[PName],
            P.[SystemUserID]
        FROM
            Patient AS P
        WHERE
            P.[SystemUserID] = @UserName;
    END
    ELSE IF EXISTS (SELECT 1 FROM Staff WHERE [SystemUserID] = @UserName)
    BEGIN
        -- User is a staff member
        SET @UserRole = 'Staff';
        SELECT
            @UserRole AS UserType,
            S.[StaffID],
            S.[SName],
            S.[Position]
        FROM
            Staff AS S
        WHERE
            S.[SystemUserID] = @UserName;
    END
    ELSE
    BEGIN
        -- User not found in either table or has a different role
        SET @UserRole = 'Admin';
        PRINT 'User not found or has a different role compare layer.';
    END

	--Print the username
	PRINT 'Login Use: ' + ISNULL(@UserName + ' in Compare', 'NULL in Compare');
	-- Print the user role
    PRINT 'User Role: ' + ISNULL(@UserRole  + ' in Compare', 'NULL in Compare');

END;

GO

-- Create the UpdateSecurityPolicies procedure
CREATE PROCEDURE dbo.UpdateSecurityPolicies
AS
BEGIN
	DECLARE @UserName NVARCHAR(100);
    DECLARE @UserResult NVARCHAR(50);

    EXEC ComparePatientAndStaffData @UserRole = @UserResult OUTPUT;

	--Print the username
	PRINT 'Login Use: ' + ISNULL(@UserName  + ' in Policie', 'NULL in Policies');
	-- Print the user role
    PRINT 'User Role: ' + ISNULL(@UserResult  + ' in Policie', 'NULL in Policies');

    -- Check user role and enable/disable policies accordingly
    IF @UserResult = 'Patient'
    BEGIN
        -- Disable Nurse Policy for Patients
        --ALTER SECURITY POLICY [SMS_StaffSecurityPolicy] WITH (STATE = OFF);

        -- Enable Patient Policy for Patients
        ALTER SECURITY POLICY [SMS_PatientSecurityPolicy] WITH (STATE = ON);
    END
    ELSE IF @UserResult = 'Staff'
    BEGIN


        -- Disable Patient Policy for Staff (Nurses and Doctors)
        ALTER SECURITY POLICY [SMS_PatientSecurityPolicy] WITH (STATE = OFF);

        -- Enable Staff Policy for Staff (Nurses and Doctors)
        ALTER SECURITY POLICY [SMS_StaffSecurityPolicy] WITH (STATE = ON);

    END
    ELSE
    BEGIN
        -- Handle other roles or no match
        PRINT 'User not found or has a different role in policies layer.';
    END
END;


/*
-- Drop the ComparePatientAndStaffData procedure
DROP PROCEDURE ComparePatientAndStaffData;

-- Drop the UpdateSecurityPolicies procedure
DROP PROCEDURE dbo.UpdateSecurityPolicies;

*/

/*
-- This is execute in user login page -check role -change policy state
-- Create an AFTER LOGON trigger
EXEC dbo.UpdateSecurityPolicies;
*/

/*
-- Grant EXECUTE permission on UpdateSecurityPolicies to your_user, assuming it's in the dbo schema
GRANT EXECUTE ON dbo.UpdateSecurityPolicies TO PatientRole;
GRANT EXECUTE ON dbo.UpdateSecurityPolicies TO NurseRole;
GRANT EXECUTE ON dbo.UpdateSecurityPolicies TO DoctorRole;


--important for security policy
GRANT ALTER ON SCHEMA::dbo TO PatientRole;
GRANT ALTER ON SCHEMA::dbo TO NurseRole;
GRANT ALTER ON SCHEMA::dbo TO DoctorRole;
*/

/* CAN'T WORKING
-- Grant permissions to the roles
GRANT REFERENCES ON SCHEMA::dbo TO PatientRole;
GRANT REFERENCES ON SCHEMA::dbo TO NurseRole;
GRANT REFERENCES ON SCHEMA::dbo TO DoctorRole;

GRANT ALTER ON SECURITY POLICY::[SMS_PatientSecurityPolicy] TO PatientRole;
GRANT ALTER ON SECURITY POLICY::[SMS_PatientSecurityPolicy] TO NurseRole;
GRANT ALTER ON SECURITY POLICY::[SMS_PatientSecurityPolicy] TO DoctorRole;

GRANT ALTER ON SECURITY POLICY::[SMS_StaffSecurityPolicy] TO PatientRole;
GRANT ALTER ON SECURITY POLICY::[SMS_StaffSecurityPolicy] TO NurseRole;
GRANT ALTER ON SECURITY POLICY::[SMS_StaffSecurityPolicy] TO DoctorRole;
*/

-- Grant permissions to the roles

GRANT EXECUTE ON dbo.UpdateSecurityPolicies TO PatientRole;
GRANT EXECUTE ON dbo.UpdateSecurityPolicies TO NurseRole;
GRANT EXECUTE ON dbo.UpdateSecurityPolicies TO DoctorRole;

GRANT REFERENCES ON SCHEMA::dbo TO PatientRole;
GRANT REFERENCES ON SCHEMA::dbo TO NurseRole;
GRANT REFERENCES ON SCHEMA::dbo TO DoctorRole;

-- Grant ALTER ANY SECURITY POLICY permission
GRANT ALTER ANY SECURITY POLICY TO PatientRole;
GRANT ALTER ANY SECURITY POLICY TO NurseRole;
GRANT ALTER ANY SECURITY POLICY TO DoctorRole;

/*

GRANT ALTER ON SECURITY POLICY::dbo.SMS_PatientSecurityPolicy TO DoctorRole;
GRANT ALTER ON SECURITY POLICY::dbo.SMS_StaffSecurityPolicy TO DoctorRole;
*/

/*
REVOKE ALTER ANY SECURITY POLICY TO PatientRole;
REVOKE ALTER ANY SECURITY POLICY TO NurseRole;


REVOKE EXECUTE ON dbo.UpdateSecurityPolicies TO PatientRole;
REVOKE EXECUTE ON dbo.UpdateSecurityPolicies TO NurseRole;
REVOKE EXECUTE ON dbo.UpdateSecurityPolicies TO DoctorRole;


REVOKE ALTER ANY SECURITY POLICY TO DoctorRole;

REVOKE ALTER ON SCHEMA::dbo TO DoctorRole;
REVOKE ALTER ON SECURITY POLICY::dbo.SMS_PatientSecurityPolicy TO DoctorRole;
REVOKE ALTER ON SECURITY POLICY::dbo.SMS_StaffSecurityPolicy TO DoctorRole;
*/

--SELECT * FROM sys.database_permissions
--WHERE grantee_principal_id = DATABASE_PRINCIPAL_ID('DoctorRole') AND class_desc = 'SECURITY POLICY';

/*
--testing execute by user
DECLARE @UserName NVARCHAR(100) = 'user001'; -- replace with the actual username
EXEC dbo.UpdateSecurityPolicies;
*/



/*

--- CHECKING AND DROP THE RLS------------------------------------------------------------------------------------

-- Check for the exists of security policies
SELECT * FROM sys.security_policies;

-- Check the status of RLS
SELECT name, is_enabled
FROM sys.security_policies;


SELECT schema_id, name, principal_id
FROM sys.schemas
WHERE name = 'Security';

--get schema name
SELECT schema_name
FROM information_schema.schemata;


--check policies available
SELECT 
    schema_name([schema_id]) AS SchemaName,
    [name] AS PolicyName
FROM sys.security_policies
WHERE schema_name([schema_id]) = 'dbo';


--print CURRENT_USER

*/






/**************************************Procedure for Doctor *********************************************************************************/
GO;


-- Create the stored procedure with a table-valued parameter
CREATE PROCEDURE dbo.ManagePrescription
    @PatientID NVARCHAR(6),
	@DoctorID NVARCHAR(10),
    @MedicineName NVARCHAR(50),
    @Action VARCHAR(10) -- 'INSERT', 'UPDATE', 'DELETE'
AS
BEGIN


	-- Handle different actions
	IF @Action = 'INSERT'
	BEGIN
		-- Get the latest PrescriptionID
		DECLARE @LatestPrescriptionID INT;
		SELECT @LatestPrescriptionID = ISNULL(MAX(PresID), 0) + 1 --get latest PresID + 1
		FROM Prescription;

		-- Get the latest MedicineID
		DECLARE @LatestMedicineID NVARCHAR(10);
		DECLARE @NewMedicineID NVARCHAR(10);
		
		--SELECT 1 FROM Medicine WHERE MName = 'Medicine K';
		--exists same medicine name
		IF EXISTS (SELECT 1 FROM Medicine WHERE MName = @MedicineName)
		BEGIN
			--SELECT MID FROM Medicine WHERE MName = 'Medicine A';
			SELECT @NewMedicineID = MID FROM Medicine WHERE MName = @MedicineName;
			
		END

		--not exists medicine name
		ELSE
		BEGIN
			
			--SELECT * FROM Medicine ORDER BY MID DESC ;
			--SET @LatestMedicineID = 'M0016'
			SELECT @LatestMedicineID = ISNULL(MAX(MID), 'M0') -- Assuming 'M000' is the starting value for MedicineID
			FROM Medicine

			-- Extract the numeric part of the MedicineID
			DECLARE @NumericPart INT;
			SET @NumericPart = CAST(SUBSTRING(@LatestMedicineID, 2, LEN(@LatestMedicineID)) AS INT); --get the last digit
		
			-- Increment the numeric part
			SET @NumericPart = @NumericPart + 1;

			-- Format the new MedicineID with leading zeros
			SET @NewMedicineID = 'M' + RIGHT('0' + CAST(@NumericPart AS NVARCHAR(10)), 4); 

			-- Print the value
			--PRINT 'Latest MedicineID: ' + @NewMedicineID;
			
			INSERT INTO Medicine (MID, MName) VALUES (@NewMedicineID, @MedicineName);
		END

		
		

		/*Insert to Prescription table*/
		-- GET DoctorID based on loginID, and insert to PrescriptionMedicine table
		IF NOT EXISTS (SELECT 1 FROM Staff WHERE SystemUserID = @DoctorID)
		BEGIN
			PRINT 'DoctorID does not exist in the Staff table.';
		END
		ELSE
		BEGIN
			-- Get the DoctorID based on SystemUserID
			DECLARE @DoctorIDInTable NVARCHAR(6);
			SELECT @DoctorIDInTable = StaffID FROM Staff WHERE SystemUserID = @DoctorID; --get StaffID based on loginID

			-- Insert the prescription details into the Prescription table
			INSERT INTO Prescription (PatientID, DoctorID, PharmacistID, PresDateTime)
			VALUES (@PatientID, @DoctorIDInTable, 'S005', GETDATE());
			PRINT 'insert Precription can'
		END 



		/*Insert to PrescriptionMedicine*/
		-- Insert medicine IDs into PrescriptionMedicine table
		INSERT INTO PrescriptionMedicine (PresID, MedID) VALUES (@LatestPrescriptionID, @NewMedicineID);


		-- After the INSERT INTO PrescriptionMedicine
		--SELECT 'Rows in PrescriptionMedicine:', COUNT(*) FROM PrescriptionMedicine WHERE PresID = @LatestPrescriptionID;

		EXEC dbo.ManagePrescription
            @PatientID = @PatientID,
            @DoctorID = @DoctorID,
			@MedicineName = @MedicineName,
            @Action = 'SELECT';

		
	END -- END IF 'Insert'





	
	/* SELECT STATEMETN to check own's patient medicine details*/
	ELSE IF @Action = 'SELECT'
	BEGIN
		SELECT 
			PID AS [Patient ID],
			PName AS [Patient Name],
			PPassportNumber AS [Patient Passport Number],
			PPhone AS [Patient Phone Number],
			[Doctor Name],
			STRING_AGG(MedicineName, ', ') AS [Medicine Names]
		FROM (
			SELECT DISTINCT 
				Patient.PID,
				PName,
				PPassportNumber,
				PPhone,
				Staff.SName AS [Doctor Name],
				Medicine.MNAME AS MedicineName
			FROM Patient
			INNER JOIN Prescription ON Prescription.PatientID = Patient.PID
			INNER JOIN Staff ON Staff.StaffID = Prescription.DoctorID
			INNER JOIN PrescriptionMedicine ON PrescriptionMedicine.PresID = Prescription.PresID
			INNER JOIN Medicine ON Medicine.MID = PrescriptionMedicine.MedID
			WHERE Staff.SystemUserID = @DoctorID AND PID = @PatientID
		) AS DistinctMedicines
		GROUP BY PID, PName, PPassportNumber, PPhone, [Doctor Name];


	END -- END ELSE IF 'SELECT'







	ELSE IF @Action = 'UPDATE'
    BEGIN

		--IF Input DoctorID = CurrentID 
		IF @DoctorID = CURRENT_USER
		BEGIN

			DECLARE @UpdatePresID int; --user for update new medicine
			DECLARE @UpdateMedicineID NVARCHAR(50); --check precriptionmedicine table exist
			DECLARE @UpdateDoctorID NVARCHAR(6);
			--SELECT TOP 1 @UpdatePresID = PresID FROM Prescription WHERE PatientID = 'P001' AND DoctorID = 'S001' ORDER BY PresDateTime DESC;
			--print @UpdatePresID;

			--check exist patientID, doctorID and MedicineID info in database
			IF EXISTS (SELECT 1 FROM Staff WHERE SystemUserID = @DoctorID)
			BEGIN
				SELECT @UpdateDoctorID = StaffID FROM Staff WHERE SystemUserID = @DoctorID;

				--if exists both, in Prescription table
				IF EXISTS (SELECT 1 FROM Prescription WHERE PatientID = @PatientID AND DoctorID = @UpdateDoctorID)
				BEGIN
					--Get PresID from Prescription table
					SELECT TOP 1  @UpdatePresID = PresID FROM Prescription WHERE PatientID = @PatientID AND DoctorID = @UpdateDoctorID ORDER BY PresDateTime DESC;
				
					--if exists medicine record
					IF EXISTS (SELECT 1 FROM PrescriptionMedicine WHERE PresID = @UpdatePresID)
					BEGIN
						--get MedicineID
						SELECT @UpdateMedicineID = MID FROM Medicine WHERE MName = @MedicineName;

						-- update 'Prescription' table
						UPDATE PrescriptionMedicine
						SET MedID = @UpdateMedicineID --update medicine id
						WHERE PresID = @UpdatePresID; -- check if update presID

					END
				END
				ELSE
				BEGIN
					PRINT 'PatientID and DoctorID do not exist in the Prescription table.';
				END

			END -- end check exists
		END --end if inputDoctorID = Current_user
		ELSE 
		BEGIN 
			 -- The @DoctorID is not the current user
			 PRINT 'The DoctorID is not the current user, You NOT Allow to update other doctor medicine';

		END --end if NOT inputDoctorID = Current_user
	END --end else if 'UPDATE'


		
	/*DELETE the Medicine*/
	ELSE IF @Action = 'DELETE'
    BEGIN
		--IF Input DoctorID = CurrentID 
		IF @DoctorID = CURRENT_USER
		BEGIN

			DECLARE @DeletePresID int; --user for update new medicine
			DECLARE @DeleteMedicineID NVARCHAR(50); --check precriptionmedicine table exist
			DECLARE @DeleteDoctorID NVARCHAR(6);
			/*
			DECLARE @DeletePresID int
			SELECT TOP 1 @DeletePresID = p.PresID
				FROM Prescription AS p
				INNER JOIN PrescriptionMedicine AS pm ON p.PresID = pm.PresID
				INNER JOIN Medicine AS m ON pm.MedID = m.MID
				WHERE p.PatientID = 'P001'
				  AND m.MName = 'Medicine A'
				  AND p.DoctorID = 'S001'
				ORDER BY PresDateTime DESC;
			print @DeletePresID

			SELECT  1 
				FROM Prescription AS p
				INNER JOIN PrescriptionMedicine AS pm ON p.PresID = pm.PresID
				INNER JOIN Medicine AS m ON pm.MedID = m.MID
				WHERE p.PatientID = 'P001'
				  AND m.MName = 'Medicine A'
				  AND p.DoctorID = 'S001'
				ORDER BY PresDateTime DESC;		
			*/
			SELECT @DeleteDoctorID = StaffID FROM Staff WHERE SystemUserID = @DoctorID;
			IF EXISTS (
				SELECT 1
				FROM Prescription AS p
				INNER JOIN PrescriptionMedicine AS pm ON p.PresID = pm.PresID
				INNER JOIN Medicine AS m ON pm.MedID = m.MID
				WHERE p.PatientID = @PatientID
				  AND p.DoctorID = @DeleteDoctorID
				  AND m.MName = @MedicineName
			)
			BEGIN
				SELECT TOP 1 @DeletePresID = p.PresID FROM Prescription AS p
				INNER JOIN PrescriptionMedicine AS pm ON p.PresID = pm.PresID
				INNER JOIN Medicine AS m ON pm.MedID = m.MID
				WHERE 
				  p.PatientID = @PatientID
				  AND m.MName = @MedicineName
				  AND p.DoctorID = @DeleteDoctorID
				  ORDER BY PresDateTime DESC

				  --DELETE FROM PrescriptionMedicine WHERE MedID = 'M0011';
				  --DELETE FROM Medicine WHERE MID = 'M0011';

				-- Delete records from PrescriptionMedicine table
				DELETE FROM PrescriptionMedicine WHERE PresID = @DeletePresID;

				-- Delete record from Prescription table
				DELETE FROM Prescription WHERE PresID = @DeletePresID;
			END
			ELSE
				BEGIN
					PRINT 'NOT FOUND the Medicine or Patient information in Database';
			END -- end check exist
		END -- end if inputDoctorID == Current_user
		ELSE
		BEGIN
			 -- The @DoctorID is not the current user
			 PRINT 'The DoctorID is not the current user, You NOT Allow to DELETE other doctor medicine';

		END --end if NOT inputDoctorID = Current_user

     END --end else if 'DELETE'


	
END --end whole procedure

GO


--DROP PROCEDURE dbo.ManagePrescription;

-- Grant EXECUTE permission on the stored procedure to the user or role
GRANT EXECUTE ON dbo.ManagePrescription TO DoctorRole;

--REVOKE EXECUTE ON dbo.ManagePrescription TO DoctorRole;




/**************************************END Procedure for Doctor *********************************************************************************/