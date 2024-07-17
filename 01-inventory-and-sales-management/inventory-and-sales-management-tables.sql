--; gestion inventario y ventas
--CREATE DATABASE Grune_InventorySales
USE [Grune_InventorySales]
GO


IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[EmployeeSales]'))
BEGIN
	ALTER TABLE [dbo].[EmployeeSales] DROP CONSTRAINT IF EXISTS [FK_EmployeeSales_Employees]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Sales]'))
BEGIN
	ALTER TABLE [dbo].[Sales] DROP CONSTRAINT IF EXISTS [FK_Sales_Customers]
END
GO
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Sales]'))
BEGIN
	ALTER TABLE [dbo].[Sales] DROP CONSTRAINT IF EXISTS [FK_Sales_PaymentMethods]
END
GO
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[SalesDetails]'))
BEGIN
	ALTER TABLE [dbo].[SalesDetails] DROP CONSTRAINT IF EXISTS [FK_SalesDetails_Sales]
END
GO
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[SalesDetails]'))
BEGIN
	ALTER TABLE [dbo].[SalesDetails] DROP CONSTRAINT IF EXISTS [FK_SalesDetails_Products]
END
GO
IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Products]'))
BEGIN
	ALTER TABLE [dbo].[Products] DROP CONSTRAINT IF EXISTS [FK_Products_Categories]
END
GO
IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Products]'))
BEGIN
	ALTER TABLE [dbo].[Products] DROP CONSTRAINT IF EXISTS [FK_Products_Suppliers]
END
GO
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Employees]'))
BEGIN 
	ALTER TABLE [dbo].[Employees] DROP CONSTRAINT IF EXISTS [FK_Employees_Positions]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Employees]'))
BEGIN 
	ALTER TABLE [dbo].[Employees] DROP CONSTRAINT IF EXISTS [FK_Employees_Departments]
END



IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[EmployeeSales]'))
BEGIN
	DROP TABLE [dbo].[EmployeeSales]
END
GO

IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Customers]'))
BEGIN
	DROP TABLE [dbo].[Customers]
END
GO
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[PaymentMethods]'))
BEGIN
	DROP TABLE [dbo].[PaymentMethods]
END
GO
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Categories]'))
BEGIN
	DROP TABLE [dbo].[Categories]
END
GO
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Suppliers]'))
BEGIN
	DROP TABLE [dbo].[Suppliers]
END
GO
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[db].[Employees]'))
BEGIN 
	DROP TABLE [dbo].[Employees]
END
GO
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Sales]'))
BEGIN
	DROP TABLE [dbo].[Sales]
END
GO
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Products]'))
BEGIN
	DROP TABLE [dbo].[Products]
END
GO
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Departments]'))
BEGIN
	DROP TABLE [dbo].[Departments]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Employees]'))
BEGIN 
	DROP TABLE [dbo].[Employees]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[Positions]'))
BEGIN 
	DROP TABLE [dbo].[Positions]
