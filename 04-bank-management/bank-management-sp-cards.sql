--; sistema gestion bancaria
--CREATE DATABASE Grune_Bank
USE [Grune_Bank]
GO



IF OBJECT_ID('[dbo].[Usp_Cards_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Cards_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Cards_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Cards_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Cards_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Cards_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Cards_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Cards_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Cards_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Cards_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Cards_INS
		@UserId INT,
		@CardNumber NVARCHAR(16),
		@ExpirationDate DATETIME,
		@Cvv INT ,
		@Active BIT 
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

		IF EXISTS(SELECT 1 FROM [dbo].[Cards] WHERE CardNumber = @CardNumber AND UserId = @UserId)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Card already exists', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[Cards](UserId, CardNumber, ExpirationDate, Cvv, Active)
			VALUES(@UserId, @CardNumber, @ExpirationDate, @Cvv, @Active)
			
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
	Usp_Cards_GET
	@CardId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			CardId INT,
			UserId INT,
			CardNumber NVARCHAR(16),
			ExpirationDate DATETIME,
			Cvv INT ,
			Active BIT,
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Cards WHERE CardId = @CardId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, CardId, UserId, CardNumber, ExpirationDate, Cvv, Active, OperationDateTime)
				SELECT 1, 'Card found', CardId, UserId, CardNumber, ExpirationDate, Cvv, Active ,GETDATE()
				FROM Cards
				WHERE CardId = @CardId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, CardId, UserId, CardNumber, ExpirationDate, Cvv, Active, OperationDateTime)
				VALUES(0, 'Error: Card not found', @CardId, NULL, NULL, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, CardId, UserId, CardNumber, ExpirationDate, Cvv, Active, OperationDateTime)
			VALUES(0, @ErrorMessage, @CardId, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Cards_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			CardId INT,
			UserId INT,
			CardNumber NVARCHAR(16),
			ExpirationDate DATETIME,
			Cvv INT ,
			Active BIT,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, CardId, UserId, CardNumber, ExpirationDate, Cvv, Active, OperationDateTime)
			SELECT 1, 'Card found', CardId, UserId, CardNumber, ExpirationDate, Cvv, Active, GETDATE()
			FROM Cards
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, CardId, UserId, CardNumber, ExpirationDate, Cvv, Active, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Cards_UPD
		@CardId INT,
		@UserId INT,
		@CardNumber NVARCHAR(16),
		@ExpirationDate DATETIME,
		@Cvv INT ,
		@Active BIT 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Result AS TABLE
	(
		ResultStatus BIT,
		ResultMessage NVARCHAR(100),
		OperationType NVARCHAR(16),
		AffectedRecordId INT,
		OperationDateTime DATETIME
	)
	BEGIN TRY
		BEGIN TRANSACTION TUPD

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Cards] WHERE CardId = @CardId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Card not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Cards
			SET 
				UserId = @UserId ,
				CardNumber = @CardNumber,
				ExpirationDate = @ExpirationDate,
				Cvv = @Cvv,
				Active = @Active
			WHERE CardId = @CardId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @CardId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @CardId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Cards_DEL
		@CardId INT
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

			DELETE FROM Cards
			WHERE CardId = @CardId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Card not found', 'NONE', @CardId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @CardId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @CardId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***


DECLARE @InsCardNumber BIGINT = CAST(round(RAND()*10000000000000000,0) AS BIGINT)
DECLARE @CardINS NVARCHAR(16) = CONVERT(NVARCHAR(16), @InsCardNumber) 

EXEC Usp_Cards_INS
		@UserId = 1,
		@CardNumber = @CardINS,
		@ExpirationDate = '20250612',
		@Cvv = 835,
		@Active = 1

DECLARE @UpdCardNumber BIGINT = CAST(round(RAND()*10000000000000000,0) AS BIGINT)
DECLARE @CardUPD NVARCHAR(16) = CONVERT(NVARCHAR(16), @UpdCardNumber) 

EXEC Usp_Cards_UPD 
		@CardId = 8, 
		@UserId = 1,
		@CardNumber = CardUPD,
		@ExpirationDate = '20260612',
		@Cvv = 938,
		@Active = 0

EXEC Usp_Cards_GET @CardId = 1

EXEC Usp_Cards_GET_ALL

EXEC Usp_Cards_DEL @CardId = 6


DECLARE @CardOne BIGINT = CAST(round(RAND()*10000000000000000,0) AS BIGINT)
DECLARE @CardTwo BIGINT = CAST(round(RAND()*10000000000000000,0) AS BIGINT)
INSERT INTO Cards (UserId, CardNumber, ExpirationDate, Cvv, Active) 
VALUES (1, CONVERT(NVARCHAR(16), @CardOne), DATEADD(YEAR, 2, GETDATE()), 283, 1),
		(2, CONVERT(NVARCHAR(16), @CardTwo), DATEADD(YEAR, 3, GETDATE()), 391, 0)

**/
