--; gestion inventario y ventas
--CREATE DATABASE Grune_InventorySales
USE [Grune_InventorySales]
GO


IF OBJECT_ID('[dbo].[Usp_Suppliers_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Suppliers_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Suppliers_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Suppliers_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Suppliers_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Suppliers_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Suppliers_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Suppliers_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Suppliers_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Suppliers_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Suppliers_INS
		@Name NVARCHAR(50),
		@Contact NVARCHAR(50),
		@Address NVARCHAR(50),
		@Phone NVARCHAR(20)
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

		IF EXISTS(SELECT 1 FROM [dbo].[Suppliers] WHERE Name = @name)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Supplier already exists', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[Suppliers](Name, Contact, Address, Phone)
			VALUES(@Name, @Contact, @Address, @Phone)
			
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
	Usp_Suppliers_GET
	@SupplierId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			SupplierId INT,
			Name NVARCHAR(50),
			Contact NVARCHAR(50),
			Address NVARCHAR(50),
			Phone NVARCHAR(20),
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Suppliers WHERE SupplierId = @SupplierId)
			BEGIN

				INSERT INTO @Result(ResultStatus, ResultMessage, SupplierId, Name, Contact, Address, Phone, OperationDateTime)
				SELECT 1, 'Supplier found', SupplierId, Name, Contact, Address, Phone, GETDATE()
				FROM Suppliers
				WHERE SupplierId = @SupplierId

			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, SupplierId, Name, Contact, Address, Phone, OperationDateTime)
				VALUES(0, 'Error: Supplier not found', @SupplierId, NULL, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, SupplierId, Name, Contact, Address, Phone, OperationDateTime)
			VALUES(0, @ErrorMessage, @SupplierId, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Suppliers_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			SupplierId INT, 
			Name NVARCHAR(50),
			Contact NVARCHAR(50),
			Address NVARCHAR(50),
			Phone NVARCHAR(20),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, SupplierId, Name, Contact, Address, Phone, OperationDateTime)
			SELECT 1, 'Supplier found', SupplierId, Name, Contact, Address, Phone, GETDATE()
			FROM Suppliers
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, SupplierId, Name, Contact, Address, Phone, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Suppliers_UPD
		@SupplierId INT,
		@Name NVARCHAR(50),
		@Contact NVARCHAR(50), 
		@Address NVARCHAR(50),
		@Phone NVARCHAR(20)
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Suppliers] WHERE SupplierId = @SupplierId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Supplier not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Suppliers
			SET Name = @Name,
				Contact = @Contact,
				Address = @Address,
				Phone = @Phone
			WHERE SupplierId = @SupplierId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @SupplierId, GETDATE()

			COMMIT TRANSACTION TrnxUpSuppliers
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @SupplierId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Suppliers_DEL
		@SupplierId INT
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

			DELETE FROM Suppliers
			WHERE SupplierId = @SupplierId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Supplier not found', 'NONE', @SupplierId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELTE', @SupplierId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @SupplierId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

EXEC Usp_Suppliers_INS 
	@Name = 'Supplier A', @Contact = 'Contact A', @Address = 'OldTown 123', @Phone = '123-123-1234'

EXEC Usp_Suppliers_UPD 
	@SupplierId = 1, @Name = 'Supplier 1', @Contact = 'Contact A', @Address = 'OldTown 123', @Phone = '123-123-1234'

EXEC Usp_Suppliers_GET @SupplierId = 1
EXEC Usp_Suppliers_GET_ALL
EXEC Usp_Suppliers_DEL @SupplierId = 1


INSERT INTO [dbo].[Suppliers] (Name, Contact, Address, Phone) 
VALUES ('Proveedor A', 'Contacto A', 'OldTown 123', '123-123-1234'),
		('Proveedor B', 'Contacto B', 'OldTown 456', '123-123-1234'),
		('Proveedor C', 'Contacto C', 'OldTown 789', '123-123-1234'),
		('Proveedor D', 'Contacto D', 'OldTown 101', '123-123-1234');

**/
