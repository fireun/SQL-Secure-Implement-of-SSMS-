

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

		END
	END --end else if 'UPDATE'



	/*DELETE the Medicine*/
	ELSE IF @Action = 'DELETE'
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
		END
     END --end else if 'DELETE'

	
	
END --end whole procedure

GO


DROP PROCEDURE dbo.ManagePrescription;


-- Declare and grant permission
-- Grant EXECUTE permission on the stored procedure to the user or role
GRANT EXECUTE ON dbo.ManagePrescription TO DoctorRole;

REVOKE EXECUTE ON dbo.ManagePrescription TO DoctorRole;



-- included Task 5 & Task 6 (INSERT, UPDATE, DELETE Patient Medicine Details)
EXEC dbo.UpdateSecurityPolicies;
print Current_User;


/* Doctor Add Medicine to Patient*/

DECLARE @CurrentUser NVARCHAR(10);
-- Execute the stored procedure
SET @CurrentUser = CURRENT_USER;

SELECT TOP 1 * FROM Prescription WHERE PatientID = 'P001' ORDER BY PresDateTime DESC
SELECT * FROM Medicine;

-- Execute the stored procedure
EXEC dbo.ManagePrescription
    @PatientID = 'P001',
	@DoctorID = @CurrentUser,
	@MedicineName = 'Medicine O',
    @Action = 'INSERT';
	
--check just insert details
SELECT TOP 1 P.PresID, P.PatientID, P.DoctorID, P.PharmacistID, P.PresDateTime, Medicine.MID AS MedicineID, Medicine.MName
FROM Prescription P 
INNER JOIN PrescriptionMedicine PM ON PM.PresID = P.PresID
INNER JOIN Medicine ON Medicine.MID = PM.MedID
WHERE P.PatientID = 'P001'
ORDER BY PresDateTime DESC


DECLARE @CurrentUser NVARCHAR(10);
-- Execute the stored procedure
SET @CurrentUser = CURRENT_USER;
EXEC dbo.ManagePrescription
    @PatientID = 'P001',
	@DoctorID = @CurrentUser,
	@MedicineName = 'Medicine K',
    @Action = 'UPDATE';

--check just UPDATE details
SELECT TOP 1 P.PresID, P.PatientID, P.DoctorID, P.PharmacistID, P.PresDateTime, Medicine.MID AS MedicineID, Medicine.MName
FROM Prescription P 
INNER JOIN PrescriptionMedicine PM ON PM.PresID = P.PresID
INNER JOIN Medicine ON Medicine.MID = PM.MedID
WHERE P.PatientID = 'P001'
ORDER BY PresDateTime DESC


DECLARE @CurrentUser NVARCHAR(10);
-- Execute the stored procedure
SET @CurrentUser = CURRENT_USER;
EXEC dbo.ManagePrescription
    @PatientID = 'P001',
	@DoctorID = @CurrentUser,
	@MedicineName = 'Medicine K',
    @Action = 'DELETE';

