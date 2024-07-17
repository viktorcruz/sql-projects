--; sistema seminuevos
--CREATE DATABASE Grune_PreOwned
USE [Grune_PreOwned]
GO



IF OBJECT_ID('[dbo].[Usp_Messages_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Messages_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Messages_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Messages_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Messages_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Messages_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Messages_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Messages_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Messages_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Messages_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Messages_INS
		@AddresseeId INT,
		@SenderId INT,
		@VehicleId INT,
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
		BEGIN TRANSACTION TINS

		IF EXISTS(SELECT 1 FROM [dbo].[Messages] WHERE SenderId = @SenderId AND AddresseeId = @AddresseeId)
		BEGIN 

			INSERT INTO [dbo].[Messages](AddresseeId, SenderId, VehicleId, Description, DatePublication)
			VALUES(@AddresseeId, @SenderId, @VehicleId, @Description, GETDATE())
			
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully inserted', 'INSERT', (SELECT SCOPE_IDENTITY()), GETDATE()

			COMMIT TRANSACTION TINS

		END
		ELSE BEGIN

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Message not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TINS

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
	Usp_Messages_GET
	@MessageId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			MessageId INT,
			AddresseeId INT,
			SenderId INT,
			VehicleId INT,
			Description NVARCHAR(255),
			DatePublication DATETIME,
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Messages WHERE MessageId = @MessageId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, MessageId, AddresseeId, SenderId, VehicleId, Description, DatePublication, OperationDateTime)
				SELECT 1, 'Message found', MessageId, AddresseeId, SenderId, VehicleId, Description, DatePublication, GETDATE()
				FROM Messages
				WHERE MessageId = @MessageId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, MessageId, AddresseeId, SenderId, VehicleId, Description, DatePublication, OperationDateTime)
				VALUES(0, 'Error: Message not found', @MessageId, NULL, NULL, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, MessageId, AddresseeId, SenderId, VehicleId, Description, DatePublication, OperationDateTime)
			VALUES(0, @ErrorMessage, @MessageId, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Messages_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			MessageId INT,
			AddresseeId INT,
			SenderId INT,
			VehicleId INT,
			Description NVARCHAR(255),
			DatePublication DATETIME,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, MessageId, AddresseeId, SenderId, VehicleId, Description, DatePublication, OperationDateTime)
			SELECT 1, 'Message found', MessageId,  AddresseeId, SenderId, VehicleId, Description, DatePublication, GETDATE()
			FROM Messages
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, MessageId, AddresseeId, SenderId, VehicleId, Description, DatePublication, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Messages_UPD
		@MessageId INT,
		@AddresseeId INT,
		@SenderId INT,
		@VehicleId INT,
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Messages] WHERE MessageId = @MessageId AND VehicleId = @VehicleId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES( 0, 'Error: Message not found', 'NONE', NULL, GETDATE())

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Messages
			SET 
				AddresseeId = @AddresseeId,
				SenderId = @SenderId,
				VehicleId = @VehicleId, 
				Description= @Description
			WHERE MessageId = @MessageId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES( 1, 'Data has been sucessfully updated', 'UPDATE', @MessageId, GETDATE() )

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @MessageId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Messages_DEL
		@MessageId INT
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

			DELETE FROM Messages
			WHERE MessageId = @MessageId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Message not found', 'NONE', @MessageId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @MessageId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @MessageId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***


EXEC Usp_Messages_INS 
		@AddresseeId = 1,
		@SenderId = 2,
		@VehicleId = 2,
		@Description = 'Description 1'


EXEC Usp_Messages_UPD 
		@MessageId = 1,
		@AddresseeId = 1,
		@SenderId = 2,
		@VehicleId = 2,
		@Description = 'Description 2'

EXEC Usp_Messages_GET @MessageId = 2

EXEC Usp_Messages_GET_ALL

EXEC Usp_Messages_DEL @MessageId = 2



INSERT INTO Messages 
	(
		AddresseeId,
		SenderId,
		VehicleId,
		Description,
		DatePublication 
	)
VALUES( 1, 2, 3, 'Description 3', GETDATE()),
		( 2, 3, 1, 'Description 4', DATEADD(MONTH, -8, GETDATE())),
		( 3, 4, 2, 'Description 5', DATEADD(MONTH, -7, GETDATE())),
		( 4, 1, 4, 'Description 6', DATEADD(MONTH, -6, GETDATE()))
**/
