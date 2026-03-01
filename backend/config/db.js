const mongoose = require('mongoose');

const connectDB = async () => {
  let uri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/portfolio';

  // Safety check to prevent "Invalid scheme" error if MONGO_URI is empty string
  if (!uri || uri.trim() === '') {
    uri = 'mongodb://127.0.0.1:27017/portfolio';
  }

  console.log('--- DEBUG: MongoDB Connection ---');
  console.log('Raw process.env.MONGO_URI:', process.env.MONGO_URI ? 'EXISTS' : 'NOT FOUND');
  console.log('Final URI being used:', uri);
  console.log('---------------------------------');

  try {
    await mongoose.connect(uri.trim(), { useNewUrlParser: true, useUnifiedTopology: true });
    console.log('MongoDB connected');
  } catch (err) {
    console.error('MongoDB connection error:', err.message);
    process.exit(1);
  }
};

let isConnected = false;
const connectOnce = async () => {
  if (isConnected) {
    console.log('Using existing MongoDB connection');
    return;
  }
  await connectDB();
  isConnected = true;
};

module.exports = { connectDB, connectOnce };
