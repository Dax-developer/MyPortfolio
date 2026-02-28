const mongoose = require('mongoose');
require('dotenv').config();
const User = require('./models/User');

const check = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/my_portfolio_v2');
        const users = await User.find({}, 'email');
        console.log('--- USERS IN DB ---');
        users.forEach(u => console.log(u.email));
        console.log('-------------------');
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

check();
