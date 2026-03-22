# Answer 1.1 -  Normalization Report — orders_flat.csv

---

## Anomaly Analysis

The file `orders_flat.csv` is a **denormalized flat table** that stores customer, product, sales representative, and order information all in a single table. This design introduces three types of data anomalies, as identified below.

---

### Insert Anomaly

**Definition:** An insert anomaly occurs when we cannot add new data without being forced to add unrelated or incomplete data.

**Example from dataset:**
Suppose we hire a new sales representative — say, a fourth rep named *Sunita Rao* — but she has not yet been assigned any orders. In the current flat-file design, it is **impossible to store her details** (rep ID, name, email, office address) without creating a fake/dummy order row. There is no separate table for sales representatives, so their data can only exist if an order exists.

> Affected columns: `sales_rep_id`, `sales_rep_name`, `sales_rep_email`, `office_address`

---

### Update Anomaly

**Definition:** An update anomaly occurs when the same piece of information is stored in multiple rows, making it necessary to update many rows to change one fact — and risking inconsistency if some rows are missed.

**Example from dataset:**
Customer **Priya Sharma** (customer_id: C002) appears in multiple order rows. If her email address changes, it must be updated in every row where she appears. In our dataset, she appears in rows including `ORD1027`, `ORD1002`, `ORD1037`, `ORD1054`, and `ORD1048`. If even one row is missed, the database will have two different emails for the same customer — an inconsistency.

> Affected columns: `customer_id`, `customer_name`, `customer_email`, `customer_city`

---

### Delete Anomaly

**Definition:** A delete anomaly occurs when deleting one piece of data unintentionally destroys other, unrelated information.

**Example from dataset:**
All information about sales representative **Ravi Kumar** (sales_rep_id: SR03, email: ravi@corp.com, office: South Zone, MG Road, Bangalore - 560001) is stored only within order rows. If all orders assigned to Ravi Kumar are deleted from the system, his **entire profile is permanently lost** — even though we may still want to keep his employment record. Orders `ORD1037`, `ORD1075`, and `ORD1162` are among the rows that carry his details.

> Affected columns: `sales_rep_id`, `sales_rep_name`, `sales_rep_email`, `office_address`

---

## Normalization Justification

**Question posed by manager:** *"Keeping everything in one table is simpler, and normalization is over-engineering. Defend or refute this position."*

The manager's argument has surface appeal — one table does feel simple at first. However, the `orders_flat.csv` dataset itself demonstrates exactly why this reasoning fails in practice.

Consider what happens when **Priya Sharma** (C002) changes her email address. In the flat file, she appears across at least five order rows. A developer must run an UPDATE statement touching every single one of those rows. If even one is missed — perhaps due to a network timeout or a bug — the database now silently contains two different emails for the same person. The data looks correct but is not. In a normalized design, customer information lives in a dedicated `customers` table with a single row per customer. Updating her email requires changing exactly **one row**, and the correctness is guaranteed.

The delete anomaly is even more dangerous. Sales rep **Ravi Kumar's** contact details and office address exist only because he has orders. The moment those orders are deleted — perhaps as part of a data cleanup or archiving process — his entire record vanishes. A business that needs to pay him, contact him, or audit his history has no recourse. A normalized `sales_reps` table would preserve his record independently of whether he has any current orders.

The insert anomaly is similarly limiting. The company cannot onboard a new sales representative into the system until that person receives their first order. This is a direct operational constraint caused purely by poor schema design.

Normalization to **Third Normal Form (3NF)** resolves all three anomalies by ensuring each fact is stored in exactly one place. The resulting schema — with separate tables for customers, products, sales representatives, and orders — is not more complex to query; it is simply more correct. JOINs are a standard, efficient SQL operation. The trade-off of writing a JOIN is far preferable to the trade-off of corrupted, incomplete, or accidentally deleted business data.

In summary, the "one table is simpler" argument mistakes **familiarity** for **correctness**. Normalization is not over-engineering; it is the foundation of reliable, maintainable data.

---
