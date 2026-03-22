# Part 3 - ETL Notes — Retail Transactions Data Warehouse

**File:** `part3-datawarehouse/etl_notes.md`    
**Dataset:** `retail_transactions.csv` (300 rows, 9 columns)

---

## ETL Decisions

### Decision 1 — Standardizing Inconsistent Category Names

**Problem:**  
The `category` column in the raw CSV contained the same categories spelled in different ways due to inconsistent data entry. For example, `"electronics"`, `"Electronics"` were treated as two different categories. Similarly, `"Grocery"` and `"Groceries"` appeared as separate values, even though they represent the same product group. This would cause incorrect GROUP BY results in analytical queries — the same category would appear multiple times with split revenue figures.

**Resolution:**  
During the ETL process, I applied a standardization step before loading into the data warehouse:
1. Converted all category values to lowercase using `.str.lower()` to eliminate case differences.
2. Applied a mapping dictionary to unify variant spellings:
   - `"electronics"` → `"Electronics"`
   - `"groceries"` → `"Grocery"`
   - `"grocery"` → `"Grocery"`
   - `"clothing"` → `"Clothing"`

This ensures the `dim_product` table only contains 3 clean, distinct categories: **Electronics**, **Grocery**, and **Clothing**.

---

### Decision 2 — Resolving Mixed Date Formats

**Problem:**  
The `date` column contained dates in at least 3 different formats across the 300 rows:
- `29/08/2023` (DD/MM/YYYY)
- `20-02-2023` (DD-MM-YYYY)
- `2023-01-15` (YYYY-MM-DD / ISO format)

This inconsistency would cause date parsing failures and prevent correct sorting, filtering, or time-series analysis. If loaded as-is, SQL queries using `ORDER BY date` or `WHERE MONTH(date) = 8` would produce wrong or unpredictable results.

**Resolution:**  
I used Python's `dateutil.parser.parse()` function with the `dayfirst=True` flag. This automatically detects and correctly parses all three date formats. After parsing, all dates were converted to the standard **ISO 8601 format** (`YYYY-MM-DD`) before loading into `dim_date`. This ensures consistent date arithmetic and correct month/quarter extraction inside the warehouse.

---

### Decision 3 — Filling Missing City Values Using Store Name Mapping

**Problem:**  
The `store_city` column had **NULL (missing) values** for several rows. Since the store name uniquely identifies the city (e.g., `"Chennai Anna"` is always in `"Chennai"`), these NULLs were not truly unknown — they were just missing due to data entry gaps. Loading NULLs into the `dim_store` table would break BI reports that filter or group by city.

**Resolution:**  
I created a reference dictionary mapping each store name to its known city:
- `Chennai Anna` → `Chennai`
- `Delhi South` → `Delhi`
- `Bangalore MG` → `Bangalore`
- `Pune FC Road` → `Pune`
- `Mumbai Central` → `Mumbai`

Using this lookup, I filled all NULL city values during the transformation step before inserting into `dim_store`. This approach is safe because the store-to-city relationship is deterministic and does not require guessing — every store has exactly one city.
