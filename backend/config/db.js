const mongoose = require('mongoose');

// Suppress Mongoose 7 deprecation warning
mongoose.set('strictQuery', false);

const connectDB = async () => {
  let uri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/portfolio';

  if (!uri || uri.trim() === '') {
    uri = 'mongodb://127.0.0.1:27017/portfolio';
  }

  console.log('--- [DATABASE] Connection Attempt ---');
  console.log('URI Source:', process.env.MONGO_URI ? 'Environment Variable' : 'Local Fallback');
  console.log('Target URI:', uri.replace(/:([^@]+)@/, ':****@')); // Hide password in logs
  console.log('-----------------------------------');

  try {
    await mongoose.connect(uri.trim(), {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 15000 // 15s timeout
    });
    console.log('✔ [DATABASE] MongoDB connected successfully');
  } catch (err) {
    console.error('✘ [DATABASE] MongoDB connection error:', err.message);
    if (err.reason) console.error('Reason:', err.reason);
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
