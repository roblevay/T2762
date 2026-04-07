# Lab: JSON in SQL Server – from the very beginning

## Goal

After this lab, you should be able to:

* understand what JSON is
* recognize a JSON document
* create simple JSON from a SQL query
* read values from JSON in SQL Server

---

## Part 1 – What is JSON?

JSON is a text format for data.

It is commonly used in:

* web applications
* APIs
* system integrations

A very simple JSON example:

```json
{
  "Product": "Mountain Bike",
  "Price": 1999,
  "InStock": true
}
```

This JSON document contains three properties:

* `Product`
* `Price`
* `InStock`

---

## Part 2 – Create your first JSON string

Run this in SQL Server:

```sql
SELECT N'{"Name":"Robert","City":"Stocksund"}' AS JsonText;
```

### What is happening?

You are just creating a normal string that happens to contain JSON.

### Think about

* What is the key for the name?
* What is the value for the city?

---

## Part 3 – Check if text is valid JSON

Run this:

```sql
SELECT ISJSON(N'{"Name":"Robert","City":"Stocksund"}') AS IsValidJson;
```

### Expected result

`1` means the text is valid JSON.

Now try this:

```sql
SELECT ISJSON(N'Robert') AS IsValidJson;
```

### Question

Why is the result different?

---

## Part 4 – Read a value from JSON

Run this:

```sql
DECLARE @j nvarchar(max) = N'{"Name":"Robert","City":"Stocksund"}';

SELECT JSON_VALUE(@j, '$.Name') AS Name,
       JSON_VALUE(@j, '$.City') AS City;
```

### What is happening?

* `JSON_VALUE` extracts a single value
* `$.Name` means: get the value of the `Name` property
* `$.City` means: get the value of the `City` property

---

## Part 5 – Try with more values

Run this:

```sql
DECLARE @j nvarchar(max) = N'{
  "Product": "Mountain Bike",
  "Price": 1999,
  "Color": "Red"
}';

SELECT JSON_VALUE(@j, '$.Product') AS Product,
       JSON_VALUE(@j, '$.Price') AS Price,
       JSON_VALUE(@j, '$.Color') AS Color;
```

### Task

Change:

* product name
* price
* color

Run again and see how the result changes.

---

## Part 6 – Create JSON from a SELECT statement

Now we go from table data to JSON.

Run this:

```sql
SELECT 1 AS ProductID,
       'Mountain Bike' AS ProductName,
       1999 AS Price
FOR JSON PATH;
```

### What is happening?

SQL Server returns the result as JSON.

### Example output

```json
[{"ProductID":1,"ProductName":"Mountain Bike","Price":1999}]
```

Notice that the result is an **array** (`[]`).

---

## Part 7 – Multiple rows to JSON

Run this:

```sql
SELECT v.ProductID,
       v.ProductName,
       v.Price
FROM (VALUES
    (1, 'Mountain Bike', 1999),
    (2, 'Road Bike', 2499),
    (3, 'Helmet', 299)
) AS v(ProductID, ProductName, Price)
FOR JSON PATH;
```

### What is happening?

Multiple rows become a JSON array with multiple objects.

### Question

Can you see that each row becomes one JSON object?

---

## Part 8 – Add a root element

Run this:

```sql
SELECT v.ProductID,
       v.ProductName,
       v.Price
FROM (VALUES
    (1, 'Mountain Bike', 1999),
    (2, 'Road Bike', 2499)
) AS v(ProductID, ProductName, Price)
FOR JSON PATH, ROOT('Products');
```

### What is happening?

The JSON result now has an outer root element called `Products`.

---

## Part 9 – Read JSON from an array

Run this:

```sql
DECLARE @j nvarchar(max) = N'[
  {"Product":"Mountain Bike","Price":1999},
  {"Product":"Helmet","Price":299}
]';

SELECT JSON_VALUE(@j, '$[0].Product') AS FirstProduct,
       JSON_VALUE(@j, '$[1].Price') AS SecondPrice;
```

### What is happening?

* `$[0]` = first object in the array
* `$[1]` = second object in the array

---

## Part 10 – Exercises

### Exercise 1

Create a JSON string with:

* Name = Anna
* Age = 32
* Country = Sweden

Then use `JSON_VALUE` to read all three values.

### Exercise 2

Create JSON from this query:

```sql
SELECT 101 AS CourseID,
       'JSON Basics' AS CourseName,
       'Beginner' AS Level
FOR JSON PATH;
```

### Exercise 3

Add one more row using `VALUES` and run again.

---

## Part 11 – Summary

In this lab you have learned that:

* JSON is just text
* SQL Server can validate JSON using `ISJSON`
* SQL Server can read values using `JSON_VALUE`
* SQL Server can generate JSON using `FOR JSON PATH`

---

## Extra (if you have time)

Try creating JSON from a real table in AdventureWorks, for example products.

Example:

```sql
SELECT TOP (5)
       ProductID,
       Name
FROM Production.Product
FOR JSON PATH;
```

---

## Instructor notes

This is intentionally a very simple introduction lab.

The goal is that participants first understand:

1. JSON is just text
2. what a JSON document looks like
3. how to read a value
4. how SQL Server can generate JSON automatically

Next steps after this lab:

* `JSON_QUERY`
* `OPENJSON`
* comparison between JSON and XML
