FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PORT 8000

# Create and set working directory
WORKDIR /app

# Install system dependencies needed for compiling Python packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy backend requirements
COPY backend/requirements.txt /app/

# Install CPU-only PyTorch first to save ~2.5GB, then install other requirements
RUN pip install --no-cache-dir torch==2.3.1 torchvision==0.18.1 --index-url https://download.pytorch.org/whl/cpu \
    && pip install --no-cache-dir -r requirements.txt

# Copy the entire backend folder into the container
COPY backend/ /app/

# Expose the port
EXPOSE 8000

# Start command
CMD daphne -b 0.0.0.0 -p ${PORT:-8000} backend.asgi:application
