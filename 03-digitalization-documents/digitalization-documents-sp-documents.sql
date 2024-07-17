--; digitalizacion de documentos
--CREATE DATABASE Grune_DigitalizationDocuments
USE [Grune_DigitalizationDocuments]
GO

CREATE OR ALTER PROCEDURE
	Usp_Documents_INS
		@DocumentTypeId INT,
		@EmployeeId INT,
		@FormatId INT,
		@LocationStorageId INT,
		@Name NVARCHAR(100),
		@Description NVARCHAR(255),
		@UploadDate DATETIME,
		@FilePath NVARCHAR(255),
		@DocumentVersion INT 
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

		IF EXISTS(SELECT 1 FROM [dbo].[Documents] WHERE Name = @Name AND EmployeeId = EmployeeId AND FilePath = @FilePath)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Document alredy exists', 'NONE', NULL,  GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[Documents](DocumentTypeId, EmployeeId, FormatId, LocationStorageId, Name, Description, UploadDate, FilePath, DocumentVersion)
			VALUES(@DocumentTypeId, @EmployeeId, @FormatId, @LocationStorageId, @Name, @Description, @UploadDate, @FilePath, @DocumentVersion)

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
	Usp_Documents_GET
		@DocumentId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			DocumentId INT,
			DocumentTypeId INT,
			EmployeeId INT,
			FormatId INT,
			LocationStorageId INT,
			Name NVARCHAR(100),
			Description NVARCHAR(255),
			UploadDate DATETIME,
			FilePath NVARCHAR(255),
			DocumentVersion INT,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			IF EXISTS(SELECT 1 FROM [dbo].[Documents] WHERE DocumentId = @DocumentId)
			BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, DocumentId, DocumentTypeId, EmployeeId, FormatId, LocationStorageId, Name, Description, UploadDate, FilePath, DocumentVersion, OperationDateTime)
				SELECT 1, 'Document found', DocumentId, DocumentTypeId, EmployeeId, FormatId, LocationStorageId, Name, Description, UploadDate, FilePath, DocumentVersion, GETDATE()
				FROM [dbo].[Documents]
				WHERE DocumentId = @DocumentId
			END
			ELSE BEGIN
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						DocumentId, 
						DocumentTypeId, 
						EmployeeId, 
						FormatId, 
						LocationStorageId, 
						Name, 
						Description, 
						UploadDate, 
						FilePath, 
						DocumentVersion, 
						OperationDateTime
					)
				VALUES(0, 'Error: Document not found', @DocumentId, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result
				(
					ResultStatus, 
					ResultMessage, 
					DocumentId, 
					DocumentTypeId, 
					EmployeeId, 
					FormatId, 
					LocationStorageId, 
					Name, 
					Description, 
					UploadDate, 
					FilePath, 
					DocumentVersion, 
					OperationDateTime
				)
			VALUES(0, @ErrorMessage, @DocumentId, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_Documents_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			DocumentId INT,
			DocumentTypeId INT,
			EmployeeId INT,
			FormatId INT,
			LocationStorageId INT,
			Name NVARCHAR(100),
			Description NVARCHAR(255),
			UploadDate DATETIME,
			FilePath NVARCHAR(255),
			DocumentVersion INT,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result
				(
					ResultStatus, 
					ResultMessage, 
					DocumentId, 
					DocumentTypeId, 
					EmployeeId, 
					FormatId, 
					LocationStorageId, 
					Name, 
					Description, 
					UploadDate, 
					FilePath, 
					DocumentVersion, 
					OperationDateTime
				)
			SELECT
					1, 
					'Docuemnt found', 
					DocumentId, 
					DocumentTypeId, 
					EmployeeId, 
					FormatId, 
					LocationStorageId, 
					Name, 
					Description, 
					UploadDate, 
					FilePath, 
					DocumentVersion, 
					GETDATE()
			FROM [dbo].[Documents]
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result
				(
					ResultStatus, 
					ResultMessage, 
					DocumentId, 
					DocumentTypeId, 
					EmployeeId, 
					FormatId, 
					LocationStorageId, 
					Name, 
					Description, 
					UploadDate, 
					FilePath, 
					DocumentVersion, 
					OperationDateTime
				)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,  NULL, GETDATE())
		END CATCH
	SET NOCOUNT OFF;
	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_Documents_UPD
		@DocumentId INT,
		@DocumentTypeId INT,
		@EmployeeId INT,
		@FormatId INT,
		@LocationStorageId INT,
		@Name NVARCHAR(100),
		@Description NVARCHAR(255),
		@UploadDate DATETIME,
		@FilePath NVARCHAR(255),
		@DocumentVersion INT 
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

		IF EXISTS(SELECT 1 FROM [dbo].[Documents] WHERE DocumentId = @DocumentId AND EmployeeId = EmployeeId)
		BEGIN 
			UPDATE Documents
			SET 
				DocumentTypeId = @DocumentTypeId,
				EmployeeId = @EmployeeId,
				FormatId = @FormatId,
				LocationStorageId = @LocationStorageId,
				Name = @Name,
				Description = @Description,
				UploadDate = @UploadDate,
				FilePath = @FilePath,
				DocumentVersion = @DocumentVersion  
			WHERE DocumentId = @DocumentId 

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully updated', 'UPDATE', @DocumentId, GETDATE())

			COMMIT TRANSACTION TUPD
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0,'Document not found', 'NONE', NULL, GETDATE())

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
	Usp_Documents_DEL
		@DocumentId INT
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
			IF EXISTS(SELECT 1 FROM [dbo].[Documents] WHERE DocumentId = @DocumentId)
			BEGIN
				DELETE FROM [dbo].[Documents]
				WHERE DocumentId = @DocumentId

				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(1, 'Data has benn sucessfully deleted', 'DELETE', @DocumentId, GETDATE())

				COMMIT TRANSACTION TDEL
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(0, 'Error: Document not found', 'NONE', @DocumentId, GETDATE())

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
		VALUES(0, @Error_Message, 'ERROR', @DocumentId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;
	SELECT * FROM @Result
END

/**

EXEC Usp_Documents_INS 
	@DocumentTypeId = 6,		--; reports
	@EmployeeId = 1, 
	@FormatId = 7,				--; pdf
	@LocationStorageId = 2,		--; cloud 
	@Name = 'Annual Report',	 
	@Description = 'Annual Finance Report', 
	@UploadDate = '20240505', 
	@FilePath = '/company/rh/annual_report.pdf', 
	@DocumentVersion = 1

EXEC Usp_Documents_UPD 
	@DocumentId = 1, 
	@DocumentTypeId = 6,		--; reports
	@EmployeeId = 1, 
	@FormatId = 6,				--; txt
	@LocationStorageId = 1,		--; local
	@Name = 'Annual Report',	 
	@Description = 'Annual Finance Report', 
	@UploadDate = '20240505', 
	@FilePath = 'c:\company\rh\annual_report.pdf', 
	@DocumentVersion = 2

EXEC Usp_Documents_GET @DocumentId = 1

EXEC Usp_Documents_GET_ALL

EXEC Usp_Documents_DEL @DocumentId = 2

INSERT INTO [dbo].[Documents]
	(
		DocumentTypeId, 
		EmployeeId, 
		FormatId, 
		LocationStorageId, 
		Name, 
		Description, 
		UploadDate, 
		FilePath, 
		DocumentVersion
	)
VALUES
	(
		6,	--; reports 
		1, 
		7,	--; pdf
		2,	--; cloud 
		'Annual Report', 
		'Annual Finance Report', 
		GETDATE(), 
		'/company/rh/annual_report.pdf', 
		1
	)

SELECT 
		D.DocumentId, 
		D.DocumentTypeId,
		DT.TypeName,
		D.EmployeeId,
		Concat(E.FirstName, ' ', E.LastName) AS Employee,
		D.FormatId, 
		F.FormatName AS Format,
		D.LocationStorageId, 
		L.StorageType AS Storage,
		L.Description,
		D.Name, 
		D.Description, 
		D.UploadDate, 
		D.FilePath, 
		D.DocumentVersion
FROM [dbo].[Documents] D (NOLOCK)
INNER JOIN
	[dbo].[DocumentTypes] DT (NOLOCK) ON DT.DocumentTypeId = D.DocumentTypeId
INNER JOIN
	[dbo].[Employees] E (NOLOCK) ON D.EmployeeId = E.EmployeeId
INNER JOIN 
	[dbo].[Formats] F (NOLOCK) ON D.FormatId = F.FormatId
INNER JOIN
	[dbo].[LocationStorage] L (NOLOCK) ON D.LocationStorageId = L.LocationStorageId


**/