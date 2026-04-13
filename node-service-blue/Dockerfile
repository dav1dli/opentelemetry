FROM node:20-alpine

WORKDIR /app
RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -s /bin/sh -D appuser

COPY package*.json ./

# Zscaler / Proxy workaround
RUN npm config set strict-ssl false && \
    npm install --only=production

COPY . .
RUN chown -R appuser:appgroup /app

USER 1001
ENV NODE_ENV=production
ENV OTEL_SERVICE_NAME=node-service-blue
ENV OTEL_TRACES_EXPORTER=otlp
ENV OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"
ENV NODE_OPTIONS="--require @opentelemetry/auto-instrumentations-node/register"
EXPOSE 3020
CMD ["node", "./bin/www"]