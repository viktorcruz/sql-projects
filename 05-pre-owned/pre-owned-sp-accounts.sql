--; sistema seminuevos
--CREATE DATABASE Grune_PreOwned
USE [Grune_PreOwned]
GO



IF OBJECT_ID('[dbo].[Usp_Accounts_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Accounts_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Accounts_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Accounts_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Accounts_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Accounts_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Accounts_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Accounts_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Accounts_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Accounts_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Accounts_INS
		@UserId INT,
		@PasswordHash NVARCHAR(255),
		@OpeningDate DATETIME 
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

		IF EXISTS(SELECT 1 FROM [dbo].[Accounts] WHERE UserId = @UserId)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Account already exists', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[Accounts](UserId, PasswordHash, OpeningDate)
			VALUES(@UserId, @PasswordHash, @OpeningDate)
			
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
	Usp_Accounts_GET
	@AccountId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			AccountId INT,
			UserId INT,
			PasswordHash NVARCHAR(255),
			OpeningDate DATETIME,
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Accounts WHERE AccountId = @AccountId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, AccountId, UserId, PasswordHash, OpeningDate, OperationDateTime)
				SELECT 1, 'Account found', AccountId, UserId, PasswordHash, OpeningDate ,GETDATE()
				FROM Accounts
				WHERE AccountId = @AccountId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, AccountId, UserId, PasswordHash, OpeningDate, OperationDateTime)
				VALUES(0, 'Error: Account not found', @AccountId, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, AccountId, UserId, PasswordHash, OpeningDate, OperationDateTime)
			VALUES(0, @ErrorMessage, @AccountId, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Accounts_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			AccountId INT,
			UserId INT,
			PasswordHash NVARCHAR(255),
			OpeningDate DATETIME,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, AccountId, UserId, PasswordHash, OpeningDate, OperationDateTime)
			SELECT 1, 'Account found', AccountId, UserId, PasswordHash, OpeningDate, GETDATE()
			FROM Accounts
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, AccountId, UserId, PasswordHash, OpeningDate, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Accounts_UPD
		@AccountId INT,
		@UserId INT,
		@PasswordHash NVARCHAR(255)
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Accounts] WHERE AccountId = @AccountId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES( 0, 'Error: Account not found', 'NONE', NULL, GETDATE())

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Accounts
			SET 
				UserId = @UserId, 
				PasswordHash = @PasswordHash
			WHERE AccountId = @AccountId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES( 1, 'Data has been sucessfully updated', 'UPDATE', @AccountId, GETDATE() )

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @AccountId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Accounts_DEL
		@AccountId INT
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

			DELETE FROM Accounts
			WHERE AccountId = @AccountId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Account not found', 'NONE', @AccountId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @AccountId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @AccountId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

EXEC Usp_Accounts_INS 
	@UserId = 1, 
	@PasswordHash = '$62309LKJASm982cj$OSI9809ddoHhv5BlZQWD6Oe12JLgTt0HDJFh3hzOW9A', 
	@OpeningDate = '20240606'

EXEC Usp_Accounts_UPD 
	@AccountId = 2,
	@UserId = 1, 
	@PasswordHash = '$128xalkAS992makASm982cj$OSI9809ddoHhv5BlZQWD6Oe12JLgHDJFOW9A'

EXEC Usp_Accounts_GET @AccountId = 2

EXEC Usp_Accounts_GET_ALL

EXEC Usp_Accounts_DEL @AccountId = 1


INSERT INTO Accounts (UserId, PasswordHash, OpeningDate) 
VALUES (1, '$128xalkAS992makASm982cj$OSI9809ddoHhv5BlZQWD6Oe12JLgHDJFOW9A', GETDATE()),
		(2, '$09X99x98ASDFxcvASm982cj$OSI9809ddoHhv5BlZQWD6Oe12JLgHDJFOW9A', GETDATE()),
		(3, '$lkXKJoi98ASm982cj$OSI9809ddoHhv5BlZQWD6Oe12JLgHDJFOW9A', GETDATE()),
		(4, '$90x89a09X09AKmakASm982cj$OSI9809ddoHhv5BlZQWD6Oe12JLgHDJFOW9A', GETDATE())

**/