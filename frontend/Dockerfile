# Dev Stage
FROM node:18-alpine AS dev
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]

# Production Build Stage
FROM node:18-alpine AS build
WORKDIR /app
COPY . .
RUN npm install && npm run build

# Serve with Nginx
FROM nginx:alpine AS prod
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
