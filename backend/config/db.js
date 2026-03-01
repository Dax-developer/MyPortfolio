const mongoose = require('mongoose');

// Suppress Mongoose 7 deprecation warning
mongoose.set('strictQuery', false);

const connectDB = async (retries = 3) => {
  let uri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/portfolio';

  if (!uri || uri.trim() === '') {
    uri = 'mongodb://127.0.0.1:27017/portfolio';
  }

  console.log('--- [DATABASE] Connection Attempt ---');
  console.log('URI Source:', process.env.MONGO_URI ? 'Environment Variable' : 'Local Fallback');
  console.log('Target URI:', uri.replace(/:([^@]+)@/, ':****@')); // Hide password in logs
  console.log('-----------------------------------');

  while (retries > 0) {
    try {
      await mongoose.connect(uri.trim(), {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        serverSelectionTimeoutMS: 20000 // 20s timeout
      });
      console.log('✔ [DATABASE] MongoDB connected successfully');
      return;
    } catch (err) {
      retries--;
      console.error(`✘ [DATABASE] Attempt failed (${3 - retries}/3):`, err.message);
      if (retries > 0) {
        console.log(`[DATABASE] Retrying in 5 seconds...`);
        await new Promise(resolve => setTimeout(resolve, 5000));
      } else {
        console.error('✘ [DATABASE] All connection attempts failed.');
        if (err.reason) console.error('Reason:', err.reason);
        process.exit(1);
      }
    }
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
