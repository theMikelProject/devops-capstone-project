# ────────────────────────────────────────────────────────────────
# 1. Base image ─ Python 3.9 slim
# ────────────────────────────────────────────────────────────────
FROM python:3.9-slim

# ────────────────────────────────────────────────────────────────
# 2. Working directory inside the container
# ────────────────────────────────────────────────────────────────
WORKDIR /app

# ────────────────────────────────────────────────────────────────
# 3. Install Python dependencies
#   copy only requirements first for layer-cache efficiency
# ────────────────────────────────────────────────────────────────
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip wheel \
 && pip install --no-cache-dir -r requirements.txt

# ────────────────────────────────────────────────────────────────
# 4. Copy application source
# ────────────────────────────────────────────────────────────────
COPY service ./service

# ────────────────────────────────────────────────────────────────
# 5. Create non-root user and adjust ownership
# ────────────────────────────────────────────────────────────────
RUN adduser --disabled-password --gecos '' theia \
 && chown -R theia:theia /app
USER theia

# ────────────────────────────────────────────────────────────────
# 6. Network and runtime settings
# ────────────────────────────────────────────────────────────────
EXPOSE 8080
CMD ["gunicorn", "--bind=0.0.0.0:8080", "--log-level=info", "service:app"]
