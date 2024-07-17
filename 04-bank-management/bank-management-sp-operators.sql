--; sistema gestion bancaria
--CREATE DATABASE Grune_Bank
USE [Grune_Bank]
GO



IF OBJECT_ID('[dbo].[Usp_Operators_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Operators_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Operators_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Operators_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Operators_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Operators_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Operators_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Operators_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Operators_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Operators_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Operators_INS
		@OperatorName NVARCHAR(50),
		@Country NVARCHAR(50)
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

		IF EXISTS(SELECT 1 FROM [dbo].[Operators] WHERE OperatorName = @OperatorName AND Country = @Country)
		BEGIN 

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Operator already exists', 'NONE', NULL, GETDATE())

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN

			INSERT INTO [dbo].[Operators]
				(
					OperatorName,
					Country
				)
			VALUES
				(
					@OperatorName,
					@Country 
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
	Usp_Operators_GET
	@OperatorId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			OperatorId INT,
			OperatorName NVARCHAR(50),
			Country NVARCHAR(50),
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Operators WHERE OperatorId = @OperatorId)
			BEGIN
			 
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						OperatorId,
						OperatorName,
						Country,
						OperationDateTime
					)
				SELECT
						1, 
						'Service found', 
						OperatorId, 
						OperatorName,
						Country,
						GETDATE()
				FROM Operators
				WHERE OperatorId = @OperatorId
				
			END
			ELSE BEGIN
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						OperatorId, 
						OperatorName,
						Country,
						OperationDateTime
					)
				VALUES(0, 'Error: Operator not found', @OperatorId, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						OperatorId, 
						OperatorName,
						Country,
						OperationDateTime					)
			VALUES(0, @ErrorMessage, @OperatorId, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Operators_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			OperatorId INT,
			OperatorName NVARCHAR(50),
			Country NVARCHAR(50),
			OperationDateTime DATETIME
		)

		BEGIN TRY
				INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						OperatorId, 
						OperatorName,
						Country,
						OperationDateTime
					)
				SELECT
						1, 
						'Operator found', 
						OperatorId, 
						OperatorName,
						Country,
						GETDATE()
			FROM Operators
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result
					(
						ResultStatus, 
						ResultMessage, 
						OperatorId, 
						OperatorName,
						Country,
						OperationDateTime				
					)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Operators_UPD
		@OperatorId INT,
		@OperatorName NVARCHAR(50),
		@Country NVARCHAR(50)
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Operators] WHERE OperatorId = @OperatorId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Operator not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Operators
			SET 
				OperatorName = @OperatorName,
				Country = @Country
			WHERE OperatorId = @OperatorId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @OperatorId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @OperatorId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Operators_DEL
		@OperatorId INT
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

			DELETE FROM Operators
			WHERE OperatorId = @OperatorId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Operator not found', 'NONE', @OperatorId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @OperatorId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @OperatorId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***


EXEC Usp_Operators_INS 
		@OperatorName = 'TELCEL',
		@Country = 'MEXICO'


EXEC Usp_Operators_UPD 
		@OperatorId INT,
		@OperatorName = 'TELCEL',
		@Country = 'MEXICO'

EXEC Usp_Operators_GET @OperatorId = 1

EXEC Usp_Operators_GET_ALL

EXEC Usp_Operators_DEL @OperatorId = 1


INSERT INTO [dbo].[Operators]
(
		OperatorName,
		Country
)
VALUES('T-SYSTEMS', 'DEUTCHLAND'),
		('T-SYSTEMS', 'OUSTERREICH'),
		('AT&T', 'UNITED STATES'),
		('T-SYSTEMS', 'RUSSIAN'),
		('MOVISTAR', 'SPAIN'),
		('MOVISTAR', 'MEXICO')

**/