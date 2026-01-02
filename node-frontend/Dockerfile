FROM node:20-alpine
RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -s /bin/sh -D appuser
WORKDIR /app
COPY node-frontend/package*.json ./node-frontend/
COPY opentelemetry-js/package*.json ./opentelemetry-js/
RUN cd node-frontend && npm install --production
RUN cd opentelemetry-js && npm install --production
COPY node-frontend/ ./node-frontend/
COPY opentelemetry-js/ ./opentelemetry-js/
RUN chown -R appuser:appgroup /app

USER 1001
WORKDIR /app/node-frontend
ENV PORT=8080
ENV NODE_ENV=production
EXPOSE 8080
CMD ["node", "./bin/www"]