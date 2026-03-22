# Part 2 - NoSQL vs RDBMS Analysis

---

## Database Recommendation

**Scenario:** A healthcare startup is building a patient management system. One engineer recommends MySQL; another recommends MongoDB. Given your understanding of ACID vs BASE and the CAP theorem, which would you recommend and why? Would your answer change if they also needed to add a fraud detection module?

---

### My Recommendation: MySQL (Relational Database)

For a **patient management system**, I would strongly recommend **MySQL** over MongoDB, and here is my detailed reasoning.

**Patient data is among the most critical and legally sensitive data in existence.** A patient's medical history, prescriptions, allergies, diagnoses, and treatment records must be stored with absolute accuracy and consistency. This is precisely where relational databases and the **ACID properties** (Atomicity, Consistency, Isolation, Durability) prove essential.

Consider a real scenario: a doctor updates a patient's allergy record from "no known allergies" to "allergic to Penicillin" while simultaneously a nurse is generating a prescription that includes Penicillin. In a MySQL database, ACID guarantees that either the allergy update completes fully before the prescription is generated, or the system rolls back — preventing a life-threatening inconsistency. MongoDB follows the **BASE model** (Basically Available, Soft state, Eventually consistent), which means two parts of the system might temporarily see different versions of the same data. In a healthcare context, this "eventual consistency" is not acceptable — a patient could receive the wrong medication during that inconsistent window.

From a **CAP theorem** perspective, MySQL prioritizes **Consistency and Partition tolerance (CP)**, sacrificing some availability in edge cases. For healthcare, consistency is non-negotiable. MongoDB, being an **AP system** (Available and Partition-tolerant), sacrifices consistency for availability — the wrong trade-off for medical records.

Additionally, patient data has **well-defined, structured relationships** — patients have appointments, appointments have doctors, doctors belong to departments, prescriptions link to medicines. These relationships are naturally and efficiently modelled using relational tables with foreign keys, joins, and constraints. MongoDB's flexible schema provides no advantage here and actually introduces risk — a missing field in a patient document could go undetected until it causes a clinical error.

---

### Would My Answer Change for a Fraud Detection Module?

**Yes, partially.** If the startup adds a fraud detection module — for example, to detect unusual billing patterns, duplicate insurance claims, or abnormal prescription requests — the answer becomes more nuanced.

Fraud detection requires analysing **large volumes of unstructured, rapidly changing behavioural data** in real time. It may involve graph-like relationships (which doctor is connected to which pharmacy, which patient visited how many hospitals), variable attributes per claim type, and high-speed writes from multiple sources. These are scenarios where **MongoDB's flexible schema and horizontal scalability** offer a genuine advantage.

Therefore, the ideal architecture for this startup would be a **hybrid approach**: MySQL for the core patient management system (medical records, prescriptions, appointments) where ACID compliance and data integrity are critical, and MongoDB (or a graph database like Neo4j) for the fraud detection module where flexibility, speed, and pattern analysis across loosely structured data are the priority. This is a common real-world pattern — using the right database for the right job rather than forcing one system to do everything.

---
