# Running Bookstore Analytics on a local SQL Server install

**Important honesty note:** the SQLite version (in the parent folder) was
actually built and run end-to-end here, including both ETL passes — I saw
the SCD history get created correctly. This SQL Server version is a careful
syntax conversion of that same tested logic, but I don't have a SQL Server
instance available in my environment to execute it against, so run it
yourself and shout if anything errors — most likely culprits are the driver
name or instance name below.

## 1. Install what you need

- **SQL Server** (Developer or Express edition, both free) — this is the actual database engine
- **SSMS** (SQL Server Management Studio) — the GUI you write/run queries in
- **Python 3** + `pip install pyodbc` — needed only for the ETL script
- **ODBC Driver 17 (or 18) for SQL Server** — needed for Python to talk to SQL Server; download from Microsoft if `pyodbc.connect(...)` complains it's missing

## 2. Create the two databases

In SSMS, connect to your local instance (usually `localhost` or
`localhost\SQLEXPRESS` — check what the installer told you), then run:

```sql
CREATE DATABASE BookstoreBusinessDB;
CREATE DATABASE BookstoreDWH;
```

## 3. Build the schemas + load data

In SSMS, make sure the query window is pointed at `BookstoreBusinessDB`
(dropdown at the top of the toolbar), then run in order:

1. `01_business_db_create_mssql.sql`
2. `02_seed_data_mssql.sql`

Switch the query window to `BookstoreDWH`, then run:

3. `03_dwh_create_mssql.sql`

## 4. Run the ETL

Open `06_etl_mssql.py` and check the top of the file — `SERVER` needs to
match your actual instance name (SSMS shows this when you connect, e.g.
`localhost\SQLEXPRESS` or just `localhost`). Then:

```bash
pip install pyodbc
python 06_etl_mssql.py
```

## 5. Trigger and verify the SCD scenario

```bash
# In SSMS, pointed at BookstoreBusinessDB, run:
04_seed... (skip) -> run 05_scd_demo_update_mssql.sql

# Then re-run the ETL:
python 06_etl_mssql.py
```

Same expected output as the SQLite version: Dim_Buch and Dim_Kunde each get
one new SCD Typ 2 version, Dim_Verlag gets overwritten in place (Typ 1), and
the fact table doesn't reload anything. Query `Dim_Buch` / `Dim_Kunde` in
SSMS afterwards for your presentation screenshot.

## If something doesn't connect

- `Trusted_Connection=yes` uses Windows Authentication — this only works if
  you're logged into Windows with the same account SQL Server trusts. If you
  set up SQL Server with a SQL login/password instead, replace that line in
  `get_conn()` with `UID=your_user;PWD=your_password;`.
- If `pyodbc.connect` raises a driver-not-found error, run
  `python -c "import pyodbc; print(pyodbc.drivers())"` to see what's
  actually installed, and update `DRIVER` in the script to match exactly.
