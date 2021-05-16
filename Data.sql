CREATE DATABASE QuanLyQuanCafe
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
	INSERT dbo.Bill (DateCheckIn, DateCheckOut, idTable, status, discount)
	VALUES (GETDATE(), NULL, @idTable, 0, 0)
END
GO

CREATE PROC USP_InsertBillInfo
@idBill INT, @idFood INT, @count INT
AS 
BEGIN

		DECLARE @isExitBillInfo INT
		DECLARE @foodCount INT = 1

		SELECT @isExitBillInfo = id, @foodCount = b.count 
		FROM dbo.BillInfo as b 
		WHERE idBill = @idBill AND idFood = @idFood
		
		IF (@isExitBillInfo >0)
		BEGIN
			DECLARE @newCount INT  = @foodCount + @count
			IF (@newCount > 0)
				UPDATE dbo.BillInfo SET count = @foodCount + @count WHERE idFood = @idFood
			ELSE
				DELETE dbo.BillInfo WHERE idBill = @idBill AND idFood = @idFood
		END
		ELSE
		BEGIN
			INSERT dbo.BillInfo (idBill, idFood, count)
			VALUES (@idBill, @idFood, @count)
		END
END
GO

DELETE dbo.BillInfo
GO
DELETE dbo.Bill
GO

alter TRIGGER UTG_UpdateBillInfo
ON dbo.BillInfo FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @idBill INT

	SELECT @idBill = idBill FROM inserted

	DECLARE @idTable INT

	SELECT @idTable = idTable FROM dbo.Bill WHERE id = @idBill AND status = 0
	
	DECLARE @count INT
	SELECT @count =  COUNT(*) FROM dbo.BillInfo WHERE idBill = @idBill

	IF(@count > 0)
		UPDATE dbo.TableFood SET status = N'Có người' WHERE id = @idTable
	ELSE
		UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable
END
GO

CREATE TRIGGER UTG_UpdateBill
ON dbo.Bill FOR UPDATE
AS 
BEGIN
	DECLARE @idBill INT

	SELECT @idBill = id FROM inserted

	DECLARE @idTable INT

	SELECT @idTable = idTable FROM dbo.Bill WHERE id = @idBill

	DECLARE @count INT = 0

	SELECT @count = count(*) FROM dbo.Bill WHERE idTable = @idTable AND status = 0

	IF(@count = 0)
		UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable
END
GO

ALTER TABLE dbo.Bill
ADD discount INT
UPDATE dbo.Bill SET discount = 0
GO

CREATE PROC USP_SwitchTable
@idTable1 INT, @idTable2 INT
AS
BEGIN

	DECLARE @idFirstBill int
	DECLARE @idSecondBill int

	DECLARE @isFristTableEmty INT = 1
	DECLARE @isSecondTableEmty INT = 1

	SELECT @idSecondBill = id FROM dbo.Bill WHERE idTable = @idTable2 AND status = 0
	SELECT @idFirstBill = id FROM dbo.Bill WHERE idTable = @idTable1 AND status = 0

	IF(@idFirstBill is NUlL)
	BEGIN
		INSERT dbo.Bill(DateCheckIn, DateCheckOut, idTable, status)
		VALUES (GETDATE(), NULL, @idTable1, 0)
		SELECT @idFirstBill = MAX(id) FROM dbo.Bill WHERE idTable = @idTable1 AND status = 0
	END
	SELECT @isFristTableEmty = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idFirstBill

	IF(@idSecondBill is NUlL)
	BEGIN
		INSERT dbo.Bill(DateCheckIn, DateCheckOut, idTable, status)
		VALUES (GETDATE(), NULL, @idTable2, 0)
		SELECT @idSecondBill = MAX(id) FROM dbo.Bill WHERE idTable = @idTable2 AND status = 0
	END
	SELECT @isSecondTableEmty = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idSecondBill

	SELECT id INTO IDBillInfoTable FROM dbo.BillInfo WHERE idBill = @idSecondBill
	
	UPDATE dbo.BillInfo SET idBill = @idSecondBill WHERE idBill = @idFirstBill

	UPDATE dbo.BillInfo SET idBill = @idFirstBill WHERE id IN (SELECT * FROM IDBillInfoTable)

	DROP TABLE IDBillInfoTable

	IF(@isFristTableEmty = 0)
		UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable2
	IF(@isSecondTableEmty = 0)
		UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable1
