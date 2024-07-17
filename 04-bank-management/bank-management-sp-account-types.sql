--; sistema gestion bancaria
--CREATE DATABASE Grune_Bank
USE [Grune_Bank]
GO



IF OBJECT_ID('[dbo].[Usp_AccountTypes_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_AccountTypes_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_AccountTypes_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_AccountTypes_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_AccountTypes_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_AccountTypes_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_AccountTypes_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_AccountTypes_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_AccountTypes_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_AccountTypes_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_AccountTypes_INS
		@TypeName NVARCHAR(20) 
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

		IF EXISTS(SELECT 1 FROM [dbo].[AccountTypes] WHERE TypeName = @TypeName)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Type already exists', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[AccountTypes](TypeName)
			VALUES(@TypeName)
			
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
	Usp_AccountTypes_GET
	@AccountTypeId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			AccountTypeId INT,
		    TypeName NVARCHAR(20),
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM AccountTypes WHERE AccountTypeId = @AccountTypeId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, AccountTypeId, TypeName, OperationDateTime)
				SELECT 1, 'Type found', AccountTypeId, TypeName,GETDATE()
				FROM AccountTypes
				WHERE AccountTypeId = @AccountTypeId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, AccountTypeId, TypeName, OperationDateTime)
				VALUES(0, 'Error: Type not found', @AccountTypeId, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, AccountTypeId, TypeName, OperationDateTime)
			VALUES(0, @ErrorMessage, @AccountTypeId, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_AccountTypes_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			AccountTypeId INT,
		    TypeName NVARCHAR(20),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, AccountTypeId, TypeName, OperationDateTime)
			SELECT 1, 'Type found', AccountTypeId, TypeName, GETDATE()
			FROM AccountTypes
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, AccountTypeId, TypeName, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL,  NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_AccountTypes_UPD
		@AccountTypeId INT,
		@TypeName NVARCHAR(20)
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[AccountTypes] WHERE AccountTypeId = @AccountTypeId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Type not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE AccountTypes
			SET 
				TypeName = @TypeName
			WHERE AccountTypeId = @AccountTypeId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @AccountTypeId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @AccountTypeId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_AccountTypes_DEL
		@AccountTypeId INT
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

			DELETE FROM AccountTypes
			WHERE AccountTypeId = @AccountTypeId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Type not found', 'NONE', @AccountTypeId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @AccountTypeId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @AccountTypeId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

EXEC Usp_AccountTypes_INS 
	@TypeName = 'Debit'

EXEC Usp_AccountTypes_UPD 
	@AccountTypeId = 1, 
	@TypeName = 'Credit' 

EXEC Usp_AccountTypes_GET @AccountTypeId = 1

EXEC Usp_AccountTypes_GET_ALL

EXEC Usp_AccountTypes_DEL @AccountTypeId = 1


INSERT INTO AccountTypes (TypeName) 
VALUES ('Debit'), ('Credit'), ('Saving')

**/