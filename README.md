# Journey-1 Ecosystem

This repository contains the complete "Journey-1" suite, including the mobile measurement app, the administrative portal, and the supporting backend.

## Project Structure

-   **/backend**: Django (Python) API with ASGI/WebSocket support. Connects to MongoDB.
-   **/administrator_portal**: React (Vite) dashboard for managing applications and users.
-   **/journey-1**: React (Vite) customer-facing portal for document uploads.
-   **/demo_flutter_app**: Flutter mobile application with AR measurement capabilities.

## Deployment Quick-Start

For detailed instructions, see the [Hosting Plan]

### 1. Backend (Render)
- **Runtime**: Python 3
- **Root Directory**: `backend`
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `daphne -b 0.0.0.0 -p $PORT backend.asgi:application`

### 2. Frontends (Vercel)
- **Framework Preset**: Vite
- **Root Directories**: `administrator_portal` and `journey-1`
- **Build Command**: `npm run build`
- **Environment Variable**: Set `VITE_API_URL` to your backend Render URL.

## Features
- **AR Measurement**: Precise 3D-to-2D projection with zero vertical offset.
- **Surface Tracking**: Adaptive feature-point visualization (Yellow dots) for robust tracking.
- **Real-time Updates**: Real-time journey completion status via WebSockets.
- **Full-Screen Immersive UI**: Optimized for mobile and desktop displays.
