# Lab: Working with XML Data in SQL Server

## Goal
In this lab, you will learn how to:
- receive XML data
- store XML in SQL Server
- extract XML data into a relational table
- generate XML from a table
- understand a simple end-to-end XML workflow

---

# Part 1 – Create a table

Now create a relational table to store the product data.

```sql
CREATE TABLE ProductsXml
(
    ProductID int,
    Name nvarchar(100),
    Category nvarchar(100),
    Price int
);
```

# Part 2 – Incoming XML data

Imagine that your system receives product data from another system in XML format.

Here is the incoming XML document:

```xml
<Products>
  <Product>
    <ProductID>1</ProductID>
    <Name>Mountain Bike</Name>
    <Category>Bikes</Category>
    <Price>1999</Price>
  </Product>
  <Product>
    <ProductID>2</ProductID>
    <Name>Road Bike</Name>
    <Category>Bikes</Category>
    <Price>2499</Price>
  </Product>
  <Product>
    <ProductID>3</ProductID>
    <Name>Helmet</Name>
    <Category>Accessories</Category>
    <Price>299</Price>
  </Product>
  <Product>
    <ProductID>4</ProductID>
    <Name>Gloves</Name>
    <Category>Accessories</Category>
    <Price>99</Price>
  </Product>
  <Product>
    <ProductID>5</ProductID>
    <Name>Jersey</Name>
    <Category>Clothing</Category>
    <Price>499</Price>
  </Product>
  <Product>
    <ProductID>6</ProductID>
    <Name>Shorts</Name>
    <Category>Clothing</Category>
    <Price>399</Price>
  </Product>
  <Product>
    <ProductID>7</ProductID>
    <Name>Socks</Name>
    <Category>Clothing</Category>
    <Price>59</Price>
  </Product>
  <Product>
    <ProductID>8</ProductID>
    <Name>Water Bottle</Name>
    <Category>Accessories</Category>
    <Price>49</Price>
  </Product>
  <Product>
    <ProductID>9</ProductID>
    <Name>Pump</Name>
    <Category>Accessories</Category>
    <Price>199</Price>
  </Product>
  <Product>
    <ProductID>10</ProductID>
    <Name>Lock</Name>
    <Category>Accessories</Category>
    <Price>149</Price>
  </Product>
</Products>
```

---

# Part 3 – Store the XML in a variable

Run this code and paste the XML into the variable:

```sql
DECLARE @x xml = N'
<Products>
  <Product>
    <ProductID>1</ProductID>
    <Name>Mountain Bike</Name>
    <Category>Bikes</Category>
    <Price>1999</Price>
  </Product>
  <Product>
    <ProductID>2</ProductID>
    <Name>Road Bike</Name>
    <Category>Bikes</Category>
    <Price>2499</Price>
  </Product>
  <Product>
    <ProductID>3</ProductID>
    <Name>Helmet</Name>
    <Category>Accessories</Category>
    <Price>299</Price>
  </Product>
  <Product>
    <ProductID>4</ProductID>
    <Name>Gloves</Name>
    <Category>Accessories</Category>
    <Price>99</Price>
  </Product>
  <Product>
    <ProductID>5</ProductID>
    <Name>Jersey</Name>
    <Category>Clothing</Category>
    <Price>499</Price>
  </Product>
  <Product>
    <ProductID>6</ProductID>
    <Name>Shorts</Name>
    <Category>Clothing</Category>
    <Price>399</Price>
  </Product>
  <Product>
    <ProductID>7</ProductID>
    <Name>Socks</Name>
    <Category>Clothing</Category>
    <Price>59</Price>
  </Product>
  <Product>
    <ProductID>8</ProductID>
    <Name>Water Bottle</Name>
    <Category>Accessories</Category>
    <Price>49</Price>
  </Product>
  <Product>
    <ProductID>9</ProductID>
    <Name>Pump</Name>
    <Category>Accessories</Category>
    <Price>199</Price>
  </Product>
  <Product>
    <ProductID>10</ProductID>
    <Name>Lock</Name>
    <Category>Accessories</Category>
    <Price>149</Price>
  </Product>
</Products>';
```

---



---

# Part 4 – Insert XML data into the table

Use `.nodes()` and `.value()` to read the XML and insert the values into the table.

