--; digitalizacion de documentos
--CREATE DATABASE Grune_DigitalizationDocuments
USE [Grune_DigitalizationDocuments]
GO

CREATE OR ALTER PROCEDURE
	Usp_Departments_INS
		@Name NVARCHAR(50)
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

		IF EXISTS(SELECT 1 FROM [dbo].[Departments] WHERE Name = @Name)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Department alredy exists', 'NONE', NULL,  GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[Departments](Name)
			VALUES(@Name)

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
	Usp_Departments_GET
		@DepartmentId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			DepartmentId INT,
			Name NVARCHAR(50),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			IF EXISTS(SELECT 1 FROM [dbo].[Departments] WHERE DepartmentId = @DepartmentId)
			BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, DepartmentId, Name, OperationDateTime)
				SELECT 1, 'Departmet found', DepartmentId, Name, GETDATE()
				FROM [dbo].[Departments]
				WHERE DepartmentId = @DepartmentId
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, DepartmentId, Name, OperationDateTime)
				VALUES(0, 'Error: Deparment not found', @DepartmentId, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, DepartmentId, Name, OperationDateTime)
			VALUES(0, @ErrorMessage, @DepartmentId, Null, GETDATE())
		END CATCH
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_Departments_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			DepartmentId INT,
			Name NVARCHAR(50),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, DepartmentId, Name, OperationDateTime)
			SELECT 1, 'Department found', DepartmentId, Name, GETDATE()
			FROM [dbo].[Departments]
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, DepartmentId, Name, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, GETDATE())
		END CATCH
	SET NOCOUNT OFF;
	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_Departments_UPD
		@DepartmentId INT,
		@Name NVARCHAR(50)
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

		IF EXISTS(SELECT 1 FROM [dbo].[Departments] WHERE DepartmentId = @DepartmentId)
		BEGIN 
			UPDATE Departments
			SET 
				Name = @Name
			WHERE DepartmentId = @DepartmentId 

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully updated', 'UPDATE', @DepartmentId, GETDATE())

			COMMIT TRANSACTION TUPD
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0,'Department not found', 'NONE', NULL, GETDATE())

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
	Usp_Departments_DEL
		@DepartmentId INT
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
			IF EXISTS(SELECT 1 FROM [dbo].[Departments] WHERE DepartmentId = @DepartmentId)
			BEGIN
				DELETE FROM [dbo].[Departments]
				WHERE DepartmentId = @DepartmentId

				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @DepartmentId, GETDATE())

				COMMIT TRANSACTION TDEL
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(0, 'Error: Department not found', 'NONE', @DepartmentId, GETDATE())

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
		VALUES(0, @Error_Message, 'ERROR', @DepartmentId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;
	SELECT * FROM @Result
END

/**
EXEC Usp_Departments_INS @Name = 'Development'
EXEC Usp_Departments_UPD @DepartmentId = 1, @Name = 'Development 2'
EXEC Usp_Departments_GET @DepartmentId = 1
EXEC Usp_Departments_GET_ALL
EXEC Usp_Departments_DEL @DepartmentId = 1

INSERT INTO Departments (Name) 
	VALUES ('Sales'), 
			('Finance'), 
			('Marketing'), 
			('Delivery'), 
			('Human Resources'), 
			('Production'), 
			('Operations'), 
			('Technology')
**/