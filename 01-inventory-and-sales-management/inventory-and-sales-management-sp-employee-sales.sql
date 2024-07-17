--; gestion inventario y ventas
--CREATE DATABASE Grune_InventorySales
USE [Grune_InventorySales]
GO


IF OBJECT_ID('[dbo].[Usp_EmployeeSales_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_EmployeeSales_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_EmployeeSales_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_EmployeeSales_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_EmployeeSales_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_EmployeeSales_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_EmployeeSales_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_EmployeeSales_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_EmployeeSales_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_EmployeeSales_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_EmployeeSales_INS
		@EmployeeSaleId INT,
		@EmployeeId INT
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

		IF EXISTS(SELECT 1 FROM [dbo].[EmployeeSales] WHERE EmployeeSaleId = @EmployeeSaleId)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Employee already exists', 'NONE', NULL, GETDATE())

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[EmployeeSales](EmployeeSaleId, EmployeeId)
			VALUES(@EmployeeSaleId, @EmployeeId)
			
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully inserted', 'INSERT', @EmployeeSaleId, GETDATE())

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


/** GET **/
CREATE OR ALTER PROCEDURE
	Usp_EmployeeSales_GET
	@EmployeeSaleId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			EmployeeSaleId INT,
			EmployeeId INT,
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM EmployeeSales WHERE EmployeeSaleId = @EmployeeSaleId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, EmployeeSaleId, EmployeeId, OperationDateTime)
				SELECT 1, 'Employee found', EmployeeSaleId, EmployeeId, GETDATE()
				FROM EmployeeSales
				WHERE EmployeeId = @EmployeeSaleId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, EmployeeSaleId, EmployeeId, OperationDateTime)
				VALUES(0, 'Error: Employee not found', @EmployeeSaleId, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, EmployeeSaleId, EmployeeId, OperationDateTime)
			VALUES(0, @ErrorMessage, @EmployeeSaleId, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_EmployeeSales_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			EmployeeSaleId INT,
			EmployeeId INT,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, EmployeeSaleId, EmployeeId, OperationDateTime)
			SELECT 1, 'Employee found', EmployeeSaleId, EmployeeId, GETDATE()
			FROM EmployeeSales
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, EmployeeSaleId, EmployeeId, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_EmployeeSales_UPD
		@EmployeeSaleId INT,
		@EmployeeId INT
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[EmployeeSales] WHERE EmployeeSaleId = @EmployeeSaleId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Employee not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE EmployeeSales
			SET 
				EmployeeId = @EmployeeId
			WHERE EmployeeSaleId = @EmployeeSaleId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @EmployeeSaleId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @EmployeeId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_EmployeeSales_DEL
		@EmployeeSaleId INT
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

			DELETE FROM EmployeeSales
			WHERE EmployeeSaleId = @EmployeeSaleId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Employee not found', 'NONE', @EmployeeSaleId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @EmployeeSaleId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @EmployeeSaleId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

EXEC Usp_EmployeeSales_INS @EmployeeSaleId = 3, @EmployeeId = 1
EXEC Usp_EmployeeSales_UPD @EmployeeSaleId = 1, @EmployeeId = 2
EXEC Usp_EmployeeSales_GET @EmployeeSaleId = 1
EXEC Usp_EmployeeSales_GET_ALL
EXEC Usp_EmployeeSales_DEL @EmployeeSaleId = 1

INSERT INTO EmployeeSales (EmployeeSaleId, EmployeeId) 
	VALUES (1,1), (1,2)
**/