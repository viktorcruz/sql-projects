--; gestion de nomina
--CREATE DATABASE Grune_Payrolls
USE [Grune_Payrolls]
GO

IF OBJECT_ID('[dbo].[Usp_PayrollDeductions_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_PayrollDeductions_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_PayrollDeductions_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_PayrollDeductions_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_PayrollDeductions_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_PayrollDeductions_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_PayrollDeductions_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_PayrollDeductions_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_PayrollDeductions_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_PayrollDeductions_DEL]
END
GO



/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_PayrollDeductions_INS
		@PayrollId INT,
		@DeductionId INT,
		@Amount MONEY 
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

		IF EXISTS(SELECT 1 FROM [dbo].[PayrollDeductions] WHERE PayrollId = @PayrollId)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES( 0, 'Error: Payroll already exists', 'NONE', NULL, GETDATE() )

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[PayrollDeductions](PayrollId, DeductionId, Amount)
			VALUES(@PayrollId, @DeductionId, @Amount)
			
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
	Usp_PayrollDeductions_GET
	@PayrollId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			PayrollId INT,
			DeductionId INT,
			Amount MONEY,
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM PayrollDeductions WHERE PayrollId = @PayrollId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, PayrollId, DeductionId, Amount, OperationDateTime)
				SELECT 1, 'Payroll found', PayrollId, DeductionId, Amount, GETDATE()
				FROM PayrollDeductions
				WHERE PayrollId = @PayrollId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, PayrollId, DeductionId, Amount, OperationDateTime)
				VALUES(0, 'Error: Payroll not found', @PayrollId, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, PayrollId, DeductionId, Amount, OperationDateTime)
			VALUES(0, @ErrorMessage, @PayrollId, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_PayrollDeductions_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			PayrollId INT,
			DeductionId INT,
			Amount MONEY,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, PayrollId, DeductionId, Amount, OperationDateTime)
			SELECT 1, 'Payroll found', PayrollId, DeductionId, Amount, GETDATE()
			FROM PayrollDeductions
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, PayrollId, DeductionId, Amount, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_PayrollDeductions_UPD
		@PayrollId INT,
		@DeductionId INT,
		@Amount MONEY 
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[PayrollDeductions] WHERE PayrollId = @PayrollId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Payroll not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE PayrollDeductions
			SET 
				DeductionId = @DeductionId,
				Amount = @Amount
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
	Usp_PayrollDeductions_DEL
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

			DELETE FROM PayrollDeductions
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

EXEC Usp_PayrollDeductions_INS 
		@PayrollId = 3,
		@DeductionId = 1,
		@Amount = 344

EXEC Usp_PayrollDeductions_UPD 
		@PayrollId = 1,
		@DeductionId = 1,
		@FAmount = 933

EXEC Usp_PayrollDeductions_GET @PayrollId = 1

EXEC Usp_PayrollDeductions_GET_ALL

EXEC Usp_PayrollDeductions_DEL @PayrollId = 1

INSERT INTO PayrollDeductions (PayrollId, DeductionId, Amount) 
	VALUES (1, 1, 390), (2, 2, 938)

**/
