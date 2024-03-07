  ---Authrization Matrix table
SELECT TOP (1000) [RoleName]
      ,[TableName]
      ,[PermissionType]
  FROM [MedicalInfoSystem_Grp23].[dbo].[AuthorizationMatrix]


  ---Medicine table
  SELECT TOP (1000) [MID]
      ,[MName]
  FROM [MedicalInfoSystem_Grp23].[dbo].[Medicine]

  ---Prescription table
  SELECT TOP (1000) [PresID]
      ,[PatientID]
      ,[DoctorID]
      ,[PharmacistID]
      ,[PresDateTime]
  FROM [MedicalInfoSystem_Grp23].[dbo].[Prescription]


  ---Patient table
  SELECT TOP (1000) [PID]
      ,[PName]
      ,[PassportNumber]
      ,[PPhone]
      ,[SystemUserID]
      ,[PaymentCardNumber]
      ,[PaymentCardPinCode]
  FROM [MedicalInfoSystem_Grp23].[dbo].[Patient]

    ---PrescriptionMedicine table
  SELECT TOP (1000) [PresID]
      ,[MedID]
  FROM [MedicalInfoSystem_Grp23].[dbo].[PrescriptionMedicine]


  ---Staff table
  SELECT TOP (1000) [StaffID]
      ,[SName]
      ,[SPassportNumber]
      ,[SPhone]
      ,[SystemUserID]
      ,[Position]
  FROM [MedicalInfoSystem_Grp23].[dbo].[Staff]

   ---[Users] table
  SELECT TOP (1000) [UserID]
      ,[Username]
      ,[PasswordHash]
  FROM [MedicalInfoSystem_Grp23].[dbo].[Users]


  --doctor check medicine
  -- SELECT Patient.PID, Medicine.MNAME
  --	FROM Patient WHERE PID='P001' OR PNAME='John Doe'
  --		INNER JOIN Prescription ON Patient.PID = Prescription.PatientID
  --		INNER JOIN PrescriptionMedicine ON Prescription.PresID = PrescriptionMedicine.PresID 
  --		INNER JOIN Medicine ON PrescriptionMedicine.MedID = Medicine.MID;

  --check table column type

  SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'Prescription';

  SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'PrescriptionMedicine';



SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'Medicine';


SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'Staff';