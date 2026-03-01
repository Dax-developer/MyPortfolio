const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./models/User');

dotenv.config();

const resetDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('✔ Connected to MongoDB');

        const res = await User.deleteMany({});
        console.log(`✔ Successfully deleted ${res.deletedCount} users.`);
        console.log('Database is now clean. You can start testing from fresh Signup.');

        process.exit(0);
    } catch (err) {
        console.error('✘ Error:', err.message);
        process.exit(1);
    }
};

resetDB();
