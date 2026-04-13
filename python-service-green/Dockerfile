FROM python:3.12-slim
WORKDIR /app
RUN useradd -m -u 1001 appuser

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN chown -R appuser:appuser /app

USER 1001
EXPOSE 5001

# Start the app with OTel auto-instrumentation
CMD ["opentelemetry-instrument", "python", "app.py"]