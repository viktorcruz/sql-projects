--; gestion de nomina
--CREATE DATABASE Grune_Payrolls
USE [Grune_Payrolls]
GO

IF OBJECT_ID('[dbo].[Usp_Payrolls_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Payrolls_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Payrolls_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Payrolls_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Payrolls_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Payrolls_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Payrolls_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Payrolls_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Payrolls_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Payrolls_DEL]
END
GO



/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Payrolls_INS
		@EmployeeId INT,
		@PayrollNumber NVARCHAR(50),
		@PaymentDate DATETIME,
		@GrossSalary MONEY,
		@TotalDeductions MONEY,
		@NetSalary MONEY
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

		IF EXISTS(SELECT 1 FROM [dbo].[Payrolls] WHERE PayrollNumber = @PayrollNumber)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES( 0, 'Error: Payroll already exists', 'NONE', NULL, GETDATE() )

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[Payrolls](EmployeeId, PayrollNumber, PaymentDate, GrossSalary, TotalDeductions, NetSalary)
			VALUES(@EmployeeId, @PayrollNumber, @PaymentDate, @GrossSalary, @TotalDeductions, @NetSalary)
			
			DECLARE @NewId INT
			SET @NewId = SCOPE_IDENTITY()
			
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES( 1, 'Data has been sucessfully inserted', 'INSERT', @NewId , GETDATE() )

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
	Usp_Payrolls_GET
	@PayrollId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			PayrollId INT,
			EmployeeId INT, 
			PayrollNumber NVARCHAR(50),
			PaymentDate DATETIME,
			GrossSalary MONEY, 
			TotalDeductions MONEY,
			NetSalary MONEY,
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Payrolls WHERE PayrollId = @PayrollId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, PayrollId, EmployeeId, PayrollNumber, PaymentDate, GrossSalary, TotalDeductions, NetSalary, OperationDateTime)
				SELECT 1, 'Payroll found', PayrollId, EmployeeId, PayrollNumber, PaymentDate, GrossSalary, TotalDeductions, NetSalary, GETDATE()
				FROM Payrolls
				WHERE PayrollId = @PayrollId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, PayrollId, EmployeeId, PayrollNumber, PaymentDate, GrossSalary, TotalDeductions, NetSalary, OperationDateTime)
				VALUES(0, 'Error: Payroll not found', @PayrollId, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, PayrollId, EmployeeId, PayrollNumber, PaymentDate, GrossSalary, TotalDeductions, NetSalary, OperationDateTime)
			VALUES(0, @ErrorMessage, @PayrollId, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Payrolls_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			PayrollId INT,
			EmployeeId INT, 
			PayrollNumber NVARCHAR(50),
			PaymentDate DATETIME,
			GrossSalary MONEY, 
			TotalDeductions MONEY,
			NetSalary MONEY,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, PayrollId, EmployeeId, PayrollNumber, PaymentDate, GrossSalary, TotalDeductions, NetSalary, OperationDateTime)
			SELECT 1, 'Payroll found', PayrollId, EmployeeId, PayrollNumber, PaymentDate, GrossSalary, TotalDeductions, NetSalary, GETDATE()
			FROM Payrolls
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, PayrollId, EmployeeId, PayrollNumber, PaymentDate, GrossSalary, TotalDeductions, NetSalary, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Payrolls_UPD
		@PayrollId INT,
		@EmployeeId INT,
		@PayrollNumber NVARCHAR(50),
		@PaymentDate DATETIME,
		@GrossSalary MONEY,
		@TotalDeductions MONEY,
		@NetSalary MONEY
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Payrolls] WHERE PayrollId = @PayrollId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Payroll not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Payrolls
			SET 
				EmployeeId = @EmployeeId,
				PayrollNumber = @PayrollNumber,
				PaymentDate = @PaymentDate,
				GrossSalary = @GrossSalary,
				TotalDeductions = @TotalDeductions,
				NetSalary = @NetSalary 
			WHERE PayrollId = @PayrollId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @PayrollId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @PayrollId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Payrolls_DEL
		@PayrollId INT
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

			DELETE FROM Payrolls
			WHERE PayrollId = @PayrollId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Payroll not found', 'NONE', @PayrollId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @PayrollId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @PayrollId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***
DECLARE @DateInsert DATETIME = GETDATE()
DECLARE @PayrollInsert UNIQUEIDENTIFIER = CONVERT(NVARCHAR(50), NEWID())
EXEC Usp_Payrolls_INS 
		@EmployeeId = 1,
		@PayrollNumber = @PayrollInsert,
		@PaymentDate = @DateInsert,
		@GrossSalary = 1200,
		@TotalDeductions = 2000,
		@NetSalary =  1600

DECLARE @DateUpdate DATETIME = GETDATE()
DECLARE @PayrollUpdate UNIQUEIDENTIFIER = NEWID()
EXEC Usp_Payrolls_UPD 
		@PayrollId = 1,
		@EmployeeId = 1,
		@PayrollNumber = CONVERT(NVARCHAR(50), @PayrollUpdate),
		@PaymentDate = @DateUpdate,
		@GrossSalary = 1200,
		@TotalDeductions = 2000,
		@NetSalary =  1600

EXEC Usp_Payrolls_GET @PayrollId = 1
EXEC Usp_Payrolls_GET_ALL
EXEC Usp_Payrolls_DEL @PayrollId = 1

INSERT INTO Payrolls (EmployeeId, PayrollNumber, PaymentDate, GrossSalary, TotalDeductions, NetSalary) 
	VALUES (1, CONVERT(NVARCHAR(50), NEWID()), GETDATE(), 1200, 3000, 1300),
			(2, CONVERT(NVARCHAR(50), NEWID()), GETDATE(), 3200, 5000, 3300),
			(3, CONVERT(NVARCHAR(50), NEWID()), GETDATE(), 3200, 3000, 2300)

**/

