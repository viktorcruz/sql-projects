--; sistema gestion bancaria
--CREATE DATABASE Grune_Bank
USE [Grune_Bank]
GO



IF OBJECT_ID('[dbo].[Usp_Transactions_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Transactions_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Transactions_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Transactions_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Transactions_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Transactions_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Transactions_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Transactions_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Transactions_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Transactions_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Transactions_INS
		@TransactionNumber NVARCHAR(255),
		@UserId INT,
		@TransactionType NVARCHAR(20),
		@Amount MONEY,
		@TransactionDate DATETIME,
		@Description NVARCHAR(255)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ErrorMessage NVARCHAR(4000)
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

		IF EXISTS(SELECT 1 FROM [dbo].[Transactions] WHERE TransactionNumber = @TransactionNumber)
		BEGIN 

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Transaction already exists', 'NONE', NULL, GETDATE())

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN

			INSERT INTO [dbo].[Transactions]
				(
					TransactionNumber,
					UserId,
					TransactionType,
					Amount,
					TransactionDate,
					Description 
				)
			VALUES
				(
					@TransactionNumber,
					@UserId,
					@TransactionType,
					@Amount,
					@TransactionDate,
					@Description 				
				)
			DECLARE @NewId INT 
			SET @NewId = SCOPE_IDENTITY()
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully inserted', 'INSERT', @NewId, GETDATE()

			COMMIT TRANSACTION TINS
		END

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TINS
		END

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
	Usp_Transactions_GET
	@TransactionId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			TransactionId INT,
			TransactionNumber NVARCHAR(255),
			UserId INT,
			TransactionType NVARCHAR(20),
			Amount MONEY,
			TransactionDate DATETIME,
			Description NVARCHAR(255),
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Transactions WHERE TransactionId = @TransactionId)
			BEGIN
			 
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						TransactionId,
						TransactionNumber,
						UserId,
						TransactionType,
						Amount,
						TransactionDate,
						Description,
						OperationDateTime
					)
				SELECT
						1, 
						'Transaction found', 
						TransactionId, 
						TransactionNumber,
						UserId,
						TransactionType,
						Amount,
						TransactionDate,
						Description,
						GETDATE()
				FROM Transactions
				WHERE TransactionId = @TransactionId
				
			END
			ELSE BEGIN
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						TransactionId, 
						UserId,
						TransactionType,
						Amount,
						TransactionDate,
						Description,
						OperationDateTime
					)
				VALUES(0, 'Error: Transaction not found', @TransactionId, NULL, NULL, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						TransactionId, 
						UserId,
						TransactionType,
						Amount,
						TransactionDate,
						Description,
						OperationDateTime
					)
			VALUES(0, @ErrorMessage, @TransactionId, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Transactions_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			TransactionId INT,
			TransactionNumber NVARCHAR(255),
			UserId INT,
			TransactionType NVARCHAR(20),
			Amount MONEY,
			TransactionDate DATETIME,
			Description NVARCHAR(255),
			OperationDateTime DATETIME
		)

		BEGIN TRY
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						TransactionId,
						TransactionNumber,
						UserId,
						TransactionType,
						Amount,
						TransactionDate,
						Description,
						OperationDateTime
					)
				SELECT
						1, 
						'Transaction found', 
						TransactionId, 
						TransactionNumber,
						UserId,
						TransactionType,
						Amount,
						TransactionDate,
						Description,
						GETDATE()
			FROM Transactions
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						TransactionId, 
						UserId,
						TransactionType,
						Amount,
						TransactionDate,
						Description,
						OperationDateTime
					)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Transactions_UPD
		@TransactionId INT,
		@TransactionNumber NVARCHAR(255),
		@UserId INT,
		@TransactionType NVARCHAR(20),
		@Amount MONEY,
		@TransactionDate DATETIME,
		@Description NVARCHAR(255)
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

		IF EXISTS(SELECT 1 FROM [dbo].[Transactions] WHERE TransactionId = @TransactionId AND TransactionNumber = @TransactionNumber)
		BEGIN
			UPDATE Transactions
			SET 
				TransactionNumber = @TransactionNumber,
				UserId = @UserId,
				TransactionType = @TransactionType,
				Amount = @Amount,
				TransactionDate = @TransactionDate,
				Description = @Description 
			WHERE TransactionId = @TransactionId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @TransactionId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Transaction not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @TransactionId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Transactions_DEL
		@TransactionId INT
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

			DELETE FROM Transactions
			WHERE TransactionId = @TransactionId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Transaction not found', 'NONE', @TransactionId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @TransactionId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @TransactionId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

DECLARE @OperationINS NVARCHAR(50) = CONVERT(NVARCHAR(50), NEWID())

EXEC Usp_Transactions_INS 
		@TransactionNumber = @OperationINS,
		@UserId = 1,
		@TransactionType = 1,
		@Amount = 9930.99,
		@TransactionDate = '20240506',
		@Description = 'Description 1'

DECLARE @OperationUPD NVARCHAR(50) = CONVERT(NVARCHAR(50), NEWID())
--; 5D8B5F97-33CF-434C-9307-2E0EC6DB9E4A
EXEC Usp_Transactions_UPD 
		@TransactionId = 2,
		@TransactionNumber = '5D8B5F97-33CF-434C-9307-2E0EC6DB9E4A' ,
		@UserId = 1,
		@TransactionType = 1,
		@Amount = 293800.99,
		@TransactionDate = '20240506',
		@Description = 'Description 2'

EXEC Usp_Transactions_GET @TransactionId = 1

EXEC Usp_Transactions_GET_ALL

EXEC Usp_Transactions_DEL @TransactionId = 1


INSERT INTO [dbo].[Transactions]
	(
		TransactionNumber,
		UserId,
		TransactionType,
		Amount,
		TransactionDate,
		Description 
	)
VALUES( CONVERT(NVARCHAR(50), NEWID()), 1, 1, 33.20, GETDATE(), 'Description 01'),
		( CONVERT(NVARCHAR(50), NEWID()), 2, 2, 100.00, GETDATE(), 'Description 02'),
		( CONVERT(NVARCHAR(50), NEWID()), 3, 1, 299.13, GETDATE(), 'Description 03'),
		( CONVERT(NVARCHAR(50), NEWID()), 4, 2, 91840.25, GETDATE(), 'Description 04'),
		( CONVERT(NVARCHAR(50), NEWID()), 2, 1, 9821.54, GETDATE(), 'Description 05')

**/