END
GO

ALTER TABLE dbo.Bill ADD totalPrice FLOAT

DELETE dbo.BillInfo
GO
DELETE dbo.Bill
GO

CREATE PROC USP_GetListBillByDate
@checkIn date, @checkOut date
AS
BEGIN
	SELECT tf.name as [Tên bàn], b.totalPrice as [Tổng tiền], DateCheckIn as [Ngày vào], DateCheckOut as [Ngày ra], discount as [Giảm giá]
	FROM dbo.Bill as b, dbo.TableFood as tf
	WHERE DateCheckIn >= @checkIn AND DateCheckOut <= @checkOut AND b.status = 1
	AND tf.id = b.idTable
END
GO

CREATE PROC USP_UpdateAccount
@userName NVARCHAR(100), @displayName NVARCHAR(100), @password NVARCHAR(1000), @newPassword NVARCHAR(1000)
AS
BEGIN
	DECLARE @isRightPass INT
	
	SELECT @isRightPass = COUNT(*) FrOM dbo.Account WHERE UserName = @userName AND PassWord = @password

	IF(@isRightPass = 1)
	BEGIN
		IF(@newPassword is NUll OR @newPassword = '')
		BEGIN
			UPDATE dbo.Account SET DisplayName = @displayName WHERE UserName = @userName
		END
		ELSE
			UPDATE dbo.Account SET DisplayName = @displayName, PassWord = @newPassword WHERE UserName = @userName
	END
END
GO

CREATE TRIGGER UTG_DeleteBillInfo
ON dbo.BillInfo FOR DELETE
AS
BEGIN
	DECLARE @idBillInfo INT
	DECLARE @idBill INT
	SELECT @idBillInfo = id, @idBill = Deleted.idBill FROM deleted

	DECLARE @idTable INT
	SELECT @idTable = idTable FROM dbo.Bill WHERE id = @idBill

	DECLARE @count INT = 0
	
	SELECT @count = COUNT(*) FROM dbo.BillInfo AS bi, dbo.Bill AS b WHERE b.id = bi.idBill AND b.id = @idBill AND b.status = 0

	IF(@count = 0)
		UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable
END
GO

CREATE PROC USP_GetListBillByDateAndPage
@checkIn date, @checkOut date, @page int
AS
BEGIN
	DECLARE @pageRows INT = 10
	DECLARE @selectRows INT = @pageRows
	DECLARE @excepRows INT = (@page - 1) * @pageRows

	-- ??? :D ???
	;WITH BillShow AS (SELECT b.id, tf.name as [Tên bàn], b.totalPrice as [Tổng tiền], DateCheckIn as [Ngày vào], DateCheckOut as [Ngày ra], discount as [Giảm giá]
	FROM dbo.Bill as b, dbo.TableFood as tf
	WHERE DateCheckIn >= @checkIn AND DateCheckOut <= @checkOut AND b.status = 1
	AND tf.id = b.idTable)

	SELECT TOP (@selectRows) * FROM BillShow WHERE BillShow.id NOT IN
	(SELECT TOP (@excepRows) id FROM BillShow)
END
GO

CREATE PROC USP_GetNumBillByDate
@checkIn date, @checkOut date
AS
BEGIN
	SELECT COUNT(*)
	FROM dbo.Bill as b, dbo.TableFood as tf
	WHERE DateCheckIn >= @checkIn AND DateCheckOut <= @checkOut AND b.status = 1
	AND tf.id = b.idTable
END
GO