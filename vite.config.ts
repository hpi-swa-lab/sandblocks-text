import { defineConfig } from 'vite';
import path from 'path';
import { cpSync } from 'fs';

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

// Plugin to copy external folder to dist/external
function copyExternal() {
  return {
    name: 'copy-external',
    closeBundle() {
      cpSync('external', 'dist/external', { recursive: true });
    },
  };
}

export default defineConfig({
  base: './',
  publicDir: false,
  plugins: [resolveTsExtensions(), copyExternal()],
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
    lib: {
      entry: {
        lib: 'lib.ts',
      },
      formats: ['es'],
      fileName: () => `sandblocks.js`,
    },
    rollupOptions: {
      external: (id) => {
        return id.includes('/external/');
      },
    },
  },
});
