USE MedicalInfoSystem_Grp23


-------------------------------------------------------
--						Task						--	
-------------------------------------------------------
/*
1. Patient can check him's doctor own medicine, NOT change or delete (Done)
2. Patient can't access other Patient info or medicine info (Done)
3. Nurses & Doctor can check patient personal info EXCEPT sensitive details
4. Nurses can check patient medicine details BUT NOT insert, update, or delete
5. Doctor can insert new medicine details for their patient
6. Doctor can update and delete thier medicine details
7. Doctor can check all patient's medicine details INCLUDE medication given by other details
8. Doctor CAN'T update or delete other doctor medicine details
*/
-------------------------------------------------------


--After user login, check role & change policies
EXEC dbo.UpdateSecurityPolicies;

print Current_User;

/******************************************	Patient Test ******************************************/
--1. Patient can check him's doctor own medicine, NOT change or delete (Done)
--2. Patient can't access other Patient info or medicine info (Done)


--Task 1: Patient check their own personal details
SELECT 
	PName AS [Full NAME],
	PPassportNumber AS [Passport Number],
	PPhone AS [Phone Number],
	PaymentCardNumber AS [Payment Card Number],
	PaymentCardPinCode AS [Payment Card Pin Code]
	FROM 
		Patient;

/*
--patient cant check PID & SystemUserID
SELECT 
	SystemUserID AS Username
	FROM 
		Patient;
*/

--UPDATE Personal Details include 'Passport Number, Phone, Payment Card Number & Pin Code' only allowed.
UPDATE Patient
SET PPassportNumber = '12345',
    PPhone = '012-345-6789',
    PaymentCardNumber = '987654321',
	PaymentCardPinCode = 321
WHERE Patient.SystemUserID = CURRENT_USER;


SELECT 
	PName AS [Full NAME],
	PPassportNumber AS [Passport Number],
	PPhone AS [Phone Number],
	PaymentCardNumber AS [Payment Card Number],
	PaymentCardPinCode AS [Payment Card Pin Code]
	FROM 
		Patient;
		

--patient update the deny permission rule
UPDATE Patient
SET SystemUserID = 'user900',
    PName = 'Jasons'
WHERE Patient.SystemUserID = CURRENT_USER;




--update back the data
UPDATE Patient
SET PPassportNumber = '456789',
    PPhone = '016-4573-9134',
    PaymentCardNumber = '1234567812345678',
	PaymentCardPinCode = 124
WHERE Patient.SystemUserID = CURRENT_USER;

SELECT 
	PName AS [Full NAME],
	PPassportNumber AS [Passport Number],
	PPhone AS [Phone Number],
	PaymentCardNumber AS [Payment Card Number],
	PaymentCardPinCode AS [Payment Card Pin Code]
	FROM 
		Patient;
		

--Task 2: Check personal medicine details
--doctor name, pharmacistID, patient name, presdatetime,medicine name
--inner join
SELECT 
    P.PName AS [Patient Name],
	Prescription.DoctorID AS [Doctor],
	Prescription.PresDateTime AS [Pharmacist Date],
    STRING_AGG(MName, ', ') AS [Medicine Names]
FROM 
    Patient AS P
INNER JOIN 
    Prescription ON Prescription.PatientID = P.PID
INNER JOIN 
    PrescriptionMedicine ON PrescriptionMedicine.PresID = Prescription.PresID
INNER JOIN 
    Medicine ON Medicine.MID = PrescriptionMedicine.MedID
WHERE 
    P.[SystemUserID] = CURRENT_USER
GROUP BY P.PName, Prescription.PresID, Prescription.DoctorID, Prescription.PresDateTime;



/******************************************	End Patient Test ******************************************/




EXEC dbo.UpdateSecurityPolicies;

print Current_User;
/******************************************	Nurses Test ******************************************/
--3. Nurses can CHECK & UPDATE patient personal info EXCEPT sensitive  details  
--4. Nurses can check patient medicine details BUT NOT insert, update, or delete


