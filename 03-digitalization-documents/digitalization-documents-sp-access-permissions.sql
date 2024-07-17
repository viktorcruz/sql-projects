--; digitalizacion de documentos
--CREATE DATABASE Grune_DigitalizationDocuments
USE [Grune_DigitalizationDocuments]
GO

CREATE OR ALTER PROCEDURE
	Usp_AccessPermissions_INS
		@DocumentId INT,
		@EmployeeId INT,
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
		BEGIN TRANSACTION TINS

		IF EXISTS(SELECT 1 FROM [dbo].[AccessPermissions] WHERE DocumentId = @DocumentId AND EmployeeId = @EmployeeId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Access alredy exists', 'NONE', NULL,  GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[AccessPermissions](DocumentId, EmployeeId, TypeAuthorizationId)
			VALUES(@DocumentId, @EmployeeId, @TypeAuthorizationId)

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
	Usp_AccessPermissions_GET
		@PermissionId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			PermissionId INT,
			DocumentId INT,
			EmployeeId INT,
			TypeAuthorizationId INT,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			IF EXISTS(SELECT 1 FROM [dbo].[AccessPermissions] WHERE PermissionId = @PermissionId)
			BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, PermissionId, DocumentId, EmployeeId, TypeAuthorizationId, OperationDateTime)
				SELECT 1, 'Access found', PermissionId, DocumentId, EmployeeId, TypeAuthorizationId, GETDATE()
				FROM [dbo].[AccessPermissions]
				WHERE PermissionId = @PermissionId
			END
			ELSE BEGIN
				INSERT INTO @Result( ResultStatus, ResultMessage, PermissionId, DocumentId, EmployeeId, TypeAuthorizationId, OperationDateTime )
				VALUES(0, 'Error: Access not found', @PermissionId, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, PermissionId, DocumentId, EmployeeId, TypeAuthorizationId, OperationDateTime)
			VALUES(0, @ErrorMessage, @PermissionId, NULL, NULL, NULL, GETDATE())
		END CATCH
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_AccessPermissions_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			PermissionId INT,
			DocumentId INT,
			EmployeeId INT,
			TypeAuthorizationId INT,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result( ResultStatus, ResultMessage, PermissionId, DocumentId, EmployeeId, TypeAuthorizationId, OperationDateTime )
			SELECT 1, 'Access found', PermissionId, DocumentId, EmployeeId, TypeAuthorizationId, GETDATE()
			FROM [dbo].[AccessPermissions]
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, PermissionId, DocumentId, EmployeeId, TypeAuthorizationId, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	SET NOCOUNT OFF;
	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_AccessPermissions_UPD
		@PermissionId INT,
		@DocumentId INT,
		@EmployeeId INT,
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
		BEGIN TRANSACTION TUPD

		IF EXISTS(SELECT 1 FROM [dbo].[AccessPermissions] WHERE PermissionId = @PermissionId)
		BEGIN 
			UPDATE AccessPermissions
			SET 
				DocumentId = @DocumentId,
				EmployeeId = @EmployeeId,
				TypeAuthorizationId = @TypeAuthorizationId 
			WHERE PermissionId = @PermissionId 

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully updated', 'UPDATE', @PermissionId, GETDATE())

			COMMIT TRANSACTION TUPD
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0,'Access not found', 'NONE', NULL, GETDATE())

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
	Usp_AccessPermissions_DEL
		@PermissionId INT
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
			IF EXISTS(SELECT 1 FROM [dbo].[AccessPermissions] WHERE PermissionId = @PermissionId)
			BEGIN
				DELETE FROM [dbo].[AccessPermissions]
				WHERE PermissionId = @PermissionId

				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @PermissionId, GETDATE())

				COMMIT TRANSACTION TDEL
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(0, 'Error: Access not found', 'NONE', @PermissionId, GETDATE())

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
		VALUES(0, @Error_Message, 'ERROR', @PermissionId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;
	SELECT * FROM @Result
END

/**

EXEC Usp_AccessPermissions_INS 
		@DocumentId = 1,
		@EmployeeId = 1,
		@TypeAuthorizationId = 1

EXEC Usp_AccessPermissions_UPD 
		@PermissionId = 1,
		@DocumentId = 1,
		@EmployeeId = 2,
		@TypeAuthorizationId = 3

EXEC Usp_AccessPermissions_GET @PermissionId = 1

EXEC Usp_AccessPermissions_GET_ALL

EXEC Usp_AccessPermissions_DEL @PermissionId = 1


INSERT INTO [dbo].[AccessPermissions](DocumentId, EmployeeId, TypeAuthorizationId)
VALUES(1, 3, 2)

**/

