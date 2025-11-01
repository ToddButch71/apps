FROM node:24-alpine AS builder
WORKDIR /app/frontend

# COPY /package.json package-lock.json 
# update OS packages to pick up security fixes, then install dependencies
#RUN npm update && apk upgrade --no-cache && npm ci --omit=dev

COPY package*.json ./
RUN npm install

# Copy source files
COPY . .

RUN npm run build

FROM nginx:1-alpine-slim
COPY --from=builder /app/frontend/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

