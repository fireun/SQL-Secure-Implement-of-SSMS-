

-- Create a new role for update
CREATE ROLE PatientUpdatePersonalDetailRole; --patient update thier own personal details
CREATE ROLE NursesUpdatePatientPersonalDetailRole; --nurses update patient's personal details
CREATE ROLE StaffUpdatePersonalDetailRole; --nurses and doctors update their own personal details
CREATE ROLE StaffSelectPatientNonSensitiveRole; --nurses access patient data with nonsensitive data

/*
CREATE ROLE PatientSelectNonSensitiveRole;
CREATE ROLE StaffSelectNonSensitiveRole;
*/

/*Remove role member and delete the role group*/
-- Remove a member ('user002') from the role group ('NursesSelectNonSensitiveRole')
--EXEC sp_droprolemember 'PatientSelectNonSensitiveRole', 'user101';
--DROP ROLE PatientSelectNonSensitiveRole;

									/*	UPDATE data Permission Setup */
-- patient update personal details rule
GRANT UPDATE ([PPassportNumber], [PPhone],[PaymentCardNumber],[PaymentCardPinCode]) ON Patient TO PatientUpdatePersonalDetailRole;
DENY UPDATE ([PID],[PName],[SystemUserID]) ON Patient TO PatientUpdatePersonalDetailRole;
--REVOKE SELECT ([PName],[PPassportNumber], [PPhone],[PaymentCardNumber],[PaymentCardPinCode]) ON Patient TO PatientUpdatePersonalDetailRole;
--REVOKE SELECT ([PID],[SystemUserID]) ON Patient TO PatientUpdatePersonalDetailRole;
-- Add the user to the role, with system_login_user_ID
EXEC sp_addrolemember 'PatientUpdatePersonalDetailRole', 'user101';


-- nurses update patient personal details rule
GRANT UPDATE ([PName],[PPhone]) ON Patient TO NursesUpdatePatientPersonalDetailRole;
DENY UPDATE ([PPassportNumber], [PaymentCardNumber],[PaymentCardPinCode],[SystemUserID]) ON Patient TO NursesUpdatePatientPersonalDetailRole;
-- Add the user to the role, with system_login_user_ID
EXEC sp_addrolemember 'NursesUpdatePatientPersonalDetailRole', 'user002';


--nurse and doctor update personal details
GRANT UPDATE ([SName],[SPassportNumber],[SPhone]) ON Staff TO StaffUpdatePersonalDetailRole;
DENY UPDATE ([StaffID], [SystemUserID],[Position]) ON Staff TO StaffUpdatePersonalDetailRole;
-- Add the user to the role, with system_login_user_ID
EXEC sp_addrolemember 'StaffUpdatePersonalDetailRole', 'user001';
EXEC sp_addrolemember 'StaffUpdatePersonalDetailRole', 'user002';




										/*	SELECT data Permission Setup */
-- nurses select patient permission
GRANT SELECT ON dbo.Patient (PID, PName,PPassportNumber,PPhone) TO StaffSelectPatientNonSensitiveRole;
DENY SELECT ON dbo.Patient ([SystemUserID], [PaymentCardNumber],[PaymentCardPinCode]) TO StaffSelectPatientNonSensitiveRole;
EXEC sp_addrolemember 'StaffSelectPatientNonSensitiveRole', 'user001';
EXEC sp_addrolemember 'StaffSelectPatientNonSensitiveRole', 'user002';

/*
-- patient select  permission
GRANT SELECT ON dbo.Patient (PName,PPassportNumber,PPhone,[PaymentCardNumber],[PaymentCardPinCode]) TO PatientSelectNonSensitiveRole;
DENY SELECT ON dbo.Patient ([PID],[SystemUserID]) TO PatientSelectNonSensitiveRole;
EXEC sp_addrolemember 'PatientSelectNonSensitiveRole', 'user101';


-- Staff select permission
GRANT SELECT ON dbo.Staff ([StaffID],[SName],[SPassportNumber],[SPhone],[Position]) TO StaffSelectNonSensitiveRole;
DENY SELECT ON dbo.Staff ([SystemUserID]) TO StaffSelectNonSensitiveRole;
EXEC sp_addrolemember 'StaffSelectNonSensitiveRole', 'user001';
EXEC sp_addrolemember 'StaffSelectNonSensitiveRole', 'user002';
*/



