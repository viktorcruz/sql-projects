--; digitalizacion de documentos
--CREATE DATABASE Grune_DigitalizationDocuments
USE [Grune_DigitalizationDocuments]
GO

CREATE OR ALTER PROCEDURE
	Usp_LocationStorage_INS
		@StorageType NVARCHAR(10),
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

		IF EXISTS(SELECT 1 FROM [dbo].[LocationStorage] WHERE StorageType = @StorageType)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Location alredy exists', 'NONE', NULL,  GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[LocationStorage](StorageType, Description)
			VALUES(@StorageType, @Description)

			DECLARE @NewId INT 
			SET @NewId = SCOPE_IDENTITY()

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully inserted', 'INSERT', @NewId, GETDATE()

			COMMIT TRANSACTION TINS
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TINS
		END

		DECLARE @ErrorMessage NVARCHAR(4000)
		SET @ErrorMessage = ERROR_MESSAGE()

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, @ErrorMessage, 'ERROR', NULL, GETDATE()) 
	END CATCH

	SET NOCOUNT OFF;
	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_LocationStorage_GET
		@LocationStorageId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			LocationStorageId INT,
			StorageType NVARCHAR(10),
			Description NVARCHAR(255),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			IF EXISTS(SELECT 1 FROM [dbo].[LocationStorage] WHERE LocationStorageId = @LocationStorageId)
			BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, LocationStorageId, StorageType, Description, OperationDateTime)
				SELECT 1, 'Location found', LocationStorageId, StorageType, Description, GETDATE()
				FROM [dbo].[LocationStorage]
				WHERE LocationStorageId = @LocationStorageId
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, LocationStorageId, StorageType, Description, OperationDateTime)
				VALUES(0, 'Error: Location not found', @LocationStorageId, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, LocationStorageId, StorageType, OperationDateTime)
			VALUES(0, @ErrorMessage, @LocationStorageId, Null, GETDATE())
		END CATCH
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_LocationStorage_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			LocationStorageId INT,
			StorageType NVARCHAR(10),
			Description NVARCHAR(255),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, LocationStorageId, StorageType, Description, OperationDateTime)
			SELECT 1, 'Location found', LocationStorageId, StorageType, Description, GETDATE()
			FROM [dbo].[LocationStorage]
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, LocationStorageId, StorageType, Description, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, GETDATE())
		END CATCH
	SET NOCOUNT OFF;
	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_LocationStorage_UPD
		@LocationStorageId INT,
		@StorageType NVARCHAR(10),
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

		IF EXISTS(SELECT 1 FROM [dbo].[LocationStorage] WHERE LocationStorageId = @LocationStorageId)
		BEGIN 
			UPDATE LocationStorage
			SET 
				StorageType = @StorageType,
				Description = Description
			WHERE LocationStorageId = @LocationStorageId 

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully updated', 'UPDATE', @LocationStorageId, GETDATE())

			COMMIT TRANSACTION TUPD
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0,'Location not found', 'NONE', NULL, GETDATE())

			ROLLBACK TRANSACTION TUPD
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			DECLARE @Error_Message NVARCHAR(4000)
			SET @Error_Message = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, @Error_Message, 'NONE', NULL, GETDATE())
		END
	END CATCH
	SET NOCOUNT OFF;
	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_LocationStorage_DEL
		@LocationStorageId INT
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
		BEGIN TRANSACTION TDEL
			IF EXISTS(SELECT 1 FROM [dbo].[LocationStorage] WHERE LocationStorageId = @LocationStorageId)
			BEGIN
				DELETE FROM [dbo].[LocationStorage]
				WHERE LocationStorageId = @LocationStorageId

				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @LocationStorageId, GETDATE())

				COMMIT TRANSACTION TDEL
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(0, 'Error: Location not found', 'NONE', @LocationStorageId, GETDATE())

				ROLLBACK TRANSACTION TDEL
			END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TDEL
		END

		DECLARE @Error_Message NVARCHAR(4000)
		SET @Error_Message = ERROR_MESSAGE()

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, @Error_Message, 'ERROR', @LocationStorageId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;
	SELECT * FROM @Result
END

/**

EXEC Usp_LocationStorage_INS 
	@StorageType = 'Server', 
	@Description = 'Document Storage Location guarantees that documents are always stored'

EXEC Usp_LocationStorage_UPD 
	@LocationStorageId = 1, 
	@StorageType = 'Server 2', 
	@Description = ''

EXEC Usp_LocationStorage_GET @LocationStorageId = 1

EXEC Usp_LocationStorage_GET_ALL

EXEC Usp_LocationStorage_DEL @LocationStorageId = 1

INSERT INTO LocationStorage (StorageType) 
	VALUES ('Local', 'Description 1'), ('Cloud', 'Description 2')


**/