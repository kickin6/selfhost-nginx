FROM nginx:alpine

# Update and install necessary packages using apk
RUN apk update && apk add --no-cache procps net-tools iputils-ping busybox-extras

# Copy configuration files
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./sites-available /etc/nginx/sites-available
RUN mkdir -p /etc/nginx/sites-enabled
COPY ssl /etc/nginx/ssl

# Copy and make the entrypoint script executable
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

