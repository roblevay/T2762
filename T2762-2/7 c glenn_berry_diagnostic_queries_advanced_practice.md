# Glenn Berry's Diagnostic Queries - Advanced Practice Tasks

This version contains **five harder tasks** based on **Glenn Berry's Diagnostic Queries**.  
Each task includes **more concrete answer help** and explicitly asks the student to include the **query number** they used.

> **Important:** Glenn Berry changes query numbering between versions.  
> Students must therefore state the **query number from the script version they are using**.

---

## 1. Find the most likely memory pressure symptoms on the server

Use Glenn Berry's Diagnostic Queries to investigate whether the SQL Server instance shows signs of **memory pressure**.

Your answer must include:
- the **query number(s)** you used
- evidence from at least **two different queries**
- whether the pressure looks like:
  - buffer pool pressure
  - plan cache pressure
  - overall memory pressure
  - or no obvious memory pressure

### Suggested answer 1
A strong answer should name the exact query numbers used, for example:

- **Query #__**: memory status / server memory information
- **Query #__**: page life expectancy, buffer usage, or memory clerks
- **Query #__**: plan cache or cache store pressure

A concrete answer should say something like:

> I used **Query #__** and **Query #__**.  
> SQL Server has **X GB target memory** and **Y GB total server memory currently committed**.  
> **PLE is approximately ___**, which suggests **stable memory / possible pressure / serious pressure**.  
> The largest memory consumers appear to be **buffer pool / plan cache / columnstore / clerks**.  
> Based on these findings, I conclude that the server shows **no clear memory pressure / moderate memory pressure / significant memory pressure**.

What to look for:
- very low or unstable **PLE**
- SQL Server close to target memory but with poor cache health
- unusually large plan cache or clerk usage
- memory grants or cache pressure indicators if present

---

## 2. Determine whether tempdb is a likely performance bottleneck

Use Glenn Berry's Diagnostic Queries to decide whether **tempdb** may be contributing to performance problems.

Your answer must include:
- the **query number(s)** you used
- tempdb file layout observations
- tempdb I/O or wait-related evidence
- a conclusion about whether tempdb needs attention

### Suggested answer 2
A strong answer should identify the relevant query numbers, for example:

- **Query #__**: tempdb file layout or tempdb configuration
- **Query #__**: I/O latency by file
- **Query #__**: waits that may point to tempdb contention

A concrete answer should say something like:

> I used **Query #__**, **Query #__**, and **Query #__**.  
> tempdb has **__ data files** and **__ log file(s)**.  
> The data files are **equal size / not equal size**.  
> The highest tempdb read latency is **__ ms** and write latency is **__ ms**.  
> I also observed waits such as **PAGELATCH_UP / PAGELATCH_EX / WRITELOG / IO_COMPLETION / no relevant tempdb waits**.  
> Based on this, tempdb looks **healthy / somewhat stressed / a likely bottleneck**.

What to look for:
- too few tempdb data files for the workload
- uneven tempdb file sizes
- high latency on tempdb files
- latch waits that often indicate allocation contention
- log write pressure in tempdb

---

## 3. Identify a query tuning candidate and explain *why* it is a candidate

Use Glenn Berry's Diagnostic Queries to find **one specific query or procedure** that should be investigated for tuning.

Your answer must include:
- the **query number(s)** you used
- the SQL text or procedure name
- why it is a tuning candidate
- whether the problem is due to **CPU**, **reads**, **duration**, or **execution count**

### Suggested answer 3
A strong answer should cite the exact Glenn Berry query number used to find the workload hotspot, for example:

- **Query #__**: top cached queries by CPU
- **Query #__**: top cached queries by logical reads
- **Query #__**: top cached queries by elapsed time

A concrete answer should say something like:

> I used **Query #__** and selected the statement / procedure **[name or excerpt]**.  
> It has approximately **__ executions**, **__ average CPU**, **__ average logical reads**, and **__ average elapsed time**.  
> I chose it as a tuning candidate because the main cost driver appears to be **high CPU per execution / very high logical reads / long duration / extremely frequent execution**.  
> This means the query is expensive because **it runs badly each time / it runs too often / both**.

Useful interpretation patterns:
- **High average CPU** → investigate joins, scalar functions, sorts, expressions
- **High logical reads** → investigate indexes, predicates, scanning, stale stats
- **High elapsed time but modest CPU** → investigate blocking, waits, I/O, parallelism, remote access
- **Huge execution count** → small inefficiency multiplied many times can matter a lot

---

## 4. Evaluate whether missing index requests should actually be implemented

Use Glenn Berry's Diagnostic Queries to find one or more **missing index recommendations**, and then evaluate whether one recommendation looks worth testing.

Your answer must include:
- the **query number(s)** you used
- table name
- equality columns
- inequality columns
- included columns
- estimated impact
- whether you would test it, merge it with an existing index, or reject it

### Suggested answer 4
A strong answer should explicitly state the Glenn Berry query number, for example:

- **Query #__**: missing index details or missing index impact

A concrete answer should say something like:

> I used **Query #__** and found a recommendation on **schema.table**.  
> Equality columns: **(...)**  
> Inequality columns: **(...)**  
> Included columns: **(...)**  
> Estimated impact: **__**  
> I would **test / not test / first compare with existing indexes** because the recommendation looks **high value / overlapping / too wide / too narrow / based on limited evidence**.

Good judgment points to mention:
- missing index DMVs do **not** know your full indexing strategy
- recommendations may overlap with existing indexes
- very wide included-column lists can be expensive
- the best action may be to **modify an existing index** rather than create a new one
- high estimated impact alone is **not enough**

---

## 5. Use wait statistics to form a focused performance hypothesis

Use Glenn Berry's Diagnostic Queries to identify the most important **wait statistics** and propose a likely performance hypothesis.

Your answer must include:
- the **query number(s)** you used
- the top 3 waits that seem most relevant
- which waits you ignored as benign/common background waits
- a short hypothesis about the main bottleneck

### Suggested answer 5
A strong answer should include the Glenn Berry wait-stats query number, for example:

- **Query #__**: wait statistics since startup

A concrete answer should say something like:

> I used **Query #__**.  
> The most relevant waits were **WAIT_1**, **WAIT_2**, and **WAIT_3**.  
> I ignored waits such as **SLEEP_TASK, BROKER_TASK_STOP, XE_TIMER_EVENT, SQLTRACE_BUFFER_FLUSH** because they are usually not useful for root-cause analysis.  
> My hypothesis is that the main bottleneck is **I/O / locking-blocking / CPU pressure / parallelism issues / log write latency / tempdb contention**, mainly because the dominant waits point in that direction.

Helpful wait interpretation examples:
- **PAGEIOLATCH_*** → storage read latency / I/O pressure
- **WRITELOG** → transaction log bottleneck
- **LCK_M_*** → blocking and concurrency issues
- **CXPACKET / CXCONSUMER** → parallelism needs interpretation, not automatic blame
- **PAGELATCH_*** → often in-memory contention, frequently tempdb or hot pages
- **SOS_SCHEDULER_YIELD** → CPU pressure or inefficient queries
- **ASYNC_NETWORK_IO** → client/app consuming rows slowly

---

## Submission format for students

For each answer, use this format:

### Answer X
- **Query number(s):**
- **Key findings:**
- **Evidence from result set:**
- **Interpretation:**
- **Conclusion:**

---

## Teaching note

These questions are harder because students must do more than just find a number.  
They must:
- choose the relevant Glenn Berry query
- report the **query number**
- extract evidence from the result
- interpret what the evidence means
- avoid jumping to conclusions from a single DMV
