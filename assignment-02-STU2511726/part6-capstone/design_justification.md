# Answer 6.2 - Design Justification

## Storage Systems

The hospital AI system has four distinct goals, each requiring a different type of storage system chosen for specific reasons.

**Goal 1 — Predict patient readmission risk** uses **PostgreSQL (OLTP relational database)**. Patient treatment history involves structured data with clear relationships between patients, diagnoses, medications, and visits. A relational database enforces data integrity through foreign keys and supports complex JOIN queries needed to retrieve a patient's full medical history for feeding into the ML model. PostgreSQL also supports structured ML feature extraction efficiently.

**Goal 2 — Allow doctors to query patient history in plain English** uses a **Vector Database (Pinecone or Weaviate)**. When a doctor asks "Has this patient had a cardiac event before?", the system needs semantic search — not keyword matching. Patient notes and records are converted into vector embeddings using a language model, stored in the vector DB, and searched by meaning similarity. This enables natural language querying that a traditional database cannot support. A Large Language Model (LLM) with Retrieval-Augmented Generation (RAG) retrieves relevant records and generates a human-readable answer.

**Goal 3 — Generate monthly reports** uses **Snowflake or BigQuery (OLAP Data Warehouse)**. Monthly reports on bed occupancy and department costs require aggregating millions of records across time periods. OLAP systems are optimized specifically for this — they use columnar storage that makes GROUP BY, SUM, and AVG queries on large datasets extremely fast. These queries would be too slow on a transactional PostgreSQL database.

**Goal 4 — Stream and store real-time ICU vitals** uses a **Time-Series Database (InfluxDB or TimescaleDB)**. ICU devices generate thousands of readings per second. Time-series databases are designed specifically for this — they compress time-stamped data efficiently, support fast time-window queries ("show vitals in the last 5 minutes"), and integrate with stream processors like Apache Kafka for real-time alert triggering.

All four storage systems sit inside a **Data Lakehouse** (Amazon S3 + Delta Lake) which serves as the central raw data store before data is routed to the appropriate specialized system.

## OLTP vs OLAP Boundary

The **OLTP boundary** covers all transactional, real-time, and operational systems — PostgreSQL (patient records), InfluxDB (live ICU vitals), and the vector database (doctor queries). These systems handle individual, frequent read/write operations with low latency. For example, when a nurse updates a patient's medication record, that is a single-row INSERT into PostgreSQL — a classic OLTP operation.

The **OLAP boundary begins** at the data warehouse (Snowflake/BigQuery). Data flows from the OLTP systems into the Data Lakehouse through nightly ETL batch jobs, and from there into Snowflake for analytical processing. When the hospital management runs a report asking "What was the average bed occupancy across all departments in November?", that query touches millions of rows — a classic OLAP operation requiring columnar storage and distributed query execution. The ETL pipeline (Apache Spark) is the boundary between the two worlds, transforming and loading operational data into the analytical system.

## Trade-offs

**Trade-off identified: Complexity vs. Specialization**

The most significant trade-off in this design is **operational complexity versus performance specialization**. By using four different storage systems (PostgreSQL, Vector DB, OLAP Warehouse, Time-Series DB), each system performs its specific task optimally. However, managing four different databases increases infrastructure cost, requires specialized skills for each system, and creates data consistency challenges — the same patient record must stay synchronized across multiple stores.

**Mitigation strategy:** The Data Lakehouse (S3 + Delta Lake) acts as the **single source of truth**. All raw data lands here first. Specialized databases are populated downstream through well-defined ETL pipelines with clear data contracts. This ensures that if any downstream system has stale data, it can be reloaded from the lakehouse. Additionally, using a managed cloud service for each system (AWS RDS for PostgreSQL, Pinecone managed cloud, BigQuery) reduces the operational burden significantly since the cloud provider handles scaling, backups, and maintenance.
