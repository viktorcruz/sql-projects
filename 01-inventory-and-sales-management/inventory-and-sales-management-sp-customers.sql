--; gestion inventario y ventas
--CREATE DATABASE Grune_InventorySales
USE [Grune_InventorySales]
GO


IF OBJECT_ID('[dbo].[Usp_Customers_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Customers_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Customers_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Customers_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Customers_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Customers_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Customers_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Customers_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Customers_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Customers_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Customers_INS
		@FirstName NVARCHAR(20),
		@LastName NVARCHAR(20),
		@Email NVARCHAR(20),
		@Phone NVARCHAR(20),
		@Address NVARCHAR(100)
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

		IF EXISTS(SELECT 1 FROM [dbo].[Customers] WHERE FirstName = @FirstName)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Customer already exists', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[Customers](FirstName, LastName, Email, Phone, Address)
			VALUES(@FirstName, @LastName, @Email, @Phone, @Address)
			
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
	Usp_Customers_GET
	@CustomerId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			CustomerId INT,
		    FirstName NVARCHAR(20),
			LastName NVARCHAR(20),
			Email NVARCHAR(20),
			Phone NVARCHAR(20),
			Address NVARCHAR(100),
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Customers WHERE CustomerId = @CustomerId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, CustomerId, FirstName, LastName, Email, Phone, Address, OperationDateTime)
				SELECT 1, 'Customer found', CustomerId, FirstName, LastName, Email, Phone, Address, GETDATE()
				FROM Customers
				WHERE CustomerId = @CustomerId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, CustomerId, FirstName, LastName, Email, Phone, Address, OperationDateTime)
				VALUES(0, 'Error: Customer not found', @CustomerId, NULL, NULL, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, CustomerId, FirstName, LastName, Email, Phone, Address, OperationDateTime)
			VALUES(0, @ErrorMessage, @CustomerId, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Customers_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			CustomerId INT,
		    FirstName NVARCHAR(20),
			LastName NVARCHAR(20),
			Email NVARCHAR(20),
			Phone NVARCHAR(20),
			Address NVARCHAR(100),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, CustomerId, FirstName, LastName, Email, Phone, Address, OperationDateTime)
			SELECT 1, 'Customer found', CustomerId, FirstName, LastName, Email, Phone, Address, GETDATE()
			FROM Customers
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, CustomerId, FirstName, LastName, Email, Phone, Address, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL,  NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Customers_UPD
		@CustomerId INT,
		@FirstName NVARCHAR(20),
		@LastName NVARCHAR(20),
		@Email NVARCHAR(20),
		@Phone NVARCHAR(20),
		@Address NVARCHAR(100)
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Customers] WHERE CustomerId = @CustomerId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Customer not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Customers
			SET 
				FirstName = @FirstName,
				LastName = @LastName,
				Email = @Email,
				Phone = @Phone,
				Address = @Address
			WHERE CustomerId = @CustomerId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @CustomerId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @CustomerId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Customers_DEL
		@CustomerId INT
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

			DELETE FROM Customers
			WHERE CustomerId = @CustomerId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Customer not found', 'NONE', @CustomerId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @CustomerId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @CustomerId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

EXEC Usp_Customers_INS 
	@FirstName = 'Scarlett', @LastName = 'Johansson', @Email = 'scarlett@example.com', 
	@Phone = '123-133-1234', @Address = 'OldTown 101'

EXEC Usp_Customers_UPD 
	@CustomerId = 6, @FirstName = 'Scarlett 2', @LastName = 'Johansson 2', @Email = 'scarlett@example.com', 
	@Phone = '123-133-1234', @Address = 'OldTown 101'

EXEC Usp_Customers_GET @CustomerId = 6
EXEC Usp_Customers_GET_ALL
EXEC Usp_Customers_DEL @CustomerId = 1

INSERT INTO Customers (FirstName, LastName, Email, Phone, Address) 
VALUES ('Delle', 'Seyah', 'delle@example.com', '123-123-1234', 'OldTown 123'),
			('Hannah', 'Joh-K', 'hannah@example.com', '123-123-1234', 'OldTown 456'),
			('John', 'Andras', 'john@example.com', '123-123-1234', 'OldTown 789'),
			('Kelly', 'Perez', 'keylly@example.com', '123-123-1234', 'OldTown 101'),
			('Gerad', 'Fox', 'gerad@example.com', '123-123-1234', 'OldTown 111')
**/