--CHECK & UPDATE their own personal detail
SELECT TOP (1000) [StaffID]
      ,[SName]
      ,[SPassportNumber]
      ,[SPhone]
      ,[SystemUserID]
      ,[Position]
  FROM [MedicalInfoSystem_test].[dbo].[Staff]
  WHERE SystemUserID = CURRENT_USER




--Nurses allow change personal details
UPDATE Staff
SET 
	[SPassportNumber] = '642165',
    [SPhone] = '018-654-2359'
WHERE SystemUserID = CURRENT_USER;

SELECT * FROM Staff;


--Nurses deny change personal details
UPDATE Staff
SET [StaffID] = 'S0009',
    [Position] = 'Dcotor'
WHERE SystemUserID = CURRENT_USER;


--reset back data
UPDATE Staff
SET 
	[SPassportNumber] = '789012',
    [SPhone] = '013-456-7890'
WHERE SystemUserID = CURRENT_USER;

SELECT * FROM Staff;






--Task 3: Nurses can CHECK & UPDATE patient personal, EXCEPT sensitive details
--CHECK ALL PATIENT
SELECT 
	PID AS [Patient ID],
	PName AS [Patient Name],
	PPassportNumber AS [Patient Passport Number],
	PPhone AS [Patient Phone Number]
FROM Patient

--nurses not allow access patient's sensitive details
SELECT 
	[SystemUserID],
	PaymentCardNumber AS [Payment Card Number],
	PaymentCardPinCode AS [Payment Card Pin Code]
FROM Patient


--nurses UPDATE Not allow permission
SELECT 
	PID AS [Patient ID],
	PName AS [Patient Name],
	PPassportNumber AS [Patient Passport Number],
	PPhone AS [Patient Phone Number]
FROM Patient
WHERE PID = 'P001';

-- UPDATE Deny permission
UPDATE Patient
SET PPassportNumber = '12345',
    PPhone = '012-345-6789',
    PaymentCardNumber = '987654321',
	PaymentCardPinCode = 321,
	[SystemUserID] = 'user202'
WHERE Patient.PID = 'P001';


-- Task 4: CHECK any patient's medicine details without ADD, EDIT, DELETE
/*SELECT 
    P.PName AS [Patient Name],
	Prescription.DoctorID AS [Doctor],
    STRING_AGG(MName, ', ') AS [Medicine Names]
FROM 
    Patient AS P
INNER JOIN 
    Prescription ON Prescription.PatientID = P.PID
INNER JOIN 
    PrescriptionMedicine ON PrescriptionMedicine.PresID = Prescription.PresID
INNER JOIN 
    Medicine ON Medicine.MID = PrescriptionMedicine.MedID
WHERE 
    P.PID = 'P001'
GROUP BY P.PName, Prescription.DoctorID;
*/

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
			Patient.PName,
			Patient.PPassportNumber,
			Patient. PPhone,
			Staff.SName AS [Doctor Name],
			Medicine.MNAME AS MedicineName
		FROM Patient 
		INNER JOIN Prescription ON Prescription.PatientID = Patient.PID
		INNER JOIN Staff ON Staff.StaffID = Prescription.DoctorID
		INNER JOIN PrescriptionMedicine ON PrescriptionMedicine.PresID = Prescription.PresID
		INNER JOIN Medicine ON Medicine.MID = PrescriptionMedicine.MedID
		WHERE Patient.PID = 'P001'
	) AS DistinctMedicines
	GROUP BY PID, PName, PPassportNumber, PPhone, [Doctor Name];



/******************************************	End Nurses Test ******************************************/







/******************************************	Doctor Test ******************************************/
--5. Doctor can insert new medicine details for their patient
--6. Doctor can update and delete thier medicine details
--7. Doctor can check all patient's medicine details INCLUDE medication given by other details
--8. Doctor CAN'T update or delete other doctor medicine details
--9. Doctor can check patient details EXCEPT sensitive details
EXEC dbo.UpdateSecurityPolicies;

