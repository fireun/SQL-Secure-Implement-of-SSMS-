/*Admin RUN*/

DROP PROCEDURE dbo.TestMedicineListType1;
DROP TYPE dbo.MedicineListType1;


-- Create the type
CREATE TYPE dbo.MedicineListType1 AS TABLE
(
    MedicineName1 NVARCHAR(50)
);

GO

-- Create a stored procedure using the type
CREATE PROCEDURE TestMedicineListType1
    @Medicines1 dbo.MedicineListType1 READONLY
AS
BEGIN
    -- Use the type within the procedure
    SELECT DISTINCT MedicineName1 FROM @Medicines1;
END;

DECLARE @Medicines1 dbo.MedicineListType1;
GRANT EXECUTE ON TYPE::dbo.MedicineListType1 TO DoctorRole;
-- Grant EXECUTE permission on the stored procedure to the user or role
GRANT EXECUTE ON dbo.TestMedicineListType1 TO DoctorRole;




/*Doctor RUN*/
EXEC dbo.UpdateSecurityPolicies;
print Current_User;

-- Declare a variable of the type
DECLARE @Medicines1 dbo.MedicineListType1;

-- Insert values into the variable
INSERT INTO @Medicines1 VALUES ('Medicine1'), ('Medicine2'), ('Medicine 1'), ('Medicine2');

-- Execute the stored procedure
EXEC TestMedicineListType1 @Medicines1;










/* Test : IF & ELSE Statement with return exist value from tabl*/
PRINT CURRENT_USER;
DECLARE @DoctorID1 VARCHAR(10);
SET @DoctorID1  = 'SFefwef';
--PRINT @DoctorID1;

SELECT 1 FROM Staff WHERE SystemUserID = @DoctorID1;
IF NOT EXISTS (SELECT 1 FROM Staff WHERE SystemUserID = @DoctorID1)
		BEGIN
			PRINT 'DoctorID does not exist in the Staff table.';
		END
	ELSE
		BEGIN
			PRINT 'Exits';
		END


DECLARE @LatestPrescriptionID INT;
		SELECT @LatestPrescriptionID = ISNULL(MAX(PresID), 0) + 1 --get latest PresID + 1
		FROM Prescription;
PRINT @LatestPrescriptionID

SELECT * FROM Prescription
SELECT * FROM PrescriptionMedicine



-- Before the INSERT INTO PrescriptionMedicine
SELECT @LatestPrescriptionID AS LatestPrescriptionID;

-- Insert medicine IDs into PrescriptionMedicine table
INSERT INTO PrescriptionMedicine (PresID, MedID)
SELECT @LatestPrescriptionID, MedicineID
FROM @MedicineTable;

-- After the INSERT INTO PrescriptionMedicine
SELECT 'Rows in PrescriptionMedicine:', COUNT(*) FROM PrescriptionMedicine WHERE PresID = @LatestPrescriptionID;


 