const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

// Serve static files
app.use(express.static('public'));

// Basic route
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Authentik Deployment</title>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                max-width: 800px;
                margin: 0 auto;
                padding: 2rem;
                line-height: 1.6;
                color: #333;
            }
            .header {
                text-align: center;
                margin-bottom: 2rem;
                padding: 2rem;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border-radius: 10px;
            }
            .status {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                gap: 1rem;
                margin: 2rem 0;
            }
            .card {
                padding: 1.5rem;
                border: 1px solid #e1e5e9;
                border-radius: 8px;
                background: #f8f9fa;
            }
            .card h3 {
                margin-top: 0;
                color: #495057;
            }
            .badge {
                display: inline-block;
                padding: 0.25rem 0.5rem;
                font-size: 0.875rem;
                font-weight: 500;
                border-radius: 4px;
                background: #28a745;
                color: white;
            }
            .links {
                margin-top: 2rem;
            }
            .links a {
                display: inline-block;
                margin: 0.5rem 1rem 0.5rem 0;
                padding: 0.75rem 1.5rem;
                background: #007bff;
                color: white;
                text-decoration: none;
                border-radius: 5px;
                transition: background 0.3s;
            }
            .links a:hover {
                background: #0056b3;
            }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>🔐 Authentik Deployment</h1>
            <p>Production-ready identity provider with GitOps automation</p>
        </div>

        <div class="status">
            <div class="card">
                <h3>📊 Deployment Status</h3>
                <p><span class="badge">Ready</span></p>
                <p>All components configured and ready for deployment</p>
            </div>

            <div class="card">
                <h3>🏗️ Architecture</h3>
                <ul>
                    <li>Docker Compose (Local)</li>
                    <li>Kubernetes (Production)</li>
                    <li>Helm Charts</li>
                    <li>ArgoCD GitOps</li>
                </ul>
            </div>

            <div class="card">
                <h3>🔧 Components</h3>
                <ul>
                    <li>Authentik Server</li>
                    <li>Authentik Worker</li>
                    <li>PostgreSQL Database</li>
                    <li>Redis Cache</li>
                    <li>Nginx Proxy</li>
                </ul>
            </div>

            <div class="card">
                <h3>🌿 Branches</h3>
                <ul>
                    <li><strong>main</strong>: Production</li>
                    <li><strong>develop</strong>: Staging</li>
                    <li><strong>sre</strong>: Infrastructure</li>
                </ul>
            </div>
        </div>

        <div class="links">
            <a href="https://github.com/nolet7/authentik-bobo" target="_blank">📁 GitHub Repository</a>
            <a href="https://goauthentik.io/docs/" target="_blank">📚 Authentik Docs</a>
            <a href="https://argo-cd.readthedocs.io/" target="_blank">🔄 ArgoCD Docs</a>
        </div>

        <div style="margin-top: 3rem; padding: 1rem; background: #e9ecef; border-radius: 5px;">
            <h3>🚀 Quick Start</h3>
            <pre><code># Local development
docker-compose up -d

# Production deployment
git push origin main</code></pre>
        </div>
    </body>
    </html>
  `);
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// API endpoint for deployment info
app.get('/api/info', (req, res) => {
  res.json({
    name: 'Authentik Deployment',
    version: '1.0.0',
    components: [
      'Authentik Server',
      'Authentik Worker', 
      'PostgreSQL',
      'Redis',
      'Nginx'
    ],
    branches: ['main', 'develop', 'sre'],
    status: 'ready'
  });
});

app.listen(port, () => {
  console.log(`🔐 Authentik Deployment Server running on port ${port}`);
  console.log(`📊 Health check: http://localhost:${port}/health`);
  console.log(`🌐 Web interface: http://localhost:${port}`);
});

module.exports = app;