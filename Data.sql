﻿CREATE DATABASE QuanLyQuanCafe
GO

USE QuanLyQuanCafe
GO

-- Food
-- Table
-- FoodCategory
-- Account
-- Bill
-- BillInfo

CREATE TABLE TableFood
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Bàn chưa có tên',
	status NVARCHAR(100) NOT NULL DEFAULT N'Trống'	-- Trống || Có người
)
GO

CREATE TABLE Account
(
	DisplayName NVARCHAR(100) NOT NULL DEFAULT N'Admin',
	UserName NVARCHAR(100) PRIMARY KEY,
	PassWord NVARCHAR(1000) NOT NULL DEFAULT 0,
	Type INT NOT NULL DEFAULT 0 -- 1: Admin && 0: Staff
)
GO

CREATE TABLE FoodCategory
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Chưa đặt tên'
)
GO

CREATE TABLE Food
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Chưa đặt tên',
	idCategory INT NOT NULL,
	price FLOAT NOT NULL DEFAULT 0

	FOREIGN KEY (idCategory) REFERENCES dbo.FoodCategory(id)
)
GO

CREATE TABLE Bill
(
	id INT IDENTITY PRIMARY KEY,
	DateCheckIn DATE NOT NULL DEFAULT GETDATE(),
	DateCheckOut DATE,
	idTable INT NOT NULL,
	status INT NOT NULL	DEFAULT 0-- 1: đã thanh toán && 0: chưa thanh toán
	
	FOREIGN KEY (idTable) REFERENCES dbo.TableFood(id)
)
GO

CREATE TABLE BillInfo
(
	id INT IDENTITY PRIMARY KEY,
	idBill INT NOT NULL,
	idFood INT NOT NULL,
	count INT NOT NULL DEFAULT 0

	FOREIGN KEY (idBill) REFERENCES dbo.Bill(id),
	FOREIGN KEY (idFood) REFERENCES dbo.Food(id)
)
GO

INSERT INTO dbo.Account
(
	UserName,
	DisplayName,
	PassWord,
	Type
)
VALUES 
(
	N'K9', -- UserName - nvarchar(100)
	N'RongK9', -- DisplayName - nvarchar(100)
	N'1', -- PassWord - nvarchar(1000)
	1 -- Type - int
)
GO

INSERT INTO dbo.Account
(
	UserName,
	DisplayName,
	PassWord,
	Type
)
VALUES 
(
	N'staff', -- UserName - nvarchar(100)
	N'staff', -- DisplayName - nvarchar(100)
	N'1', -- PassWord - nvarchar(1000)
	0 -- Type - int
)
GO

--Select * From dbo.Account

CREATE PROC USP_GetAccountByUserName
@userName nvarchar(100)
As
Begin
	Select * From dbo.Account Where UserName = @userName
End
GO

CREATE PROC USP_Login
@userName nvarchar(100), @passWord nvarchar(100)
AS
BEGIN
	SELECT * FROM Account WHERE UserName = @userName AND PassWord = @passWord
END
GO

DECLARE @i INT = 0
WHILE @i <= 10
BEGIN
	INSERT dbo.TableFood (name)
	VALUES (N'Bàn ' + CAST(@i AS nvarchar(100)))
	SET @i = @i + 1
END
GO

CREATE PROC USP_GetTableList
AS SELECT * FROM dbo.TableFood
GO

UPDATE dbo.TableFood SET status = N'Có người' where id = 8
GO

-- thêm bàn
DECLARE @i INT = 0
WHILE @i <= 10
BEGIN
	INSERT dbo.TableFood (name)
	VALUES (N'Bàn ' + CAST(@i AS nvarchar(100)))
	SET @i = @i + 1
END
GO

-- thêm category
INSERT dbo.FoodCategory(name)
VALUES (N'Hải sản')
INSERT dbo.FoodCategory (name)
VALUES (N'Nông sản')
INSERT dbo.FoodCategory (name)
VALUES (N'Lâm sản')
INSERT dbo.FoodCategory (name)
VALUES (N'Sản sản')
INSERT dbo.FoodCategory (name)
VALUES (N'Nước')

-- thêm món ăn
INSERT dbo.Food(name, idCategory, price)
VALUES (N'Mực một nắng sa tế', 1, 120000)
INSERT dbo.Food(name, idCategory, price)
VALUES (N'Nghêu hấp sả', 1, 50000)
INSERT dbo.Food(name, idCategory, price)
VALUES (N'Dú dê nướng sữa', 2, 60000)
INSERT dbo.Food(name, idCategory, price)
VALUES (N'Heo rừng nướng muối ớt', 3, 75000)
INSERT dbo.Food(name, idCategory, price)
VALUES (N'Cơm chiên mushi', 4, 999999)
INSERT dbo.Food(name, idCategory, price)
VALUES (N'7up', 5, 15000)
INSERT dbo.Food(name, idCategory, price)
VALUES (N'Cafe', 5, 12000)

-- thêm bill
INSERT dbo.Bill (DateCheckIn, DateCheckOut, idTable, status)
VALUES (GETDATE(), NULL, 1, 0)
INSERT dbo.Bill (DateCheckIn, DateCheckOut, idTable, status)
VALUES (GETDATE(), NULL, 2, 0)
INSERT dbo.Bill (DateCheckIn, DateCheckOut, idTable, status)
VALUES (GETDATE(), GETDATE(), 2, 1)
INSERT dbo.Bill (DateCheckIn, DateCheckOut, idTable, status)
VALUES (GETDATE(), GETDATE(), 4, 1)

-- thêm bill info
INSERT dbo.BillInfo (idBill, idFood, count)
VALUES (1, 1, 2)
INSERT dbo.BillInfo (idBill, idFood, count)
VALUES (1, 3, 4)
INSERT dbo.BillInfo (idBill, idFood, count)
VALUES (1, 5, 1)
INSERT dbo.BillInfo (idBill, idFood, count)
VALUES (2, 1, 2)
INSERT dbo.BillInfo (idBill, idFood, count)
VALUES (2, 6, 2)
INSERT dbo.BillInfo (idBill, idFood, count)
VALUES (3, 5, 2)
INSERT dbo.BillInfo (idBill, idFood, count)
VALUES (4, 5, 2)

GO

CREATE PROC USP_InsertBill
@idTable INT
AS 
BEGIN
	INSERT dbo.Bill (DateCheckIn, DateCheckOut, idTable, status)
	VALUES (GETDATE(), NULL, @idTable, 0)
END
GO

CREATE PROC USP_InsertBillInfo
@idBill INT, @idFood INT, @count INT
AS 
BEGIN

		DECLARE @isExitBillInfo INT
		DECLARE @foodCount INT = 1

		SELECT @isExitBillInfo = COUNT (*), @foodCount = count FROM dbo.BillInfo WHERE idBill = @idBill AND idFood = @idFood
		
		IF (@isExitBillInfo >0)
		BEGIN
			UPDATE dbo.BillInfo SET count = @foodCount + @count
		END
		ELSE
		BEGIN
			INSERT dbo.BillInfo (idBill, idFood, count)
			VALUES (@idBill, @idFood, @count)
		END
END
GO

