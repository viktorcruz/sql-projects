--; sistema gestion bancaria
--CREATE DATABASE Grune_Bank
USE [Grune_Bank]
GO


IF OBJECT_ID('[dbo].[Usp_AirTime_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_AirTime_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_AirTime_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_AirTime_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_AirTime_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_AirTime_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_AirTime_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_AirTime_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_AirTime_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_AirTime_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_AirTime_INS
		@UserId INT,
		@OperatorId INT,
		@ReferenceNumber NVARCHAR(255),
		@Amount MONEY,
		@AirTimeDate DATETIME 
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

		IF EXISTS(SELECT 1 FROM [dbo].[AirTime] WHERE ReferenceNumber = @ReferenceNumber)
		BEGIN 

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Reference already exists', 'NONE', NULL, GETDATE())

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN

			INSERT INTO [dbo].[AirTime]
				(
					UserId,
					OperatorId,
					ReferenceNumber,
					Amount,
					AirTimeDate 
				)
			VALUES
				(
					@UserId,
					@OperatorId,
					@ReferenceNumber,
					@Amount,
					@AirTimeDate 
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
	Usp_AirTime_GET
	@AirTimeId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			AirTimeId INT,
			UserId INT,
			OperatorId INT,
			ReferenceNumber NVARCHAR(255),
			Amount MONEY,
			AirTimeDate DATETIME,
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM AirTime WHERE AirTimeId = @AirTimeId)
			BEGIN
			 
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						AirTimeId,
						UserId,
						OperatorId,
						ReferenceNumber,
						Amount,
						AirTimeDate,
						OperationDateTime
					)
				SELECT
						1, 
						'Reference found', 
						AirTimeId, 
						UserId,
						OperatorId,
						ReferenceNumber,
						Amount,
						AirTimeDate,
						GETDATE()
				FROM AirTime
				WHERE AirTimeId = @AirTimeId
				
			END
			ELSE BEGIN
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						AirTimeId,
						UserId,
						OperatorId,
						ReferenceNumber,
						Amount,
						AirTimeDate,
						OperationDateTime
					)
				VALUES(0, 'Error: Reference not found', @AirTimeId, NULL, NULL, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						AirTimeId,
						UserId,
						OperatorId,
						ReferenceNumber,
						Amount,
						AirTimeDate,
						OperationDateTime
					)
			VALUES(0, @ErrorMessage, @AirTimeId, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_AirTime_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			AirTimeId INT,
			UserId INT,
			OperatorId INT,
			ReferenceNumber NVARCHAR(255),
			Amount MONEY,
			AirTimeDate DATETIME,
			OperationDateTime DATETIME
		)

		BEGIN TRY
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						AirTimeId,
						UserId,
						OperatorId,
						ReferenceNumber,
						Amount,
						AirTimeDate,
						OperationDateTime
					)
				SELECT
						1, 
						'Reference found', 
						AirTimeId,
						UserId,
						OperatorId,
						ReferenceNumber,
						Amount,
						AirTimeDate,
						GETDATE()
			FROM AirTime
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						AirTimeId,
						UserId,
						OperatorId,
						ReferenceNumber,
						Amount,
						AirTimeDate,
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
	Usp_AirTime_UPD
		@AirTimeId INT,
		@UserId INT,
		@OperatorId INT,
		@ReferenceNumber NVARCHAR(255),
		@Amount MONEY,
		@AirTimeDate DATETIME 
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

		IF EXISTS(SELECT 1 FROM [dbo].[AirTime] WHERE AirTimeId = @AirTimeId AND ReferenceNumber = @ReferenceNumber)
		BEGIN
			UPDATE AirTime
			SET 
				UserId = @UserId,
				OperatorId = @OperatorId,
				ReferenceNumber = @ReferenceNumber,
				Amount = @Amount,
				AirTimeDate = @AirTimeDate 
			WHERE AirTimeId = @AirTimeId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @AirTimeId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Reference not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @AirTimeId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_AirTime_DEL
		@AirTimeId INT
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

			DELETE FROM AirTime
			WHERE AirTimeId = @AirTimeId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Reference not found', 'NONE', @AirTimeId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @AirTimeId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @AirTimeId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

DECLARE @OperationINS NVARCHAR(50) = CONVERT(NVARCHAR(50), NEWID())

EXEC Usp_AirTime_INS 
		@UserId = 1,
		@OperatorId = 1,
		@ReferenceNumber = @OperationINS,
		@Amount =  99.00,
		@AirTimeDate = '20240505'

DECLARE @OperationUPD NVARCHAR(50) = CONVERT(NVARCHAR(50), NEWID())
--; 1CA21FBE-668F-411D-99B8-AB16D517C17D
EXEC Usp_AirTime_UPD 
		@AirTimeId = 1,
		@UserId = 1,
		@OperatorId = 1,
		@ReferenceNumber = '1CA21FBE-668F-411D-99B8-AB16D517C17D',
		@Amount =  10099.00,
		@AirTimeDate = '20240505'


EXEC Usp_AirTime_GET @AirTimeId = 1

EXEC Usp_AirTime_GET_ALL

EXEC Usp_AirTime_DEL @AirTimeId = 1


INSERT INTO [dbo].[AirTime]
	(
		UserId,
		OperatorId,
		ReferenceNumber,
		Amount,
		AirTimeDate
	)
VALUES ( 1, 1, CONVERT(NVARCHAR(50), NEWID()), 100.00, GETDATE() ),
	( 2, 3, CONVERT(NVARCHAR(50), NEWID()), 100.00, GETDATE() ),
	( 3, 2, CONVERT(NVARCHAR(50), NEWID()), 100.00, GETDATE() ),
	( 4, 1, CONVERT(NVARCHAR(50), NEWID()), 100.00, GETDATE() ),
	( 1, 3, CONVERT(NVARCHAR(50), NEWID()), 100.00, GETDATE() ),
	( 2, 2, CONVERT(NVARCHAR(50), NEWID()), 100.00, GETDATE() )

**/