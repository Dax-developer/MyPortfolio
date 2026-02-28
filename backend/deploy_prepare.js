const fs = require('fs-extra');
const path = require('path');
const { execSync } = require('child_process');

const srcDir = path.join(__dirname, '../frontend/build/web');
const destDir = path.join(__dirname, 'public');

async function prepare() {
    try {
        console.log('Building Flutter Web...');
        execSync('cd ../frontend && flutter build web', { stdio: 'inherit' });

        console.log('Cleaning up public folder...');
        await fs.remove(destDir);
        await fs.ensureDir(destDir);

        console.log('Copying build files to backend/public...');
        await fs.copy(srcDir, destDir);

        console.log('Success! Frontend is now ready in backend/public');
    } catch (err) {
        console.error('Error during preparation:', err);
        process.exit(1);
    }
}

prepare();
