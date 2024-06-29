FROM nginx:alpine

COPY nginx.conf /etc/nginx/nginx.conf
COPY sites-available /etc/nginx/sites-available
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
