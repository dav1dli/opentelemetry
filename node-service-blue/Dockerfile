FROM node:20-slim
WORKDIR /app
RUN groupadd -g 1001 appuser && \
    useradd -r -u 1001 -g appuser appuser
COPY package*.json ./

# Zscaler workaround: disable strict-ssl for the npm install step
RUN npm config set strict-ssl false && \
    npm install --only=production
COPY . .
RUN chown -R appuser:appuser /app

USER 1001
ENV PORT=8080
EXPOSE 3020
CMD ["node", "./bin/www"]