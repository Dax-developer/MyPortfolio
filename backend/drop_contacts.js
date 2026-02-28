const mongoose = require('mongoose');
require('dotenv').config();

const dropContacts = async () => {
    try {
        const uri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/my_portfolio_v2';
        await mongoose.connect(uri);
        console.log('Connected to:', uri);

        const db = mongoose.connection.db;
        const collections = await db.listCollections({ name: 'contacts' }).toArray();

        if (collections.length > 0) {
            await db.collection('contacts').drop();
            console.log('Collection "contacts" dropped successfully.');
        } else {
            console.log('Collection "contacts" does not exist.');
        }

        process.exit(0);
    } catch (err) {
        console.error('Error dropping collection:', err);
        process.exit(1);
    }
};

dropContacts();
