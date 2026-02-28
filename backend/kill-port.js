const { exec } = require('child_process');

const killPort = (port) => {
    const cmd = process.platform === 'win32'
        ? `netstat -ano | findstr :${port}`
        : `lsof -i tcp:${port} | grep LISTEN | awk '{print $2}'`;

    exec(cmd, (err, stdout) => {
        if (stdout) {
            const lines = stdout.trim().split('\n');
            const pids = lines.map(line => {
                const parts = line.trim().split(/\s+/);
                return parts[parts.length - 1]; // PID is usually the last part on Windows
            }).filter(pid => pid && pid !== '0' && !isNaN(pid));

            const uniquePids = [...new Set(pids)];

            if (uniquePids.length > 0) {
                console.log(`Killing processes using port ${port}: ${uniquePids.join(', ')}`);
                uniquePids.forEach(pid => {
                    process.kill(pid, 'SIGKILL');
                });
            } else {
                console.log(`No processes found using port ${port}.`);
            }
        } else {
            console.log(`Port ${port} is clear.`);
        }
    });
};

const port = process.env.PORT || 5000;
killPort(port);
