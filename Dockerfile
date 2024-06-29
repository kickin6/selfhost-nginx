# Use the official Nginx image from the Docker Hub
FROM nginx:latest

# Copy the custom Nginx configuration file to the appropriate directory in the container
COPY nginx.conf /etc/nginx/nginx.conf

# (Optional) Copy SSL certificates if you're using SSL
COPY ssl/cert.pem /etc/nginx/ssl/cert.pem
COPY ssl/key.pem /etc/nginx/ssl/key.pem
