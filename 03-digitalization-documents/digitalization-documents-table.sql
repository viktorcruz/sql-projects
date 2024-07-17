--; digitalizacion de documentos
--CREATE DATABASE Grune_DigitalizationDocuments
USE [Grune_DigitalizationDocuments]
GO


IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FileFormats]'))
BEGIN
	ALTER TABLE [dbo].[FileFormats] DROP CONSTRAINT IF EXISTS [FK_FileFormats_Formats]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID= OBJECT_ID(N'[dbo].[Documents]'))
BEGIN
	ALTER TABLE [dbo].[Documents] DROP CONSTRAINT IF EXISTS [FK_Documents_DocumentTypes]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID= OBJECT_ID(N'[dbo].[Documents]'))
BEGIN
	ALTER TABLE [dbo].[Documents] DROP CONSTRAINT IF EXISTS [FK_Documents_Employees]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID= OBJECT_ID(N'[dbo].[Documents]'))
BEGIN
	ALTER TABLE [dbo].[Documents] DROP CONSTRAINT IF EXISTS [FK_Documents_FileFormats]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Documents]'))
BEGIN
	ALTER TABLE [dbo].[Documents] DROP CONSTRAINT IF EXISTS [FK_Documents_LocationStorage]
END	
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[VersionHistory]'))
BEGIN
	ALTER TABLE [dbo].[VersionHistory] DROP CONSTRAINT IF EXISTS [FK_VersionHistory_Documents]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[AccessPermissions]'))
BEGIN 
	ALTER TABLE [dbo].[AccessPermissions] DROP CONSTRAINT IF EXISTS [FK_AccessPermissions_Docuemnts]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[AccessPermissions]'))
BEGIN 
	ALTER TABLE [dbo].[AccessPermissions] DROP CONSTRAINT IF EXISTS [FK_AccessPermissions_PermissionTypes]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[AccessPermissions]'))
BEGIN 
	ALTER TABLE [dbo].[AccessPermissions] DROP CONSTRAINT IF EXISTS [FK_AccessPermissions_Employees]
END



IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Documents]'))
BEGIN 
	DROP TABLE [dbo].[Documents]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[PermissionTypes]'))
BEGIN 
	DROP TABLE [dbo].[PermissionTypes]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FileFormats]'))
BEGIN 
	DROP TABLE [dbo].[FileFormats]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[LocationStorage]'))
BEGIN 
	DROP TABLE [dbo].[LocationStorage]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Formats]'))
BEGIN
	DROP TABLE [dbo].[Formats]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[DocumentTypes]'))
BEGIN
	DROP TABLE [dbo].[DocumentTypes]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Employees]'))
BEGIN
	DROP TABLE [dbo].[Employees]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Positions]'))
BEGIN
	DROP TABLE [dbo].[Positions]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Departments]'))
BEGIN
	DROP TABLE [dbo].[Departments]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[AccessPermissions]'))
BEGIN 
	DROP TABLE [dbo].[AccessPermissions]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[VersionHistory]'))
BEGIN 
	DROP TABLE [dbo].[VersionHistory]
END


IF OBJECT_ID(N'Departments') IS NULL
BEGIN
	CREATE TABLE Departments
	(
		DepartmentId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		Name NVARCHAR(50) NOT NULL
	);
END

IF OBJECT_ID(N'Positions') IS NULL
BEGIN
	CREATE TABLE Positions
	(
		PositionId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		Name NVARCHAR(20) NOT NULL
	);
END

IF OBJECT_ID(N'Employees') IS NULL
BEGIN 
	CREATE TABLE Employees
	(
		EmployeeId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		PositionId INT NOT NULL,
		DepartmentId INT NOT NULL,
		FirstName NVARCHAR(20) NOT NULL,
		LastName NVARCHAR(20) NOT NULL,
		Email NVARCHAR(20) NOT NULL,
		Phone NVARCHAR(20)
	);
		ALTER TABLE [Employees]
			WITH CHECK ADD CONSTRAINT [FK_Employees_Positions]
			FOREIGN KEY([PositionId]) REFERENCES Positions([PositionId])
		ALTER TABLE [Employees]
			WITH CHECK ADD CONSTRAINT [FK_Employees_Departments]
			FOREIGN KEY([DepartmentId]) REFERENCES Departments([DepartmentId])
END

