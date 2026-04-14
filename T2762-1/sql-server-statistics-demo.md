# SQL Server Statistics Demo

This short demo shows how to inspect statistics in SQL Server by using `DBCC SHOW_STATISTICS` and the catalog view `sys.stats`.

Statistics help SQL Server estimate how many rows will match a predicate. Those estimates are important because they influence the execution plan, for example whether SQL Server chooses an index seek, an index scan, or a join strategy.

In this example, we inspect the statistics object `Person_FirstName` on the table `Person.Person`.

## 1. Show the full statistics output

```sql
DBCC SHOW_STATISTICS('Person.Person', Person_FirstName)
```

This command returns **three result sets**.

### Part 1: Header
The **header** contains metadata about the statistics object, such as:

- the statistics name
- when it was last updated
- how many rows were in the table when the statistics were built
- how many rows were sampled
- the number of histogram steps
- the average key length
- whether the statistics were created automatically or by the user

This section is useful when you want to check whether the statistics are recent and whether SQL Server used a full scan or sampling.

### Part 2: Density Vector
The **density vector** contains information about the uniqueness of the column values.

A lower density usually means higher selectivity, which means fewer rows are expected to match a specific value. This helps the optimizer estimate cardinality for equality predicates such as:

```sql
WHERE FirstName = 'Robert'
```

For multi-column statistics, this section also shows densities for different column prefixes.

### Part 3: Histogram
The **histogram** shows the distribution of values in the first key column of the statistics object.

It is divided into steps and helps SQL Server estimate how many rows match a value or a range of values. This is especially important for predicates such as:

```sql
WHERE FirstName = 'Mary'
WHERE FirstName > 'M'
```

The histogram is often the most interesting part when you want to understand why SQL Server estimated a certain number of rows.

---

## 2. Show only the header

```sql
DBCC SHOW_STATISTICS('Person.Person', Person_FirstName) WITH STAT_HEADER
```

Use this when you only want the metadata and do not need the density vector or histogram.

Typical reasons to check the header:

- verify when the statistics were last updated
- see whether sampling was used
- check row counts and modification counters

---

## 3. Show only the density vector

```sql
DBCC SHOW_STATISTICS('Person.Person', Person_FirstName) WITH DENSITY_VECTOR
```

Use this when you want to focus on selectivity and uniqueness.

This is especially helpful when explaining how SQL Server estimates equality predicates and why some values are considered more or less selective.

---

## 4. Find statistics objects in `sys.stats`

```sql
SELECT * 
FROM sys.stats 
WHERE object_id = OBJECT_ID('Person.Person');
```

This query lists the statistics objects that exist on `Person.Person`.

You can use it to:

- find the exact name of a statistics object
- see whether statistics were auto-created
- inspect user-created versus automatically created statistics
- identify which statistics belong to the table before calling `DBCC SHOW_STATISTICS`

In practice, this query is often the starting point when exploring statistics on a table.

---

## Suggested demo flow

A simple classroom or workshop demo could look like this:

1. Run the query against `sys.stats` to find available statistics on `Person.Person`.
2. Run `DBCC SHOW_STATISTICS('Person.Person', Person_FirstName)`.
3. Point out that the output has three parts: **Header**, **Density Vector**, and **Histogram**.
4. Run `WITH STAT_HEADER` separately and explain freshness, sampling, and row counts.
5. Run `WITH DENSITY_VECTOR` separately and explain selectivity.
6. Go back to the full output and discuss how the histogram helps SQL Server estimate row counts.

---

## Demo script

```sql
-- Full statistics output: returns Header, Density Vector, and Histogram
DBCC SHOW_STATISTICS('Person.Person', Person_FirstName);

-------------------------------
-- Header only
DBCC SHOW_STATISTICS('Person.Person', Person_FirstName) WITH STAT_HEADER;

-------------------------------
-- Density Vector only
DBCC SHOW_STATISTICS('Person.Person', Person_FirstName) WITH DENSITY_VECTOR;

-------------------------------
-- List statistics defined on the table
SELECT * 
FROM sys.stats 
WHERE object_id = OBJECT_ID('Person.Person');
```

## Key takeaway

`DBCC SHOW_STATISTICS` is one of the best tools for understanding how SQL Server estimates row counts.

- **Header** = metadata about the statistics object
- **Density Vector** = selectivity and uniqueness information
- **Histogram** = value distribution for the first key column

Together, these help explain why the optimizer chooses a certain execution plan.
