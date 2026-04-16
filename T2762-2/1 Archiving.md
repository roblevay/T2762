
---

# 🧪 Exercise: Archiving with Sliding Window (Partitioning)

## 📘 Scenario

You are working with a table that stores **orders**.

* New data is inserted every day
* Old data should be archived after 1 month
* Queries mostly access **recent data**

👉 Goal:

> Keep the table fast by moving old data out efficiently

---

# 🎯 Goal

* Understand **why partitioning helps archiving**
* Implement a **sliding window scenario**
* Move data **without DELETE**

---

# 🧱 Step 1: Create a Partitioned Table

## 🛠️ Create Partition Function (by month)

```sql
USE tempdb;

CREATE PARTITION FUNCTION pfOrders (DATE)
AS RANGE RIGHT FOR VALUES 
(
    '2024-01-01',
    '2024-02-01',
    '2024-03-01',
    '2024-04-01'
);
```

---

## 🛠️ Create Partition Scheme

```sql
CREATE PARTITION SCHEME psOrders
AS PARTITION pfOrders
ALL TO ([PRIMARY]); -- keep it simple
```

---

## 🛠️ Create Table

```sql
DROP TABLE IF EXISTS Orders;
GO

CREATE TABLE Orders
(
    OrderID INT IDENTITY(1,1) NOT NULL,
    OrderDate DATE NOT NULL,
    Amount INT NOT NULL,
    CONSTRAINT PK_Orders PRIMARY KEY (OrderDate, OrderID)
)
ON psOrders(OrderDate);
GO
```

---

# 🧪 Step 2: Insert Data (Multiple Months)

```sql
INSERT INTO Orders (OrderDate, Amount)
VALUES 
('2023-12-15', 100),
('2024-01-10', 200),
('2024-02-10', 300),
('2024-03-10', 400);
```

---

## 🔍 Check where data is stored

```sql
SELECT 
    $PARTITION.pfOrders(OrderDate) AS PartitionNumber,
    *
FROM Orders
ORDER BY OrderDate;
```

👉 This shows how rows are distributed across partitions

---

# 🧪 Step 3: Create Archive Table

```sql
DROP TABLE IF EXISTS Orders_Archive;

CREATE TABLE Orders_Archive
(
    OrderID INT,
    OrderDate DATE,
    Amount INT
);
```

---

# 🧪 Step 4: Archive Old Data (Traditional Way ❌)

Dont't do this!
DELETE FROM Orders
WHERE OrderDate < '2024-01-01';


---

## ❓ Discussion

* What happens with large tables?
* Logging?
* Locks?

👉 This is what we want to avoid.

---

# 🧪 Step 5: Sliding Window (Partition SWITCH ✅)

## 🛠️ Create staging table

```sql
DROP TABLE IF EXISTS Orders_Staging;
GO

CREATE TABLE Orders_Staging
(
    OrderID INT NOT NULL,
    OrderDate DATE NOT NULL,
    Amount INT NOT NULL,
    CONSTRAINT PK_Orders_Staging PRIMARY KEY CLUSTERED (OrderDate, OrderID)
);
GO
```

---

## 🛠️ Switch out oldest partition

```sql
ALTER TABLE Orders
SWITCH PARTITION 1
TO Orders_Staging;
```

---

## 🔍 Check result

```sql
SELECT * FROM Orders;
SELECT * FROM Orders_Staging;
```

👉 Old data moved instantly!

---

# 🧪 Step 6: Archive the data

```sql
INSERT INTO Orders_Archive
SELECT * FROM Orders_Staging;

TRUNCATE TABLE Orders_Staging;
```

---

# 🧪 Step 7: Slide the Window Forward

## Add a new partition

```sql
ALTER PARTITION FUNCTION pfOrders()
SPLIT RANGE ('2024-05-01');
```

---

## (Optional) Remove old boundary

```sql
ALTER PARTITION FUNCTION pfOrders()
MERGE RANGE ('2024-01-01');
```


## Check the data

```sql
SELECT 
    p.partition_number,
    p.rows,
    prv.value AS BoundaryValue
FROM sys.partitions p
JOIN sys.indexes i
    ON p.object_id = i.object_id
    AND p.index_id = i.index_id
LEFT JOIN sys.partition_schemes ps
    ON ps.data_space_id = i.data_space_id
LEFT JOIN sys.partition_functions pf
    ON pf.function_id = ps.function_id
LEFT JOIN sys.partition_range_values prv
    ON prv.function_id = pf.function_id
    AND prv.boundary_id = p.partition_number
WHERE p.object_id = OBJECT_ID('dbo.orders')
    AND p.index_id IN (0,1)
ORDER BY p.partition_number;
```
---

# ✅ What just happened?

Instead of:

❌ DELETE (slow, logged, locks)

You used:

✅ SWITCH (metadata-only, instant)

---

# 💡 Developer Insights

Ask participants:

* Why is SWITCH so fast?
* Why must tables be “identical”?
* When is partitioning worth it?

---

# 🎯 Key Takeaways

* Partitioning = **manage data, not just query it**
* Sliding window = **keep only relevant data “hot”**
* SWITCH = **instant archiving**

---




