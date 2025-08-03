FROM python:3.13-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install Python dependencies with uv
RUN uv sync --frozen

# Copy project files
COPY . .

# Collect static files
RUN uv run python manage.py collectstatic --noinput

# Run migrations and start server
CMD uv run python manage.py migrate && \
    uv run python manage.py runserver 0.0.0.0:$PORT