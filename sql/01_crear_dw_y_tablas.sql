CREATE DATABASE DW_TDC;
GO

USE DW_TDC;
GO


CREATE TABLE DimDate
(
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    DayNumber TINYINT NOT NULL,
    MonthNumber TINYINT NOT NULL,
    MonthName VARCHAR(20) NOT NULL,
    QuarterNumber TINYINT NOT NULL,
    YearNumber SMALLINT NOT NULL,
    WeekDayNumber TINYINT NOT NULL,
    WeekDayName VARCHAR(20) NOT NULL,
    IsWeekend BIT NOT NULL,
    IsHoliday BIT NOT NULL
);
GO


CREATE TABLE DimProduct
(
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID VARCHAR(10) NOT NULL,
    ProductName VARCHAR(100) NOT NULL,
    ProductCategory VARCHAR(50) NOT NULL,
    PackageType VARCHAR(50) NOT NULL,
    UnitLiters DECIMAL(10,2) NOT NULL,
    IsDiet BIT NOT NULL
);
GO


CREATE TABLE DimCustomer
(
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    BirthDate DATE NOT NULL,
    AgeGroup VARCHAR(30) NOT NULL,
    ZipCode VARCHAR(20) NOT NULL,
    CustomerType VARCHAR(20) NOT NULL
);
GO


CREATE TABLE DimEmployee
(
    EmployeeKey INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    EmploymentDate DATE NOT NULL,
    EducationLevel VARCHAR(50) NOT NULL
);
GO


CREATE TABLE DimRegion
(
    RegionKey INT IDENTITY(1,1) PRIMARY KEY,
    RegionName VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    City VARCHAR(50) NOT NULL,
    ZipCode VARCHAR(20) NOT NULL,
    RegionCode VARCHAR(10)
);
GO


CREATE TABLE FactSales
(
    SalesKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    BillingID INT NOT NULL,

    DateKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    EmployeeKey INT NOT NULL,
    RegionKey INT NOT NULL,

    Quantity INT NOT NULL,
    SoldLiters DECIMAL(18,2) NOT NULL,
    UnitPrice DECIMAL(18,2) NULL,
    DiscountPercent DECIMAL(5,2) NOT NULL,
    SalesAmount DECIMAL(18,2) NULL,

    CONSTRAINT FK_FactSales_Date
        FOREIGN KEY (DateKey)
        REFERENCES DimDate(DateKey),

    CONSTRAINT FK_FactSales_Customer
        FOREIGN KEY (CustomerKey)
        REFERENCES DimCustomer(CustomerKey),

    CONSTRAINT FK_FactSales_Product
        FOREIGN KEY (ProductKey)
        REFERENCES DimProduct(ProductKey),

    CONSTRAINT FK_FactSales_Employee
        FOREIGN KEY (EmployeeKey)
        REFERENCES DimEmployee(EmployeeKey),

    CONSTRAINT FK_FactSales_Region
        FOREIGN KEY (RegionKey)
        REFERENCES DimRegion(RegionKey)
);
GO

CREATE TABLE DimDate2
(
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    DayNumber TINYINT NOT NULL,
    MonthNumber TINYINT NOT NULL,
    MonthName VARCHAR(20) NOT NULL,
    QuarterNumber TINYINT NOT NULL,
    YearNumber SMALLINT NOT NULL,
    WeekDayNumber TINYINT NOT NULL,
    WeekDayName VARCHAR(20) NOT NULL,
    IsWeekend BIT NOT NULL,
    IsHoliday BIT NOT NULL
);
GO


CREATE TABLE DimProduct2
(
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID VARCHAR(10) NOT NULL,
    ProductName VARCHAR(100) NOT NULL,
    ProductCategory VARCHAR(50) NOT NULL,
    PackageType VARCHAR(50) NOT NULL,
    UnitLiters DECIMAL(10,2) NOT NULL,
    IsDiet BIT NOT NULL
);
GO