print Current_User;

--CHECK & UPDATE their own personal detail
SELECT TOP (1000) [StaffID]
      ,[SName]
      ,[SPassportNumber]
      ,[SPhone]
      ,[SystemUserID]
      ,[Position]
  FROM [MedicalInfoSystem_test].[dbo].[Staff]
  WHERE SystemUserID = CURRENT_USER

UPDATE Staff
SET [SPassportNumber] = '546943',
    [SPhone] = '011-1352-9814'
WHERE SystemUserID = CURRENT_USER;

SELECT * FROM Staff;

--doctor deny change personal details (staffID and position)
UPDATE Staff
SET [StaffID] = 'S0009',
    [Position] = 'Nurses'
WHERE SystemUserID = CURRENT_USER;




--5. Doctor can insert new medicine details for their patient 
-- get MedicineName and PatientID, after do get MedicineID
-- get the lastest ID from Prescription, insert the medicine to the PrescriptionMedicine first, after pass the ID insert to Prescription
--display they own patient
SELECT 
	PID AS [Patient ID],
	PName AS [Patient Name],
	PPassportNumber AS [Patient Passport Number],
	PPhone AS [Patient Phone Number],
	Staff.SName AS [Doctor Name]
FROM Patient
INNER JOIN Prescription ON Prescription.PatientID = Patient.PID
INNER JOIN Staff ON Staff.StaffID = Prescription.DoctorID
WHERE Staff.SystemUserID = CURRENT_USER 
GROUP BY PID, PName, PPassportNumber, PPhone, Staff.SName;


--6. Doctor can update and delete thier medicine details
GO

/*

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


*/


-- included Task 5 & Task 6 (INSERT, UPDATE, DELETE Patient Medicine Details)
EXEC dbo.UpdateSecurityPolicies;
print Current_User;


/* Doctor Add Medicine to Patient*/

SELECT TOP 1 * FROM Prescription WHERE PatientID = 'P001' ORDER BY PresDateTime DESC
SELECT * FROM Medicine;


DECLARE @CurrentUser NVARCHAR(10);
-- Execute the stored procedure
SET @CurrentUser = CURRENT_USER;


-- Execute the stored procedure
EXEC dbo.ManagePrescription
    @PatientID = 'P001',
	@DoctorID = @CurrentUser,
	@MedicineName = 'Medicine P',
    @Action = 'INSERT';
	
--check just insert details
SELECT TOP 1 P.PresID, P.PatientID, P.DoctorID, P.PresDateTime, Medicine.MID AS MedicineID, Medicine.MName
FROM Prescription P 
INNER JOIN PrescriptionMedicine PM ON PM.PresID = P.PresID
INNER JOIN Medicine ON Medicine.MID = PM.MedID
WHERE P.PatientID = 'P001'
ORDER BY PresDateTime DESC



--update action
EXEC dbo.ManagePrescription
    @PatientID = 'P001',
	@DoctorID = 'user001',
	@MedicineName = 'Medicine B',
    @Action = 'UPDATE';

--check just UPDATE details
SELECT TOP 1 P.PresID, P.PatientID, P.DoctorID, P.PresDateTime, Medicine.MID AS MedicineID, Medicine.MName
FROM Prescription P 
INNER JOIN PrescriptionMedicine PM ON PM.PresID = P.PresID
INNER JOIN Medicine ON Medicine.MID = PM.MedID
WHERE P.PatientID = 'P001'
ORDER BY PresDateTime DESC



--delete action
EXEC dbo.ManagePrescription
    @PatientID = 'P001',
	@DoctorID = 'user001',
	@MedicineName = 'Medicine B',
    @Action = 'DELETE';

