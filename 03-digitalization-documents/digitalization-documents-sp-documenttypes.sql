--; digitalizacion de documentos
--CREATE DATABASE Grune_DigitalizationDocuments
USE [Grune_DigitalizationDocuments]
GO

CREATE OR ALTER PROCEDURE
	Usp_DocumentTypes_INS
		@TypeName NVARCHAR(50)
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

		IF EXISTS(SELECT 1 FROM [dbo].[DocumentTypes] WHERE TypeName = @TypeName)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Type alredy exists', 'NONE', NULL,  GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[DocumentTypes](TypeName)
			VALUES(@TypeName)

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
	Usp_DocumentTypes_GET
		@DocumentTypeId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			DocumentTypeId INT,
			TypeName NVARCHAR(50),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			IF EXISTS(SELECT 1 FROM [dbo].[DocumentTypes] WHERE DocumentTypeId = @DocumentTypeId)
			BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, DocumentTypeId, TypeName, OperationDateTime)
				SELECT 1, 'Type found', DocumentTypeId, TypeName, GETDATE()
				FROM [dbo].[DocumentTypes]
				WHERE DocumentTypeId = @DocumentTypeId
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, DocumentTypeId, TypeName, OperationDateTime)
				VALUES(0, 'Error: Type not found', @DocumentTypeId, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, DocumentTypeId, TypeName, OperationDateTime)
			VALUES(0, @ErrorMessage, @DocumentTypeId, Null, GETDATE())
		END CATCH
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_DocumentTypes_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			DocumentTypeId INT,
			TypeName NVARCHAR(50),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, DocumentTypeId, TypeName, OperationDateTime)
			SELECT 1, 'Type found', DocumentTypeId, TypeName, GETDATE()
			FROM [dbo].[DocumentTypes]
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, DocumentTypeId, TypeName, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, GETDATE())
		END CATCH
	SET NOCOUNT OFF;
	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_DocumentTypes_UPD
		@DocumentTypeId INT,
		@TypeName NVARCHAR(50)
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

		IF EXISTS(SELECT 1 FROM [dbo].[DocumentTypes] WHERE DocumentTypeId = @DocumentTypeId)
		BEGIN 
			UPDATE DocumentTypes
			SET 
				TypeName = @TypeName
			WHERE DocumentTypeId = @DocumentTypeId 

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully updated', 'UPDATE', @DocumentTypeId, GETDATE())

			COMMIT TRANSACTION TUPD
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0,'Type not found', 'NONE', NULL, GETDATE())

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
	Usp_DocumentTypes_DEL
		@DocumentTypeId INT
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
			IF EXISTS(SELECT 1 FROM [dbo].[DocumentTypes] WHERE DocumentTypeId = @DocumentTypeId)
			BEGIN
				DELETE FROM [dbo].[DocumentTypes]
				WHERE DocumentTypeId = @DocumentTypeId

				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @DocumentTypeId, GETDATE())

				COMMIT TRANSACTION TDEL
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(0, 'Error: Type not found', 'NONE', @DocumentTypeId, GETDATE())

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
		VALUES(0, @Error_Message, 'ERROR', @DocumentTypeId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;
	SELECT * FROM @Result
END

/**

EXEC Usp_DocumentTypes_INS @TypeName = 'README'

EXEC Usp_DocumentTypes_UPD @DocumentTypeId = 1, @TypeName = 'README 2'

EXEC Usp_DocumentTypes_GET @DocumentTypeId = 1

EXEC Usp_DocumentTypes_GET_ALL

EXEC Usp_DocumentTypes_DEL @DocumentTypeId = 1

INSERT INTO DocumentTypes (TypeName) 
	VALUES ('Invoices'), ('Contracts'), ('Legal Records'), ('Personal Records'), ('Bills'), 
		('Reports'), ('Payrolls'), ('Medical Certificates'), ('Company policies'), ('Workers files'),
		('Position Manual')

**/