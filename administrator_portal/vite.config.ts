import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
//import basicSSL from '@vitejs/plugin-basic-ssl'
// https://vite.dev/config/
export default defineConfig({
  //plugins: [react(), basicSSL()],
  plugins: [react()],
  server: {
    host: true,
    port: 5174,
    strictPort: true,
  }
})
