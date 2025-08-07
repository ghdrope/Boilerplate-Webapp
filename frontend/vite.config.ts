/**
 * Vite configuration file
 *
 * - React support (Fast Refresh)
 * - Dev server on port 3000
 * - API proxy to localhost:8080
 * - Path alias @ -> /src
 */

import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { fileURLToPath, URL } from 'url';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000, // Dev server port
    // Proxy API calls to backend server during development to avoid CORS issues
    proxy: {
      '/api': {
        target: 'http://localhost:8080', // Backend server address
        changeOrigin: true, // Modifies the origin of the host header to the target URL
        secure: false, // If backend uses HTTPS with self-signed certs, set to false
      },
    },
  },
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
    // Allows importing files without specifying these extensions explicitly
    extensions: ['.tsx', '.ts', '.js'],
  },
});
