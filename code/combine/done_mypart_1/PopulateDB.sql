--Data Population
--Group 23

-- Use Database
USE MedicalInfoSystem_Grp23;
GO

-- Insert sample data into the Staff table
INSERT INTO Staff (StaffID, SName, SPassportNumber, SPhone, SystemUserID, Position)
VALUES
    ('S001', 'Dr. Koa', '111456', '012-345-6789', 'user001', 'Doctor'),
    ('S002', 'Nurse Thomas', '789012', '013-456-7890', 'user002', 'Nurse'),
	('S003', 'Nurse Jerry', '123332', '014-567-8901', 'user003', 'Nurse'),
	('S004', 'Dr. Sam', '766812', '015-678-9012', 'user004', 'Doctor'),
	('S005', 'Nurse Johnson', '589012', '016-789-0123', 'user005', 'Nurse'),
	('S006', 'Nurse Samon', '111012', '017-890-1234', 'user006', 'Nurse'),
	('S007', 'Dr. Tom', '333012', '018-901-2345', 'user007', 'Doctor');

-- Insert sample data into the Patient table
INSERT INTO Patient (PID, PName, PPassportNumber, PPhone, SystemUserID, PaymentCardNumber, PaymentCardPinCode)
VALUES
    ('P001', 'John Doe', '456789', '019-012-3456', 'user101', '1234567812345678', '124'),
    ('P002', 'Jane Smith', '987654', '010-123-4567', 'user102', '8777432187654321', '508'),
	('P003', 'Wade', '707789', '011-234-5678', 'user103', '5732149856123478', '546'),
	('P004', 'Dave', '455489', '012-345-6780', 'user104', '8901234567890123', '121'),
	('P005', 'Seth', '889609', '013-456-7891', 'user105', '4567123987654321', '315'),
	('P006', 'Ivan', '796061', '014-567-8902', 'user106', '6543217890123456', '723');

-- Insert sample data into the Medicine table
INSERT INTO Medicine (MID, MName)
VALUES
    ('M001', 'Medicine A'),
    ('M002', 'Medicine B'),
	('M003', 'Medicine C'),
	('M004', 'Medicine D'),
	('M005', 'Medicine E'),
	('M006', 'Medicine F'),
	('M007', 'Medicine G'),
	('M008', 'Medicine H'),
	('M009', 'Medicine I'),
	('M010', 'Medicine J');

-- Insert sample data into the Prescription table
INSERT INTO Prescription (PatientID, DoctorID, PresDateTime)
VALUES
    ('P001', 'S001', '2023-10-09 10:20:00'),
	('P002', 'S004', '2023-10-10 15:00:00'),
	('P003', 'S001', '2023-10-10 11:45:00'),
	('P004', 'S001', '2023-10-11 09:20:00'),
	('P005', 'S007', '2023-10-12 10:00:00'),
    ('P006', 'S004', '2023-10-13 11:00:00');

-- Insert sample data into the PrescriptionMedicine table
INSERT INTO PrescriptionMedicine (PresID, MedID)
VALUES
    (1, 'M001'),
	(1, 'M003'),
	(1, 'M007'),
	(2, 'M002'),
	(2, 'M003'),
	(3, 'M004'),
	(3, 'M005'),
	(3, 'M006'),
	(3, 'M007'),
	(4, 'M001'),
	(4, 'M002'),
	(5, 'M007'),
	(5, 'M008'),
	(5, 'M009'),
	(6, 'M005'),
	(6, 'M008'),
    (6, 'M009'),
    (6, 'M010');