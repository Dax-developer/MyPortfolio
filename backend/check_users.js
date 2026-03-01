const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./models/User');

dotenv.config();

const checkUsers = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('✔ Connected to MongoDB');

        const users = await User.find({}, 'email isVerified createdAt');
        console.log('\n--- Existing Users ---');
        if (users.length === 0) {
            console.log('No users found in database.');
        } else {
            users.forEach(u => {
                console.log(`- Email: ${u.email} | Verified: ${u.isVerified} | Created: ${u.createdAt}`);
            });
        }
        console.log('----------------------\n');

        process.exit(0);
    } catch (err) {
        console.error('✘ Error:', err.message);
        process.exit(1);
    }
};

checkUsers();
