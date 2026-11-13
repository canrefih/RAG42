FROM node:26.13.1-alpine AS build

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:1.31.8-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
RUN mkdir -p /tmp/nginx \
    && chown -R nginx:nginx /tmp/nginx /usr/share/nginx/html \
    && chmod 644 /etc/nginx/conf.d/default.conf \
    && sed -i '/^user /d; s|/var/run/nginx.pid|/tmp/nginx/nginx.pid|g; s|/run/nginx.pid|/tmp/nginx/nginx.pid|g' /etc/nginx/nginx.conf

USER nginx
EXPOSE 3000
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
