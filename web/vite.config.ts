import react from "@vitejs/plugin-react"
import { defineConfig } from "vite"

export default defineConfig({
  plugins: [react()],
  server: {
    port: 35173,
    proxy: {
      "/api": "http://localhost:37000",
    },
  },
  build: {
    outDir: "dist",
    rollupOptions: {
      output: {
        entryFileNames: "assets/[name]-[hash]-v2.js",
      },
    },
  },
})
