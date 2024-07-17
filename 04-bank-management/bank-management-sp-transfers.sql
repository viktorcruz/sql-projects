--; sistema gestion bancaria
--CREATE DATABASE Grune_Bank
USE [Grune_Bank]
GO



IF OBJECT_ID('[dbo].[Usp_Accounts_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Accounts_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Accounts_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Accounts_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Accounts_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Accounts_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Accounts_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Accounts_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Accounts_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Accounts_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Accounts_INS
		@OperationNumber NVARCHAR(100),
		@SourceAccountId INT,
		@DestinationAccountId INT,
		@Amount MONEY,
		@TransferDate DATETIME,
		@TransferType NVARCHAR(20),
		@TransferStatus NVARCHAR(20) 
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

		IF EXISTS(SELECT 1 FROM [dbo].[Transfers] WHERE OperationNumber = @OperationNumber)
		BEGIN 

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Transfer already exists', 'NONE', NULL, GETDATE())

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN

			INSERT INTO [dbo].[Transfers]
				(
					OperationNumber, 
					SourceAccountId, 
					DestinationAccountId, 
					Amount, 
					TransferDate,
					TransferType,
					TransferStatus
				)
			VALUES
				(
					@OperationNumber, 
					@SourceAccountId, 
					@DestinationAccountId, 
					@Amount, 
					@TransferDate,
					@TransferType,
					@TransferStatus
				)
			
			
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
	Usp_Accounts_GET
	@TransferId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			TransferId INT,
			SourceAccountId INT,
			DestinationAccountId INT,
			OperationNumber NVARCHAR(50),
			Amount MONEY,
			TransferDate DATETIME,
			TransferType NVARCHAR(20),
			TransferStatus NVARCHAR(20),
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Transfers WHERE TransferId = @TransferId)
			BEGIN
			 
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						TransferId, 
						OperationNumber, 
						SourceAccountId, 
						DestinationAccountId, 
						Amount, 
						TransferDate,
						TransferType,
						TransferStatus,
						OperationDateTime
					)
				SELECT
						1, 
						'Transfer found', 
						TransferId, 
						OperationNumber, 
						SourceAccountId, 
						DestinationAccountId, 
						Amount, 
						TransferDate,
						TransferType,
						TransferStatus,
						GETDATE()
				FROM Transfers
				WHERE TransferId = @TransferId
				
			END
			ELSE BEGIN
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						TransferId, 
						OperationNumber, 
						SourceAccountId, 
						DestinationAccountId, 
						Amount, 
						TransferDate,
						TransferType,
						TransferStatus,
						OperationDateTime
					)
				VALUES(0, 'Error: Transfer not found', @TransferId, NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						TransferId, 
						OperationNumber, 
						SourceAccountId, 
						DestinationAccountId, 
						Amount, 
						TransferDate,
						TransferType,
						TransferStatus,
						OperationDateTime
					)
			VALUES(0, @ErrorMessage, @TransferId, NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Accounts_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			TransferId INT,
			SourceAccountId INT,
			DestinationAccountId INT,
			OperationNumber NVARCHAR(100),
			Amount MONEY,
			TransferDate DATETIME,
			TransferType NVARCHAR(20),
			TransferStatus NVARCHAR(20),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						TransferId, 
						OperationNumber, 
						SourceAccountId, 
						DestinationAccountId, 
						Amount, 
						TransferDate,
						TransferType,
						TransferStatus,
						OperationDateTime
					)
			SELECT 
						1, 
						'Transfer found', 
						TransferId, 
						OperationNumber, 
						SourceAccountId, 
						DestinationAccountId, 
						Amount, 
						TransferDate,
						TransferType,
						TransferStatus,
						GETDATE()
			FROM Transfers
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						TransferId, 
						OperationNumber, 
						SourceAccountId, 
						DestinationAccountId, 
						Amount, 
						TransferDate,
						TransferType,
						TransferStatus,
						OperationDateTime
					)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Accounts_UPD
		@TransferId INT,
		@SourceAccountId INT,
		@DestinationAccountId INT,
		@OperationNumber NVARCHAR(100),
		@Amount MONEY,
		@TransferDate DATETIME,
		@TransferType NVARCHAR(20),
		@TransferStatus NVARCHAR(20) 
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Transfers] WHERE TransferId = @TransferId AND OperationNumber = @OperationNumber)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Transfer not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Transfers
			SET 
					SourceAccountId = @SourceAccountId,
					DestinationAccountId = @DestinationAccountId,
					OperationNumber = @OperationNumber,
					Amount = @Amount,
					TransferDate = @TransferDate,
					TransferType = @TransferType,
					TransferStatus = @TransferStatus 
					WHERE TransferId = @TransferId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @TransferId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @TransferId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Accounts_DEL
		@TransferId INT
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

			DELETE FROM Transfers
			WHERE TransferId = @TransferId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Transfer not found', 'NONE', @TransferId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @TransferId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @TransferId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

DECLARE @CurrentDateINS DATETIME = GETDATE()
DECLARE @OperationINS NVARCHAR(50) = CONVERT(NVARCHAR(50), NEWID())

EXEC Usp_Accounts_INS 
		@OperationNumber = @OperationINS,
		@SourceAccountId = 6,
		@DestinationAccountId = 7,
		@Amount = 99,
		@TransferDate = @CurrentDateINS,
		@TransferType = 'SPEI',				--; SPEI (MX)
		@TransferStatus = 'Pending'			--; pending, completed, failed


DECLARE @CurrentDateUPD DATETIME = GETDATE()
DECLARE @OperationUPD NVARCHAR(50) = CONVERT(NVARCHAR(50), NEWID())
--; BC8C5BE2-36AF-45FA-B48A-4B068B50C994
EXEC Usp_Accounts_UPD 
		@TransferId = 6,
		@OperationNumber = 'BC8C5BE2-36AF-45FA-B48A-4B068B50C994',
		@SourceAccountId = 6,
		@DestinationAccountId = 7,
		@Amount = 2983,
		@TransferDate = @CurrentDateUPD,
		@TransferType = 'SPEI',				--; SPEI (MX)
		@TransferStatus = 'Completed'			--; pending, completed, failed

EXEC Usp_Accounts_GET @TransferId = 6

EXEC Usp_Accounts_GET_ALL

EXEC Usp_Accounts_DEL @TransferId = 10


INSERT INTO [dbo].[Transfers]
(
	OperationNumber, 
	SourceAccountId, 
	DestinationAccountId, 
	Amount, 
	TransferDate,
	TransferType,
	TransferStatus
)
VALUES
(
	CONVERT(NVARCHAR(50), NEWID()), 
	8, 
	9, 
	99.00, 
	GETDATE(),
	1,
	'PENDING'
)

select * from accounts
**/