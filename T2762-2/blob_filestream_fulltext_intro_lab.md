# Lab: Introduction to BLOB Data, FILESTREAM, and Full-Text Search

## Goal
After this lab, you should be able to:
- understand what BLOB data is
- see why BLOB data can be connected to relational data
- create a very simple table design for file-related data
- understand the basic idea of FILESTREAM
- create and test a very simple full-text search example

---

# Part 1 – What is BLOB data?

A **BLOB** is a **Binary Large Object**.

Examples:
- PDF files
- Word documents
- Excel files
- images
- videos

A database often stores normal structured data such as:
- product number
- product name
- price

But sometimes we also want to connect a product to:
- a manual
- a photo
- a video
- a document

That is where BLOB data becomes important.

---

# Part 2 – A simple design idea

Imagine that a company sells bicycles.

The company has a product table:

```sql
CREATE TABLE Products
(
    ProductID int PRIMARY KEY,
    ProductName nvarchar(100),
    Price int
);
```

And it wants to connect each product to a file.

A very simple table could look like this:

```sql
CREATE TABLE ProductDocuments
(
    DocumentID int PRIMARY KEY,
    ProductID int,
    FileName nvarchar(200),
    FileType nvarchar(50),
    FilePath nvarchar(500)
);
```

### Discussion
This table does **not** store the file itself.
It stores information **about** the file.

For example:
- file name
- file type
- where the file is stored

---

# Part 3 – Insert simple sample data

Run this:

```sql
INSERT INTO Products VALUES
(1, 'Mountain Bike', 1999),
(2, 'Road Bike', 2499),
(3, 'Helmet', 299);
```

Run this:

```sql
INSERT INTO ProductDocuments VALUES
(1, 1, 'mountain_bike_manual.pdf', 'PDF', 'C:\Docs\mountain_bike_manual.pdf'),
(2, 2, 'road_bike_manual.pdf', 'PDF', 'C:\Docs\road_bike_manual.pdf'),
(3, 3, 'helmet_photo.jpg', 'Image', 'C:\Docs\helmet_photo.jpg');
```

Check the result:

```sql
SELECT *
FROM Products;

SELECT *
FROM ProductDocuments;
```

---

# Part 4 – Join product data and document data

Now connect the tables.

```sql
SELECT
    p.ProductID,
    p.ProductName,
    d.FileName,
    d.FileType,
    d.FilePath
FROM Products AS p
INNER JOIN ProductDocuments AS d
    ON p.ProductID = d.ProductID;
```

### What is the idea?
The database stores:
- structured product data in one table
- file-related data in another table

This is a very common design.

---

# Part 5 – Basic considerations for BLOB data

When working with BLOB data, think about these questions:

1. Should the file be stored **inside** the database?
2. Should the file be stored **outside** the database, with only a path in the table?
3. How large are the files?
4. How often are the files read?
5. Do we need backup and restore together with the database?
6. Do users need to search inside document contents?

### Simple rule of thumb
- Small structured data -> normal columns
- Large files -> special handling is often needed

---

# Part 6 – What is FILESTREAM?

**FILESTREAM** is a SQL Server feature for storing large binary files in the file system, while still managing them through SQL Server.

### In simple words
It is a bridge between:
- the database
- the Windows file system

### Why use it?
Because storing very large files directly in normal table columns is not always the best choice.

### Important
In this lab, we only learn the idea.
A real FILESTREAM setup usually requires:
- SQL Server configuration
- a FILESTREAM filegroup
- special table design

---

# Part 7 – A very simple FILESTREAM table example

This is what a FILESTREAM table can look like:

```sql
CREATE TABLE ProductFiles
(
    FileID uniqueidentifier ROWGUIDCOL NOT NULL UNIQUE,
    ProductID int,
    FileName nvarchar(200),
    FileData varbinary(max) FILESTREAM
);
```

### Note
You do **not** need to run this unless FILESTREAM is enabled in your environment.

### Focus on the concept
- `varbinary(max)` stores binary data
- `FILESTREAM` tells SQL Server to store it in the file system
- SQL Server still controls access and consistency

