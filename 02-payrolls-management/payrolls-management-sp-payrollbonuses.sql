--; gestion de nomina
--CREATE DATABASE Grune_Payrolls
USE [Grune_Payrolls]
GO

IF OBJECT_ID('[dbo].[Usp_PayrollBonuses_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_PayrollBonuses_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_PayrollBonuses_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_PayrollBonuses_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_PayrollBonuses_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_PayrollBonuses_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_PayrollBonuses_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_PayrollBonuses_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_PayrollBonuses_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_PayrollBonuses_DEL]
END
GO



/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_PayrollBonuses_INS
		@PayrollId INT,
		@BonusId INT,
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

		IF EXISTS(SELECT 1 FROM [dbo].[PayrollBonuses] WHERE PayrollId = @PayrollId)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES( 0, 'Error: Payroll already exists', 'NONE', NULL, GETDATE() )

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN

			INSERT INTO [dbo].[PayrollBonuses](PayrollId, BonusId, Amount)
			VALUES(@PayrollId, @BonusId, @Amount)
			
			--DECLARE @NewId INT
			--SET @NewId = SCOPE_IDENTITY()
			
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES( 1, 'Data has been sucessfully inserted', 'INSERT', (SELECT SCOPE_IDENTITY()) , GETDATE() )

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
	Usp_PayrollBonuses_GET
	@PayrollId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			PayrollId INT,
			BonusId INT,
			Amount MONEY,
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM PayrollBonuses WHERE PayrollId = @PayrollId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, PayrollId, BonusId, Amount, OperationDateTime)
				SELECT 1, 'Payroll found', PayrollId, BonusId, Amount, GETDATE()
				FROM PayrollBonuses
				WHERE PayrollId = @PayrollId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, PayrollId, BonusId, Amount, OperationDateTime)
				VALUES(0, 'Error: Payroll not found', @PayrollId, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, PayrollId, BonusId, Amount, OperationDateTime)
			VALUES(0, @ErrorMessage, @PayrollId, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_PayrollBonuses_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			PayrollId INT,
			BonusId INT,
			Amount MONEY,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, PayrollId, BonusId, Amount, OperationDateTime)
			SELECT 1, 'Payroll found', PayrollId, BonusId, Amount, GETDATE()
			FROM PayrollBonuses
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, PayrollId, BonusId, Amount, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_PayrollBonuses_UPD
		@PayrollId INT,
		@BonusId INT,
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[PayrollBonuses] WHERE PayrollId = @PayrollId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Payroll not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE PayrollBonuses
			SET 
				BonusId = @BonusId,
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
	Usp_PayrollBonuses_DEL
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

			DELETE FROM PayrollBonuses
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

EXEC Usp_PayrollBonuses_INS 
		@PayrollId = 3,
		@BonusId = 1,
		@Amount = 344

EXEC Usp_PayrollBonuses_UPD 
		@PayrollId = 1,
		@BonusId = 1,
		@FAmount = 933

EXEC Usp_PayrollBonuses_GET @PayrollId = 1

EXEC Usp_PayrollBonuses_GET_ALL

EXEC Usp_PayrollBonuses_DEL @PayrollId = 1

INSERT INTO PayrollBonuses (PayrollId, BonusId, Amount) 
	VALUES (1, 1, 390), (2, 2, 938)

**/
