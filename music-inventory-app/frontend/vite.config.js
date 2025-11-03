import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react-swc';

export default defineConfig({
  plugins: [react()],
  root: '.',
  build: {
    sourcemap: true, // Generate source maps for debugging
  },
});
