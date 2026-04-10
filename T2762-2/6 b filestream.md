# SQL Server FILESTREAM – Step-by-Step Lab (Beginner Friendly)

This lab is designed for training. Follow each step and verify before moving on.

---

# 🎯 Goal

You will:

1. Download 3 PDF files
2. Enable FILESTREAM
3. Create a FILESTREAM database
4. Insert files into SQL Server
5. Read files from SQL




# 📥 Step 1 – Download PDF files

Create a local folder called **C:\Pdfs**

Download the three pdf files from  **https://github.com/roblevay/T2762/tree/main/pdfs** to the local folder **C:\Pdfs**
✅ Verify:

* Go to `C:Pdfs`
* Confirm that 3 PDF files exist

---

# ⚙️ Step 2 – Enable FILESTREAM

## 2.1 SQL Server Configuration Manager

1. Open **SQL Server Configuration Manager**
2. Right-click your instance → **Properties**
3. Go to **FILESTREAM tab**

Enable:

* ✔ Enable FILESTREAM for Transact-SQL access
* ✔ Enable FILESTREAM for file I/O streaming access
* ✔ Allow remote clients (optional)

Set share name:

```
FilestreamShare
```

4. Click OK
5. Restart SQL Server

---

## 2.2 Enable in SQL Server

Run in SSMS:

```sql
EXEC sp_configure filestream_access_level, 2;
RECONFIGURE;
```

✅ Verify:

```sql
EXEC sp_configure 'filestream access level';
```

Expected value: **2**

---

# 🗄️ Step 3 – Create FILESTREAM Database

```sql
CREATE DATABASE FileStreamDB
ON PRIMARY
(
    NAME = FSDB_Data,
    FILENAME = 'C:\Data\FSDB_Data.mdf'
),
FILEGROUP FSGroup CONTAINS FILESTREAM
(
    NAME = FSDB_FS,
    FILENAME = 'C:\Data\FSData'
)
LOG ON
(
    NAME = FSDB_Log,
    FILENAME = 'C:\Data\FSDB_Log.ldf'
);
GO
```

✅ Verify:

* A new folder `C:\data\FSData` should be created

---

# 🧾 Step 4 – Create Table

```sql
USE FileStreamDB;
GO

CREATE TABLE Documents
(
    Id UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL UNIQUE,
    FileName NVARCHAR(255),
    FileData VARBINARY(MAX) FILESTREAM
);
GO
```

---

# 📤 Step 5 – Insert Files

```sql
INSERT INTO Documents (Id, FileName, FileData)
SELECT NEWID(), 'dictionary.pdf', *
FROM OPENROWSET(BULK 'C:\Pdfs\dictionary.pdf', SINGLE_BLOB) AS x;

INSERT INTO Documents (Id, FileName, FileData)
SELECT NEWID(), 'invoicesample.pdf', *
FROM OPENROWSET(BULK 'C:\Pdfs\invoicesample.pdf', SINGLE_BLOB) AS x;

INSERT INTO Documents (Id, FileName, FileData)
SELECT NEWID(), 'somatosensory.pdf', *
FROM OPENROWSET(BULK 'C:\Pdfs\somatosensory.pdf', SINGLE_BLOB) AS x;
```

✅ Verify:

```sql
SELECT COUNT(*) FROM Documents;
```

Expected result: **3**

---

# 📖 Step 6 – Read Files from SQL

```sql
SELECT Id, FileName, DATALENGTH(FileData) AS FileSize
FROM Documents;
```

✅ You should see:

* 3 rows
* File sizes > 0

---



# 🧠 What You Learned

* FILESTREAM stores files on disk (NTFS)
* SQL Server keeps them transaction-safe
* You can:

  * Insert via SQL
  * Read via SQL


---