```sql
INSERT INTO ProductsXml (ProductID, Name, Category, Price)
SELECT
    p.value('(ProductID)[1]', 'int') AS ProductID,
    p.value('(Name)[1]', 'nvarchar(100)') AS Name,
    p.value('(Category)[1]', 'nvarchar(100)') AS Category,
    p.value('(Price)[1]', 'int') AS Price
FROM @x.nodes('/Products/Product') AS T(p);
```

---

# Part 5 – Verify the result

```sql
SELECT *
FROM ProductsXml;
```

### Question
Can you see that each `<Product>` element became one row in the table?

---

# Part 6 – Query the relational table

Try some normal SQL queries.

```sql
-- All products in Accessories
SELECT *
FROM ProductsXml
WHERE Category = 'Accessories';

-- Average price
SELECT AVG(Price) AS AveragePrice
FROM ProductsXml;

-- Most expensive product
SELECT TOP (1) *
FROM ProductsXml
ORDER BY Price DESC;
```

---

# Part 7 – Generate XML from a table

Now go in the other direction.

Use the table data and generate XML.

```sql
SELECT
    ProductID,
    Name,
    Category,
    Price
FROM ProductsXml
FOR XML PATH('Product'), ROOT('Products');
```

### What is happening?
- each row becomes a `<Product>` element
- the result is wrapped in a root element called `<Products>`

---

# Part 8 – Create a simpler XML file format

You can also create a slightly different XML structure.

```sql
SELECT
    ProductID AS '@ID',
    Name,
    Category,
    Price
FROM ProductsXml
FOR XML PATH('Product'), ROOT('Products');
```

### What changed?
Now `ProductID` becomes an **attribute** instead of an element.

Example:

```xml
<Product ID="1">
  <Name>Mountain Bike</Name>
  <Category>Bikes</Category>
  <Price>1999</Price>
</Product>
```

---

# Part 9 – Save the generated XML in a variable

Sometimes you want to create XML and keep it in a variable.

```sql
DECLARE @ExportXml xml;

SET @ExportXml =
(
    SELECT
        ProductID,
        Name,
        Category,
        Price
    FROM ProductsXml
    FOR XML PATH('Product'), ROOT('Products')
);

SELECT @ExportXml AS ExportedXml;
```

---

# Part 10 – Think of this as an XML file

In real life, the XML result could:
- be saved to a file by an application
- be sent to another system
- be returned from a stored procedure
- be used in an integration process

So even if you do not physically create a file in this lab, you are creating the XML content that could become a file.

---

# Part 11 – Optional extra: store the whole XML document in a table

Sometimes you want to store the original XML document before shredding it into rows.

Create a table for raw XML:

```sql
CREATE TABLE XmlMessages
(
    MessageID int IDENTITY(1,1) PRIMARY KEY,
    ReceivedAt datetime2 NOT NULL DEFAULT sysdatetime(),
    XmlData xml
);
```

Insert the XML document:

```sql
INSERT INTO XmlMessages (XmlData)
VALUES (@x);
```

Check the table:

```sql
SELECT *
FROM XmlMessages;
```

### Why do this?
Because some systems:
- store the original message
- keep it for auditing
- then extract the relational data afterwards

---

# Part 12 – Exercises

## Exercise 1
Add a new element called `Brand` to each product in the XML.
Then:
- update the table design
- insert the new value as well

## Exercise 2
Generate XML only for products in the `Accessories` category.

Example idea:

```sql
SELECT
    ProductID,
    Name,
    Category,
    Price
FROM ProductsXml
WHERE Category = 'Accessories'
FOR XML PATH('Product'), ROOT('Products');
```

## Exercise 3
Generate XML where `Price` is an attribute instead of an element.

---

# Part 13 – Summary

In this lab, you have learned how to:
- receive XML data
- store XML in an XML variable
- extract XML into a relational table
- query the relational table
- generate XML from table data

This is a common XML workflow:

**incoming XML -> SQL Server -> relational table -> outgoing XML**

---

# Instructor notes

This lab is useful because it shows both directions:

1. **Import XML**
   - receive XML
   - parse it
   - insert into tables

2. **Export XML**
   - read rows from a table
   - generate XML

That makes XML feel more practical and less abstract.

A good classroom discussion is:

- When would you store the whole XML document?
- When would you shred it into tables immediately?
- When is XML better as transport than as storage?
