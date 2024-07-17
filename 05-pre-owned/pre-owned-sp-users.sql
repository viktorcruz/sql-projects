--; sistema seminuevos
--CREATE DATABASE Grune_PreOwned
USE [Grune_PreOwned]
GO



IF OBJECT_ID('[dbo].[Usp_Users_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Users_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Users_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Users_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Users_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Users_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Users_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Users_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Users_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Users_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Users_INS
		@FirstName NVARCHAR(20),
		@LastName NVARCHAR(20),
		@Email NVARCHAR(50),
		@Phone NVARCHAR(20),
		@Address NVARCHAR(100),
		@RegistrationDate DATETIME,
		@UserType NVARCHAR(100)
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

		IF EXISTS(SELECT 1 FROM [dbo].[Users] WHERE FirstName = @FirstName)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: User already exists', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[Users](FirstName, LastName, Email, Phone, Address, RegistrationDate, UserType)
			VALUES(@FirstName, @LastName, @Email, @Phone, @Address, @RegistrationDate, @UserType)
			
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
	Usp_Users_GET
	@UserId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			UserId INT,
		    FirstName NVARCHAR(20),
			LastName NVARCHAR(20),
			Email NVARCHAR(20),
			Phone NVARCHAR(20),
			Address NVARCHAR(100),
			RegistrationDate DATETIME,
			UserType NVARCHAR(100),
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Users WHERE UserId = @UserId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, UserId, FirstName, LastName, Email, Phone, Address, RegistrationDate, UserType, OperationDateTime)
				SELECT 1, 'User found', UserId, FirstName, LastName, Email, Phone, Address, RegistrationDate, UserType,GETDATE()
				FROM Users
				WHERE UserId = @UserId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, UserId, FirstName, LastName, Email, Phone, Address, RegistrationDate, UserType, OperationDateTime)
				VALUES(0, 'Error: User not found', @UserId, NULL, NULL, NULL, NULL, NULL, NULL, NULL,GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, UserId, FirstName, LastName, Email, Phone, Address, RegistrationDate, UserType, OperationDateTime)
			VALUES(0, @ErrorMessage, @UserId, NULL, NULL, NULL, NULL, NULL, NULL, NULL,GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Users_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			UserId INT,
		    FirstName NVARCHAR(20),
			LastName NVARCHAR(20),
			Email NVARCHAR(20),
			Phone NVARCHAR(20),
			Address NVARCHAR(100),
			RegistrationDate DATETIME,
			UserType NVARCHAR(100),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, UserId, FirstName, LastName, Email, Phone, Address, RegistrationDate, UserType, OperationDateTime)
			SELECT 1, 'User found', UserId, FirstName, LastName, Email, Phone, Address, RegistrationDate, UserType, GETDATE()
			FROM Users
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, UserId, FirstName, LastName, Email, Phone, Address, RegistrationDate, UserType, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL,  NULL, NULL, NULL, NULL, NULL, NULL, NULL,GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Users_UPD
		@UserId INT,
		@FirstName NVARCHAR(20),
		@LastName NVARCHAR(20),
		@Email NVARCHAR(50),
		@Phone NVARCHAR(20),
		@Address NVARCHAR(100),
		@RegistrationDate DATETIME,
		@UserType NVARCHAR(100)
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Users] WHERE UserId = @UserId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: User not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Users
			SET 
				FirstName = @FirstName,
				LastName = @LastName,
				Email = @Email,
				Phone = @Phone,
				Address = @Address,
				RegistrationDate = @RegistrationDate,
				UserType = @UserType
			WHERE UserId = @UserId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @UserId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @UserId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Users_DEL
		@UserId INT
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

			DELETE FROM Users
			WHERE UserId = @UserId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: User not found', 'NONE', @UserId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @UserId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @UserId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

EXEC Usp_Users_INS 
	@FirstName = 'Scarlett', 
	@LastName = 'Johansson', 
	@Email = 'scarlett@example.com', 
	@Phone = '123-133-1234', 
	@Address = 'OldTown 101', 
	@RegistrationDate = '20240605',
	@UserType = 'Buyer'

EXEC Usp_Users_UPD 
	@UserId = 1, 
	@FirstName = 'Scarlett 2', 
	@LastName = 'Johansson 2', 
	@Email = 'scarlett@example.com', 
	@Phone = '123-133-1234', 
	@Address = 'OldTown 101',
	@RegistrationDate = '20240605',
	@UserType = 'Seller'

EXEC Usp_Users_GET @UserId = 1

EXEC Usp_Users_GET_ALL

EXEC Usp_Users_DEL @UserId = 1


INSERT INTO Users (FirstName, LastName, Email, Phone, Address, RegistrationDate, UserType) 
VALUES ('Delle', 'Seyah', 'delle@example.com', '123-123-1234', 'OldTown 123', '20240606', 'Buyer'),
			('Hannah', 'Joh-K', 'hannah@example.com', '123-123-1234', 'OldTown 456', '20240606', 'Seller'),
			('John', 'Andras', 'john@example.com', '123-123-1234', 'OldTown 789', '20240606', 'Seller'),
			('Kelly', 'Perez', 'keylly@example.com', '123-123-1234', 'OldTown 101', '20240606', 'Buyer'),
			('Gerad', 'Fox', 'gerad@example.com', '123-123-1234', 'OldTown 111', '20240606', 'Buyer')


**/