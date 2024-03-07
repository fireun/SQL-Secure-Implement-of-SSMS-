USE MedicalInfoSystem_Grp23
GO

--Implement RLS
--1. Create User table
--2. Create user login
--3. Grant User permission, not sure Role Group (Do it in Role Group -> RoleSetup.sql)
--4. create schema, function, security policy
--5. security policy need set up which TABLE
--6. [Testing scenario] 
--		EXECUTE AS USER = 'UserID';
--		SQL ACTION;
--		REVERT;

--create schema name with Security (Schename used to organize database object), in database level
CREATE SCHEMA Security;
GO

--create user-defined function (It functions return single column named 'fn_securitypredicate_result' if 1 = match the username OR the owner is 'dbo' database owner)
CREATE FUNCTION Security.fn_securitypredicate_staff(@UserName AS nvarchar(100))
RETURNS TABLE
WITH SCHEMABINDING
AS
   RETURN SELECT 1 AS fn_securitypredicate_result
   WHERE @UserName = USER_NAME() OR USER_NAME() = 'dbo';
GO

CREATE FUNCTION Security.fn_securitypredicate_patient(@UserName AS nvarchar(100))
RETURNS TABLE
WITH SCHEMABINDING
AS
   RETURN SELECT 1 AS fn_securitypredicate_result
   WHERE @UserName = USER_NAME() OR USER_NAME() = 'dbo';
GO

-- Create security policy for the Staff table
CREATE SECURITY POLICY [SMS_StaffSecurityPolicy]
ADD FILTER PREDICATE [Security].[fn_securitypredicate_staff]([SystemUserID])
ON [dbo].[Staff]
WITH (STATE = ON, SCHEMABINDING = ON);


--create security policy (It function applied to the [dbo].[Customer] table, uses the function to filtering the column 'Customer' table
CREATE SECURITY POLICY [SMS_PatientSecurityPolicy]
ADD FILTER PREDICATE [Security].[fn_securitypredicate_patient]([SystemUserID]) --([ColumnName])
ON [dbo].[Patient] --[dbo].[TableName/ ObjectName]
WITH (STATE = ON, SCHEMABINDING = ON);




-- Create procedure to get patient data
/***CREATE PROCEDURE GetPatientData
AS
BEGIN
    SELECT * FROM [dbo].[Patient]
    WHERE [Patient].[SystemUserID] = USER_NAME();
END;
***/


/***
DECLARE @UserID NVARCHAR(50) = 'S1001'

--create security policy for Patient Data (define filtering predicate for the table)
CREATE SECURITY POLICY PatientPolicy
ADD FILTER PREDICATE dbo.fn_securitypredicate(UserID) ON dbo.SalesData --UserID = access user ID, can be staffID
WITH (STATE = ON)


--create user-defined function(UDF) return the filtering predicate
CREATE FUNCTION dbo.fn_securitypredicate(@UserID AS INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
   RETURN SELECT 1
   WHERE @UserID = USER_ID();

   ALTER SECURITY POLICY PatientPolicy ADD FILTER SCHEMABINDING;
GO


***/


--test RLS
EXECUTE AS USER = 'user101';
EXEC GetPatientData;
REVERT;
