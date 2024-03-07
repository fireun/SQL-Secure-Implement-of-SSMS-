
DECLARE @LatestMedicineID NVARCHAR(10);
SELECT @LatestMedicineID = ISNULL(MAX(MID), 'M0') FROM Medicine;

DECLARE @NumericPart INT;
SET @NumericPart = CAST(SUBSTRING(@LatestMedicineID, 2, LEN(@LatestMedicineID)) AS INT); 
--starting from the second character (excluding 'M')
--CAST to convert the substring to an integer.

SET @NumericPart = @NumericPart + 1;

DECLARE @NewMedicineID NVARCHAR(10);
SET @NewMedicineID = 'M' + RIGHT('0' + CAST(@NumericPart AS NVARCHAR(10)), 3);
-- RIGHT to add leading zeros by concatenating the numeric part with '0'

PRINT 'Latest MedicineID: ' + @LatestMedicineID;
PRINT 'New MedicineID: ' + @NewMedicineID;


