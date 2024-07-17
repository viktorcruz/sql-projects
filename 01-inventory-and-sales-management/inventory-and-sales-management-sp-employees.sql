--; gestion inventario y ventas
--CREATE DATABASE Grune_InventorySales
USE [Grune_InventorySales]
GO


IF OBJECT_ID('[dbo].[Usp_Employees_INS]', 'P') IS NOT NULL
BEGIN 
	DROP PROCEDURE [dbo].[Usp_Employees_INS]
END
GO
IF OBJECT_ID('[dbo].[Usp_Employees_GET]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Employees_GET]
END
GO
IF OBJECT_ID('[dbo].[Usp_Employees_GET_ALL]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Employees_GET_ALL]
END
GO
IF OBJECT_ID('[dbo].[Usp_Employees_UPD]','P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Employees_UPD]
END
GO
IF OBJECT_ID('[dbo].[Usp_Employees_DEL]', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[Usp_Employees_DEL]
END
GO


/** INSERT **/
CREATE OR ALTER PROCEDURE
	Usp_Employees_INS
		@FirstName NVARCHAR(20),
		@LastName NVARCHAR(20),
		@Email NVARCHAR(20),
		@Phone NVARCHAR(20),
		@PositionId INT,
		@DepartmentId INT 
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

		IF EXISTS(SELECT 1 FROM [dbo].[Employees] WHERE FirstName = @FirstName)
		BEGIN 
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Employee already exists', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TINS
		END
		ELSE BEGIN
			INSERT INTO [dbo].[Employees](FirstName, LastName, Email, Phone, PositionId, DepartmentId)
			VALUES(@FirstName, @LastName, @Email, @Phone, @PositionId, @DepartmentId)
			
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
	Usp_Employees_GET
	@EmployeeId INT
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			EmployeeId INT,
			FirstName NVARCHAR(20),
			LastName NVARCHAR(20),
			Email NVARCHAR(20),
			Phone NVARCHAR(20),
			PositionId INT,
			DepartmentId INT,
			OperationDateTime DATETIME
		)
		BEGIN TRY
			IF EXISTS(SELECT 1 FROM Employees WHERE EmployeeId = @EmployeeId)
			BEGIN
			 
				INSERT INTO @Result(ResultStatus, ResultMessage, EmployeeId, FirstName, LastName, Email, Phone, PositionId, DepartmentId, OperationDateTime)
				SELECT 1, 'Employee found', EmployeeId, FirstName, LastName, Email, Phone, PositionId, DepartmentId, GETDATE()
				FROM Employees
				WHERE EmployeeId = @EmployeeId
				
			END
			ELSE BEGIN
				INSERT INTO @Result(ResultStatus, ResultMessage, EmployeeId, FirstName, LastName, Email, Phone, PositionId, DepartmentId, OperationDateTime)
				VALUES(0, 'Error: Employee not found', @EmployeeId, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
			END
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, EmployeeId, FirstName, LastName, Email, Phone, PositionId, DepartmentId, OperationDateTime)
			VALUES(0, @ErrorMessage, @EmployeeId, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** GET ALL **/
CREATE OR ALTER PROCEDURE
	Usp_Employees_GET_ALL
AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @Result AS TABLE
		(
			ResultStatus BIT,
			ResultMessage NVARCHAR(100),
			EmployeeId INT,
			FirstName NVARCHAR(20),
			LastName NVARCHAR(20),
			Email NVARCHAR(20),
			Phone NVARCHAR(20),
			PositionId INT,
			DepartmentId INT,
			OperationDateTime DATETIME
		)

		BEGIN TRY
			INSERT INTO @Result(ResultStatus, ResultMessage, EmployeeId, FirstName, LastName, Email, Phone, PositionId, DepartmentId, OperationDateTime)
			SELECT 1, 'Employee found', EmployeeId, FirstName, LastName, Email, Phone, PositionId, DepartmentId, GETDATE()
			FROM Employees
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000)
			SET @ErrorMessage = ERROR_MESSAGE()

			INSERT INTO @Result(ResultStatus, ResultMessage, EmployeeId, FirstName, LastName, Email, Phone, PositionId, DepartmentId, OperationDateTime)
			VALUES(0, @ErrorMessage, NULL, NULL, NULL, NULL, NULL, NULL, NULL, GETDATE())
		END CATCH
	
	SET NOCOUNT OFF;

	SELECT * FROM @Result
END
GO


/** UPDATE **/
CREATE OR ALTER PROCEDURE
	Usp_Employees_UPD
		@EmployeeId INT,
		@FirstName NVARCHAR(20),
		@LastName NVARCHAR(20),
		@Email NVARCHAR(20),
		@Phone NVARCHAR(20),
		@PositionId INT,
		@DepartmentId INT 
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

		IF NOT EXISTS(SELECT 1 FROM [dbo].[Employees] WHERE EmployeeId = @EmployeeId)
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 0, 'Error: Employee not found', 'NONE', NULL, GETDATE()

			ROLLBACK TRANSACTION TUPD
		END
		ELSE BEGIN
			UPDATE Employees
			SET 
				FirstName = @FirstName,
				LastName = @LastName,
				Email = @Email,
				Phone = @Phone,
				PositionId = @PositionId,
				DepartmentId = @DepartmentId  
			WHERE EmployeeId = @EmployeeId

			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			SELECT 1, 'Data has been sucessfully updated', 'UPDATE', @EmployeeId, GETDATE()

			COMMIT TRANSACTION TUPD
		END
	END TRY
	
	
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TUPD
		END

		INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
		VALUES(0, ERROR_MESSAGE(), 'ERROR', @EmployeeId, GETDATE())

	END CATCH
	SET NOCOUNT OFF;
	
	SELECT * FROM @Result
END
GO


/** DELETE **/
CREATE OR ALTER PROCEDURE
	Usp_Employees_DEL
		@EmployeeId INT
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

			DELETE FROM Employees
			WHERE EmployeeId = @EmployeeId

		IF @@ROWCOUNT = 0
		BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(0, 'Error: Employee not found', 'NONE', @EmployeeId, GETDATE())

			ROLLBACK TRANSACTION TDEL
		END
		ELSE BEGIN
			INSERT INTO @Result(ResultStatus, ResultMessage, OperationType, AffectedRecordId, OperationDateTime)
			VALUES(1, 'Data has been sucessfully deleted', 'DELETE', @EmployeeId, GETDATE())

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
		VALUES(0, @ErrorMessage, 'NONE', @EmployeeId, GETDATE())
	END CATCH

	SET NOCOUNT OFF;

	SELECT * FROM @Result
END

/***

EXEC Usp_Employees_INS 
	@FirstName = 'Sarah', @LastName = 'Connor', @Email = 'sandra@example.com', 
	@Phone = '33-1234567890', @PositionId = 1, @DepartmentId = 1

EXEC Usp_Employees_UPD 
	@EmployeeId = 1, @FirstName = 'Natasha', @LastName = 'Romanoff', @Email = 'natasha@example.com', 
	@Phone = '33-1234567890', @PositionId = 1, @DepartmentId = 1

EXEC Usp_Employees_GET @EmployeeId = 1
EXEC Usp_Employees_GET_ALL
EXEC Usp_Employees_DEL @EmployeeId = 1

INSERT INTO Employees (FirstName, LastName, Email, Phone, PositionId, DepartmentId) 
	VALUES ('Gavin', 'Steward', 'gavin@example.com', '123-123-1234', 1, 1),
			('Sandra', 'Hernandez', 'sandra@example.com', '123-123-1234', 1, 1),
			('Juan', 'Perez', 'juan@example.com', '123-123-1234', 1, 1),
			('Artur', 'Byrn', 'artur@example.com', '123-123-1234', 1, 1)
**/