IF OBJECT_ID(N'DocumentTypes') IS NULL
BEGIN
	CREATE TABLE DocumentTypes
	(
		DocumentTypeId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		Type NVARCHAR(20) NOT NULL
	);
END

IF OBJECT_ID(N'Formats') IS NULL
BEGIN
CREATE TABLE Formats
(
	FormatId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	Name NVARCHAR(20) NOT NULL
);
END

IF OBJECT_ID(N'LocationStorage') IS NULL
BEGIN
	CREATE TABLE LocationStorage
	(
		LocationStorageId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		Type NVARCHAR(10) NOT NULL,
		Description NVARCHAR(255) 
	);
END

IF OBJECT_ID(N'FileFormats') IS NULL
BEGIN
	CREATE TABLE FileFormats
	(
		FileFormatId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		FormatId INT NOT NULL
	);
		ALTER TABLE FileFormats
			WITH CHECK ADD CONSTRAINT [FK_FileFormats_Formats]
			FOREIGN KEY([FormatId]) REFERENCES Formats([FormatId])
END

IF OBJECT_ID(N'PermissionTypes') IS NULL
BEGIN
	CREATE TABLE PermissionTypes
	(
		PermissionTypeId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		Name NVARCHAR(20) NOT NULL
	);
END


IF OBJECT_ID(N'Documents') IS NULL
BEGIN
	CREATE TABLE Documents
	(
		DocumentId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		DocumentTypeId INT NOT NULL,
		EmployeeId INT NOT NULL,
		FileFormatId INT NOT NULL,
		LocationStorageId INT NOT NULL,
		Name NVARCHAR(100) NOT NULL,
		Description NVARCHAR(255) NOT NULL,
		UploadDate DATETIME NOT NULL,
		FilePath NVARCHAR(255) NOT NULL,
		DocumentVersion INT NOT NULL DEFAULT 1
	);
		ALTER TABLE [Documents]
			WITH CHECK ADD CONSTRAINT [FK_Documents_DocumentTypes]
			FOREIGN KEY([DocumentTypeId]) REFERENCES DocumentTypes([DocumentTypeId])
		ALTER TABLE [Documents]
			WITH CHECK ADD CONSTRAINT [FK_Documents_Employees]
			FOREIGN KEY([EmployeeId]) REFERENCES Employees([EmployeeId])
		ALTER TABLE [Documents]
			WITH CHECK ADD CONSTRAINT [FK_Documents_FileFormats]
			FOREIGN KEY([FileFormatId]) REFERENCES FileFormats([FileFormatId])
		ALTER TABLE [Documents]
			WITH CHECK ADD CONSTRAINT [FK_Documents_LocationStorage]
			FOREIGN KEY([LocationStorageId]) REFERENCES LocationStorage([LocationStorageId])
END

IF OBJECT_ID(N'AccessPermissions') IS NULL
BEGIN
	CREATE TABLE AccessPermissions
	(
		PermissionId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		DocumentId INT NOT NULL,
		EmployeeId INT NOT NULL,
		PermissionTypeId INT NOT NULL
	);
		ALTER TABLE AccessPermissions
			WITH CHECK ADD CONSTRAINT [FK_AccessPermissions_Docuemnts]
			FOREIGN KEY([DocumentId]) REFERENCES Documents([DocumentId])
		ALTER TABLE AccessPermissions
			WITH CHECK ADD CONSTRAINT [FK_AccessPermissions_Employees]
			FOREIGN KEY([EmployeeId]) REFERENCES Employees([EmployeeId])
		ALTER TABLE AccessPermissions
			WITH CHECK ADD CONSTRAINT [FK_AccessPermissions_PermissionTypes]
			FOREIGN KEY([PermissionTypeId]) REFERENCES PermissionTypes([PermissionTypeId])
END

IF OBJECT_ID(N'VersionHistory') IS NULL
BEGIN
	CREATE TABLE VersionHistory
	(
		VersionHistoryId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		DocumentId INT NOT NULL,
		Name NVARCHAR(255) NOT NULL,
		Description NVARCHAR(255),
		FilePath NVARCHAR(255) NOT NULL,
		Version INT NOT NULL
	);
		ALTER TABLE [VersionHistory]
			WITH CHECK ADD CONSTRAINT [FK_VersionHistory_Documents]
			FOREIGN KEY([DocumentId]) REFERENCES Documents([DocumentId])
END
