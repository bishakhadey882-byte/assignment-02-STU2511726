# Part 5 - Architecture Choice

## Architecture Recommendation

For a fast-growing food delivery startup that collects GPS location logs, customer text reviews, payment transactions, and restaurant menu images, I would recommend a **Data Lakehouse** architecture.

Here are 3 specific reasons for this choice:

**Reason 1 — Handles All Data Types Together**
The startup deals with four completely different types of data: GPS logs (structured time-series), customer text reviews (unstructured text), payment transactions (structured relational), and menu images (binary/unstructured). A traditional Data Warehouse only handles structured data with a fixed schema — it cannot store GPS logs or menu images at all. A pure Data Lake stores everything raw but cannot run fast analytical queries. A Data Lakehouse combines both: it stores all formats cheaply in a raw lake layer (like Amazon S3) while also providing a structured, queryable layer on top using formats like Delta Lake or Apache Iceberg. This makes it the only architecture that handles all four data types efficiently in one system.

**Reason 2 — Supports Both Real-Time and Batch Processing**
A food delivery startup needs real-time processing for live GPS tracking and instant order status updates, as well as batch processing for weekly revenue reports and monthly customer trend analysis. A Data Warehouse is designed only for batch and reporting workloads. A pure Data Lake struggles with low-latency queries. A Data Lakehouse supports both streaming data ingestion (via Apache Kafka or Spark Streaming) and fast analytical SQL queries (via DuckDB or Spark SQL), making it ideal for this mixed workload requirement without needing two separate systems.

**Reason 3 — Cost-Effective Scalability**
GPS logs and customer reviews can grow to terabytes very quickly. A Data Warehouse like Snowflake or BigQuery charges high costs for storing large volumes of unstructured data. A Data Lakehouse stores the bulk of raw data cheaply on cloud object storage (S3 or GCS costs as low as $0.023 per GB), while only the frequently queried, refined data is stored in an optimized table format. This gives the startup the best balance of low storage cost, high query performance, and easy scalability as the business grows rapidly.

In conclusion, a **Data Lakehouse** is the most suitable choice because it provides the flexibility of a Data Lake, the query performance of a Data Warehouse, and the cost efficiency that a fast-growing startup needs when managing diverse, high-volume data from multiple sources.
