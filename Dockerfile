# stage 1

FROM node:alpine AS my-app-build
WORKDIR /app
COPY . .
RUN npm ci && npm run build

# stage 2

FROM nginx:alpine
COPY --from=my-app-build /app/dist/hello-brave-new-world /usr/share/nginx/html
COPY ./nginx-custom.conf /etc/nginx/conf.d/default.conf

