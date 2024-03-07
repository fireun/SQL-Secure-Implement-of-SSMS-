USE MedicalInfoSystem_Grp23



--Manage User Login to Database (Server Layer)
--1. server -> properties -> security -> enable 'SQL authentication and window authentication'
--2. server -> security -> login -> right click 'new login'
--3. choose SQL server authentication -> key in username and password, if simple password then direct unclick 'enforced policy'

--4. Implement to database, user[databaseUserName] for login [above_SQL_Authentication_UserName]


--User Login ------------------------------------------------------------------------------------

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


--- Implement RLS need setup what action/permission allow inside RLS policy------------------------------------------------------------------------------------

-- Check for the exists of security policies
SELECT * FROM sys.security_policies;

-- Check the status of RLS
SELECT name, is_enabled
FROM sys.security_policies;

/*
Create Or Alter View CustomerPurchase_View
As
Select c.UserID, c.CustID, cp.PurchaseID, cp.PurchaseDate,
cpd.ProductCode, cpd.PurchasePrice, cpd.Quantity, cpd.Total
From Customer c
Inner Join CustomerPurchase cp On c.CustID=cp.CustID
Inner Join CustomerPurchaseDetail cpd On cp.PurchaseID = cpd.PurchaseID


GRANT SELECT ON CustomerPurchase_View TO Customers;

REVOKE SELECT ON dbo.CustomerPurchase TO Customers;
REVOKE SELECT ON dbo.CustomerPurchaseDetail TO Customers;
*/






--- Test RLS ------------------------------------------------------------------------------------
--1. Login by SQL Authetication, and Patient account: John
--2. Select patient info to see result.
--3. run the 
--			SELECT * FROM PatientDetailsView;
--		in Completed_RoleSetup

--Ex: Below here is used create without login:

-- CREATE USER HENLEY WITHOUT LOGIN
-- GRANT SELECT ON dbo.Patient TO HENLEY
/*EXECUTE AS USER = HENLEY;
EXEC GetPatientData;
REVERT;
*/


