--; gestion inventario y ventas
--CREATE DATABASE Grune_InventorySales
USE [Grune_InventorySales]
GO


IF OBJECT_ID('[dbo].[Usp_Sales_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Sales_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Sales_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Sales_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Sales_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Sales_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Sales_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Sales_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Sales_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Sales_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE Usp_Sales_INS
    @TicketNumber NVARCHAR(50),
    @CustomerId INT,
    @PaymentMethodId INT,
    @TotalSale MONEY
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

        IF EXISTS(SELECT 1 FROM [dbo].[Sales] WHERE TicketNumber = @TicketNumber)
        BEGIN 
            INSERT INTO @Result (ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
            VALUES (0, 'Error: Sale already exists', 'NONE', NULL, GETDATE());

            ROLLBACK TRANSACTION TINS;
        END
        ELSE
        BEGIN

            INSERT INTO [dbo].[Sales] (TicketNumber, CustomerId, PaymentMethodId, TotalSale, SaleDate)
            VALUES (@TicketNumber, @CustomerId, @PaymentMethodId, @TotalSale, GETDATE());

            DECLARE @NewSaleId INT;
            SET @NewSaleId = SCOPE_IDENTITY();

            INSERT INTO @Result (ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
            VALUES (1, 'Data has been sucessfully inserted', 'INSERT', @NewSaleId, GETDATE());

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
	Usp_Sales_GET
	@SaleId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			SaleId INT,
			TicketNumber NVARCHAR(50),
			CustomerId INT,
			PaymentMethodId INT,
			TotalSale MONEY,
			SaleDate DATETIME,
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Sales WHERE SaleId = @SaleId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, SaleId, TicketNumber, CustomerId, PaymentMethodId, TotalSale, SaleDate, OperationDateTime)
				SELECT 1, 'Sale found', SaleId, TicketNumber, CustomerId, PaymentMethodId, TotalSale, SaleDate, GETDATE()
				FROM Sales
				WHERE SaleId = @SaleId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, SaleId, TicketNumber, CustomerId, PaymentMethodId, TotalSale, SaleDate, OperationDateTime)
				VALUES(0, 'Error: Sale not found', @SaleId, NULL, NULL, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, SaleId, TicketNumber, CustomerId, PaymentMethodId, TotalSale, SaleDate, OperationDateTime)
			VALUES(0, @ErrorMessage, @SaleId, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Sales_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			SaleId INT,
			TicketNumber NVARCHAR(50),
			CustomerId INT,
			PaymentMethodId INT,
			TotalSale MONEY,
			SaleDate DATETIME,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, SaleId, TicketNumber, CustomerId, PaymentMethodId, TotalSale, SaleDate, OperationDateTime)
			SELECT 1, 'Sale found', SaleId, TicketNumber, CustomerId, PaymentMethodId, TotalSale, SaleDate, GETDATE()
			FROM Sales
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, SaleId, TicketNumber, CustomerId, PaymentMethodId, TotalSale, SaleDate, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Sales_UPD
		@SaleId INT,
		@TicketNumber NVARCHAR(50),
		@CustomerId INT,
		@PaymentMethodId INT,
		@TotalSale MONEY
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Sales] WHERE SaleId = @SaleId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Sale not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Sales
			SET 
				TicketNumber = @TicketNumber,
				CustomerId = @CustomerId,
				PaymentMethodId = @PaymentMethodId ,
				TotalSale = @TotalSale
			WHERE SaleId = @SaleId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @SaleId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @SaleId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Sales_DEL
		@SaleId INT
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

			DELETE FROM Sales
			WHERE SaleId = @SaleId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Sale not found', 'NONE', @SaleId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully delete', 'DELETE', @SaleId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @SaleId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

EXEC Usp_Sales_INS 
	@TicketNumber = '10011', @CustomerId = 1, @PaymentMethodId = 1, @TotalSale = 3099

EXEC Usp_Sales_UPD 
	@SaleId = 3, @TicketNumber = '10011', @CustomerId = 1, @PaymentMethodId = 2, @TotalSale = 1099

EXEC Usp_Sales_GET @SaleId = 1
EXEC Usp_Sales_GET_ALL
EXEC Usp_Sales_DEL @SaleId = 1

INSERT INTO Sales (TicketNumber, CustomerId, PaymentMethodId, TotalSale, SaleDate) 
	VALUES ('10012', 1, 1, 1200, GETDATE()),
			('10014', 1, 2, 2200, GETDATE()),
			('10013', 1, 3, 1300, GETDATE())

**/

