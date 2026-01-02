# Use a lightweight Node image
FROM node:20-alpine
RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -s /bin/sh -D appuser
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
RUN chown -R appuser:appgroup /app

USER 1001
ENV PORT=8080
ENV NODE_ENV=production
ENV OTEL_SERVICE_NAME=node-frontend
ENV OTEL_TRACES_EXPORTER=otlp
ENV OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"
ENV NODE_OPTIONS="--require @opentelemetry/auto-instrumentations-node/register"
EXPOSE 8080
CMD ["node", "./bin/www"]