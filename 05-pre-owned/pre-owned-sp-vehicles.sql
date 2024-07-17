--; sistema seminuevos
--CREATE DATABASE Grune_PreOwned
USE [Grune_PreOwned]
GO



IF OBJECT_ID('[dbo].[Usp_Vehicles_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Vehicles_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Vehicles_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Vehicles_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Vehicles_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Vehicles_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Vehicles_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Vehicles_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Vehicles_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Vehicles_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Vehicles_INS
		@AccountId INT,
		@RerefenceNumber NVARCHAR(255),
		@Make NVARCHAR(50),
		@Model NVARCHAR(50),
		@Year INT,
		@Price DECIMAL(10,2),
		@Mileage INT,
		@Description NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Result AS TABLE
	(
		ResultStatus BIT,
		ResultMessage NVARCHAR(100),
		OperationType NVARCHAR(20),
		AffectedRecordId INT,
		OperationDateTime DATETIME
	)
	
	BEGIN TRY
		BEGIN TRANSACTION TINS

		IF EXISTS(SELECT 1 FROM [dbo].[Vehicles] WHERE RerefenceNumber = @RerefenceNumber)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Vehicle already exists', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[Vehicles](AccountId, RerefenceNumber, Make, Model, Year, Price, Mileage, Description)
			VALUES(@AccountId, @RerefenceNumber, @Make, @Model, @Year, @Price, @Mileage, @Description)
			
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully inserted', 'INSERT', (SELECT SCOPE_IDENTITY()), GETDATE()

			COMMIT TRANSACTION TINS
		END

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TINS
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', NULL, GETDATE())

	END CATCH
	
	SET NOCOUNT OFF;
	SELECT * FROM @Result
END
GO


/** GET **/
CREATE OR ALTER PROCEDURE
	Usp_Vehicles_GET
	@VehicleId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			VehicleId INT,
			AccountId INT,
			RerefenceNumber NVARCHAR(255),
			Make NVARCHAR(50),
			Model NVARCHAR(50),
			Year INT,
			Price DECIMAL(10,2),
			Mileage INT,
			Description NVARCHAR(255),
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Vehicles WHERE VehicleId = @VehicleId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, VehicleId, AccountId, RerefenceNumber, Make, Model, Year, Price, Mileage, Description, OperationDateTime)
				SELECT 1, 'Vehicle found', VehicleId, AccountId, RerefenceNumber, Make, Model, Year, Price, Mileage, Description ,GETDATE()
				FROM Vehicles
				WHERE VehicleId = @VehicleId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, VehicleId, AccountId, RerefenceNumber, Make, Model, Year, Price, Mileage, Description, OperationDateTime)
				VALUES(0, 'Error: Vehicle not found', @VehicleId, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, VehicleId, AccountId, RerefenceNumber, Make, Model, Year, Price, Mileage, Description, OperationDateTime)
			VALUES(0, @ErrorMessage, @VehicleId, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Vehicles_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			VehicleId INT,
			AccountId INT,
			RerefenceNumber NVARCHAR(255),
			Make NVARCHAR(50),
			Model NVARCHAR(50),
			Year INT,
			Price DECIMAL(10,2),
			Mileage INT,
			Description NVARCHAR(255),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, VehicleId, AccountId, RerefenceNumber, Make, Model, Year, Price, Mileage, Description, OperationDateTime)
			SELECT 1, 'Vehicle found', VehicleId, AccountId, RerefenceNumber, Make, Model, Year, Price, Mileage, Description, GETDATE()
			FROM Vehicles
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, VehicleId, AccountId, RerefenceNumber, Make, Model, Year, Price, Mileage, Description, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Vehicles_UPD
		@VehicleId INT,
		@AccountId INT,
		@RerefenceNumber NVARCHAR(255),
		@Make NVARCHAR(50),
		@Model NVARCHAR(50),
		@Year INT,
		@Price DECIMAL(10,2),
		@Mileage INT,
		@Description NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result AS TABLE
	(
		ResultStatus BIT,
		ResultMessage NVARCHAR(100),
		OperationType NVARCHAR(20),
		AffectedRecordId INT,
		OperationDateTime DATETIME
	)
	BEGIN TRY
		BEGIN TRANSACTION TUPD

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Vehicles] WHERE VehicleId = @VehicleId AND RerefenceNumber = @RerefenceNumber)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES( 0, 'Error: Vehicle not found', 'NONE', NULL, GETDATE())

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Vehicles
			SET 
				AccountId = @AccountId,
				RerefenceNumber = @RerefenceNumber,
				Make = @Make,
				Model = @Model,
				Year = @Year,
				Price = @Price,
				Mileage = @Mileage,
				Description = @Description 
			WHERE VehicleId = @VehicleId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES( 1, 'Data has been sucessfully updated', 'UPDATE', @VehicleId, GETDATE() )

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @VehicleId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Vehicles_DEL
		@VehicleId INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ErrorMessage NVARCHAR(4000) 
	DECLARE @Result AS TABLE
	(
		ResultStatus INT,
		ResultMessage NVARCHAR(100),
		OperationType NVARCHAR(20),
		AffectedRecordId INT, 
		OperationDateTime DATETIME
	)
	BEGIN TRY
		BEGIN TRANSACTION TDEL

			DELETE FROM Vehicles
			WHERE VehicleId = @VehicleId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Vehicle not found', 'NONE', @VehicleId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @VehicleId, GETDATE())

			COMMIT TRANSACTION TDEL
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TDEL
		END

		SET @ErrorMessage = ERROR_MESSAGE()

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, @ErrorMessage, 'NONE', @VehicleId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

