FROM node:25-alpine3.22 AS builder
WORKDIR /app/frontend

# COPY /package.json package-lock.json 
# update OS packages to pick up security fixes, then install dependencies
#RUN npm update && apk upgrade --no-cache && npm ci --omit=dev

COPY package*.json ./
RUN npm install

# Copy source files
COPY . .

RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/frontend/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

