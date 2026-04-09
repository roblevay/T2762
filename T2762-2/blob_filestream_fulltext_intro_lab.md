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

## Install Full-Text Search in SQL Server

Run SQL Server Setup again:

1. Open **SQL Server Installation Center** SETUP.EXE in C:\Sqlinstall\SQLServer2019-DEV-x64-ENU

2. Select:
   ➜ **New SQL Server stand-alone installation or add features to an existing instance** 
   
3. Check the option:
   - ✅ **Full-Text and Semantic Extractions for Search**
   
4. Click **Install** and complete the setup

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

# Part 13 – Search using CONTAINSTABLE

This gives ranking information.

```sql
SELECT n.NoteID, n.ProductID, n.NoteText, ft.[RANK]
FROM CONTAINSTABLE(
    ProductNotes,
    NoteText,
    'ISABOUT(performance WEIGHT(0.8), bike WEIGHT(0.2))'
) ft
JOIN ProductNotes n ON n.NoteID = ft.[KEY]
ORDER BY ft.[RANK] DESC;
```

### What is new?
The result now includes a ranking value.
Higher rank usually means a better match.

---

