FROM node:20-alpine
RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -s /bin/sh -D appuser
WORKDIR /app
COPY node-service-blue/package*.json ./node-service-blue/
COPY opentelemetry-js/package*.json ./opentelemetry-js/
RUN cd node-service-blue && npm install --production
RUN cd opentelemetry-js && npm install --production
COPY node-service-blue/ ./node-service-blue/
COPY opentelemetry-js/ ./opentelemetry-js/
RUN chown -R appuser:appgroup /app

USER 1001
WORKDIR /app/node-service-blue
ENV PORT=3020
ENV NODE_ENV=production
EXPOSE 3020
CMD ["node", "./bin/www"]