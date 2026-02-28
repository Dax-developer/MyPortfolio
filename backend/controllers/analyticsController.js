const User = require('../models/User');
const Contact = require('../models/Contact');
const Review = require('../models/Review');

exports.getStats = async (req, res) => {
    try {
        const userCount = await User.countDocuments();
        const contactCount = await Contact.countDocuments();
        const reviewCount = await Review.countDocuments();

        res.json({
            users: userCount,
            contacts: contactCount,
            reviews: reviewCount
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
