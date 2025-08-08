# Etapa de construcción
FROM node:18-alpine as build

# Establecer directorio de trabajo
WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias
RUN npm ci

# Copiar código fuente
COPY . .

# Construir la aplicación
RUN npm run build

# Etapa de producción
FROM nginx:alpine

# Copiar archivos construidos desde la etapa anterior
COPY --from=build /app/build /usr/share/nginx/html

# Copiar configuración personalizada de nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Crear script para sustituir variables de entorno
RUN echo '#!/bin/sh' > /docker-entrypoint.d/30-envsubst.sh && \
    echo 'envsubst < /usr/share/nginx/html/env-config.js.template > /usr/share/nginx/html/env-config.js' >> /docker-entrypoint.d/30-envsubst.sh && \
    chmod +x /docker-entrypoint.d/30-envsubst.sh

# Crear plantilla de configuración del entorno
RUN echo 'window.ENV = { REACT_APP_API_URL: "${REACT_APP_API_URL}" };' > /usr/share/nginx/html/env-config.js.template

# Exponer puerto 80
EXPOSE 80

# Comando para iniciar nginx
CMD ["nginx", "-g", "daemon off;"]