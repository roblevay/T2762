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

# 🧪 Step 1: Create the Tables

## Disk-based table

```sql
DROP TABLE IF EXISTS dbo.TestDisk;
GO

CREATE TABLE dbo.TestDisk
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Value INT
);
GO
````

---

## Memory-optimized table

```sql
DROP TABLE IF EXISTS dbo.TestInMem;
GO

CREATE TABLE dbo.TestInMem
(
    ID INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
    Value INT
)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO
```

---

# 🧪 Step 2: Insert Data

Turn on timing:

```sql
SET STATISTICS TIME ON;
GO
```

---

## Insert into disk table

```sql
INSERT INTO dbo.TestDisk (Value)
SELECT TOP (50000)
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
FROM sys.all_objects a
CROSS JOIN sys.all_objects b;
GO
```

---

## Insert into memory-optimized table

```sql
INSERT INTO dbo.TestInMem (Value)
SELECT TOP (50000)
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
FROM sys.all_objects a
CROSS JOIN sys.all_objects b;
GO
```

---

## ❓ Questions

* Which insert was faster?
* Was the difference large or small?

---

# 🧪 Step 3: Read Data

## Disk-based table

```sql
SELECT SUM(Value)
FROM dbo.TestDisk;
GO
```

---

## Memory-optimized table

```sql
SELECT SUM(Value)
FROM dbo.TestInMem;
GO
```

---

## ❓ Questions

* Which query was faster?
* Was the difference noticeable?

---

# 🧪 Step 4: Point Lookup

## Disk-based table

```sql
SELECT *
FROM dbo.TestDisk
WHERE ID = 25000;
GO
```

---

## Memory-optimized table

```sql
SELECT *
FROM dbo.TestInMem
WHERE ID = 25000;
GO
```

---

## ❓ Questions

* Were both queries fast?
* Any visible difference?

---

# ⭐ Extra: Native Compiled Procedure

## Step 1: Create procedure

```sql
CREATE OR ALTER PROCEDURE dbo.usp_InsertInMem
    @Value INT
WITH NATIVE_COMPILATION, SCHEMABINDING
AS
BEGIN ATOMIC WITH
(
    TRANSACTION ISOLATION LEVEL = SNAPSHOT,
    LANGUAGE = N'us_english'
)
    INSERT INTO dbo.TestInMem (Value)
    VALUES (@Value);
END;
GO
```

---

## Step 2: Test it

```sql
EXEC dbo.usp_InsertInMem @Value = 100;
GO
```

---

## ❓ Questions

* Why might this be faster than normal procedures?
* When would this be useful?

---

# 📝 Summary

* Memory-optimized tables can improve performance
* Inserts are often faster
* Reads may or may not be faster
* Native compiled procedures can improve performance further

---

# 💡 Key Idea

> Use memory-optimized tables when you have performance problems – not by default.

```

---