/****************************************CHECKING CODE***************************************************************/

									/*	UPDATE data Permission Setup */
									/*	- Patient UPDATE Permission -*/
	--check patient update their own personal details role check
	--check role member
	SELECT 
		U.name AS UserName,
		R.name AS RoleName
	FROM sys.database_role_members RM
	JOIN sys.database_principals U ON RM.member_principal_id = U.principal_id
	JOIN sys.database_principals R ON RM.role_principal_id = R.principal_id
	WHERE R.name = 'PatientUpdatePersonalDetailRole'; -- Replace 'YourRole' with the actual role name


	--check role inside table permission 
	SELECT 
		princ.name AS [Role_Group],
		princ.type_desc AS [User_Type],
		object_name(perm.major_id) AS [Table],
		perm.permission_name,
		perm.state_desc AS [Permission_State]
	FROM sys.database_permissions perm
	INNER JOIN sys.database_principals princ ON perm.grantee_principal_id = princ.principal_id
	WHERE object_name(perm.major_id) = 'Patient' AND princ.name = 'PatientUpdatePersonalDetailRole'; -- Replace 'YourUserOrRole' with the actual user or role name
				

									/*	- Nurses UPDATE Patient Permission -*/
	--check nurses update patient personal details role check
	--check role member
	SELECT 
		U.name AS UserName,
		R.name AS RoleName
	FROM sys.database_role_members RM
	JOIN sys.database_principals U ON RM.member_principal_id = U.principal_id
	JOIN sys.database_principals R ON RM.role_principal_id = R.principal_id
	WHERE R.name = 'NursesUpdatePatientPersonalDetailRole'; -- Replace 'YourRole' with the actual role name


	--check role inside table permission 
	SELECT 
		princ.name AS [Role_Group],
		princ.type_desc AS [User_Type],
		object_name(perm.major_id) AS [Table],
		perm.permission_name,
		perm.state_desc AS [Permission_State]
	FROM sys.database_permissions perm
	INNER JOIN sys.database_principals princ ON perm.grantee_principal_id = princ.principal_id
	WHERE object_name(perm.major_id) = 'Patient' AND princ.name = 'NursesUpdatePatientPersonalDetailRole'; -- Replace 'YourUserOrRole' with the actual user or role name

	SELECT * FROM sys.database_permissions perm 
	INNER JOIN sys.database_principals princ 
	ON perm.grantee_principal_id = princ.principal_id 
	WHERE object_name(perm.major_id) = 'Patient' AND princ.name = 'NursesUpdatePatientPersonalDetailRole';


											/*	- Staff UPDATE Permission -*/
	--check staff update
	--check role member
	SELECT 
		U.name AS UserName,
		R.name AS RoleName
	FROM sys.database_role_members RM
	JOIN sys.database_principals U ON RM.member_principal_id = U.principal_id
	JOIN sys.database_principals R ON RM.role_principal_id = R.principal_id
	WHERE R.name = 'StaffUpdatePersonalDetailRole'; -- Replace 'YourRole' with the actual role name


	--check role inside table permission 
	SELECT 
		princ.name AS [Role_Group],
		princ.type_desc AS [User_Type],
		object_name(perm.major_id) AS [Table],
		perm.permission_name,
		perm.state_desc AS [Permission_State]
	FROM sys.database_permissions perm
	INNER JOIN sys.database_principals princ ON perm.grantee_principal_id = princ.principal_id
	WHERE object_name(perm.major_id) = 'Staff' AND princ.name = 'StaffUpdatePersonalDetailRole'; -- Replace 'YourUserOrRole' with the actual user or role name




										/*	SELECT data Permission Setup */
	/*										
										/*	- Staff Select Permission -*/
	--nurses select patient table with non sensitive data
	--check role member
	SELECT 
		U.name AS UserName,
		R.name AS RoleName
	FROM sys.database_role_members RM
	JOIN sys.database_principals U ON RM.member_principal_id = U.principal_id
	JOIN sys.database_principals R ON RM.role_principal_id = R.principal_id
	WHERE R.name = 'StaffSelectNonSensitiveRole'; -- Replace 'YourRole' with the actual role name


	--check role inside table permission 
	SELECT 
		princ.name AS [Role_Group],
		princ.type_desc AS [User_Type],
		object_name(perm.major_id) AS [Table],
		perm.permission_name,
		perm.state_desc AS [Permission_State]
	FROM sys.database_permissions perm
	INNER JOIN sys.database_principals princ ON perm.grantee_principal_id = princ.principal_id
	WHERE object_name(perm.major_id) = 'Staff' AND princ.name = 'StaffSelectNonSensitiveRole'; -- Replace 'YourUserOrRole' with the actual user or role name


									/*	- Patient Select Permission -*/
	--nurses select patient table with non sensitive data
	--check role member
	SELECT 
		U.name AS UserName,
		R.name AS RoleName
	FROM sys.database_role_members RM
	JOIN sys.database_principals U ON RM.member_principal_id = U.principal_id
	JOIN sys.database_principals R ON RM.role_principal_id = R.principal_id
	WHERE R.name = 'PatientSelectNonSensitiveRole'; -- Replace 'YourRole' with the actual role name


	--check role inside table permission 
	SELECT 
		princ.name AS [Role_Group],
		princ.type_desc AS [User_Type],
		object_name(perm.major_id) AS [Table],
		perm.permission_name,
		perm.state_desc AS [Permission_State]
	FROM sys.database_permissions perm
	INNER JOIN sys.database_principals princ ON perm.grantee_principal_id = princ.principal_id
	WHERE object_name(perm.major_id) = 'Patient' AND princ.name = 'PatientSelectNonSensitiveRole'; -- Replace 'YourUserOrRole' with the actual user or role name

	*/
										/*	- Staff Select Patient Permission -*/
	--nurses select patient table with non sensitive data
	--check role member
	SELECT 
		U.name AS UserName,
		R.name AS RoleName
	FROM sys.database_role_members RM
	JOIN sys.database_principals U ON RM.member_principal_id = U.principal_id
	JOIN sys.database_principals R ON RM.role_principal_id = R.principal_id
	WHERE R.name = 'StaffSelectPatientNonSensitiveRole'; -- Replace 'YourRole' with the actual role name


	--check role inside table permission 
	SELECT 
		princ.name AS [Role_Group],
		princ.type_desc AS [User_Type],
		object_name(perm.major_id) AS [Table],
		perm.permission_name,
		perm.state_desc AS [Permission_State]
	FROM sys.database_permissions perm
	INNER JOIN sys.database_principals princ ON perm.grantee_principal_id = princ.principal_id
	WHERE object_name(perm.major_id) = 'Patient' AND princ.name = 'StaffSelectPatientNonSensitiveRole'; -- Replace 'YourUserOrRole' with the actual user or role name






/****************************************END CHECKING CODE***************************************************************/


-- UPDATE
UPDATE Patient
SET PName = 'John Doe',
	PPhone = '016-457-9134'
WHERE Patient.PID = 'P001';