--check just DELETE details
SELECT TOP 1 P.PresID, P.PatientID, P.DoctorID, P.PresDateTime, Medicine.MID AS MedicineID, Medicine.MName
FROM Prescription P 
INNER JOIN PrescriptionMedicine PM ON PM.PresID = P.PresID
INNER JOIN Medicine ON Medicine.MID = PM.MedID
WHERE P.PatientID = 'P001'
ORDER BY PresDateTime DESC



-- SELECT
 EXEC dbo.ManagePrescription
    @PatientID = 'P001',
	@DoctorID = 'user001',
	@MedicineName = 'Medicine A',
    @Action = 'SELECT';





--7. Doctor can check their patient medicine details
--display all patient with medicine
SELECT 
    P.PName AS [Patient Name],
    Prescription.DoctorID AS [Doctor],
    STRING_AGG(Medicine.MNAME, ', ') AS [Medicine Names]
FROM 
    Patient AS P
INNER JOIN 
    Prescription ON Prescription.PatientID = P.PID
INNER JOIN 
    PrescriptionMedicine ON PrescriptionMedicine.PresID = Prescription.PresID
INNER JOIN 
    Medicine ON Medicine.MID = PrescriptionMedicine.MedID
GROUP BY 
    P.PName, Prescription.DoctorID;



--display thier medicine to patient, need run in one batch
-- First table get the patient ID
DECLARE @CURRENT_DOCTOR_ID NVARCHAR(6);

SELECT @CURRENT_DOCTOR_ID = StaffID FROM Staff WHERE SystemUserID = CURRENT_USER;

SELECT 
	P.PID AS PIDs INTO #TempPatientIDs
FROM 
	Patient P
INNER JOIN 
    Prescription ON Prescription.PatientID = P.PID
WHERE DoctorID = @CURRENT_DOCTOR_ID
GROUP BY P.PID;


SELECT * FROM #TempPatientIDs; --display temporary table
--DROP TABLE #TempPatientIDs; -- delete the remporary table	/* !!!After RUN Need drop this table*/

-- Second SELECT statement using the derived table
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
		WHERE Prescription.PatientID IN (SELECT #TempPatientIDS.PIDs FROM #TempPatientIDs)
	) AS DistinctMedicines
	GROUP BY PID, PName, PPassportNumber, PPhone, [Doctor Name];




 
	



--8. Doctor CAN'T update or delete other doctor medicine details
-- Prescription include DoctorID
-- PrescriptionMedicine include PresID
-- !!! DONE / Completed in procedure


-- Task 9: Doctor can CHECK Patient's Personal Details, EXCEPT sensitive details, CAN't EDIT or Delete
SELECT 
	PID AS [Patient ID],
	PName AS [Patient Name],
	PPassportNumber AS [Patient Passport Number],
	PPhone AS [Patient Phone Number]
FROM Patient

--Display All own patient's personal details
SELECT 
	PID AS [Patient ID],
	PName AS [Patient Name],
	PPassportNumber AS [Patient Passport Number],
	PPhone AS [Patient Phone Number],
	Staff.SName AS [Doctor Name]
FROM Patient
INNER JOIN Prescription ON Prescription.PatientID = Patient.PID
INNER JOIN Staff ON Staff.StaffID = Prescription.DoctorID
WHERE Staff.SystemUserID = CURRENT_USER
GROUP BY Patient.PID, Patient.PName, Patient.PPassportNumber, Patient.PPhone, Staff.SName;


-- Doctor unable to UPDATE patient personal details
UPDATE Patient
SET 
	PName = 'John Doe',
	PPhone = '016-45735-9134'
WHERE Patient.PID = 'P001';


--Doctor unable to DELETE patient personal details
DELETE FROM Patient WHERE PID = 'P001';




/******************************************	End Doctor Test ******************************************/


--Problem
------------------
--1. Patient Select Medicine 
--2. Nurse select patient
--3. doctor insert medicine, update medicine (not exiting medicine data, insert), duplicate own patient medicine details