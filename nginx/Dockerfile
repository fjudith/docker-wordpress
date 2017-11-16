FROM nginx:stable

LABEL maintainer="Florian JUDITH <florian.judith.b@gmail.com>"

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
    openssl \
    certbot

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN rm -f /etc/nginx/conf.d/default.conf
RUN rm -f /etc/nginx/conf.d/example_ssl.conf

COPY wordpress.conf /etc/nginx/conf.d/wordpress.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY docker-entrypoint.sh /
RUN chmod +x docker-entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx"]