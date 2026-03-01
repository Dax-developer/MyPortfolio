const mongoose = require('mongoose');
const Profile = require('./models/Profile');
require('dotenv').config();

const update = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected to DB');

        let profile = await Profile.findOne();
        if (!profile) {
            profile = new Profile();
        }

        profile.footerInstagram = 'https://www.instagram.com/dax___2305/';
        profile.footerGitHub = 'https://github.com/Dax-developer/MyPortfolio';
        profile.footerLinkedIn = 'https://www.linkedin.com/in/dax-patel-08866b26b/';
        profile.footerWhatsApp = 'https://web.whatsapp.com/';

        // Also update name/title if they are default
        profile.name = 'Dax Patel';
        profile.title = 'Student / Full Stack Developer';
        profile.heroSkills = 'Flutter • Node.js • MongoDB';

        await profile.save();
        console.log('Profile updated successfully');
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

update();
