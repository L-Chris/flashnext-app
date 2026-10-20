// Read-only bridge for an emulator without a Tailscale route.
// node tool/study_preview_proxy.mjs
// adb reverse tcp:18765 tcp:18765
// Integration build: --dart-define=STUDY_UPSTREAM=http://127.0.0.1:18765
import http from 'node:http';
import https from 'node:https';

http.createServer((request, response) => {
  const path = request.url;
  const allowed = (request.method === 'POST' && path === '/api/content/preview') ||
    (request.method === 'GET' && path.startsWith('/api/content/assets/') && !path.includes('..'));
  if (!allowed || Number(request.headers['content-length'] ?? 0) > 262144) {
    response.writeHead(403).end();
    return;
  }
  const chunks = [];
  let size = 0;
  request.on('data', chunk => {
    size += chunk.length;
    if (size > 262144) request.destroy();
    else chunks.push(chunk);
  });
  request.on('end', () => {
    const body = Buffer.concat(chunks);
    const upstream = https.request({
      hostname: 'mem.home.rethinkos.com',
      path,
      method: request.method,
      headers: { 'content-type': 'application/json', 'content-length': body.length },
      timeout: 20000,
    }, result => {
      console.log(`${request.method} ${path} ${result.statusCode}`);
      response.writeHead(result.statusCode, {
        'content-type': result.headers['content-type'] ?? 'application/octet-stream',
      });
      result.pipe(response);
    });
    upstream.on('timeout', () => upstream.destroy(new Error('upstream timeout')));
    upstream.on('error', error => {
      console.error(error.message);
      if (!response.headersSent) response.writeHead(502);
      response.end();
    });
    upstream.end(body);
  });
}).listen(18765, '127.0.0.1', () => console.log('Read-only preview bridge: 127.0.0.1:18765'));