---

# Part 8 – Full-text search: the basic idea

Sometimes it is not enough to search by file name.

For example:
- find all manuals that mention **performance**
- find all descriptions that mention **lightweight**
- search for words inside text documents

This is where **Full-Text Search** is useful.

---

# Part 9 – Create a simple text-based example

To keep things very easy, let us use product descriptions instead of real files.

Create a table:

```sql
CREATE TABLE ProductNotes
(
    NoteID int PRIMARY KEY,
    ProductID int,
    NoteText nvarchar(1000)
);
```

Insert sample data:

```sql
INSERT INTO ProductNotes VALUES
(1, 1, 'This mountain bike offers a high level of performance on rough trails.'),
(2, 2, 'This road bike is lightweight and designed for speed.'),
(3, 3, 'This helmet gives good protection and comfort.'),
(4, 1, 'The bike manual explains maintenance and safety.'),
(5, 2, 'This product is suitable for long-distance cycling.'),
(6, 3, 'The helmet is durable and comfortable.'),
(7, 1, 'Excellent control and strong braking performance.'),
(8, 2, 'Fast and efficient design for experienced riders.'),
(9, 3, 'Safety equipment is important for all cyclists.'),
(10, 1, 'A strong frame and reliable performance make this bike popular.');
```

Check the data:

```sql
SELECT *
FROM ProductNotes;
```

---

# Part 10 – Create a full-text catalog

```sql
CREATE FULLTEXT CATALOG ftCatalog AS DEFAULT;
```

---

# Part 11 – Create a full-text index

Before you do this, the table needs a unique key.

If needed, first create a unique index:

```sql
CREATE UNIQUE INDEX UX_ProductNotes_NoteID
ON ProductNotes(NoteID);
```

Now create the full-text index:

```sql
CREATE FULLTEXT INDEX ON ProductNotes(NoteText)
KEY INDEX UX_ProductNotes_NoteID
WITH CHANGE_TRACKING AUTO;
```

---

# Part 12 – Search using FREETEXT

Now try a simple search:

```sql
SELECT *
FROM ProductNotes
WHERE FREETEXT(NoteText, 'performance');
```

### What does this do?
It searches for rows related to the meaning of the word, not only exact matches.

---

# Part 13 – Search using FREETEXTTABLE

This gives ranking information.

```sql
SELECT
    n.NoteID,
    n.ProductID,
    n.NoteText,
    ft.[RANK]
FROM FREETEXTTABLE(ProductNotes, NoteText, 'performance') AS ft
INNER JOIN ProductNotes AS n
    ON n.NoteID = ft.[KEY]
ORDER BY ft.[RANK] DESC;
```

### What is new?
The result now includes a ranking value.
Higher rank usually means a better match.

---

# Part 14 – Exercises

## Exercise 1
Create a new product and add a related document row.

## Exercise 2
Add two more rows to `ProductNotes`.
Use words such as:
- performance
- safety
- speed

Then run the full-text queries again.

## Exercise 3
Discuss this question:
Should the system store the whole file in the database, or only the file path?

Write down one advantage and one disadvantage of each approach.

## Exercise 4
Look at the `ProductDocuments` table design.
What extra columns might be useful?

Examples:
- FileSize
- UploadedDate
- UploadedBy

---

# Part 15 – Summary

In this lab, you have learned that:
- BLOB data means large binary objects such as documents and images
- relational tables can store information about files
- FILESTREAM is used for large binary data in SQL Server
- Full-Text Search can search inside text content
- Full-Text Search can also rank search results

---

# Instructor notes

This lab is intentionally simple.

The purpose is not to build a production-ready file solution.
The purpose is to help students understand the three main ideas:

1. **BLOB data**
   - files connected to database rows

2. **FILESTREAM**
   - special handling for large binary files

3. **Full-Text Search**
   - searching inside text content

A good classroom discussion question is:

> If you were designing a product database with manuals, photos, and videos, what would you store in tables, and what would you store outside the database?
