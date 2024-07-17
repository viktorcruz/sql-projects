--; gestion inventario y ventas
--CREATE DATABASE Grune_InventorySales
USE [Grune_InventorySales]
GO


IF OBJECT_ID('[dbo].[Usp_Categories_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Categories_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Categories_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Categories_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Categories_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Categories_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Categories_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Categories_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Categories_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Categories_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Categories_INS
		@Name NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Result AS TABLE
	(
		ResultStatus BIT,
		ResultMessage VARCHAR(100),
		OperationType VARCHAR(20),
		AffectedRecordId INT,
		OperationDateTime DATETIME
	)
	
	BEGIN TRY
		BEGIN TRANSACTION TrnxInsCategories

		IF EXISTS(SELECT 1 FROM [dbo].[Categories] WHERE Name = @name)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Category already exists', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TrnxInsCategories
		END
		ELSE BEGIN
			INSERT INTO [dbo].[Categories](Name)
			VALUES(@name)
			
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully inserted', 'INSERT', (SELECT SCOPE_IDENTITY()), GETDATE()

			COMMIT TRANSACTION TrnxInsCategories
		END

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TrnxInsCategories
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
	Usp_Categories_GET
	@CategoryId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage VARCHAR(100),
			CategoryId INT,
			Name VARCHAR(50),
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Categories WHERE CategoryId = @CategoryId)
			BEGIN

				INSERT INTO @Result(ResultStatus, ResultMessage, CategoryId, Name, OperationDateTime)
				SELECT 1, 'Category found', CategoryId, Name, GETDATE()
				FROM Categories
				WHERE CategoryId = @CategoryId

			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, CategoryId, Name, OperationDateTime)
				VALUES(0, 'Error: category not found', @CategoryId, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, CategoryId, Name, OperationDateTime)
			VALUES(0, @ErrorMessage, @CategoryId, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Categories_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage VARCHAR(100),
			CategoryId INT, 
			Name VARCHAR(50),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, CategoryId, Name, OperationDateTime)
			SELECT 1, 'Category found', CategoryId, Name, GETDATE()
			FROM Categories
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, CategoryId, Name, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Categories_UPD
		@CategoryId INT,
		@Name NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result AS TABLE
	(
		ResultStatus BIT,
		ResultMessage VARCHAR(100),
		OperationType VARCHAR(20),
		AffectedRecordId INT,
		OperationDateTime DATETIME
	)
	BEGIN TRY
		BEGIN TRANSACTION TrnxUpCategories

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Categories] WHERE CategoryId = @categoryId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: caterory not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TrnxUpCategories
		END
		ELSE BEGIN
			UPDATE Categories
			SET Name = @Name
			WHERE CategoryId = @CategoryId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @CategoryId, GETDATE()

			COMMIT TRANSACTION TrnxUpCategories
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TrnUpdating
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @CategoryId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Categories_DEL
		@CategoryId INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ErrorMessage NVARCHAR(4000) 
	DECLARE @Result AS TABLE
	(
		ResultStatus INT,
		ResultMessage VARCHAR(100),
		OperationType VARCHAR(20),
		AffectedRecordId INT, 
		OperationDateTime DATETIME
	)
	BEGIN TRY
		BEGIN TRANSACTION TDEL

			DELETE FROM Categories
			WHERE CategoryId = @CategoryId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: category not found', 'NONE', @CategoryId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELTE', @CategoryId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @CategoryId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/**

EXEC Usp_Categories_INS @Name = 'Category 1'
EXEC Usp_Categories_UPD @CategoryId = 1, @Name = 'Category 2'
EXEC Usp_Categories_GET @CategoryId = 1
EXEC Usp_Categories_GET_ALL
EXEC Usp_Categories_DEL @CategoryId = 1


INSERT INTO [dbo].[Categories] (Name) 
	VALUES ('Technology'),
			('Home and Furniture'),
			('Fashion'),
			('Supermarket'),
			('Babies')
**/