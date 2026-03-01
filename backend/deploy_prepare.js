const fs = require('fs-extra');
const path = require('path');
const { execSync } = require('child_process');

const srcDir = path.join(__dirname, '../frontend/build/web');
const destDir = path.join(__dirname, 'public');
const rootPublicDir = path.join(__dirname, '../public');

async function prepare() {
    try {
        console.log('Checking for Flutter...');
        let hasFlutter = false;
        try {
            const frontendDir = path.join(__dirname, '../frontend');
            execSync(`cd "${frontendDir}" && flutter --version`, { stdio: 'ignore' });
            hasFlutter = true;
        } catch (e) {
            console.log('Flutter not found in path. Skipping frontend build step.');
        }

        if (hasFlutter) {
            console.log('Building Flutter Web...');
            const frontendDir = path.join(__dirname, '../frontend');
            execSync(`cd "${frontendDir}" && flutter build web`, { stdio: 'inherit' });

            console.log('Cleaning up public folders...');
            await fs.remove(destDir);
            await fs.ensureDir(destDir);
            await fs.remove(rootPublicDir);
            await fs.ensureDir(rootPublicDir);

            console.log('Copying build files to public folders...');
            await fs.copy(srcDir, destDir);
            await fs.copy(srcDir, rootPublicDir);
            console.log('Success! Frontend is now updated in backend/public and /public');
        } else {
            console.log('Using existing build files if available.');
            if (await fs.pathExists(destDir)) {
                console.log('Confirmed: Existing build found in backend/public');
                if (!await fs.pathExists(rootPublicDir)) {
                    console.log('Syncing backend/public to root public...');
                    await fs.copy(destDir, rootPublicDir);
                }
            } else {
                console.warn('Warning: No build found and Flutter is missing.');
            }
        }
    } catch (err) {
        console.error('Error during preparation:', err);
        // Don't exit with error if it's just a flutter build failure in a non-flutter env
        if (process.env.RENDER) {
            console.log('Proceeding with backend deployment on Render...');
        } else {
            process.exit(1);
        }
    }
}

prepare();