END
IF EXISTS(SELECT 1 FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[SalesDetails]'))
BEGIN 
	DROP TABLE [dbo].[SalesDetails]
END
GO



IF OBJECT_ID(N'Categories') IS NULL
BEGIN
	CREATE TABLE Categories
	(
		CategoryId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		Name NVARCHAR(50) NOT NULL
	);
END

IF OBJECT_ID(N'Suppliers') IS NULL
BEGIN
	CREATE TABLE Suppliers
	(
		SupplierId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		Name NVARCHAR(50) NOT NULL,
		Contact NVARCHAR(50) NOT NULL,
		Address NVARCHAR(50) NOT NULL,
		Phone NVARCHAR(20)
	);
END

IF OBJECT_ID(N'Products') IS NULL
BEGIN
	CREATE TABLE Products
	(
		ProductId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		Name NVARCHAR(100) NOT NULL,
		Description NVARCHAR(255),
		Price MONEY NOT NULL,
		Stock INT NOT NULL DEFAULT 0,
		EntryDate DATETIME NOT NULL,
		CategoryId INT NOT NULL,		
		SupplierId INT NOT NULL			
	);
	ALTER TABLE [Products]
		WITH CHECK ADD CONSTRAINT [FK_Products_Categories]
		FOREIGN KEY([CategoryId]) REFERENCES Categories([CategoryId]);
	ALTER TABLE [Products]
		WITH CHECK ADD CONSTRAINT [FK_Products_Suppliers]
		FOREIGN KEY([SupplierId]) REFERENCES Suppliers([SupplierId]);
END

IF OBJECT_ID(N'Customers') IS NULL
BEGIN
	CREATE TABLE Customers
	(
		CustomerId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		FirstName NVARCHAR(20) NOT NULL,
		LastName NVARCHAR(20) NOT NULL,
		Email NVARCHAR(50) NOT NULL,
		Phone NVARCHAR(20) NOT NULL,
		Address NVARCHAR(100) NOT NULL,
	);
END

IF OBJECT_ID(N'PaymentMethods') IS NULL
BEGIN
	CREATE TABLE PaymentMethods
	(
		PaymentMethodId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		Name NVARCHAR(20) NOT NULL
	);
END

IF OBJECT_ID(N'Sales') IS NULL
BEGIN
	CREATE TABLE Sales
	(
		SaleId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		TicketNumber NVARCHAR(50) NOT NULL,
		CustomerId INT NOT NULL,
		PaymentMethodId INT NOT NULL,
		TotalSale MONEY NOT NULL,
		SaleDate DATETIME NOT NULL
	)
	ALTER TABLE [Sales]
		WITH CHECK ADD CONSTRAINT [FK_Sales_Customers]
		FOREIGN KEY([CustomerId]) REFERENCES Customers([CustomerId]);
	ALTER TABLE [Sales]
		WITH CHECK ADD CONSTRAINT [FK_Sales_PaymentMethods]
		FOREIGN KEY([PaymentMethodId]) REFERENCES PaymentMethods([PaymentMethodId]);
END

IF OBJECT_ID(N'SalesDetails') IS NULL
BEGIN 
	CREATE TABLE SalesDetails
	(
		DetailId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		TicketNumber NVARCHAR(50) NOT NULL,
		Quantity INT NOT NULL,
		UnitPrice MONEY NOT NULL,
		Discount MONEY NOT NULL,
		SaleId INT NOT NULL,
		ProductId INT NOT NULL
	);
	ALTER TABLE [SalesDetails]
		WITH CHECK ADD CONSTRAINT [FK_SalesDetails_Sales]
		FOREIGN KEY([SaleId]) REFERENCES Sales([SaleId]);
	ALTER TABLE [SalesDetails]
		WITH CHECK ADD CONSTRAINT [FK_SalesDetails_Products]
		FOREIGN KEY([ProductId]) REFERENCES Products([ProductId]);
END

IF OBJECT_ID(N'Departments') IS NULL
BEGIN
	CREATE TABLE Departments
	(
		DepartmentId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		Name NVARCHAR(50) NOT NULL
	);
END

IF OBJECT_ID(N'Positions') IS NULL
BEGIN
	CREATE TABLE Positions
	(
		PositionId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		Name NVARCHAR(20) NOT NULL,
		Level INT 
	);
END

IF OBJECT_ID(N'Employees') IS NULL
BEGIN 
	CREATE TABLE Employees
	(
		EmployeeId INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
		FirstName NVARCHAR(20) NOT NULL,
		LastName NVARCHAR(20) NOT NULL,
		Email NVARCHAR(20) NOT NULL,
		Phone NVARCHAR(20),
		PositionId INT NOT NULL,
		DepartmentId INT NOT NULL
	);
		ALTER TABLE [Employees]
			WITH CHECK ADD CONSTRAINT [FK_Employees_Positions]
			FOREIGN KEY([PositionId]) REFERENCES Positions([PositionId])
		ALTER TABLE [Employees]
			WITH CHECK ADD CONSTRAINT [FK_Employees_Departments]
			FOREIGN KEY([DepartmentId]) REFERENCES Departments([DepartmentId])
END

IF OBJECT_ID(N'EmployeeSales') IS NULL
BEGIN
	CREATE TABLE EmployeeSales
	(
		EmployeeSaleId INT NOT NULL,
		EmployeeId INT NOT NULL
	);
	ALTER TABLE [EmployeeSales]
		WITH CHECK ADD CONSTRAINT [FK_EmployeeSales_Employees]
		FOREIGN KEY([EmployeeId]) REFERENCES Employees([EmployeeId]);
	ALTER TABLE [EmployeeSales]
		WITH CHECK ADD CONSTRAINT [FK_EmployeeSales_Sales]
		FOREIGN KEY([EmployeeSaleId]) REFERENCES Sales([SaleId])
END

