require('dotenv').config();
const express = require('express');
const { MongoClient, ServerApiVersion } = require('mongodb');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server);

// Use environment variable for MongoDB connection
const uri = process.env.MONGODB_URI;

const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  }
});

let locationCollection;

// Store active users and their locations
const activeUsers = new Map();

async function connectDB() {
  try {
    await client.connect();
    const db = client.db("location_tracker");
    locationCollection = db.collection("locations");
    console.log("Connected to MongoDB Atlas");

    // Add connection event listeners
    client.on('error', (error) => {
      console.error('Database connection error:', error);
      // Implement reconnection logic
      setTimeout(connectDB, 3000);
    });

    client.on('close', () => {
      console.log('Database connection closed. Attempting to reconnect...');
      setTimeout(connectDB, 3000);
    });

  } catch (error) {
    console.error("Failed to connect to database:", error);
    // Implement retry logic
    setTimeout(connectDB, 3000);
  }
}

// Connect to database when server starts
connectDB();

app.use(express.json());
app.use(cors());

// API endpoints
app.post('/api/send-location', async (req, res) => {
  try {
    console.log('Received location data:', req.body);

    // MongoDB connection check (correct way)
    if (!client.topology || !client.topology.isConnected()) {
      console.log('Reconnecting to database...');
      await connectDB();
    }

    const locationCollection = client.db("location_tracker").collection("locations");
    const locationData = {
      ...req.body,
      id: Date.now()
    };

    console.log('Saving location data:', locationData);
    await locationCollection.insertOne(locationData);
    
    io.emit('newLocation', locationData);
    console.log('Location data emitted to admin clients');
    
    res.status(200).json({ message: 'Location saved successfully' });

  } catch (error) {
    console.error('Error saving location:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/location-data', async (req, res) => {
  try {
    const locations = await locationCollection
      .find()
      .sort({ timestamp: -1 }) // Sort by newest first
      .toArray();
    res.status(200).json(locations);
  } catch (error) {
    console.error('Error fetching locations:', error);
    res.status(500).json({ error: error.message });
  }
});

io.on('connection', (socket) => {
  console.log('New client connected');

  // Handle user registration
  socket.on('register_user', (userData) => {
    activeUsers.set(socket.id, {
      userId: userData.userId,
      isAdmin: userData.isAdmin
    });
  });

  // Handle location updates
  socket.on('location_update', async (locationData) => {
    try {
      // Save to MongoDB
      await locationCollection.updateOne(
        { userId: locationData.userId },
        { 
          $set: {
            latitude: locationData.latitude,
            longitude: locationData.longitude,
            timestamp: new Date(),
            userId: locationData.userId
          }
        },
        { upsert: true }
      );

      // Emit to admin clients only
      const adminSockets = Array.from(activeUsers.entries())
        .filter(([_, user]) => user.isAdmin)
        .map(([socketId]) => socketId);

      adminSockets.forEach(adminSocketId => {
        io.to(adminSocketId).emit('user_location_update', locationData);
      });

    } catch (error) {
      console.error('Error saving location:', error);
    }
  });

  socket.on('disconnect', () => {
    activeUsers.delete(socket.id);
    console.log('Client disconnected');
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

async function testConnection() {
  try {
    await client.connect();
    await client.db("location_tracker").command({ ping: 1 });
    console.log("Database connection successful!");
    
    // Test database operations
    const testCollection = client.db("location_tracker").collection("locations");
    await testCollection.insertOne({ test: "connection" });
    await testCollection.deleteOne({ test: "connection" });
    console.log("Database operations working correctly!");
  } catch (error) {
    console.error("Database connection test failed:", error);
    process.exit(1); // Exit if connection fails
  }
}

// Add monitoring functions
async function monitorDatabaseHealth() {
  try {
    // Check connection status
    const isConnected = client.isConnected();
    console.log('Database connection status:', isConnected);

    // Monitor collection stats
    const stats = await locationCollection.stats();
    console.log('Collection statistics:', {
      documentCount: stats.count,
      sizeInBytes: stats.size,
      avgDocumentSize: stats.avgObjSize
    });

    // Monitor operation performance
    const operationLatency = await measureOperationLatency();
    console.log('Operation latency:', operationLatency + 'ms');

  } catch (error) {
    console.error('Monitoring error:', error);
  }
}

// Run monitoring every 5 minutes
setInterval(monitorDatabaseHealth, 300000);

// Add logging throughout your application
function logDatabaseOperation(operation, success, error = null) {
  const timestamp = new Date().toISOString();
  const logEntry = {
    timestamp,
    operation,
    success,
    error: error ? error.message : null
  };
  
  console.log(JSON.stringify(logEntry));
  // You could also save logs to a file or monitoring service
}

// Add shutdown handling
process.on('SIGINT', async () => {
  try {
    await client.close();
    console.log('Database connection closed.');
    process.exit(0);
  } catch (error) {
    console.error('Error during shutdown:', error);
    process.exit(1);
  }
});