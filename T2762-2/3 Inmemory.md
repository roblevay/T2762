
# SQL Server Lab: Memory-Optimized vs Disk-Based Tables

## 📘 Overview

In this lab, you will compare:

- a **disk-based table**
- a **memory-optimized table**

You will measure:

- insert performance
- delete performance
- (optional) native compiled procedure performance

---

# 🎯 Goal

Understand when memory-optimized tables can provide performance benefits — and when they do not.

---

# ⚠️ Before You Start

- Make sure the folder `C:\Data` exists
- You need permission to create databases and filegroups

---

# 🧪 Step 1: Create the Database

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

USE InMemoryLab;
GO
````

---

# 🧪 Step 2: Create the Tables

## Disk-based table

```sql
DROP TABLE IF EXISTS dbo.DiskBasedOrders
CREATE TABLE dbo.DiskBasedOrders
(
    OrderID    INT IDENTITY PRIMARY KEY,
    CustomerID INT NOT NULL,
    Amount     DECIMAL(10,2) NOT NULL,
    OrderDate  DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO
```

---

## Memory-optimized table

```sql
DROP TABLE IF EXISTS dbo.InMemoryOrders
CREATE TABLE dbo.InMemoryOrders
(
    OrderID    INT IDENTITY NOT NULL,
    CustomerID INT NOT NULL,
    Amount     DECIMAL(10,2) NOT NULL,
    OrderDate  DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_InMemoryOrders PRIMARY KEY NONCLUSTERED (OrderID)
)
WITH (
    MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_AND_DATA
);
GO
```

---

# 🧪 Step 3: Measure INSERT Performance

## Disk-based table

```sql
DECLARE @start DATETIME2 = SYSDATETIME();

DECLARE @i INT = 1;
WHILE @i <= 50000
BEGIN
    INSERT INTO dbo.DiskBasedOrders (CustomerID, Amount)
    VALUES (@i % 1000, RAND() * 1000);

    SET @i += 1;
END

SELECT 
    'Disk' AS TableType,
    DATEDIFF(MILLISECOND, @start, SYSDATETIME()) AS ElapsedMS;
GO
```

---

## Memory-optimized table

```sql
DECLARE @start DATETIME2 = SYSDATETIME();

DECLARE @i INT = 1;
WHILE @i <= 50000
BEGIN
    INSERT INTO dbo.InMemoryOrders (CustomerID, Amount)
    VALUES (@i % 1000, RAND() * 1000);

    SET @i += 1;
END

SELECT 
    'In-Memory' AS TableType,
    DATEDIFF(MILLISECOND, @start, SYSDATETIME()) AS ElapsedMS;
GO
```

---

## ❓ Questions

* Which insert was faster?
* Was the difference significant?

---

# 🧪 Step 4: Measure DELETE Performance

Now compare how fast you can remove all rows.

---

## Disk-based table

```sql
DECLARE @start DATETIME2 = SYSDATETIME();

DELETE FROM dbo.DiskBasedOrders;

SELECT 
    'Disk DELETE' AS Operation,
    DATEDIFF(MILLISECOND, @start, SYSDATETIME()) AS ElapsedMS;
GO
```

---

## Memory-optimized table

```sql
DECLARE @start DATETIME2 = SYSDATETIME();

DELETE FROM dbo.InMemoryOrders;

SELECT 
    'In-Memory DELETE' AS Operation,
    DATEDIFF(MILLISECOND, @start, SYSDATETIME()) AS ElapsedMS;
GO
```

---

## ❓ Questions

* Which delete was faster?
* Was the difference larger or smaller than for inserts?

---



---

# ⭐ Extra: Native Compiled Procedure

## Create procedure

```sql
CREATE OR ALTER PROCEDURE dbo.usp_InsertInMemory
    @Iterations INT
WITH NATIVE_COMPILATION, SCHEMABINDING
AS
BEGIN ATOMIC WITH (
    TRANSACTION ISOLATION LEVEL = SNAPSHOT,
    LANGUAGE = N'us_english'
)
    DECLARE @i INT = 1;

    WHILE @i <= @Iterations
    BEGIN
        INSERT INTO dbo.InMemoryOrders (CustomerID, Amount)
        VALUES (@i % 1000, CAST(RAND() * 1000 AS DECIMAL(10,2)));

        SET @i += 1;
    END
END;
GO
```

---

## Run and measure

```sql
DECLARE @start DATETIME2 = SYSDATETIME();

EXEC dbo.usp_InsertInMemory @Iterations = 50000;

SELECT 
    'Native Compiled' AS Operation,
    DATEDIFF(MILLISECOND, @start, SYSDATETIME()) AS ElapsedMS;
GO
```

---

## ❓ Questions

* Is the native compiled procedure faster?
* Why might it be faster?
* Why is this not always used?

---

# 📝 Summary

* Memory-optimized tables are not always faster
* Inserts may be slightly faster (or similar)
* Deletes may or may not differ significantly
* Native compiled procedures can improve performance further

---

# 💡 Key Insight

> In-Memory OLTP is designed for high-concurrency workloads — not just simple single-user tests.

```


