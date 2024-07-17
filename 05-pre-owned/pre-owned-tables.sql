--; sistema seminuevos
--CREATE DATABASE Grune_PreOwned
USE [Grune_PreOwned]
GO


IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Accounts]'))
BEGIN
	ALTER TABLE [dbo].[Accounts] DROP CONSTRAINT IF EXISTS [FK_Accounts_Users]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Vehicles]'))
BEGIN
	ALTER TABLE [dbo].[Vehicles] DROP CONSTRAINT IF EXISTS [FK_Vehicles_Users]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Ads]'))
BEGIN
	ALTER TABLE [dbo].[Ads] DROP CONSTRAINT IF EXISTS [FK_Ads_Vehicles]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Messages]'))
BEGIN
	ALTER TABLE [dbo].[Messages] DROP CONSTRAINT IF EXISTS [FK_Messages_Addressee]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Messages]'))
BEGIN
	ALTER TABLE [dbo].[Messages] DROP CONSTRAINT IF EXISTS [FK_Messages_Sender]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Messages]'))
BEGIN
	ALTER TABLE [dbo].[Messages] DROP CONSTRAINT IF EXISTS [FK_Messages_Vehicles]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Transactions]'))
BEGIN
	ALTER TABLE [dbo].[Transactions] DROP CONSTRAINT IF EXISTS [FK_Transactions_Accounts]
END


IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Vehicles]'))
BEGIN
	DROP TABLE [dbo].[Vehicles]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Ads]'))
BEGIN
	DROP TABLE [dbo].[Ads]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Messages]'))
BEGIN
	DROP TABLE [dbo].[Messages]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Transactions]'))
BEGIN
	DROP TABLE [dbo].[Transactions]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Users]'))
BEGIN
	DROP TABLE [dbo].[Users]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Accounts]'))
BEGIN
	DROP TABLE [dbo].[Accounts]
END


IF OBJECT_ID('Users') IS NULL
BEGIN
	CREATE TABLE Users
	(
		UserId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		FirstName NVARCHAR(20) NOT NULL,
		LastName NVARCHAR(20) NOT NULL,
		Email NVARCHAR(50) NOT NULL,
		Phone NVARCHAR(20) NOT NULL,
		Address NVARCHAR(100) NOT NULL,
		RegistrationDate DATETIME NOT NULL,
		UserType NVARCHAR(100) NOT NULL	--; comprador ;vendedor
	);
END

IF OBJECT_ID('Accounts') IS NULL
BEGIN
	CREATE TABLE Accounts
	(
		AccountId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		UserId INT NOT NULL,
		PasswordHash NVARCHAR(255) NOT NULL,
		OpeningDate DATETIME NOT NULL
	);
		ALTER TABLE Accounts
			WITH CHECK ADD CONSTRAINT [FK_Accounts_Users]
			FOREIGN KEY([UserId]) REFERENCES Users([UserId])
END

IF OBJECT_ID('Vehicles') IS NULL
BEGIN
	CREATE TABLE Vehicles
	(
		VehicleId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		AccountId INT NOT NULL,
		RerefenceNumber NVARCHAR(255) NOT NULL,
		Make NVARCHAR(50) NOT NULL,
		Model NVARCHAR(50) NOT NULL,
		Year INT NOT NULL,
		Price DECIMAL(10,2) NOT NULL,
		Mileage INT NOT NULL,
		Description NVARCHAR(255)
	);
		ALTER TABLE [Vehicles]
			WITH CHECK ADD CONSTRAINT [FK_Vehicles_Users]
			FOREIGN KEY([AccountId]) REFERENCES Accounts([AccountId])
END

IF OBJECT_ID('Ads') IS NULL
BEGIN
	CREATE TABLE Ads
	(
		AdId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		VehicleId INT NOT NULL,
		DatePublication DATETIME,
		StatusAd NVARCHAR(20),
		CONSTRAINT [FK_Ads_Vehicles] FOREIGN KEY([VehicleId]) REFERENCES Vehicles([VehicleId])
	);
END

IF OBJECT_ID('Messages') IS NULL
BEGIN
	CREATE TABLE Messages
	(
		MessageId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		AddresseeId INT NOT NULL,
		SenderId INT NOT NULL,
		VehicleId INT NOT NULL,
		Description NVARCHAR(255) NOT NULL,
		DatePublication DATETIME NOT NULL,
		CONSTRAINT [FK_Messages_Addressee] FOREIGN KEY([AddresseeId]) REFERENCES Accounts([AccountId]),
		CONSTRAINT [FK_Messages_Sender] FOREIGN KEY([SenderId]) REFERENCES Accounts([AccountId]),
		CONSTRAINT [FK_Messages_Vehicles] FOREIGN KEY([VehicleId]) REFERENCES Vehicles([VehicleId])
	);
END


IF OBJECT_ID('Transactions') IS NULL
BEGIN
	CREATE TABLE Transactions
	(
		TransactionId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		TransactionNumber NVARCHAR(255) NOT NULL,
		AccountId INT NOT NULL,
		TransactionType NVARCHAR(20),
		Amount MONEY,
		TransactionDate DATETIME NOT NULL,
		Description NVARCHAR(255)
	);
	ALTER TABLE Transactions
		WITH CHECK ADD CONSTRAINT [FK_Transactions_Accounts]
		FOREIGN KEY([AccountId]) REFERENCES Accounts([AccountId])
END
