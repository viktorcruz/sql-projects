--; gestion inventario y ventas
--CREATE DATABASE Grune_InventorySales
USE [Grune_InventorySales]
GO


IF OBJECT_ID('[dbo].[Usp_Products_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Products_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Products_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Products_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Products_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Products_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Products_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Products_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Products_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Products_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Products_INS
		@Name NVARCHAR(50),
		@Description NVARCHAR(255),
		@Price MONEY,
		@Stock INT,
		@CategoryId INT,
		@SupplierId INT
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

		IF EXISTS(SELECT 1 FROM [dbo].[Products] WHERE Name = @name)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Product already exists', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[Products](Name, Description, Price, Stock, EntryDate, CategoryId, SupplierId)
			VALUES(@Name, @Description, @Price, @Stock, GETDATE(), @CategoryId, @SupplierId)
			
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
	Usp_Products_GET
	@ProductId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			ProductId INT,
			Name NVARCHAR(50),
			Description NVARCHAR(255),
			Price MONEY,
			Stock INT,
			EntryDate DATETIME,
			CategoryId INT,
			SupplierId INT,
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Products WHERE ProductId = @ProductId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, ProductId, Name, Description, Price, Stock, EntryDate, CategoryId, SupplierId, OperationDateTime)
				SELECT 1, 'Product found', ProductId, Name, Description, Price, Stock, EntryDate, CategoryId, SupplierId, GETDATE()
				FROM Products
				WHERE ProductId = @ProductId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, ProductId, Name, Description, Price, Stock, EntryDate, CategoryId, SupplierId, OperationDateTime)
				VALUES(0, 'Error: Product not found', @ProductId, NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, ProductId, Name, Description, Price, Stock, EntryDate, CategoryId, SupplierId, OperationDateTime)
			VALUES(0, @ErrorMessage, @ProductId, NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Products_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			ProductId INT,
			Name NVARCHAR(50),
			Description NVARCHAR(255),
			Price MONEY,
			Stock INT,
			EntryDate DATETIME,
			CategoryId INT,
			SupplierId INT,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, ProductId, Name, Description, Price, Stock, EntryDate, CategoryId, SupplierId, OperationDateTime)
			SELECT 1, 'Product found', ProductId, Name, Description, Price, Stock, EntryDate, CategoryId, SupplierId, GETDATE()
			FROM Products
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, ProductId, Name, Description, Price, Stock, EntryDate, CategoryId, SupplierId, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Products_UPD
		@ProductId INT,
		@Name NVARCHAR(50),
		@Description NVARCHAR(255),
		@Price MONEY,
		@Stock INT,
		@CategoryId INT,
		@SupplierId INT
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Products] WHERE ProductId = @ProductId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Product not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Products
			SET Name = @Name,
				Description = @Description, 
				Price = @Price, 
				Stock = @Stock, 
				CategoryId = @CategoryId, 
				SupplierId = @SupplierId
			WHERE ProductId = @ProductId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @ProductId, GETDATE()

			COMMIT TRANSACTION TrnxUpProducts
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @ProductId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Products_DEL
		@ProductId INT
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

			DELETE FROM Products
			WHERE ProductId = @ProductId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Product not found', 'NONE', @ProductId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @ProductId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @ProductId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

EXEC Usp_Products_INS 
	@Name = 'iPhone 15', @Description = 'Apple Chip A16, Wi-Fi, Bluetooth', 
	@Price = 1200, @Stock = 10, @CategoryId = 1, @SupplierId = 1

EXEC Usp_Products_UPD 
	@ProductId = 1, @Name = 'iPhone 14', @Description = 'Apple Chip A16, Wi-Fi, Bluetooth', 
	@Price = 1299, @Stock = 100, @CategoryId = 1, @SupplierId = 1

EXEC Usp_Products_GET @ProductId = 1
EXEC Usp_Products_GET_ALL
EXEC Usp_Products_DEL @ProductId = 1


INSERT INTO Products (Name, Description, Price, Stock, EntryDate, CategoryId, SupplierId) 
	VALUES ('Tablet FreeYond A5 256GB y 8GB Pad 11" Full HD+ 4G/LTE Gris WiFi', '', 13200, 30, GETDATE(), 1, 1)

**/