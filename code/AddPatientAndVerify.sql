USE MedicalInfoSystem_Grp23

select * from dbo.Patient

select * from dbo.AuthorizationMatrix
--update table column name
--EXEC sp_rename 'dbo.Patient.PPassportNumber', 'PassportNumber', 'COLUMN'; //Table.OldColumnName, NewColumnName



-- Create a Users table
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL,
    PasswordHash NVARCHAR(100) NOT NULL
);

-- Sample SQL for user registration (assumes hashed passwords are provided)
INSERT INTO Users (Username, PasswordHash)
VALUES ('Dave', 'password');


--Select * from dbo.Users
--delete from dbo.Users where users.UserID = 2

-- Sample SQL for user login
DECLARE @InputUsername NVARCHAR(50) = 'Dave';
DECLARE @InputPassword NVARCHAR(100) = 'password'; -- Hash the input password
DECLARE @LoggedInUserID INT;



SET @LoggedInUserID = (SELECT UserID  
FROM dbo.Users
WHERE Username = @InputUsername
AND PasswordHash = @InputPassword);
GO

--print(@LoggedInUserID)

--Access Control
-- Create a view to filter personal details for the logged-in user
CREATE VIEW vw_PatientPersonalDetails 
	AS
	SELECT Users.UserID, Users.Username, Patient.PName, Patient.PassportNumber, Patient.PPhone, Patient.PaymentCardNumber, Patient.PaymentCardPinCode
	FROM dbo.Patient, dbo.Users
	WHERE Users.UserID = @LoggedInUserID;
GO



-- Create a stored procedure to access medications for the logged-in patient
CREATE PROCEDURE sp_GetPatientMedications
    @PatientUserID INT
AS
BEGIN
    SELECT Medicine.MName
    FROM dbo.Medicine,dbo.Patient, dbo.Prescription, dbo.PrescriptionMedicine
    WHERE Patient.SystemUserID = @PatientUserID AND Patient.PID = Prescription.PatientID AND Prescription.PresID = PrescriptionMedicine.PresID;
END;

-- Execute the stored procedure for a specific patient (e.g., PatientUserID = 123)
EXEC sp_GetPatientMedications @PatientUserID = @LoggedInUserID;
GO