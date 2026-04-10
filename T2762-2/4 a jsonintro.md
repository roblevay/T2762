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

### Exercise 1

Write your own JSON document with three properties about a person.

Use these ideas if you want:

* Name
* City
* Age

Then answer:

* Which parts are the keys?
* Which parts are the values?

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

### Exercise 2

Write a similar `SELECT` statement that returns JSON text for:

* Name = Anna
* Country = Sweden

Then change one value and run it again.

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

### Exercise 3

Test these three values with `ISJSON`:

1.

```sql
N'{"Name":"Anna"}'
```

2.

```sql
N'Anna'
```

3.

```sql
N'[1,2,3]'
```

Write down which ones are valid JSON.

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

### Exercise 4

Create a variable with this JSON:

```json
{"Product":"Helmet","Price":299,"Color":"Black"}
```

Then use `JSON_VALUE` to return:

* Product
* Price
* Color

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

### Exercise 5

Add one more property to the JSON, for example:

* Brand
* Size
* Category

Then return that value with `JSON_VALUE`.

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

### Exercise 6

Write a similar query for:

* CourseID = 101
* CourseName = 'JSON Basics'
* Level = 'Beginner'

Run it with `FOR JSON PATH`.

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

### Exercise 7

Create your own `VALUES` table with three rows of books, courses, or products.

Return the result as JSON.

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

### Exercise 8

Create JSON with a root element called:

* `Courses`

Use two rows of your own data.

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

### Exercise 9

Create your own JSON array with two objects.

Then return:

* one value from the first object
* one value from the second object

---

## Part 10 – Exercises

### Exercise 10A

Create a JSON string with:

* Name = Anna
* Age = 32
* Country = Sweden

Then use `JSON_VALUE` to read all three values.

### Exercise 10B

Create JSON from this query:

```sql
SELECT 101 AS CourseID,
       'JSON Basics' AS CourseName,
       'Beginner' AS Level
FOR JSON PATH;
```

### Exercise 10C

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

## Answer Key

### Solution 1

Example:

```json
{
  "Name": "Anna",
  "City": "Stockholm",
  "Age": 32
}
```

Keys:

* Name
* City
* Age

Values:

* Anna
* Stockholm
* 32

---

### Solution 2

```sql
SELECT N'{"Name":"Anna","Country":"Sweden"}' AS JsonText;
```

---

### Solution 3

```sql
SELECT ISJSON(N'{"Name":"Anna"}') AS Test1,
       ISJSON(N'Anna') AS Test2,
       ISJSON(N'[1,2,3]') AS Test3;
```

Expected:

* `{"Name":"Anna"}` → valid
* `Anna` → not valid
* `[1,2,3]` → valid

---

### Solution 4

```sql
DECLARE @j nvarchar(max) = N'{"Product":"Helmet","Price":299,"Color":"Black"}';

SELECT JSON_VALUE(@j, '$.Product') AS Product,
       JSON_VALUE(@j, '$.Price') AS Price,
       JSON_VALUE(@j, '$.Color') AS Color;
```

---

### Solution 5

Example:

```sql
DECLARE @j nvarchar(max) = N'{
  "Product": "Mountain Bike",
  "Price": 1999,
  "Color": "Red",
  "Brand": "Contoso"
}';

SELECT JSON_VALUE(@j, '$.Brand') AS Brand;
```

---

### Solution 6

```sql
SELECT 101 AS CourseID,
       'JSON Basics' AS CourseName,
       'Beginner' AS Level
FOR JSON PATH;
```

---

### Solution 7

Example:

```sql
SELECT v.BookID,
       v.Title,
       v.Price
FROM (VALUES
    (1, 'SQL Basics', 399),
    (2, 'JSON Basics', 299),
    (3, 'T-SQL Advanced', 499)
) AS v(BookID, Title, Price)
FOR JSON PATH;
```

---

### Solution 8

Example:

```sql
SELECT v.CourseID,
       v.CourseName
FROM (VALUES
    (101, 'JSON Basics'),
    (102, 'SQL Server Intro')
) AS v(CourseID, CourseName)
FOR JSON PATH, ROOT('Courses');
```

---

### Solution 9

Example:

```sql
DECLARE @j nvarchar(max) = N'[
  {"Name":"Anna","Age":32},
  {"Name":"Robert","Age":58}
]';

SELECT JSON_VALUE(@j, '$[0].Name') AS FirstName,
       JSON_VALUE(@j, '$[1].Age') AS SecondAge;
```

---

### Solution 10A

```sql
DECLARE @j nvarchar(max) = N'{"Name":"Anna","Age":32,"Country":"Sweden"}';

SELECT JSON_VALUE(@j, '$.Name') AS Name,
       JSON_VALUE(@j, '$.Age') AS Age,
       JSON_VALUE(@j, '$.Country') AS Country;
```

### Solution 10B

```sql
SELECT 101 AS CourseID,
       'JSON Basics' AS CourseName,
       'Beginner' AS Level
FOR JSON PATH;
```

### Solution 10C

Example:

```sql
SELECT v.CourseID,
       v.CourseName,
       v.Level
FROM (VALUES
    (101, 'JSON Basics', 'Beginner'),
    (102, 'OPENJSON Intro', 'Beginner')
) AS v(CourseID, CourseName, Level)
FOR JSON PATH;
```

---


