import { defineConfig } from 'vite';
import path from 'path';

// Plugin to resolve .ts extensions in imports
function resolveTsExtensions() {
  return {
    name: 'resolve-ts-extensions',
    resolveId(source: string, importer: string | undefined) {
      // Only handle relative imports that end in .ts
      if (source.endsWith('.ts') && importer) {
        const importerDir = path.dirname(importer);
        const resolvedPath = path.resolve(importerDir, source);
        return resolvedPath;
      }
      return null;
    },
  };
}

export default defineConfig({
  plugins: [resolveTsExtensions()],
  resolve: {
    extensions: ['.ts', '.tsx', '.js', '.jsx', '.mjs'],
  },
  server: {
    port: 3000,
    open: true,
  },
  build: {
    target: 'esnext',
    sourcemap: true,
  },
});
