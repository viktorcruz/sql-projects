--; gestion inventario y ventas
--CREATE DATABASE Grune_InventorySales
USE [Grune_InventorySales]
GO


IF OBJECT_ID('[dbo].[Usp_PaymentMethods_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_PaymentMethods_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_PaymentMethods_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_PaymentMethods_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_PaymentMethods_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_PaymentMethods_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_PaymentMethods_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_PaymentMethods_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_PaymentMethods_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_PaymentMethods_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_PaymentMethods_INS
		@Name NVARCHAR(20)
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

		IF EXISTS(SELECT 1 FROM [dbo].[PaymentMethods] WHERE Name = @Name)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Method already exists', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[PaymentMethods](Name)
			VALUES(@Name)
			
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
	Usp_PaymentMethods_GET
	@PaymentMethodId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			PaymentMethodId INT,
			Name NVARCHAR(20),
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM PaymentMethods WHERE PaymentMethodId = @PaymentMethodId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, PaymentMethodId, Name, OperationDateTime)
				SELECT 1, 'Method found', PaymentMethodId, Name, GETDATE()
				FROM PaymentMethods
				WHERE PaymentMethodId = @PaymentMethodId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, PaymentMethodId, Name, OperationDateTime)
				VALUES(0, 'Error: Method not found', @PaymentMethodId, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, PaymentMethodId, Name, OperationDateTime)
			VALUES(0, @ErrorMessage, @PaymentMethodId, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_PaymentMethods_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			PaymentMethodId INT,
		    Name NVARCHAR(20),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, PaymentMethodId, Name, OperationDateTime)
			SELECT 1, 'Method found', PaymentMethodId, Name, GETDATE()
			FROM PaymentMethods
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, PaymentMethodId, Name, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_PaymentMethods_UPD
		@PaymentMethodId INT,
		@Name NVARCHAR(20)
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[PaymentMethods] WHERE PaymentMethodId = @PaymentMethodId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Method not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE PaymentMethods
			SET 
				Name = @Name
			WHERE PaymentMethodId = @PaymentMethodId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @PaymentMethodId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @PaymentMethodId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_PaymentMethods_DEL
		@PaymentMethodId INT
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

			DELETE FROM PaymentMethods
			WHERE PaymentMethodId = @PaymentMethodId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Method not found', 'NONE', @PaymentMethodId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @PaymentMethodId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @PaymentMethodId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

EXEC Usp_PaymentMethods_INS @Name = 'Cash'
EXEC Usp_PaymentMethods_UPD @PaymentMethodId = 1, @Name = 'Cash Type 1'
EXEC Usp_PaymentMethods_GET @PaymentMethodId = 1
EXEC Usp_PaymentMethods_GET_ALL
EXEC Usp_PaymentMethods_DEL @PaymentMethodId = 1

INSERT INTO PaymentMethods(Name) 
	VALUES ('Cash'),
			('Debit Card'),
			('Credit Card'),
			('To Define');
**/