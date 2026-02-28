const mongoose = require('mongoose');

const LanguageSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        unique: true
    },
    proficiency: {
        type: String,
        required: true,
        enum: ['Beginner', 'Intermediate', 'Fluent', 'Native']
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Language', LanguageSchema);
