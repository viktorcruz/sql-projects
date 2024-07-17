--; digitalizacion de documentos
--CREATE DATABASE Grune_DigitalizationDocuments
USE [Grune_DigitalizationDocuments]
GO

CREATE OR ALTER PROCEDURE
	Usp_VersionHistory_INS
		@DocumentId INT,
		@Name NVARCHAR(255),
		@Description NVARCHAR(255),
		@FilePath NVARCHAR(255),
		@Version INT 
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

		IF EXISTS(SELECT 1 FROM [dbo].[VersionHistory] WHERE DocumentId = @DocumentId AND Version = @Version)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Historical alredy exists', 'NONE', NULL,  GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[VersionHistory](DocumentId, Name, Description, FilePath, Version)
			VALUES(@DocumentId, @Name, @Description, @FilePath, @Version)

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
	Usp_VersionHistory_GET
		@VersionHistoryId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			VersionHistoryId INT,
			DocumentId INT,
			Name NVARCHAR(255),
			Description NVARCHAR(255),
			FilePath NVARCHAR(255),
			Version INT,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			IF EXISTS(SELECT 1 FROM [dbo].[VersionHistory] WHERE VersionHistoryId = @VersionHistoryId)
			BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, VersionHistoryId, DocumentId, Name, Description, FilePath, Version, OperationDateTime)
				SELECT 1, 'Historical found', VersionHistoryId, DocumentId, Name, Description, FilePath, Version, GETDATE()
				FROM [dbo].[VersionHistory]
				WHERE VersionHistoryId = @VersionHistoryId
			END
			ELSE BEGIN
				INSERT INTO @Result( ResultStatus, ResultMessage, VersionHistoryId, DocumentId, Name, Description, FilePath, Version, OperationDateTime )
				VALUES(0, 'Error: Historical not found', @VersionHistoryId, NULL, NULL, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, VersionHistoryId, DocumentId, Name, Description, FilePath, Version, OperationDateTime)
			VALUES(0, @ErrorMessage, @VersionHistoryId, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_VersionHistory_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			VersionHistoryId INT,
			DocumentId INT,
			Name NVARCHAR(255),
			Description NVARCHAR(255),
			FilePath NVARCHAR(255),
			Version INT,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result( ResultStatus, ResultMessage, VersionHistoryId, DocumentId, Name, Description, FilePath, Version, OperationDateTime )
			SELECT 1, 'Historical found', VersionHistoryId, DocumentId, Name, Description, FilePath, Version, GETDATE()
			FROM [dbo].[VersionHistory]
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, VersionHistoryId, DocumentId, Name, Description, FilePath, Version, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	SET NOCOUNT OFF;
	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_VersionHistory_UPD
		@VersionHistoryId INT,
		@DocumentId INT,
		@Name NVARCHAR(255),
		@Description NVARCHAR(255),
		@FilePath NVARCHAR(255),
		@Version INT 
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

		IF EXISTS(SELECT 1 FROM [dbo].[VersionHistory] WHERE VersionHistoryId = @VersionHistoryId)
		BEGIN 
			UPDATE VersionHistory
			SET 
				DocumentId = @DocumentId, 
				Name = @Name, 
				Description = @Description,
				FilePath = @FilePath, 
				Version = @Version 
			WHERE VersionHistoryId = @VersionHistoryId 

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully updated', 'UPDATE', @VersionHistoryId, GETDATE())

			COMMIT TRANSACTION TUPD
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Historical not found', 'NONE', NULL, GETDATE())

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
	Usp_VersionHistory_DEL
		@VersionHistoryId INT
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
			IF EXISTS(SELECT 1 FROM [dbo].[VersionHistory] WHERE VersionHistoryId = @VersionHistoryId)
			BEGIN
				DELETE FROM [dbo].[VersionHistory]
				WHERE VersionHistoryId = @VersionHistoryId

				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @VersionHistoryId, GETDATE())

				COMMIT TRANSACTION TDEL
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(0, 'Error: Historical not found', 'NONE', @VersionHistoryId, GETDATE())

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
		VALUES(0, @Error_Message, 'ERROR', @VersionHistoryId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;
	SELECT * FROM @Result
END

/**

EXEC Usp_VersionHistory_INS 
		@DocumentId = 1,
		@Name = 'Annual Report v1',
		@Description = 'Annual Finance Report', 
		@FilePath = '/company/reports/annual_report.pdf',
		@Version = 1 

EXEC Usp_VersionHistory_UPD 
		@VersionHistoryId = 1,
		@DocumentId = 1,
		@Name = '',
		@Description = '', 
		@FilePath = '',
		@Version = 1 

EXEC Usp_VersionHistory_GET @VersionHistoryId = 1

EXEC Usp_VersionHistory_GET_ALL

EXEC Usp_VersionHistory_DEL @VersionHistoryId = 1


INSERT INTO [dbo].[VersionHistory](DocumentId, Name, Description, FilePath, Version)
VALUES(1, 'Annual Report v2', 'Annual Finance Report', '/company/reports/annual_report.pdf', 1)

**/
