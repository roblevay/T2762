# Lab: Working with Incoming JSON Data (Practical Examples)

## Goal

In this lab, you will:

* receive JSON data (as if from an API)
* store it in SQL Server
* extract and insert it into relational tables

---

# Example 1 – Orders from an API


## Step 1 – Create table

```sql
CREATE TABLE Orders (
    OrderID int,
    Customer nvarchar(100),
    Total int
);
```

## Step 2 – Store JSON in a variable

```sql
DECLARE @json nvarchar(max) = N'[...]'; -- paste JSON here
```

## Step 3 – Incoming JSON

```json
[
  {"OrderID": 1, "Customer": "Anna", "Total": 1200},
  {"OrderID": 2, "Customer": "Robert", "Total": 950},
  {"OrderID": 3, "Customer": "Maria", "Total": 430},
  {"OrderID": 4, "Customer": "John", "Total": 2200},
  {"OrderID": 5, "Customer": "Emma", "Total": 780},
  {"OrderID": 6, "Customer": "Liam", "Total": 1500},
  {"OrderID": 7, "Customer": "Olivia", "Total": 300},
  {"OrderID": 8, "Customer": "Noah", "Total": 670},
  {"OrderID": 9, "Customer": "Ava", "Total": 2100},
  {"OrderID": 10, "Customer": "Lucas", "Total": 890}
]
```


---

## Step 4 – Insert JSON into table

```sql
INSERT INTO Orders (OrderID, Customer, Total)
SELECT OrderID, Customer, Total
FROM OPENJSON(@json)
WITH (
    OrderID int,
    Customer nvarchar(100),
    Total int
);
```

---

## Step 5 – Verify

```sql
SELECT * FROM Orders;
```

---

# Example 2 – Products with Categories

## Step 1 – Incoming JSON

```json
[
  {"ProductID": 1, "Name": "Mountain Bike", "Category": "Bikes", "Price": 1999},
  {"ProductID": 2, "Name": "Road Bike", "Category": "Bikes", "Price": 2499},
  {"ProductID": 3, "Name": "Helmet", "Category": "Accessories", "Price": 299},
  {"ProductID": 4, "Name": "Gloves", "Category": "Accessories", "Price": 99},
  {"ProductID": 5, "Name": "Jersey", "Category": "Clothing", "Price": 499},
  {"ProductID": 6, "Name": "Shorts", "Category": "Clothing", "Price": 399},
  {"ProductID": 7, "Name": "Socks", "Category": "Clothing", "Price": 59},
  {"ProductID": 8, "Name": "Water Bottle", "Category": "Accessories", "Price": 49},
  {"ProductID": 9, "Name": "Pump", "Category": "Accessories", "Price": 199},
  {"ProductID": 10, "Name": "Lock", "Category": "Accessories", "Price": 149}
]
```

---

## Step 2 – Create table

```sql
CREATE TABLE Products (
    ProductID int,
    Name nvarchar(100),
    Category nvarchar(100),
    Price int
);
```

---

## Step 3 – Insert data

```sql
INSERT INTO Products (ProductID, Name, Category, Price)
SELECT ProductID, Name, Category, Price
FROM OPENJSON(@json)
WITH (
    ProductID int,
    Name nvarchar(100),
    Category nvarchar(100),
    Price int
);
```

---

## Step 4 – Try queries

```sql
-- All products in Accessories
SELECT * FROM Products WHERE Category = 'Accessories';

-- Average price
SELECT AVG(Price) FROM Products;
```

---

# Example 3 – Orders with nested items

## Step 1 – Incoming JSON

```json
[
  {
    "OrderID": 1,
    "Customer": "Anna",
    "Items": [
      {"Product": "Bike", "Qty": 1},
      {"Product": "Helmet", "Qty": 2}
    ]
  },
  {
    "OrderID": 2,
    "Customer": "Robert",
    "Items": [
      {"Product": "Gloves", "Qty": 3},
      {"Product": "Pump", "Qty": 1}
    ]
  }
]
```

---

## Step 2 – Tables

```sql
CREATE TABLE Orders2 (
    OrderID int,
    Customer nvarchar(100)
);

CREATE TABLE OrderItems (
    OrderID int,
    Product nvarchar(100),
    Qty int
);
```

---

## Step 3 – Insert Orders

```sql
INSERT INTO Orders2 (OrderID, Customer)
SELECT OrderID, Customer
FROM OPENJSON(@json)
WITH (
    OrderID int,
    Customer nvarchar(100)
);
```

---

## Step 4 – Insert Items

```sql
INSERT INTO OrderItems (OrderID, Product, Qty)
SELECT o.OrderID, i.Product, i.Qty
FROM OPENJSON(@json)
WITH (
    OrderID int,
    Items nvarchar(max) AS JSON
) o
CROSS APPLY OPENJSON(o.Items)
WITH (
    Product nvarchar(100),
    Qty int
) i;
```

---

## Step 5 – Verify

```sql
SELECT * FROM Orders2;
SELECT * FROM OrderItems;
```

---

# Exercises

## Exercise 1

Modify Example 1 and add a new column (e.g. OrderDate).

## Exercise 2

Modify Example 2 and group products by category.

## Exercise 3

In Example 3, calculate total quantity per order.

---

# Summary

You have learned how to:

* receive JSON data
* store it temporarily
* convert JSON into relational tables
* handle nested JSON structures

👉 This is a very common real-world scenario in modern systems.