--check just DELETE details
SELECT TOP 1 P.PresID, P.PatientID, P.DoctorID, P.PharmacistID, P.PresDateTime, Medicine.MID AS MedicineID, Medicine.MName
FROM Prescription P 
INNER JOIN PrescriptionMedicine PM ON PM.PresID = P.PresID
INNER JOIN Medicine ON Medicine.MID = PM.MedID
WHERE P.PatientID = 'P001'
ORDER BY PresDateTime DESC







	/*




--create procedure to UPDATE and DELETE
-- Create a user-defined table type for the list of medicines
CREATE TYPE dbo.MedicineListType AS TABLE
(
    MedicineName NVARCHAR(50)
);

GO


-- Create the stored procedure with a table-valued parameter
CREATE PROCEDURE dbo.ManagePrescription
    @PatientID NVARCHAR(6),
	@DoctorID NVARCHAR(10),
    @Medicines dbo.MedicineListType READONLY,
    @Action VARCHAR(10) -- 'INSERT', 'UPDATE', 'DELETE'
AS
BEGIN
    -- Table variable to store the list of medicine names and their corresponding MedicineIDs
    DECLARE @MedicineTable TABLE
    (
        MedicineName NVARCHAR(50),
        MedicineID NVARCHAR(10)
    );


	-- Handle different actions
	IF @Action = 'INSERT'
	BEGIN
		-- Get the latest PrescriptionID
		DECLARE @LatestPrescriptionID INT;
		SELECT @LatestPrescriptionID = ISNULL(MAX(PresID), 0) + 1 --get latest PresID + 1
		FROM Prescription;


		IF NOT EXISTS (
			SELECT 1
			FROM @Medicines mt
			WHERE NOT EXISTS (
				SELECT 1
				FROM Medicine m
				WHERE m.MName = mt.MedicineName
			)
		)
		BEGIN
			-- All medicine names exist in the Medicine table
			PRINT 'All medicine names exist in the Medicine table.';
		END
		ELSE
		BEGIN
			-- At least one medicine name does not exist in the Medicine table
			PRINT 'At least one medicine name does not exist in the Medicine table.';
		END

		
		-- Get the latest MedicineID
		DECLARE @LatestMedicineID NVARCHAR(10);
		--SET @LatestMedicineID = 'M0016'
		SELECT @LatestMedicineID = ISNULL(MAX(MID), 'M00') -- Assuming 'M000' is the starting value for MedicineID
		FROM Medicine;

		-- Extract the numeric part of the MedicineID
		DECLARE @NumericPart INT;
		SET @NumericPart = CAST(SUBSTRING(@LatestMedicineID, 2, LEN(@LatestMedicineID)) AS INT); --get the last digit
		
		-- Increment the numeric part
		SET @NumericPart = @NumericPart + 1;

		-- Format the new MedicineID with leading zeros
		DECLARE @NewMedicineID NVARCHAR(10);
		SET @NewMedicineID = 'M' + RIGHT('000' + CAST(@NumericPart AS NVARCHAR(10)), 4); 

		-- Print the value
		--PRINT 'Latest MedicineID: ' + @NewMedicineID;
		PRINT 'Latest MedicineID: ' + @NewMedicineID;



		
		MERGE INTO Medicine AS target --Medicine table from database
		USING (SELECT DISTINCT MedicineName FROM @Medicines) AS source --select ALL difference from @Medicines_Input_MedicineName(NOT Duplicated)  --USING are match only one column when more than one column match
		ON target.MName = source.MedicineName --target.MName means Medicine.MName, source.MedicineName means list of input medicine
		WHEN MATCHED THEN --if input_medicine_name existing
			UPDATE SET MName = source.MedicineName
		WHEN NOT MATCHED THEN
			 INSERT (MID, MName) VALUES (@NewMedicineID,source.MedicineName)
		--COALESCE is check MID it's not null, else will get the @NewMidicineID, it will insert to @MedicineTable
		OUTPUT COALESCE(inserted.MID, @NewMedicineID), source.MedicineName INTO @MedicineTable (MedicineID, MedicineName);

		PRINT 'Merge can update';
		
		--SELECT * FROM @MedicineTable;



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
		INSERT INTO PrescriptionMedicine (PresID, MedID)
		SELECT @LatestPrescriptionID, MedicineID
		FROM @MedicineTable;
		PRINT 'insert PerscriptionMedicine can ';

		-- After the INSERT INTO PrescriptionMedicine
		--SELECT 'Rows in PrescriptionMedicine:', COUNT(*) FROM PrescriptionMedicine WHERE PresID = @LatestPrescriptionID;

		EXEC dbo.ManagePrescription
            @PatientID = @PatientID,
            @DoctorID = @DoctorID,
            @Action = 'SELECT';

		
	END





	
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


	END
	

	
END
	/*
    -- Handle different actions
    IF @Action = 'INSERT'
    BEGIN	

		-- Get the latest PrescriptionID
		DECLARE @LatestPrescriptionID INT;
		SELECT @LatestPrescriptionID = ISNULL(MAX(PresID), 0) + 1 --get latest PresID + 1
		FROM Prescription
		WHERE PatientID = @PatientID;

		-- Insert new medicines into the Medicine table and retrieve their MedicineIDs
		INSERT INTO Medicine (MName)
		OUTPUT inserted.MName, inserted.MID INTO @MedicineTable (MedicineName, MedicineID)
		SELECT MedicineName
		FROM @Medicines;

		-- Insert medicine IDs into PrescriptionMedicine table
		INSERT INTO PrescriptionMedicine (PresID, MedID)
		SELECT @LatestPrescriptionID, MedicineID
		FROM @MedicineTable;

		-- Insert the prescription details into the Prescription table
		INSERT INTO Prescription (PatientID, DoctorID, PharmacistID, PresDateTime)
		VALUES (@PatientID, @DoctorID, 'S005', GETDATE());
    END
	
	*/

	/*
    ELSE IF @Action = 'UPDATE'
    BEGIN
        -- Update medicines in the Medicine table and retrieve their updated MedicineIDs
        UPDATE Medicine
        SET MedName = m.MedicineName
        OUTPUT inserted.MedName, inserted.MedID INTO @MedicineTable (MedicineName, MedicineID)
        FROM @Medicines m
        WHERE EXISTS (SELECT 1 FROM Medicine WHERE MedID = m.MedicineID);

        -- Update PrescriptionMedicine table
        DELETE FROM PrescriptionMedicine WHERE PresID = @PresID;

        -- Insert updated medicine IDs into PrescriptionMedicine table
        INSERT INTO PrescriptionMedicine (PresID, MedicineID)
        SELECT @PresID, mt.MedicineID
        FROM @MedicineTable;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        -- Delete records from PrescriptionMedicine table
        DELETE FROM PrescriptionMedicine WHERE PresID = @PresID;

        -- Delete record from Prescription table
        DELETE FROM Prescription WHERE PresID = @PresID;
    END
END;

*/
GO


