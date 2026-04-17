# Glenn Berry's Diagnostic Queries - Practice Tasks

This file contains five practice tasks where students use **Glenn Berry's Diagnostic Queries** to find useful information in SQL Server.  
Each task is followed by a **suggested answer section**. The answers are intentionally written as guidance rather than exact output, since actual results will depend on the server and database.

---

## 1. Find the SQL Server edition, version, and patch level

Use Glenn Berry's Diagnostic Queries to identify:
- SQL Server edition
- Product version
- Product level
- Engine edition
- Whether the instance looks like Developer, Standard, or Enterprise

### Suggested answer 1
You should be able to identify the exact SQL Server build and edition from the instance-level diagnostic query that returns version information.  
A good answer mentions:
- the **product version number**
- the **product level** (for example RTM, SP, or CU-related level information)
- the **edition name**
- whether the server is likely suitable for production or mainly for development/testing based on the edition

---

## 2. Determine which databases are consuming the most space

Use Glenn Berry's Diagnostic Queries to find:
- the largest databases on the instance
- data file size versus log file size
- which database appears to consume the most total storage

### Suggested answer 2
A correct answer should identify the top database or databases by total allocated size.  
The answer should also mention whether the storage is mostly:
- **data files**
- **log files**
- or a mix of both

A strong answer also comments on whether any database seems unusually large compared to the others.

---

## 3. Identify the most expensive recent queries by average CPU time

Use Glenn Berry's Diagnostic Queries to locate cached queries with high average CPU usage.

Focus on:
- average worker time / CPU
- execution count
- statement text
- whether the query appears to be expensive because of poor design or simply high frequency

### Suggested answer 3
A good answer identifies one or more queries near the top of the CPU-related ranking and explains:
- the query text or procedure name
- whether the cost is driven by **high average CPU per execution**
- or by **very frequent execution**
- whether the query looks like a tuning candidate

A strong answer may also mention parameter sniffing, missing indexes, scalar functions, or excessive sorting/joining if visible from the text.

---

## 4. Check for missing index recommendations in a user database

Use the database-level Glenn Berry queries to find:
- tables with missing index recommendations
- estimated impact
- equality and inequality columns
- included columns

### Suggested answer 4
A correct answer should name at least one table with a missing index recommendation and summarize:
- which columns are suggested as key columns
- which columns are suggested as included columns
- the estimated benefit or impact score

A strong answer also notes that missing index DMVs are **suggestions, not commands**, and that any recommendation should be reviewed before implementation.

---

## 5. Investigate I/O latency by database file

Use Glenn Berry's Diagnostic Queries to find:
- read latency
- write latency
- which database file has the highest stall time
- whether the problem looks more like a data file issue or a log file issue

### Suggested answer 5
A good answer should identify one or more files with relatively high latency and state:
- the database name
- the physical file name or file type
- whether reads or writes appear worse
- whether the issue is likely related to data files, log files, tempdb, or storage in general

A strong answer also comments on whether the latency looks acceptable, borderline, or problematic for a SQL Server workload.

---


