# Lab: JSON in SQL Server – Part 2 (Working with Real Data)

## Goal

After this lab, you should be able to:

* parse JSON into rows using OPENJSON
* work with structured JSON data
* understand when JSON is useful in real scenarios

---

## Part 1 – A real-world scenario

Imagine you receive data from an API in JSON format.

Example:

```json
[
  {"Product":"Mountain Bike","Price":1999},
  {"Product":"Helmet","Price":299},
  {"Product":"Gloves","Price":99}
]
```

Your task is to import and query this data in SQL Server.

---

## Part 2 – Store JSON in a variable

Run this:

```sql
DECLARE @json nvarchar(max) = N'[
  {"Product":"Mountain Bike","Price":1999},
  {"Product":"Helmet","Price":299},
  {"Product":"Gloves","Price":99}
]';
```

---

## Part 3 – Convert JSON to rows (OPENJSON)

Run this:

```sql
SELECT *
FROM OPENJSON(@json);
```

### What is happening?

* SQL Server converts JSON into rows
* Each JSON object becomes a row

You will see columns like:

* key
* value
* type

---

## Part 4 – Extract structured columns

Run this:

```sql
SELECT Product, Price
FROM OPENJSON(@json)
WITH (
    Product nvarchar(100),
    Price int
);
```

### What is happening?

* You define the structure
* SQL Server maps JSON properties to columns

---

## Part 5 – Add more fields

Try this JSON instead:

```sql
DECLARE @json nvarchar(max) = N'[
  {"Product":"Mountain Bike","Price":1999,"Category":"Bikes"},
  {"Product":"Helmet","Price":299,"Category":"Accessories"}
]';
```

Then run:

```sql
SELECT Product, Price, Category
FROM OPENJSON(@json)
WITH (
    Product nvarchar(100),
    Price int,
    Category nvarchar(100)
);
```

---

## Part 6 – Nested JSON

Now try a slightly more advanced example:

```sql
DECLARE @json nvarchar(max) = N'{
  "OrderID": 1001,
  "Customer": "Robert",
  "Items": [
    {"Product":"Bike","Qty":1},
    {"Product":"Helmet","Qty":2}
  ]
}';
```

### Extract simple values:

```sql
SELECT JSON_VALUE(@json, '$.Customer') AS Customer;
```

### Extract array items:

```sql
SELECT Product, Qty
FROM OPENJSON(@json, '$.Items')
WITH (
    Product nvarchar(100),
    Qty int
);
```

---

## Part 7 – Real use case

Imagine this JSON comes from an API.

Task:

1. Extract all products
2. Calculate total quantity

Try:

```sql
SELECT SUM(Qty) AS TotalQty
FROM OPENJSON(@json, '$.Items')
WITH (
    Qty int
);
```

---

## Part 8 – Exercises

### Exercise 1

Create your own JSON with:

* 3 products
* price and category

Use OPENJSON to return them as rows.

### Exercise 2

Create JSON with an order containing multiple items.
Extract:

* customer name
* all items

### Exercise 3

Add a new field (for example Discount) and include it in your query.

---

## Part 9 – Summary

In this lab you learned:

* OPENJSON converts JSON into rows
* WITH clause creates structured columns
* JSON can contain nested arrays
* SQL Server can query JSON like relational data

---

## Instructor notes

This lab connects JSON to real-world usage.

Key message:
👉 JSON is often used when data comes from outside SQL Server (APIs, services).

Typical flow:
API → JSON → SQL Server → relational query

Next step:

* Compare JSON vs XML
* When to store JSON vs normalize data
