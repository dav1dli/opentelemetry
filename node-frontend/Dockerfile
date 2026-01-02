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
EXPOSE 8080
CMD ["node", "./bin/www"]