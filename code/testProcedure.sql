CREATE PROCEDURE dbo.DeletePrescription
    @PatientID NVARCHAR(6),
    @DoctorID NVARCHAR(10),
    @MedicineName NVARCHAR(50),
    @UserDecision CHAR(1) = NULL
AS
BEGIN
    DECLARE @PrescriptionID NVARCHAR(10);

    -- Check if the prescription exists
    SELECT TOP 1 @PrescriptionID = p.PresID
    FROM Prescription AS p
    INNER JOIN PrescriptionMedicine AS pm ON p.PresID = pm.PresID
    INNER JOIN Medicine AS m ON pm.MedID = m.MID
    WHERE p.PatientID = @PatientID
      AND p.DoctorID = @DoctorID
      AND m.MName = @MedicineName
    ORDER BY p.PresDateTime DESC;

    IF @PrescriptionID IS NOT NULL
    BEGIN
        -- Prescription found, prompt the doctor
        IF @UserDecision IS NULL
        BEGIN
            DECLARE @ErrorMessage NVARCHAR(255);
            SET @ErrorMessage = 'Prescription found for PatientID ' + @PatientID
                + ', DoctorID ' + @DoctorID + ', MedicineName ' + @MedicineName
                + '. Do you want to delete it? (Y/N)';

            -- Raise an error with the custom message
            THROW 50000, @ErrorMessage, 1;
        END
        ELSE IF UPPER(@UserDecision) = 'Y'
        BEGIN
            -- User decided to delete, perform the deletion
            DELETE FROM Prescription WHERE PresID = @PrescriptionID;
            PRINT 'Prescription deleted successfully.';
        END
        ELSE
        BEGIN
            -- User decided not to delete
            PRINT 'Prescription not deleted.';
        END
    END
    ELSE
    BEGIN
        -- Prescription not found
        PRINT 'Prescription not found for the specified patient, doctor, and medicine.';
    END
END;



EXEC dbo.DeletePrescription
    @PatientID = 'P001',
    @DoctorID = 'S001',
    @MedicineName = 'Medicine A',
	@UserDecision = 'Y';

DROP PROCEDURE dbo.DeletePrescription;