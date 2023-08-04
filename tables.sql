CREATE DATABASE WMS

USE WMS

GO
    
CREATE TABLE Clients (
    ClientId INT PRIMARY KEY IDENTITY NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Phone CHAR(12) NOT NULL,
    CHECK (LEN(Phone) = 12)
)

GO
    
CREATE TABLE Mechanics (
    MechanicId INT PRIMARY KEY IDENTITY NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    [Address] VARCHAR(255)
)

GO
    
CREATE TABLE Models (
    ModelId INT PRIMARY KEY IDENTITY NOT NULL,
    [Name] VARCHAR(50) NOT NULL UNIQUE
)

GO
    
CREATE TABLE Jobs(
    JobId INT PRIMARY KEY IDENTITY NOT NULL,
    ModelId INT FOREIGN KEY REFERENCES Models ([ModelId]) NOT NULL,
    [Status] VARCHAR(11) NOT NULL DEFAULT ('Pending'),
    ClientId INT FOREIGN KEY REFERENCES Clients([ClientId]) NOT NULL,
    MechanicId INT FOREIGN KEY REFERENCES Mechanics([MechanicId]),
    IssueDate DATETIME2 NOT NULL,
    FinishDate DATETIME2,
    CHECK ([Status] IN ('Pending', 'In Progress', 'Finished'))
)

GO
    
CREATE TABLE Orders(
    OrderId INT PRIMARY KEY IDENTITY NOT NULL,
    JobId INT FOREIGN KEY REFERENCES Jobs ([JobId]) NOT NULL,
    IssueDate DATETIME2,
    Delivered BIT NOT NULL DEFAULT (0)
)

GO
    
CREATE TABLE Vendors(
    VendorId INT PRIMARY KEY IDENTITY NOT NULL,
    [Name] VARCHAR(50) NOT NULL UNIQUE
)

GO
    
CREATE TABLE Parts(
    PartId INT PRIMARY KEY IDENTITY NOT NULL,
    SerialNumber VARCHAR(50) NOT NULL UNIQUE,
    [Description] VARCHAR(255),
    Price DECIMAL (6, 2) NOT NULL,
    VendorId INT FOREIGN KEY REFERENCES Vendors ([VendorId]) NOT NULL,
    StockQty INT NOT NULL DEFAULT(0),
    CHECK (Price > 0),
    CHECK (StockQty >= 0)
)

GO

CREATE TABLE OrderParts(
    OrderId INT FOREIGN KEY REFERENCES Orders (OrderId) NOT NULL,
    PartId INT FOREIGN KEY REFERENCES Parts (PartId) NOT NULL,
    Quantity INT NOT NULL DEFAULT (1),
    PRIMARY KEY (OrderId, PartId),
    CHECK(Quantity > 0)
)

GO
    
CREATE TABLE PartsNeeded(
    JobId INT FOREIGN KEY REFERENCES Jobs (JobId) NOT NULL,
    PartId INT FOREIGN KEY REFERENCES Parts (PartId) NOT NULL,
    Quantity INT NOT NULL DEFAULT (1),
    PRIMARY KEY (JobId, PartId),
    CHECK(Quantity > 0)
)
