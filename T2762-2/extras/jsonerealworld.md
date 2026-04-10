# Lab: JSON in SQL Server – Part 3 (Real-World Pitfalls & Performance)

## Goal

After this lab, you should be able to:

* understand when JSON is NOT a good choice
* identify common performance problems with JSON
* compare JSON and XML in SQL Server
* apply basic optimization techniques

---

## Part 1 – The "easy" solution (that can go wrong)

Imagine a developer decides:

> "Let’s store everything as JSON in one column – it’s flexible!"

Create a table:

```sql
CREATE TABLE OrdersJson (
    OrderID int PRIMARY KEY,
    Data nvarchar(max)
);
```

Insert data:

```sql
INSERT INTO OrdersJson VALUES
(1, N'{"Customer":"Anna","Total":1000}'),
(2, N'{"Customer":"Robert","Total":2000}'),
(3, N'{"Customer":"Anna","Total":1500}');
```

---

## Part 2 – Querying JSON (slow approach)

Run this:

```sql
SELECT OrderID
FROM OrdersJson
WHERE JSON_VALUE(Data, '$.Customer') = 'Anna';
```

### Question

Why might this be slow on a large table?

👉 Hint: SQL Server must read and parse every row.

---

## Part 3 – Better approach (computed column + index)

Run this:

```sql
ALTER TABLE OrdersJson
ADD Customer AS JSON_VALUE(Data, '$.Customer');

CREATE INDEX ix_customer ON OrdersJson(Customer);
```

Now run the same query again.

### What changed?

* SQL Server can now use an index
* No need to parse JSON for every row

---

## Part 4 – When NOT to use JSON

Consider this structure:

```json
{
  "OrderID": 1,
  "Customer": "Anna",
  "Total": 1000
}
```

### Question

Should this be JSON or a table?

👉 Answer:

* If data is **structured and queried often** → use columns
* If data is **flexible or external** → JSON can make sense

---

## Part 5 – JSON vs XML

### JSON example:

```json
{
  "Product": "Bike",
  "Price": 100
}
```

### XML example:

```xml
<Product>
  <Name>Bike</Name>
  <Price>100</Price>
</Product>
```

### Discussion

| Feature      | JSON         | XML                 |
| ------------ | ------------ | ------------------- |
| Readability  | Simple       | Verbose             |
| Performance  | Often faster | Often slower        |
| Schema       | Weak         | Strong              |
| Modern usage | Very common  | Legacy / enterprise |

---

## Part 6 – Nested JSON performance problem

Run this:

```sql
DECLARE @json nvarchar(max) = N'{
  "OrderID": 1001,
  "Items": [
    {"Product":"Bike","Qty":1},
    {"Product":"Helmet","Qty":2}
  ]
}';

SELECT *
FROM OPENJSON(@json, '$.Items');
```

### Question

What happens if this structure is very large?

👉 Answer:

* Parsing becomes expensive
* Memory usage increases

---

## Part 7 – Mixing JSON and relational design

Best practice:

👉 Combine both

Example:

```sql
CREATE TABLE Orders (
    OrderID int,
    Customer nvarchar(100),
    ExtraData nvarchar(max) -- JSON for flexible fields
);
```

### Idea

* Store core data in columns
* Store optional data as JSON

---

## Part 8 – Exercises

### Exercise 1

Create a table with JSON data.
Add a computed column and index.
Compare query performance (estimated plan).

### Exercise 2

Design a table where:

* core data is relational
* optional data is JSON

Explain your design.

### Exercise 3

Take a JSON structure and redesign it as normal tables.

---

## Part 9 – Key takeaways

* JSON is flexible but can hurt performance
* Avoid storing everything as JSON
* Use computed columns + indexes for filtering
* Combine JSON with relational design

---

## Instructor notes

This lab is important for mindset.

Students often think:
👉 "JSON = modern = always better"

This lab shows:
👉 "It depends"

Good discussion questions:

* When would YOU use JSON?
* When would you avoid it?
* What happens at scale?

This usually leads to very engaging conversations.
