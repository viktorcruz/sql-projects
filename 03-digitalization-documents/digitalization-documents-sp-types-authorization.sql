--; digitalizacion de documentos
--CREATE DATABASE Grune_DigitalizationDocuments
USE [Grune_DigitalizationDocuments]
GO

CREATE OR ALTER PROCEDURE
	Usp_TypesAuthorization_INS
		@Permission NVARCHAR(20)
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

		IF EXISTS(SELECT 1 FROM [dbo].[TypesAuthorization] WHERE Permission = @Permission)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Permission alredy exists', 'NONE', NULL,  GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[TypesAuthorization](Permission)
			VALUES(@Permission)

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
	Usp_TypesAuthorization_GET
		@TypeAuthorizationId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			TypeAuthorizationId INT,
			Permission NVARCHAR(20),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			IF EXISTS(SELECT 1 FROM [dbo].[TypesAuthorization] WHERE TypeAuthorizationId = @TypeAuthorizationId)
			BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, TypeAuthorizationId, Permission, OperationDateTime)
				SELECT 1, 'Permission found', TypeAuthorizationId, Permission, GETDATE()
				FROM [dbo].[TypesAuthorization]
				WHERE TypeAuthorizationId = @TypeAuthorizationId
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, TypeAuthorizationId, Permission, OperationDateTime)
				VALUES(0, 'Error: Permission not found', @TypeAuthorizationId, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, TypeAuthorizationId, Permission, OperationDateTime)
			VALUES(0, @ErrorMessage, @TypeAuthorizationId, Null, GETDATE())
		END CATCH
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_TypesAuthorization_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			TypeAuthorizationId INT,
			Permission NVARCHAR(20),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, TypeAuthorizationId, Permission, OperationDateTime)
			SELECT 1, 'Permission found', TypeAuthorizationId, Permission, GETDATE()
			FROM [dbo].[TypesAuthorization]
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, TypeAuthorizationId, Permission, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, GETDATE())
		END CATCH
	SET NOCOUNT OFF;
	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_TypesAuthorization_UPD
		@TypeAuthorizationId INT,
		@Permission NVARCHAR(20)
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

		IF EXISTS(SELECT 1 FROM [dbo].[TypesAuthorization] WHERE TypeAuthorizationId = @TypeAuthorizationId)
		BEGIN 
			UPDATE TypesAuthorization
			SET 
				Permission = @Permission
			WHERE TypeAuthorizationId = @TypeAuthorizationId 

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully updated', 'UPDATE', @TypeAuthorizationId, GETDATE())

			COMMIT TRANSACTION TUPD
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0,'Permission not found', 'NONE', NULL, GETDATE())

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
	Usp_TypesAuthorization_DEL
		@TypeAuthorizationId INT
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
			IF EXISTS(SELECT 1 FROM [dbo].[TypesAuthorization] WHERE TypeAuthorizationId = @TypeAuthorizationId)
			BEGIN
				DELETE FROM [dbo].[TypesAuthorization]
				WHERE TypeAuthorizationId = @TypeAuthorizationId

				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @TypeAuthorizationId, GETDATE())

				COMMIT TRANSACTION TDEL
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(0, 'Error: Permission not found', 'NONE', @TypeAuthorizationId, GETDATE())

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
		VALUES(0, @Error_Message, 'ERROR', @TypeAuthorizationId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;
	SELECT * FROM @Result
END

/**

EXEC Usp_TypesAuthorization_INS 
	@Permission = 'Read'

EXEC Usp_TypesAuthorization_UPD 
	@TypeAuthorizationId = 1, 
	@Permission = 'Write'

EXEC Usp_TypesAuthorization_GET @TypeAuthorizationId = 1

EXEC Usp_TypesAuthorization_GET_ALL

EXEC Usp_TypesAuthorization_DEL @TypeAuthorizationId = 1

INSERT INTO TypesAuthorization (Permission) 
	VALUES ('Read'), ('Write'), ('Execute'), ('Denied'), ('Delete')

**/