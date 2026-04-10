# SQL Server Spatial – Very Simple Lab

This is a very simple introduction to spatial data in SQL Server.

👉 No prior knowledge required
👉 Focus: understanding, not complexity

---

# 🎯 Goal

You will learn to:

* understand what spatial data is
* create a point
* calculate distance

---

# 🧠 Part 1 – What is spatial data?

Spatial data represents locations on Earth.

Example:

* Latitude: 59.33
* Longitude: 18.06 (Stockholm)

---

# ⏱️ Part 2 – Create your first point

Run this:

```sql
DECLARE @stockholm geography = geography::Point(59.33, 18.06, 4326);

SELECT @stockholm;
```

👉 What happens?

* You created a geographic point

---

# ✏️ Exercise 1

Create a point for another city.

Example ideas:

* London
* Paris
* New York

---

# ⏱️ Part 3 – Create two points

```sql
DECLARE @stockholm geography = geography::Point(59.33, 18.06, 4326);
DECLARE @gothenburg geography = geography::Point(57.70, 11.97, 4326);

SELECT @stockholm AS Stockholm,
       @gothenburg AS Gothenburg;
```

---

# ✏️ Exercise 2

Create two cities of your own.

---

# ⏱️ Part 4 – Calculate distance

```sql
DECLARE @stockholm geography = geography::Point(59.33, 18.06, 4326);
DECLARE @gothenburg geography = geography::Point(57.70, 11.97, 4326);

SELECT @stockholm.STDistance(@gothenburg) AS DistanceInMeters;
```

👉 Result is in meters.

---

# ✏️ Exercise 3

Calculate distance between two cities of your choice.

👉 Question:

* Does the result seem reasonable?

---

# ⏱️ Part 5 – Store spatial data in a table

```sql
CREATE TABLE Cities (
    Name nvarchar(100),
    Location geography
);
```

Insert data:

```sql
INSERT INTO Cities (Name, Location)
VALUES
('Stockholm', geography::Point(59.33, 18.06, 4326)),
('Gothenburg', geography::Point(57.70, 11.97, 4326));
```

---

# ✏️ Exercise 4

Insert one more city into the table.

---

# ⏱️ Part 6 – Query the table

```sql
SELECT Name,
       Location
FROM Cities;
```

---

# ⏱️ Part 7 – Distance from one city to all

```sql
DECLARE @stockholm geography = geography::Point(59.33, 18.06, 4326);

SELECT Name,
       @stockholm.STDistance(Location) AS Distance
FROM Cities;
```

---

# ✏️ Exercise 5

Change the reference city and run again.

---

# 🧠 Summary

You have learned:

* spatial data represents locations
* geography::Point creates a location
* STDistance calculates distance
* spatial data can be stored in tables

---



Goal:
👉 curiosity, not completeness
