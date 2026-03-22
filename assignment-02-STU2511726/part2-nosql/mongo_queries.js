// ============================================================
// Answer 2.2 — MongoDB Operations
// Collection: products
// Description: MongoDB CRUD and indexing operations on the
//              e-commerce product catalog.
// ============================================================


// OP1: insertMany() — Insert all 3 documents from sample_documents.json
// This inserts one document per category: Electronics, Clothing, Groceries.

db.products.insertMany([
  {
    "_id": "PROD_E001",
    "category": "Electronics",
    "name": "Sony WH-1000XM5 Wireless Headphones",
    "brand": "Sony",
    "price": 29999,
    "currency": "INR",
    "in_stock": true,
    "stock_quantity": 45,
    "specifications": {
      "battery_life_hours": 30,
      "connectivity": ["Bluetooth 5.2", "3.5mm Jack", "USB-C"],
      "noise_cancellation": true,
      "weight_grams": 250,
      "color_options": ["Black", "Silver", "Midnight Blue"]
    },
    "warranty": {
      "duration_years": 1,
      "type": "Manufacturer Warranty",
      "covers": ["Manufacturing defects", "Hardware failure"]
    },
    "voltage_specs": {
      "input_voltage": "5V",
      "charging_standard": "USB-C PD",
      "compatible_regions": ["India", "USA", "EU"]
    },
    "ratings": { "average": 4.7, "total_reviews": 2340 },
    "tags": ["wireless", "noise-cancelling", "premium", "audio"],
    "added_date": "2024-01-15"
  },
  {
    "_id": "PROD_C001",
    "category": "Clothing",
    "name": "Men's Slim Fit Cotton Formal Shirt",
    "brand": "Raymond",
    "price": 1499,
    "currency": "INR",
    "in_stock": true,
    "stock_quantity": 120,
    "specifications": {
      "fabric": "100% Cotton",
      "fit_type": "Slim Fit",
      "sleeve": "Full Sleeve",
      "occasion": ["Formal", "Business", "Office"],
      "care_instructions": ["Machine wash cold", "Do not bleach", "Tumble dry low"]
    },
    "sizes_available": [
      { "size": "S",  "chest_inches": 36, "units_left": 20 },
      { "size": "M",  "chest_inches": 38, "units_left": 45 },
      { "size": "L",  "chest_inches": 40, "units_left": 35 },
      { "size": "XL", "chest_inches": 42, "units_left": 20 }
    ],
    "ratings": { "average": 4.3, "total_reviews": 875 },
    "tags": ["formal", "cotton", "slim-fit", "office-wear"],
    "added_date": "2024-02-10"
  },
  {
    "_id": "PROD_G001",
    "category": "Groceries",
    "name": "Organic Whole Wheat Atta",
    "brand": "Aashirvaad",
    "price": 349,
    "currency": "INR",
    "in_stock": true,
    "stock_quantity": 300,
    "specifications": {
      "weight_kg": 5,
      "organic_certified": true,
      "certifications": ["FSSAI", "India Organic", "Non-GMO"],
      "ingredients": ["100% Whole Wheat"],
      "allergens": ["Gluten"]
    },
    "nutritional_info": {
      "per_100g": {
        "calories_kcal": 340,
        "protein_g": 12,
        "carbohydrates_g": 70,
        "fiber_g": 11,
        "fat_g": 2,
        "sodium_mg": 2
      }
    },
    "expiry_details": {
      "manufactured_date": "2024-11-01",
      "expiry_date": "2025-10-31",
      "shelf_life_months": 12,
      "storage_instructions": "Store in a cool, dry place."
    },
    "ratings": { "average": 4.5, "total_reviews": 5620 },
    "tags": ["organic", "whole-wheat", "healthy", "staple"],
    "added_date": "2024-11-05"
  }
]);


// OP2: find() — Retrieve all Electronics products with price > 20000
// Filters documents where category is Electronics AND price exceeds 20000.

db.products.find(
  {
    category: "Electronics",
    price: { $gt: 20000 }
  },
  {
    name: 1,
    brand: 1,
    price: 1,
    category: 1,
    _id: 0
  }
);

// Expected output:
// { name: "Sony WH-1000XM5 Wireless Headphones", brand: "Sony", price: 29999, category: "Electronics" }


// OP3: find() — Retrieve all Groceries expiring before 2025-01-01
// Finds grocery items whose expiry_date is before January 1, 2025.

db.products.find(
  {
    category: "Groceries",
    "expiry_details.expiry_date": { $lt: "2025-01-01" }
  },
  {
    name: 1,
    brand: 1,
    "expiry_details.expiry_date": 1,
    _id: 0
  }
);

// Expected output:
// No documents returned — our grocery item expires on 2025-10-31 (after 2025-01-01).
// This query correctly returns empty, confirming no near-expiry stock exists.


// OP4: updateOne() — Add a "discount_percent" field to a specific product
// Adds a discount of 10% to the Electronics headphones product.

db.products.updateOne(
  { _id: "PROD_E001" },
  {
    $set: {
      discount_percent: 10,
      discounted_price: 26999,
      discount_valid_until: "2025-03-31"
    }
  }
);

// Expected output:
// { acknowledged: true, matchedCount: 1, modifiedCount: 1 }
// The headphones document now has a discount_percent field added without
// affecting any other fields — demonstrating MongoDB's flexible schema.


// OP5: createIndex() — Create an index on the category field and explain why
// An index on "category" speeds up all queries that filter by product category.

db.products.createIndex(
  { category: 1 },
  { name: "idx_category_asc" }
);

// WHY THIS INDEX IS IMPORTANT:
// In an e-commerce platform, the most common query pattern is filtering
// products by category (e.g., "show all Electronics", "show all Groceries").
// Without an index, MongoDB performs a COLLECTION SCAN — it reads every
// single document to find matches. This is slow when the catalog has
// thousands of products.
//
// With an index on "category", MongoDB uses a B-tree structure to jump
// directly to matching documents — making queries 10x to 100x faster
// depending on collection size.
//
// Verify the index was created:
db.products.getIndexes();

// Use explain() to confirm the index is being used:
db.products.find({ category: "Electronics" }).explain("executionStats");
// Look for "IXSCAN" (Index Scan) in the output instead of "COLLSCAN" (Collection Scan).

// ============================================================
// END OF MONGODB OPERATIONS
// ============================================================
