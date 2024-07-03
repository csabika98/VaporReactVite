import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { spawn } from 'child_process';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';

const app = express();

// Convert the URL path to a directory path for __dirname
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Function to dynamically find the project root based on directory name
function findProjectRoot(currentDir, targetFolderName) {
    const root = path.parse(currentDir).root;

    while (currentDir !== root) {
        let possiblePath = path.join(currentDir, targetFolderName);
        if (fs.existsSync(possiblePath)) {
            return currentDir; // Return the directory that contains the target folder
        }
        currentDir = path.dirname(currentDir);
    }

    return null; // or handle this case as appropriate (e.g., throw an error or use a default path)
}

const projectRoot = findProjectRoot(__dirname, 'VaporReactVite');
const VaporProjectPath = path.join(projectRoot, 'VaporReactVite');
console.log(`Building Vapor project at path: ${VaporProjectPath}`);

let VaporProcess;

const runVaporApp = () => {
    VaporProcess = spawn('wsl', ['./run_vapor.sh'], { cwd: VaporProjectPath });
    VaporProcess.stdout.on('data', (data) => console.log(`Vapor: ${data}`));
    VaporProcess.stderr.on('data', (data) => console.error(`Vapor Error: ${data}`));
    VaporProcess.on('close', (code) => {
        console.log(`Vapor process exited with code ${code}`);
    });
};

// Initial build and start
runVaporApp();

// Middleware to log all requests
app.use((req, res, next) => {
    console.log(`Request received: ${req.method} ${req.url}`);
    next();
});

// Proxy configuration to handle API and other requests
app.use('/api/', createProxyMiddleware({
    target: 'http://localhost:8080/', // Correct port
    changeOrigin: true,
    ws: true
}));

app.use('/', createProxyMiddleware({
    target: 'http://localhost:5173', // Assuming React runs on port 5173
    changeOrigin: true,
    ws: false // Enable websocket proxy for hot module replacement
}));

const PORT = 8888;
app.listen(PORT, () => {
    console.log(`Proxy server running on http://localhost:${PORT}`);
});

process.on('exit', () => {
    if (VaporProcess) VaporProcess.kill();
});