CREATE TABLE FactInventory
(
    InventoryKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    DateKey INT NOT NULL,
    ProductKey INT NOT NULL,

    MovementQuantity INT NOT NULL,

    CONSTRAINT FK_FactInventory_Date
        FOREIGN KEY (DateKey)
        REFERENCES DimDate2(DateKey),

    CONSTRAINT FK_FactInventory_Product
        FOREIGN KEY (ProductKey)
        REFERENCES DimProduct2(ProductKey)
);
GO

CREATE TABLE StageEmployee
(
    EmployeeID        VARCHAR(50),
    FullName          VARCHAR(200),
    Gender            VARCHAR(20),
    Category          VARCHAR(50),
    BirthDate         VARCHAR(20),
    EmploymentDate    VARCHAR(20),
    EducationLevel    VARCHAR(100)
);
GO


CREATE TABLE StageCustomer
(
    CustomerID   VARCHAR(50),
    FullName     VARCHAR(200),
    BirthDate    VARCHAR(20),
    ZipCode      VARCHAR(20),
    CustomerType VARCHAR(20)
);
GO



---Llenar la tabla de fechas
DECLARE @Fecha DATE = '20000101';

WHILE @Fecha <= '20111231'
BEGIN

    INSERT INTO dbo.DimDate
    (
        DateKey,
        FullDate,
        DayNumber,
        MonthNumber,
        MonthName,
        QuarterNumber,
        YearNumber,
        WeekDayNumber,
        WeekDayName,
        IsWeekend,
        IsHoliday
    )
    VALUES
    (
        YEAR(@Fecha) * 10000
        + MONTH(@Fecha) * 100
        + DAY(@Fecha),

        @Fecha,

        DAY(@Fecha),

        MONTH(@Fecha),

        DATENAME(MONTH, @Fecha),

        DATEPART(QUARTER, @Fecha),

        YEAR(@Fecha),

        DATEPART(WEEKDAY, @Fecha),

        DATENAME(WEEKDAY, @Fecha),

        CASE
            WHEN DATENAME(WEEKDAY, @Fecha) IN ('Saturday','Sunday')
                THEN 1
            ELSE 0
        END,

        0
    );

    SET @Fecha = DATEADD(DAY,1,@Fecha);

END


CREATE TABLE StageHoliday
(
    HolidayDate VARCHAR(20),
    HolidayName VARCHAR(100)
);

INSERT INTO DimDate2
(
    DateKey,
    FullDate,
    DayNumber,
    MonthNumber,
    MonthName,
    QuarterNumber,
    YearNumber,
    WeekDayNumber,
    WeekDayName,
    IsWeekend,
    IsHoliday
)
SELECT
    DateKey,
    FullDate,
    DayNumber,
    MonthNumber,
    MonthName,
    QuarterNumber,
    YearNumber,
    WeekDayNumber,
    WeekDayName,
    IsWeekend,
    IsHoliday
FROM DimDate;

select * from DimDate2

CREATE TABLE StageInventory
(
    ProductID        INT,
    MovementDate     VARCHAR(30),
    MovementQuantity INT
);


CREATE TABLE StageSales
(   BillingID INT,
    SaleDate VARCHAR(30),

    CustomerID VARCHAR(20),
    ProductID VARCHAR(20),
    EmployeeID VARCHAR(20),

    ZipCode VARCHAR(10),

    Quantity INT,

    UnitPrice DECIMAL(10,2),

    DiscountPercent DECIMAL(5,2));

--agregamos este registro para las registros de FactSales que
--no tienen una region en particular
INSERT INTO DimRegion
(RegionName,State,City,ZipCode)
VALUES ('Unknown','Unknown','Unknown','00000');

select count(*) from StageSales where ZipCode='N0000'

INSERT INTO DimRegion(RegionName,State,City,ZipCode)
VALUES('North',   'Unknown', 'Unknown', 'N0000'),
('South',   'Unknown', 'Unknown', 'S0000'),
('East',    'Unknown', 'Unknown', 'E0000'),
('West',    'Unknown', 'Unknown', 'W0000');

CREATE TABLE StageDiscounts
(
    DiscountID INT,
    DateFrom DATETIME,
    DateUntil DATETIME NULL,
    TotalBilling DECIMAL(10,2),
    Percentage INT
);



SELECT 
    name AS [NombreArchivo], 
    physical_name AS [RutaFisica] 
FROM sys.database_files;