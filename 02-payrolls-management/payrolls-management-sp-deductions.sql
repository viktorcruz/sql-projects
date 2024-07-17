--; gestion de nomina
--CREATE DATABASE Grune_Payrolls
USE [Grune_Payrolls]
GO

IF OBJECT_ID('[dbo].[Usp_Deductions_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Deductions_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Deductions_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Deductions_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Deductions_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Deductions_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Deductions_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Deductions_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Deductions_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Deductions_DEL]
END
GO



/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Deductions_INS
		@Name NVARCHAR(50),
		@Percentage DECIMAL(10,2)
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

		IF EXISTS(SELECT 1 FROM [dbo].[Deductions] WHERE Name = @Name)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES( 0, 'Error: Deduction already exists', 'NONE', NULL, GETDATE() )

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[Deductions](Name, Percentage)
			VALUES(@Name, @Percentage)
			
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
	Usp_Deductions_GET
	@DeductionId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			DeductionId INT,
			Name NVARCHAR(20),
			Percentage DECIMAL(10,2),
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Deductions WHERE DeductionId = @DeductionId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, DeductionId, Name, Percentage, OperationDateTime)
				SELECT 1, 'Deduction found', DeductionId, Name, Percentage, GETDATE()
				FROM Deductions
				WHERE DeductionId = @DeductionId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, DeductionId, Name, Percentage, OperationDateTime)
				VALUES(0, 'Error: Deduction not found', @DeductionId, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, DeductionId, Name, Percentage, OperationDateTime)
			VALUES(0, @ErrorMessage, @DeductionId, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Deductions_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			DeductionId INT,
			Name NVARCHAR(50), 
			Percentage DECIMAL(10,2),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, DeductionId, Name, Percentage, OperationDateTime)
			SELECT 1, 'Deduction found', DeductionId, Name, Percentage, GETDATE()
			FROM Deductions
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, DeductionId, Name, Percentage, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Deductions_UPD
		@DeductionId INT,
		@Name NVARCHAR(50),
		@Percentage DECIMAL(10,2)
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Deductions] WHERE DeductionId = @DeductionId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Deduction not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Deductions
			SET 
				Name = @Name,
				Percentage = @Percentage 
			WHERE DeductionId = @DeductionId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @DeductionId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @DeductionId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Deductions_DEL
		@DeductionId INT
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

			DELETE FROM Deductions
			WHERE DeductionId = @DeductionId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Deduction not found', 'NONE', @DeductionId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @DeductionId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @DeductionId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

EXEC Usp_Deductions_INS 
		@Name = 'Personal property Tax',
		@Percentage = 13.33

EXEC Usp_Deductions_UPD 
		@DeductionId = 1,
		@Name = 'Sales Tax 2',
		@Percentage = 15.55

EXEC Usp_Deductions_GET @DeductionId = 1

EXEC Usp_Deductions_GET_ALL

EXEC Usp_Deductions_DEL @DeductionId = 1

INSERT INTO Deductions (Name, Percentage) 
	VALUES ('Taxes', 10.3), ('Sales Tax', 10.3), ('Personal property Tax', 12.2)

**/
