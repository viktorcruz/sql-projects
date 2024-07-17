--; gestion de nomina
--CREATE DATABASE Grune_Payrolls
USE [Grune_Payrolls]
GO


CREATE OR ALTER PROCEDURE
	Usp_Positions_INS
		@Name NVARCHAR(50)
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

		IF EXISTS(SELECT 1 FROM [dbo].[Positions] WHERE Name = @Name)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Position alredy exists', 'NONE', NULL,  GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[Positions](Name)
			VALUES(@Name)

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

		DECLARE @ErrorMessage NVARCHAR(4000)
		SET @ErrorMessage = ERROR_MESSAGE()

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, @ErrorMessage, 'ERROR', NULL, GETDATE()) 
	END CATCH

	SET NOCOUNT OFF;
	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_Positions_GET
		@PositionId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			PositionId INT,
			Name NVARCHAR(50),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			IF EXISTS(SELECT 1 FROM [dbo].[Positions] WHERE PositionId = @PositionId)
			BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, PositionId, Name, OperationDateTime)
				SELECT 1, 'Position found', PositionId, Name, GETDATE()
				FROM [dbo].[Positions]
				WHERE PositionId = @PositionId
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, PositionId, Name, OperationDateTime)
				VALUES(0, 'Error: Position not found', @PositionId, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, PositionId, Name, OperationDateTime)
			VALUES(0, @ErrorMessage, @PositionId, Null, GETDATE())
		END CATCH
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_Positions_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			PositionId INT,
			Name NVARCHAR(50),
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, PositionId, Name, OperationDateTime)
			SELECT 1, 'Position found', PositionId, Name, GETDATE()
			FROM [dbo].[Positions]
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, PositionId, Name, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, GETDATE())
		END CATCH
	SET NOCOUNT OFF;
	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_Positions_UPD
		@PositionId INT,
		@Name NVARCHAR(50)
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

		IF EXISTS(SELECT 1 FROM [dbo].[Positions] WHERE PositionId = @PositionId)
		BEGIN 
			UPDATE Positions
			SET 
				Name = @Name
			WHERE PositionId = @PositionId 

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully updated', 'UPDATE', @PositionId, GETDATE())

			COMMIT TRANSACTION TUPD
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0,'Position not found', 'NONE', NULL, GETDATE())

			ROLLBACK TRANSACTION TUPD
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			DECLARE @Error_Message NVARCHAR(4000)
			SET @Error_Message = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, @Error_Message, 'NONE', NULL, GETDATE())
		END
	END CATCH
	SET NOCOUNT OFF;
	SELECT * FROM @Result
END
GO

CREATE OR ALTER PROCEDURE
	Usp_Positions_DEL
		@PositionId INT
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
		BEGIN TRANSACTION TDEL
			IF EXISTS(SELECT 1 FROM [dbo].[Positions] WHERE PositionId = @PositionId)
			BEGIN
				DELETE FROM [dbo].[Positions]
				WHERE PositionId = @PositionId

				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @PositionId, GETDATE())

				COMMIT TRANSACTION TDEL
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
				VALUES(0, 'Error: Position not found', 'NONE', @PositionId, GETDATE())

				ROLLBACK TRANSACTION TDEL
			END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TDEL
		END

		DECLARE @Error_Message NVARCHAR(4000)
		SET @Error_Message = ERROR_MESSAGE()

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, @Error_Message, 'ERROR', @PositionId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;
	SELECT * FROM @Result
END

/**

EXEC Usp_Positions_INS @Name = 'Development'
EXEC Usp_Positions_UPD @PositionId = 1, @Name = 'Development 2'
EXEC Usp_Positions_GET @PositionId = 1
EXEC Usp_Positions_GET_ALL
EXEC Usp_Positions_DEL @PositionId = 1

INSERT INTO Positions (Name) 
	VALUES ('Receptionist'), 
			('Office Manager'), 
			('Marketing Staff'), 
			('Managers'), 
			('Help Desk'), 
			('Scrum Master'), 
			('Software Engineer'), 
			('SQL Developer'), 
			('Web Designer')
**/