DROP PROCEDURE dbo.ManagePrescription;
DROP TYPE dbo.MedicineListType;

-- Declare and grant permission
DECLARE @Medicines dbo.MedicineListType; 
GRANT EXECUTE ON TYPE::dbo.MedicineListType TO DoctorRole;
-- Grant EXECUTE permission on the stored procedure to the user or role
GRANT EXECUTE ON dbo.ManagePrescription TO DoctorRole;

REVOKE EXECUTE ON TYPE::dbo.MedicineListType TO DoctorRole;
REVOKE EXECUTE ON dbo.ManagePrescription TO DoctorRole;


EXEC dbo.UpdateSecurityPolicies;
print Current_User;



/* Doctor Add Medicine to Patient*/

DECLARE @Medicines dbo.MedicineListType;

-- Insert into @Medicines
INSERT INTO @Medicines VALUES ('Medicine A');
--INSERT INTO @Medicines VALUES ('Medicine1','Medicine 2');

-- Check the contents of @Medicines
SELECT * FROM @Medicines;

DECLARE @CurrentUser NVARCHAR(10);
-- Execute the stored procedure
SET @CurrentUser = CURRENT_USER;

-- Execute the stored procedure
EXEC dbo.ManagePrescription
    @PatientID = 'P001',
	@DoctorID = @CurrentUser,
	@Medicines = @Medicines,
    @Action = 'INSERT';





-- Execute the stored procedure for UPDATE action
EXEC ManagePrescription
    @PresID = 1, -- Specify the PresID you want to update
    @PatientID = 123,
    @Medicines = @Medicines,
    @Action = 'UPDATE';

-- Execute the stored procedure for DELETE action
EXEC ManagePrescription
    @PresID = 1, -- Specify the PresID you want to delete
    @Action = 'DELETE';


--7. Doctor can check all patient's medicine details INCLUDE medication given by other doctor
/*
SELECT 
    P.PName AS [Patient Name],
	Prescription.DoctorID AS [Doctor],
    Medicine.MNAME AS [Medicine Name]
FROM 
    Patient AS P
INNER JOIN 
    Prescription ON Prescription.PatientID = P.PID
INNER JOIN 
    PrescriptionMedicine ON PrescriptionMedicine.PresID = Prescription.PresID
INNER JOIN 
    Medicine ON Medicine.MID = PrescriptionMedicine.MedID

SELECT 
    P.PName AS [Patient Name],
    Prescription.DoctorID AS [Doctor],
    Medicine.MNAME AS [Medicine Name],
    COUNT(*) AS [Prescription Count]
FROM 
    Patient AS P
INNER JOIN 
    Prescription ON Prescription.PatientID = P.PID
INNER JOIN 
    PrescriptionMedicine ON PrescriptionMedicine.PresID = Prescription.PresID
INNER JOIN 
    Medicine ON Medicine.MID = PrescriptionMedicine.MedID
GROUP BY 
    P.PName, Prescription.DoctorID, Medicine.MNAME;
*/


/*
-- Allow to check others doctor and all patient's medicine details 
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

SELECT * FROM Prescription;


--display all the own patient medicine detail and medicine given by other doctor
--need two procedure, first get the patient ID, second select * where patient ID = from first one.

*/

/*

SELECT 
    P.PName AS [Patient Name],
	Prescription.PresID AS [Pres ID],
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
WHERE 
	Prescription.DoctorID = 'S001'
GROUP BY 
    P.PName, Prescription.PresID,Prescription.DoctorID, Medicine.MNAME;
GO

*/