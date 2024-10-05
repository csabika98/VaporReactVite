import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { spawn } from 'child_process';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';
import os from 'os';

const app = express();


const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);


function findProjectRoot(currentDir, targetFolderName) {
    const root = path.parse(currentDir).root;

    while (currentDir !== root) {
        let possiblePath = path.join(currentDir, targetFolderName);
        if (fs.existsSync(possiblePath)) {
            return currentDir; 
        }
        currentDir = path.dirname(currentDir);
    }

    return null; 
}

const projectRoot = findProjectRoot(__dirname, 'VaporReactVite');
const VaporProjectPath = path.join(projectRoot, 'VaporReactVite');
console.log(`Building Vapor project at path: ${VaporProjectPath}`);

let VaporProcess;

const runVaporApp = () => {
    let command, args;
    console.log(os.platform())
    if (os.platform() === 'linux') {
        // If you're on Ubuntu or other Linux systems, use bash
        command = 'bash';
        args = ['./run_vapor.sh'];
    } else if (os.platform() === 'win32') {
        // If you're on Windows and using WSL
        command = 'wsl';
        args = ['./run_vapor.sh'];
    }

    VaporProcess = spawn(command, args, { cwd: VaporProjectPath });
    VaporProcess.stdout.on('data', (data) => console.log(`Vapor: ${data}`));
    VaporProcess.stderr.on('data', (data) => console.error(`Vapor: ${data}`));
    VaporProcess.on('close', (code) => {
        console.log(`Vapor process exited with code ${code}`);
    });
};


runVaporApp();


app.use((req, res, next) => {
    console.log(`Request received: ${req.method} ${req.url}`);
    next();
});


app.use('/api/', createProxyMiddleware({
    target: 'http://localhost:1337/', 
    changeOrigin: true,
    ws: true
}));

app.use('/', createProxyMiddleware({
    target: 'http://localhost:5173',
    changeOrigin: true,
    ws: false 
}));

const PORT = 8888;
app.listen(PORT, () => {
    console.log(`Proxy server running on http://localhost:${PORT}`);
});

process.on('exit', () => {
    if (VaporProcess) VaporProcess.kill();
});



