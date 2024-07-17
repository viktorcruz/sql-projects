--; gestion inventario y ventas
--CREATE DATABASE Grune_InventorySales
USE [Grune_InventorySales]
GO


IF OBJECT_ID('[dbo].[Usp_SalesDetails_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_SalesDetails_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_SalesDetails_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_SalesDetails_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_SalesDetails_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_SalesDetails_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_SalesDetails_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_SalesDetails_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_SalesDetails_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_SalesDetails_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE Usp_SalesDetails_INS
    @TicketNumber NVARCHAR(50),
	@Quantity INT,
	@UnitPrice MONEY,
	@Discount MONEY,
	@SaleId INT,
	@ProductId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Result AS TABLE
    (
        ResultStatus BIT,
        ResultMessage NVARCHAR(4000),
        OperationType NVARCHAR(20),
        AffectedRecordId INT,
        OperationDateTime DATETIME
    );

    BEGIN TRY
        BEGIN TRANSACTION TINS;

        IF EXISTS(SELECT 1 FROM [dbo].[SalesDetails] WHERE TicketNumber = @TicketNumber)
        BEGIN 
            INSERT INTO @Result (ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
            VALUES (0, 'Error: Sale already exists', 'NONE', NULL, GETDATE());

            ROLLBACK TRANSACTION TINS;
        END
        ELSE
        BEGIN

            INSERT INTO [dbo].[SalesDetails] (TicketNumber, Quantity, UnitPrice, Discount, SaleId, ProductId)
            VALUES (@TicketNumber, @Quantity, @UnitPrice, @Discount, @SaleId, @ProductId);

            DECLARE @NewDetailId INT;
            SET @NewDetailId = SCOPE_IDENTITY();

            INSERT INTO @Result (ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
            VALUES (1, 'Data has been sucessfully inserted', 'INSERT', @NewDetailId, GETDATE());

            COMMIT TRANSACTION TINS;
        END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION TINS;
        END

        DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = ERROR_MESSAGE();

        INSERT INTO @Result (ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
        VALUES (0, @ErrorMessage, 'ERROR', NULL, GETDATE());
    END CATCH;

    SET NOCOUNT OFF;
    SELECT * FROM @Result;
END;
GO


/** GET **/
CREATE OR ALTER PROCEDURE
	Usp_SalesDetails_GET
	@DetailId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			DetailId INT,
			TicketNumber NVARCHAR(50),
			Quantity INT,
			UnitPrice MONEY,
			Discount MONEY,
			SaleId INT,
			ProductId INT,
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM SalesDetails WHERE DetailId = @DetailId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, DetailId, TicketNumber, Quantity, UnitPrice, Discount, SaleId, ProductId, OperationDateTime)
				SELECT 1, 'Sale found', DetailId, TicketNumber, Quantity, UnitPrice, Discount, SaleId, ProductId, GETDATE()
				FROM SalesDetails
				WHERE DetailId = @DetailId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, DetailId, TicketNumber, Quantity, UnitPrice, Discount, SaleId, ProductId, OperationDateTime)
				VALUES(0, 'Error: Sale not found', @DetailId, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, DetailId, TicketNumber, Quantity, UnitPrice, Discount, SaleId, ProductId, OperationDateTime)
			VALUES(0, @ErrorMessage, @DetailId, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_SalesDetails_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			DetailId INT,
			TicketNumber NVARCHAR(50),
			Quantity INT,
			UnitPrice MONEY,
			Discount MONEY,
			SaleId INT,
			ProductId INT,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, DetailId, TicketNumber, Quantity, UnitPrice, Discount, SaleId, ProductId, OperationDateTime)
			SELECT 1, 'Sale found', DetailId, TicketNumber, Quantity, UnitPrice, Discount, SaleId, ProductId, GETDATE()
			FROM SalesDetails
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, DetailId, TicketNumber, Quantity, UnitPrice, Discount, SaleId, ProductId, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_SalesDetails_UPD
		@DetailId INT,
		@TicketNumber NVARCHAR(50),
		@Quantity INT,
		@UnitPrice MONEY,
		@Discount MONEY,
		@SaleId INT,
		@ProductId INT
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[SalesDetails] WHERE DetailId = @DetailId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Sale not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE SalesDetails
			SET 
				TicketNumber = @TicketNumber,
				Quantity = @Quantity ,
				UnitPrice = @UnitPrice ,
				Discount = @Discount ,
				SaleId = @SaleId ,
				ProductId = @ProductId 
			WHERE DetailId = @DetailId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @DetailId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @DetailId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_SalesDetails_DEL
		@DetailId INT
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

			DELETE FROM SalesDetails
			WHERE DetailId = @DetailId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Sale not found', 'NONE', @DetailId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @DetailId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @DetailId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

EXEC Usp_SalesDetails_INS 
	@TicketNumber = '10011', @Quantity = 1, @UnitPrice = 1200, 
	@Discount = 0, @SaleId = 1, @ProductId = 1

EXEC Usp_SalesDetails_UPD 
	@TicketNumber = '10011', @Quantity = 2, @UnitPrice = 2400, 
	@Discount = 0, @SaleId = 1, @ProductId = 1

EXEC Usp_SalesDetails_GET @DetailId = 1
EXEC Usp_SalesDetails_GET_ALL
EXEC Usp_SalesDetails_DEL @DetailId = 1

INSERT INTO SalesDetails(TicketNumber, Quantity, UnitPrice, Discount, SaleId, ProductId) 
	VALUES ('10012', 1, 1200, 0, 1, 1),
			('10013', 1, 1300, 0, 1, 1),
			('10014', 1, 2200, 0, 1, 1)

**/

