# Utilisation d'une image Debian
FROM debian:buster-slim

# Installation de Nginx
RUN apt update && apt install -y nginx openssl nano && apt clean

# Creation d'un certificat auto-signe (HTTPS)
RUN  openssl req -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=FR/ST=75/L=Paris/O=42Paris/OU=wluong/CN=localhost" -keyout localhost.dev.key -out localhost.dev.crt && \
    mkdir -p etc/ssl/certs/ && \
    mkdir -p etc/ssl/private/ && \
    mv localhost.dev.crt /etc/ssl/certs/ && \
    mv localhost.dev.key /etc/ssl/private/ && \
    chmod 600 /etc/ssl/certs/localhost.dev.crt && \
    chmod 600 /etc/ssl/private/localhost.dev.key


# Copier la configuration nginx personnalisée
COPY ./nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

