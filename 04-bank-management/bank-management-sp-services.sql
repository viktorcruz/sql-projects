--; sistema gestion bancaria
--CREATE DATABASE Grune_Bank
USE [Grune_Bank]
GO



IF OBJECT_ID('[dbo].[Usp_Services_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Services_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Services_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Services_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Services_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Services_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Services_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Services_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Services_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Services_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Services_INS
		@NameService NVARCHAR(50),
		@ServiceProvider NVARCHAR(100)					
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ErrorMessage NVARCHAR(4000)
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

		IF EXISTS(SELECT 1 FROM [dbo].[Services] WHERE NameService = @NameService)
		BEGIN 

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Service already exists', 'NONE', NULL, GETDATE())

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN

			INSERT INTO [dbo].[Services]
				(
					NameService,
					ServiceProvider
				)
			VALUES
				(
					@NameService,
					@ServiceProvider
				)
			
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

		SET @ErrorMessage = ERROR_MESSAGE()
		
		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, @ErrorMessage, 'ERROR', NULL, GETDATE())

	END CATCH
	
	SET NOCOUNT OFF;
	SELECT * FROM @Result
END
GO


/** GET **/
CREATE OR ALTER PROCEDURE
	Usp_Services_GET
	@ServiceId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			ServiceId INT,
			NameService NVARCHAR(50),
			ServiceProvider NVARCHAR(100),
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Services WHERE ServiceId = @ServiceId)
			BEGIN
			 
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						ServiceId,
						NameService,
						ServiceProvider,
						OperationDateTime
					)
				SELECT
						1, 
						'Service found', 
						ServiceId, 
						NameService,
						ServiceProvider,
						GETDATE()
				FROM Services
				WHERE ServiceId = @ServiceId
				
			END
			ELSE BEGIN
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						ServiceId, 
						NameService,
						ServiceProvider,
						OperationDateTime
					)
				VALUES(0, 'Error: Service not found', @ServiceId, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						ServiceId, 
						NameService,
						ServiceProvider,
						OperationDateTime					)
			VALUES(0, @ErrorMessage, @ServiceId, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Services_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			ServiceId INT,
			NameService NVARCHAR(50),
			ServiceProvider NVARCHAR(100),
			OperationDateTime DATETIME
		)

		BEGIN TRY
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						ServiceId,
						NameService,
						ServiceProvider,
						OperationDateTime
					)
				SELECT
						1, 
						'Service found', 
						ServiceId, 
						NameService,
						ServiceProvider,
						GETDATE()
			FROM Services
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						ServiceId,
						NameService,
						ServiceProvider,
						OperationDateTime
					)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Services_UPD
		@ServiceId INT,
		@NameService NVARCHAR(50),
		@ServiceProvider NVARCHAR(100)	
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Services] WHERE ServiceId = @ServiceId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Service not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Services
			SET 
				NameService = @NameService,
				ServiceProvider = @ServiceProvider 
			WHERE ServiceId = @ServiceId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @ServiceId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @ServiceId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Services_DEL
		@ServiceId INT
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

			DELETE FROM Services
			WHERE ServiceId = @ServiceId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Service not found', 'NONE', @ServiceId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @ServiceId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @ServiceId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***


EXEC Usp_Services_INS 
	@NameService = 'Maintenance',
	@ServiceProvider = 'Los Angeles - Fast Car'


EXEC Usp_Services_UPD 
	@ServiceId = 1,
	@NameService = 'Electricity Service',
	@ServiceProvider = 'GOV'

EXEC Usp_Services_GET @ServiceId = 1

EXEC Usp_Services_GET_ALL

EXEC Usp_Services_DEL @ServiceId = 1


INSERT INTO [dbo].[Services]
(
	NameService,
	ServiceProvider
)
VALUES
(
	'Electricity Service',
	'GOV'
)

**/