DECLARE @ReferenceINS NVARCHAR(50) = CONVERT(NVARCHAR(50), NEWID())
EXEC Usp_Vehicles_INS 
		@AccountId = 1,
		@RerefenceNumber = @ReferenceINS,
		@Make = 'FIAT',
		@Model = '',
		@Year = 1990,
		@Price = 3999,
		@Mileage = 35,
		@Description = 'Description 1'

DECLARE @ReferenceUPD NVARCHAR(50) = CONVERT(NVARCHAR(50), NEWID())
--; 9B9162E6-6D7E-49D3-A8F2-63C4DE82EE06
EXEC Usp_Vehicles_UPD 
		@VehicleId = 2,
		@AccountId = 1,
		@RerefenceNumber = '9B9162E6-6D7E-49D3-A8F2-63C4DE82EE06',	--;@ReferenceUPD,
		@Make = 'FIAT',
		@Model = 'Model ABC',
		@Year = 1990,
		@Price = 5000,
		@Mileage = 50,
		@Description = 'Description 1234'

EXEC Usp_Vehicles_GET @VehicleId = 2

EXEC Usp_Vehicles_GET_ALL

EXEC Usp_Vehicles_DEL @VehicleId = 2



INSERT INTO Vehicles 
	(
		AccountId,
		RerefenceNumber,
		Make,
		Model,
		Year,
		Price,
		Mileage,
		Description
	)
VALUES(1, CONVERT(NVARCHAR(50), NEWID()), 'CUPRA', 'MODEL X', 1999, 9821, 10, 'Description 5677'),
	(2, CONVERT(NVARCHAR(50), NEWID()), 'HONDA', 'MODEL X', 1998, 9308, 20, 'Description 5677'),
	(3, CONVERT(NVARCHAR(50), NEWID()), 'JAC', 'MODEL X', 1997, 9277, 60, 'Description 5677'),
	(4, CONVERT(NVARCHAR(50), NEWID()), 'CHIREY', 'MODEL X', 1996, 10002, 6, 'Description 5677'),
	(5, CONVERT(NVARCHAR(50), NEWID()), 'CHEVROLET', 'MODEL X', 1995, 10098, 5, 'Description 5677'),
	(2, CONVERT(NVARCHAR(50), NEWID()), 'VOLKSWAGEN', 'MODEL X', 1994, 2990, 981, 'Description 5677'),
	(3, CONVERT(NVARCHAR(50), NEWID()), 'BMW', 'MODEL X', 1993, 3988, 200, 'Description 5677'),
	(4, CONVERT(NVARCHAR(50), NEWID()), 'NISSAN', 'MODEL X', 1992, 2990, 300, 'Description 5677'),
	(1, CONVERT(NVARCHAR(50), NEWID()), 'MAZDA', 'MODEL X', 1991, 5900, 100, 'Description 5677')



**/