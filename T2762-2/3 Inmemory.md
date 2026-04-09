# SQL Server Lab: Memory-Optimized vs Disk-Based Tables (Simple Version)

## 📘 Overview

In this lab, you will compare:

- a **normal disk-based table**
- a **memory-optimized table**

You will:

- insert data into both tables
- run simple queries
- compare performance

---

# 🎯 Goal

Understand when a memory-optimized table can be faster than a traditional table.

---

# ⚠️ Before You Start

This lab requires a database that already supports memory-optimized tables.

👉 If the setup is already done by the instructor, you can skip any configuration.



---


## 🧪 Create a Database for Memory-Optimized Tables

Before starting the lab, create a database that supports memory-optimized tables.

> Make sure the folder `C:\Data` exists on your server.

---

### Step 1: Create the database

```sql
CREATE DATABASE InMemoryLab
ON 
PRIMARY 
(
    NAME = InMemoryLab_data,
    FILENAME = 'C:\Data\InMemoryLab_data.mdf'
),
FILEGROUP InMemoryLab_mod CONTAINS MEMORY_OPTIMIZED_DATA
(
    NAME = InMemoryLab_mod,
    FILENAME = 'C:\Data\InMemoryLab_mod'
)
LOG ON 
(
    NAME = InMemoryLab_log,
    FILENAME = 'C:\Data\InMemoryLab_log.ldf'
);
GO
````

---

### Step 2: Use the database

```sql
USE InMemoryLab;
GO
```

---

1. Skapa testmiljön

-- Aktivera In-Memory OLTP på databasen
ALTER DATABASE YourDB 
ADD FILEGROUP imoltp_fg CONTAINS MEMORY_OPTIMIZED_DATA;

ALTER DATABASE YourDB 
ADD FILE (NAME='imoltp', FILENAME='C:\Data\imoltp') 
TO FILEGROUP imoltp_fg;


2. Skapa en diskbaserad tabell

CREATE TABLE dbo.DiskBasedOrders (
    OrderID   INT IDENTITY PRIMARY KEY,
    CustomerID INT NOT NULL,
    Amount    DECIMAL(10,2) NOT NULL,
    OrderDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);


3. Skapa en minnesoptimerad tabell (samma struktur)

CREATE TABLE dbo.InMemoryOrders (
    OrderID    INT IDENTITY NOT NULL,
    CustomerID INT NOT NULL,
    Amount     DECIMAL(10,2) NOT NULL,
    OrderDate  DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_InMemoryOrders PRIMARY KEY NONCLUSTERED (OrderID)
)
WITH (
    MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_AND_DATA  -- eller SCHEMA_ONLY för max hastighet
);


4. Mät INSERT-prestanda

-- Diskbaserad
DECLARE @start DATETIME2 = SYSDATETIME();

DECLARE @i INT = 1;
WHILE @i <= 100000
BEGIN
    INSERT INTO dbo.DiskBasedOrders (CustomerID, Amount)
    VALUES (@i % 1000, RAND() * 1000);
    SET @i += 1;
END

SELECT 
    'Disk' AS TableType,
    DATEDIFF(MILLISECOND, @start, SYSDATETIME()) AS ElapsedMS;

-- Minnesoptimerad
SET @start = SYSDATETIME();
SET @i = 1;

WHILE @i <= 100000
BEGIN
    INSERT INTO dbo.InMemoryOrders (CustomerID, Amount)
    VALUES (@i % 1000, RAND() * 1000);
    SET @i += 1;
END

SELECT 
    'In-Memory' AS TableType,
    DATEDIFF(MILLISECOND, @start, SYSDATETIME()) AS ElapsedMS;


5. Ännu bättre – använd en natively compiled stored procedure
Det är här In-Memory OLTP verkligen lyser:

CREATE PROCEDURE dbo.usp_InsertInMemory
    @Iterations INT
WITH NATIVE_COMPILATION, SCHEMABINDING
AS
BEGIN ATOMIC WITH (
    TRANSACTION ISOLATION LEVEL = SNAPSHOT,
    LANGUAGE = N'Swedish'
)
    DECLARE @i INT = 1;
    WHILE @i <= @Iterations
    BEGIN
        INSERT INTO dbo.InMemoryOrders (CustomerID, Amount)
        VALUES (@i % 1000, CAST(RAND() * 1000 AS DECIMAL(10,2)));
        SET @i += 1;
    END
END;

-- Kör och mät
DECLARE @start DATETIME2 = SYSDATETIME();
EXEC dbo.usp_InsertInMemory @Iterations = 100000;
SELECT DATEDIFF(MILLISECOND, @start, SYSDATETIME()) AS NativeCompiledMS;
