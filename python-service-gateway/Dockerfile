# Use a slim version of Python
FROM python:3.12-slim
WORKDIR /app
RUN useradd -m -u 1001 appuser
COPY . .
RUN pip install --no-cache-dir -r requirements.txt \
  && chown -R appuser:appuser /app
USER 1001
EXPOSE 5000

# Start the app
CMD ["python", "app.py"]