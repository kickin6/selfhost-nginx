FROM nginx:alpine

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./sites-available /etc/nginx/sites-available
RUN mkdir -p /etc/nginx/sites-enabled
COPY ssl /etc/nginx/ssl

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
