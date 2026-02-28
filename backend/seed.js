const mongoose = require('mongoose');
require('dotenv').config();

const Project = require('./models/Project');
const Skill = require('./models/Skill');
const Education = require('./models/Education');

const seedData = async () => {
    try {
        const uri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/portfolio';
        await mongoose.connect(uri);
        console.log('Connected to:', uri);

        // Clear existing data
        await Project.deleteMany({});
        await Skill.deleteMany({});
        await Education.deleteMany({});

        const sampleProject = {
            title: 'Premium Portfolio v2',
            description: 'A professional portfolio website built with Flutter and Node.js, featuring a modern responsive design and dynamic project cards.',
            role: 'Lead Developer',
            githubUrl: 'https://github.com/yourusername/portfolio',
            url: 'https://yourportfolio.demo',
            tech: ['Flutter', 'Dart', 'Node.js', 'Express', 'MongoDB'],
        };

        const defaultSkills = [
            { name: 'Flutter', level: 'Expert' },
            { name: 'Dart', level: 'Expert' },
            { name: 'Node.js', level: 'Intermediate' },
            { name: 'Express', level: 'Intermediate' },
            { name: 'MongoDB', level: 'Intermediate' },
            { name: 'JavaScript', level: 'Expert' },
            { name: 'HTML/CSS', level: 'Expert' },
            { name: 'Git', level: 'Expert' }
        ];

        const sampleEducation = [
            {
                degree: 'BCA (Bachelor of Computer Applications)',
                institution: 'XYZ University',
                year: '2024',
                grade: '9.0 CGPA',
                certificateUrl: '' // Empty for now
            }
        ];

        await Project.create(sampleProject);
        await Skill.insertMany(defaultSkills);
        const createdEdu = await Education.insertMany(sampleEducation);

        console.log(`[SEED] Added 1 project`);
        console.log(`[SEED] Added ${defaultSkills.length} skills`);
        console.log(`[SEED] Added ${createdEdu.length} education entries`);

        process.exit(0);
    } catch (err) {
        console.error('Error seeding data:', err);
        process.exit(1);
    }
};

seedData();
