--; sistema gestion bancaria
--CREATE DATABASE Grune_Bank
USE [Grune_Bank]
GO



IF OBJECT_ID('[dbo].[Usp_ServicePayments_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_ServicePayments_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_ServicePayments_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_ServicePayments_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_ServicePayments_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_ServicePayments_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_ServicePayments_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_ServicePayments_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_ServicePayments_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_ServicePayments_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_ServicePayments_INS
		@ServiceId INT,
		@UserId INT,
		@Amount MONEY, 
		@PaymentDate DATETIME,
		@Barcode NVARCHAR(255) 			
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

		IF EXISTS(SELECT 1 FROM [dbo].[ServicePayments] WHERE Barcode = @Barcode)
		BEGIN 

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Payment already exists', 'NONE', NULL, GETDATE())

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN

			INSERT INTO [dbo].[ServicePayments]
				(
					ServiceId,
					UserId,
					Amount, 
					PaymentDate,
					Barcode 
				)
			VALUES
				(
					@ServiceId,
					@UserId,
					@Amount, 
					@PaymentDate,
					@Barcode
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
	Usp_ServicePayments_GET
	@ServicePaymentId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			ServicePaymentId INT,
			ServiceId INT,
			UserId INT,
			Amount MONEY, 
			PaymentDate DATETIME,
			Barcode NVARCHAR(255),
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM ServicePayments WHERE ServicePaymentId = @ServicePaymentId)
			BEGIN
			 
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						ServicePaymentId,
						ServiceId,
						UserId,
						Amount, 
						PaymentDate,
						Barcode,
						OperationDateTime
					)
				SELECT
						1, 
						'Payment found', 
						ServicePaymentId, 
						ServiceId,
						UserId,
						Amount, 
						PaymentDate,
						Barcode,
						GETDATE()
				FROM ServicePayments
				WHERE ServicePaymentId = @ServicePaymentId
				
			END
			ELSE BEGIN
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						ServicePaymentId, 
						ServiceId,
						UserId,
						Amount, 
						PaymentDate,
						Barcode,
						OperationDateTime
					)
				VALUES(0, 'Error: Payment not found', @ServicePaymentId, NULL, NULL, NULL, NULL, NULL,GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						ServicePaymentId, 
						ServiceId,
						UserId,
						Amount, 
						PaymentDate,
						Barcode,
						OperationDateTime					)
			VALUES(0, @ErrorMessage, @ServicePaymentId, NULL, NULL, NULL, NULL, NULL,GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_ServicePayments_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			ServicePaymentId INT,
			ServiceId INT,
			UserId INT,
			Amount MONEY, 
			PaymentDate DATETIME,
			Barcode NVARCHAR(255),
			OperationDateTime DATETIME
		)

		BEGIN TRY
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						ServicePaymentId,
						ServiceId,
						UserId,
						Amount, 
						PaymentDate,
						Barcode,
						OperationDateTime
					)
				SELECT
						1, 
						'Payment found', 
						ServicePaymentId, 
						ServiceId,
						UserId,
						Amount, 
						PaymentDate,
						Barcode,
						GETDATE()
			FROM ServicePayments
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						ServicePaymentId, 
						ServiceId,
						UserId,
						Amount, 
						PaymentDate,
						Barcode,
						OperationDateTime				
					)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, NULL, NULL,GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_ServicePayments_UPD
		@ServicePaymentId INT,
		@ServiceId INT,
		@UserId INT,
		@Amount MONEY, 
		@PaymentDate DATETIME,
		@Barcode NVARCHAR(255) 	
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[ServicePayments] WHERE ServicePaymentId = @ServicePaymentId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Payment not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE ServicePayments
			SET 
				ServiceId= @ServiceId,
				UserId= @UserId,
				Amount= @Amount, 
				PaymentDate= @PaymentDate,
				Barcode= @Barcode
			WHERE ServicePaymentId = @ServicePaymentId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @ServicePaymentId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @ServicePaymentId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_ServicePayments_DEL
		@ServicePaymentId INT
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

			DELETE FROM ServicePayments
			WHERE ServicePaymentId = @ServicePaymentId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Payment not found', 'NONE', @ServicePaymentId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @ServicePaymentId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @ServicePaymentId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***


EXEC Usp_ServicePayments_INS 
		@ServiceId = 6,
		@UserId = 2,
		@Amount = 99.99, 
		@PaymentDate = '20240506',
		@Barcode = 'CH39 0870 4016 0754 7300 7'


EXEC Usp_ServicePayments_UPD 
		@ServicePaymentId = 1,
		@ServiceId INT,
		@UserId INT,
		@Amount MONEY, 
		@PaymentDate DATETIME,
		@Barcode NVARCHAR(255) 

EXEC Usp_ServicePayments_GET @ServicePaymentId = 1

EXEC Usp_ServicePayments_GET_ALL

EXEC Usp_ServicePayments_DEL @ServicePaymentId = 1


INSERT INTO [dbo].[ServicePayments]
(
	ServiceId,
	UserId,
	Amount, 
	PaymentDate,
	Barcode 
)
VALUES(2, 4, 92.4 , GETDATE(), 'CH13 0870 4016 0754 2983 7'),
		(1, 4, 298.14 , GETDATE(), 'CH52 0870 4016 0754 2983 7'),
		(3, 1, 792.54 , GETDATE(), 'CH28 0870 4016 0754 2983 7'),
		(4, 3, 952.74 , GETDATE(), 'CH42 0870 4016 0754 2983 7'),
		(2, 2, 932.84 , GETDATE(), 'CH15 0870 4016 0754 2983 7'),
		(3, 1, 292.94 , GETDATE(), 'CH85 0870 4016 0754 2983 7')

**/