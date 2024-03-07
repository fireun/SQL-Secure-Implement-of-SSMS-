--Database Structure
--Group 23

-- Create Database
CREATE DATABASE MedicalInfoSystem_Grp23_Done;
GO

-- Use Database
USE MedicalInfoSystem_Grp23_Done;
GO

-- Create Staff Table with Enhanced Security
CREATE TABLE Staff (
    StaffID VARCHAR(6) PRIMARY KEY,
    SName VARCHAR(100) NOT NULL,
    SPassportNumber VARCHAR(50) NOT NULL,
    SPhone VARCHAR(20),
    SystemUserID VARCHAR(10) UNIQUE NOT NULL, -- Adding UNIQUE constraint for SystemUserID
    Position VARCHAR(20) CHECK (Position IN ('Doctor', 'Nurse'))
);

-- Create Patient Table with Enhanced Security
CREATE TABLE Patient (
    PID VARCHAR(6) PRIMARY KEY,
    PName VARCHAR(100) NOT NULL,
    PPassportNumber VARCHAR(50) NOT NULL,
    PPhone VARCHAR(20),
    SystemUserID VARCHAR(10) UNIQUE NOT NULL, -- Adding UNIQUE constraint for SystemUserID
    PaymentCardNumber VARCHAR(20),
    PaymentCardPinCode VARCHAR(20),
    CONSTRAINT CHK_CardPin CHECK (PaymentCardPinCode IS NULL OR LEN(PaymentCardPinCode) = 3) -- Adding a CHECK constraint for PIN code
);

-- Create Medicine Table
CREATE TABLE Medicine (
    MID VARCHAR(10) PRIMARY KEY,
    MName VARCHAR(50) NOT NULL
);

-- Create Prescription Table
CREATE TABLE Prescription (
    PresID INT IDENTITY(1, 1) PRIMARY KEY,
    PatientID VARCHAR(6) REFERENCES Patient(PID),
    DoctorID VARCHAR(6) REFERENCES Staff(StaffID),
    PresDateTime DATETIME NOT NULL
);

-- Create PrescriptionMedicine Table
CREATE TABLE PrescriptionMedicine (
    PresID INT REFERENCES Prescription(PresID),
    MedID VARCHAR(10) REFERENCES Medicine(MID),
    PRIMARY KEY (PresID, MedID)
);