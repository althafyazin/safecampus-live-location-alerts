require('dotenv').config();
const { MongoClient, ServerApiVersion } = require('mongodb');

// Use the environment variable instead of hardcoding the URI
const uri = process.env.MONGODB_URI;

const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  }
});

async function run() {
  try {
    await client.connect();
    await client.db("admin").command({ ping: 1 });
    console.log("✅ Connected successfully to MongoDB!");
    
    // Test database operations
    const db = client.db("location_tracker");
    const collection = db.collection("locations");
    
    // Test write operation
    await collection.insertOne({ test: true, timestamp: new Date() });
    console.log("✅ Write operation successful!");
    
  } catch (error) {
    console.error("❌ Connection error:", error);
  } finally {
    await client.close();
    console.log("Connection closed.");
  }
}

run().catch(console.dir);