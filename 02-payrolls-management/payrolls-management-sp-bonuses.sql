--; gestion de nomina
--CREATE DATABASE Grune_Payrolls
USE [Grune_Payrolls]
GO

IF OBJECT_ID('[dbo].[Usp_Bonuses_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Bonuses_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Bonuses_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Bonuses_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Bonuses_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Bonuses_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Bonuses_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Bonuses_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Bonuses_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Bonuses_DEL]
END
GO



/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Bonuses_INS
		@Name NVARCHAR(50),
		@FixedAmount MONEY
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

		IF EXISTS(SELECT 1 FROM [dbo].[Bonuses] WHERE Name = @Name)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES( 0, 'Error: Bonus already exists', 'NONE', NULL, GETDATE() )

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[Bonuses](Name, FixedAmount)
			VALUES(@Name, @FixedAmount)
			
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
	Usp_Bonuses_GET
	@BonusId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			BonusId INT,
			Name NVARCHAR(20),
			FixedAmount MONEY,
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Bonuses WHERE BonusId = @BonusId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, BonusId, Name, FixedAmount, OperationDateTime)
				SELECT 1, 'Bonus found', BonusId, Name, FixedAmount, GETDATE()
				FROM Bonuses
				WHERE BonusId = @BonusId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, BonusId, Name, FixedAmount, OperationDateTime)
				VALUES(0, 'Error: Bonus not found', @BonusId, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, BonusId, Name, FixedAmount, OperationDateTime)
			VALUES(0, @ErrorMessage, @BonusId, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Bonuses_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			BonusId INT,
			Name NVARCHAR(50), 
			FixedAmount MONEY,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, BonusId, Name, FixedAmount, OperationDateTime)
			SELECT 1, 'Bonus found', BonusId, Name, FixedAmount, GETDATE()
			FROM Bonuses
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, BonusId, Name, FixedAmount, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Bonuses_UPD
		@BonusId INT,
		@Name NVARCHAR(50),
		@FixedAmount MONEY
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Bonuses] WHERE BonusId = @BonusId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Bonus not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Bonuses
			SET 
				Name = @Name,
				FixedAmount = @FixedAmount
			WHERE BonusId = @BonusId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @BonusId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @BonusId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Bonuses_DEL
		@BonusId INT
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

			DELETE FROM Bonuses
			WHERE BonusId = @BonusId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Bonus not found', 'NONE', @BonusId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @BonusId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @BonusId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

EXEC Usp_Bonuses_INS 
		@Name = 'Christmas Bonus',
		@FixedAmount = 2000

EXEC Usp_Bonuses_UPD 
		@BonusId = 1,
		@Name = 'Christmas Bonus 2',
		@FixedAmount = 4499

EXEC Usp_Bonuses_GET @BonusId = 1

EXEC Usp_Bonuses_GET_ALL

EXEC Usp_Bonuses_DEL @BonusId = 1

INSERT INTO Bonuses (Name, FixedAmount) 
	VALUES ('Bonus Holyday', 2399), ('Referal Bonus', 1099), ('Achievement Bonus', 12.2)

**/
