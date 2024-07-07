FROM nginx:latest

# Copy custom configuration files from the current directory
COPY nginx.conf /etc/nginx/nginx.conf
COPY allowed_ips.conf /etc/nginx/allowed_ips.conf

# Copy SSL certificates
COPY ssl /etc/nginx/ssl

CMD ["nginx", "-g", "daemon off;"]

