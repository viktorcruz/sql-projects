--; sistema seminuevos
--CREATE DATABASE Grune_PreOwned
USE [Grune_PreOwned]
GO



IF OBJECT_ID('[dbo].[Usp_Ads_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Ads_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Ads_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Ads_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Ads_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Ads_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Ads_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Ads_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Ads_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Ads_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Ads_INS
		@VehicleId INT,
		@DatePublication DATETIME,
		@StatusAd NVARCHAR(20)
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

		IF EXISTS(SELECT 1 FROM [dbo].[Ads] WHERE VehicleId = @VehicleId)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Ad already exists', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN

			INSERT INTO [dbo].[Ads](VehicleId, DatePublication, StatusAd)
			VALUES(@VehicleId, @DatePublication, @StatusAd)
			
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
	Usp_Ads_GET
	@AdId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			AdId INT,
			VehicleId INT,
			DatePublication DATETIME,
			StatusAd NVARCHAR(20),
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Ads WHERE AdId = @AdId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, AdId, VehicleId, DatePublication, StatusAd, OperationDateTime)
				SELECT 1, 'Ad found', AdId, VehicleId, DatePublication, StatusAd , GETDATE()
				FROM Ads
				WHERE AdId = @AdId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, AdId, VehicleId, DatePublication, StatusAd, OperationDateTime)
				VALUES(0, 'Error: Ad not found', @AdId, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, AdId, VehicleId, DatePublication, StatusAd, OperationDateTime)
			VALUES(0, @ErrorMessage, @AdId, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Ads_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			AdId INT,
			VehicleId INT,
			DatePublication DATETIME,
			StatusAd NVARCHAR(20),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, AdId, VehicleId, DatePublication, StatusAd, OperationDateTime)
			SELECT 1, 'Ad found', AdId, VehicleId, DatePublication, StatusAd, GETDATE()
			FROM Ads
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, AdId, VehicleId, DatePublication, StatusAd, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Ads_UPD
		@AdId INT,
		@VehicleId INT,
		@DatePublication DATETIME,
		@StatusAd NVARCHAR(20)
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Ads] WHERE AdId = @AdId AND VehicleId = @VehicleId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES( 0, 'Error: Ad not found', 'NONE', NULL, GETDATE())

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Ads
			SET 
				VehicleId = @VehicleId,
				DatePublication = @DatePublication,
				StatusAd = @StatusAd
			WHERE AdId = @AdId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES( 1, 'Data has been sucessfully updated', 'UPDATE', @AdId, GETDATE() )

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @AdId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Ads_DEL
		@AdId INT
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

			DELETE FROM Ads
			WHERE AdId = @AdId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Ad not found', 'NONE', @AdId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @AdId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @AdId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

EXEC Usp_Ads_INS 
		@VehicleId = 2,
		@DatePublication = '20240606',
		@StatusAd = 'Active'							--; active ; sold; inactive

EXEC Usp_Ads_UPD 
		@AdId = 5,
		@VehicleId = 2,
		@DatePublication = '20230606',
		@StatusAd = 'Inactive'							--; active ; sold; inactive

EXEC Usp_Ads_GET @AdId = 2

EXEC Usp_Ads_GET_ALL

EXEC Usp_Ads_DEL @AdId = 2


INSERT INTO Ads 
	(
		VehicleId,
		DatePublication,
		StatusAd 
	)
VALUES(1, GETDATE(), 'Active'),
		(2, DATEADD(Month, -13, GETDATE()), 'Inactive'),
		(3, DATEADD(Month, -5, GETDATE()), 'Sold'),
		(4, DATEADD(Month, -3, GETDATE()), 'Active')

**/
