--Data Protection
--Group 23 (Tan Yan Shen - TP063627)

--SOLUTION 1: ENCRYPTION
--1.1 Enable Transparent Data Encryption (TDE) for the database
USE master;
GO

--Create a master key
CREATE MASTER KEY ENCRYPTION BY
PASSWORD = 'Grp23_MasterK3y';
GO

--Create certificate  
CREATE CERTIFICATE Cert_APUMC
WITH SUBJECT = 'APU MC Cert'
GO

USE MedicalInfoSystem_Grp23_Done;
GO

-- Create a database encryption key (DEK)
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE Cert_APUMC;
GO

-- Enable encryption on the database
ALTER DATABASE MedicalInfoSystem_Grp23_Done
SET ENCRYPTION ON;
-- close the encryption
--ALTER DATABASE MedicalInfoSystem_Grp23_Done
--SET ENCRYPTION OFF; 
GO

--Check sysmmetric key and certificates
USE master
SELECT * FROM sys.symmetric_keys
SELECT * FROM sys.certificates

-- Check the encryption status
SELECT name, is_encrypted
FROM sys.databases
WHERE name = 'MedicalInfoSystem_Grp23_Done';
--OR
--SELECT DB_NAME(a.database_id) AS DBName, a.encryption_state_desc,
--a.encryptor_type, b.name as 'DEK Encrypted By'
--FROM sys.dm_database_encryption_keys a
--INNER JOIN sys.certificates b ON a.encryptor_thumbprint = b.thumbprint;

--TDE Backup
--Backup and restrore certificate
--Backup
BACKUP CERTIFICATE Cert_APUMC
TO FILE = N'C:\APU_MC_BACKUP\Cert_APUMC.cert'
WITH PRIVATE KEY(
	FILE = N'C:\APU_MC_BACKUP\Cert_APUMC.key',
	ENCRYPTION BY PASSWORD = 'Grp23_MasterK3y'
);
GO

--Restore
--OPEN MASTER KEY DECRYPTION BY PASSWORD = 'Grp23_MasterK3y';
--CREATE CERTIFICATE Cert_APUMC
--FROM FILE = N'C:\APU_MC_BACKUP\Cert_APUMC.cert'
--WITH PRIVATE KEY(
--	FILE = N'C:\APU_MC_BACKUP\Cert_APUMC.key',
--DECRYPTION BY PASSWORD = 'Grp23_MasterK3y'
--);

USE master
Open Master Key Decryption By PASSWORD ='Grp23_MasterK3y'
BACKUP MASTER KEY TO FILE = N'C:\APU_MC_Backup\MasterKey.key'
ENCRYPTION BY password = 'Grp23_MasterK3y'
--RESTORE MASTER KEY
--FROM FILE = N'C:\APU_MC_Backup\MasterKey.key'
--ENCRYPTION BY PASSWORD = 'Grp23_MasterK3y'
--GO



-- 1.2: Column Level Encryption for customers' sensitive data
USE	MedicalInfoSystem_Grp23_Done;
GO

ALTER TABLE Patient
ADD PaymentCardNumEncrypted VARBINARY(MAX)

--Step 1 - Create Master Key
CREATE master key encryption by password = 'CLE_MasterK3y'
go
select * from sys.symmetric_keys
go

--Step 2 - Create Certificate to protect sym key
CREATE CERTIFICATE CLECert WITH SUBJECT = 'CLE Cert';
GO

--Step 3 - Create symmetric key
CREATE SYMMETRIC KEY SymKey
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE CLECert;
GO

OPEN SYMMETRIC KEY SymKey
DECRYPTION BY CERTIFICATE CLECert

UPDATE Patient
Set PaymentCardNumEncrypted =
ENCRYPTBYKEY(KEY_GUID('SymKey'),PaymentCardNumber)

CLOSE SYMMETRIC KEY SymKey

Select * From Patient
Select PID, PName, PaymentCardNumEncrypted
From Patient


--Delete Unencrypted Payment Card Number
ALTER TABLE Patient
DROP COLUMN PaymentCardNumber;



--DECRYPT
OPEN SYMMETRIC KEY	SymKey
DECRYPTION BY CERTIFICATE CLECert

Select PID, PName, CONVERT(varchar, DecryptByKey (PaymentCardNumEncrypted)) As Decrypted
From Patient

CLOSE SYMMETRIC KEY SymKey

GO


--give the permission of symkey to patient to view the encrypted data
GRANT CONTROL ON CERTIFICATE::CLECert TO PatientRole;
GRANT VIEW DEFINITION ON SYMMETRIC KEY::SymKey TO PatientRole;



--backup sym keys
Use MedicalInfoSystem_Grp23_Done
Go

OPEN SYMMETRIC KEY SymKey
DECRYPTION BY CERTIFICATE CLECert;

BACKUP SYMMETRIC KEY SymKey
   TO FILE = N'C:\APU_MC_Backup\MySymKey.key'
   ENCRYPTION BY PASSWORD = 'CLE_MasterK3y';

CLOSE SYMMETRIC KEY SymKey;

-- database masterkey
Use MedicalInfoSystem_Grp23_Done;
Go
Open Master Key Decryption By PASSWORD ='CLE_MasterK3y'
BACKUP MASTER KEY TO FILE = N'C:\APU_MC_Backup\CLE_MasterKey.key'
ENCRYPTION BY password = 'CLE_MasterK3y'
--RESTORE MASTER KEY
--FROM FILE = N'C:\APU_MC_Backup\CLE_MasterKey.key'
--ENCRYPTION BY PASSWORD = 'CLE_MasterK3y'
--GO



--SOLUTION 2: BACKUP AND RESTORE
-- Create a full database backup 
BACKUP DATABASE MedicalInfoSystem_Grp23_Done
TO DISK = N'C:\APU_MC_Backup\MedicalInfoSystem_Grp23_full.bak';

-- Optionally, create transaction log backups for point-in-time recovery
BACKUP LOG MedicalInfoSystem_Grp23_Done
TO DISK = N'C:\APU_MC_Backup\MedicalInfoSystem_Grp23_log_1.bak';

-- Repeat the transaction log backup for additional log files if needed
-- BACKUP LOG MedicalInfoSystem TO DISK = 'C:\Backup\MedicalInfoSystem_log_2.bak';

-- To Restore the database
--RESTORE DATABASE MedicalInfoSystem_Grp23_Done
--FROM DISK = N'C:\APU_MC_Backup\MedicalInfoSystem_Grp23_full.bak'