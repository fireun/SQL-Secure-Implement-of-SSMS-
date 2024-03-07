--create new connect/ actor to login server by [SQL Server authentication - without touching in database (still can't access)]
--1. server -> properties -> security -> enable 'SQL authentication and window authentication'
--2. server -> security -> login -> right click 'new login'
--3. choose SQL server authentication -> key in username and password, if simple password then direct unclick 'enforced policy'


--Admin create the login for user to access the database
USE MedicalInfoSystem_Grp23
GO

--create a username(doctortest) for which SQL Server Authentication account(test)
CREATE USER doctortest FOR LOGIN test 
GO

--When setup done role group, then can add the USER to role group (DoctorRole = role group, docktortest = username)
ALTER ROLE DoctorRole ADD MEMBER doctortest
GO

--Also can remove from the role group
--ALTER ROLE DoctorRole DROP MEMBER doctortest 
--GO

--FOR TESTING before & after add to the group
SELECT * FROM Patient
GO
