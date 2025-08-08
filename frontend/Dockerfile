FROM node:18-alpine as build

# Establecer directorio de trabajo
WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN echo '#!/bin/sh' > /docker-entrypoint.d/30-envsubst.sh && \
    echo 'envsubst < /usr/share/nginx/html/env-config.js.template > /usr/share/nginx/html/env-config.js' >> /docker-entrypoint.d/30-envsubst.sh && \
    chmod +x /docker-entrypoint.d/30-envsubst.sh

RUN echo 'window.ENV = { REACT_APP_API_URL: "${REACT_APP_API_URL}" };' > /usr/share/nginx/html/env-config.js.template

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]