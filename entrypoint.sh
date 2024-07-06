#!/bin/sh

echo "Running entrypoint.sh"

# Source the .env file if it exists
if [ -f /etc/nginx/sites-available/.env ]; then
  export $(cat /etc/nginx/sites-available/.env | sed 's/#.*//g' | xargs)
fi

# Ensure PROFILE environment variable is set
if [ -z "$PROFILE" ]; then
  echo "PROFILE environment variable is not set. Using default configuration."
  PROFILE="default"
fi

echo "PROFILE: $PROFILE"

# Split the PROFILE variable into an array
PROFILES=$(echo "$PROFILE" | tr ',' ' ')
echo "Profiles: $PROFILES"

# Function to process the template file and create the final config
process_template() {
  local template_file=$1
  local output_file="/etc/nginx/sites-enabled/$(basename "$template_file" .template)"

  echo "Processing template: $template_file -> $output_file"
  envsubst '$SSL_CERTIFICATE $SSL_CERTIFICATE_KEY $UPSTREAM_IMAGE' < "$template_file" > "$output_file"
  echo "Created config: $output_file"
}

# Function to process the IP allow list template
process_allow_ips() {
  local template_file="/etc/nginx/sites-available/allow_ips.conf.template"
  local output_file="/etc/nginx/allow_ips.conf"

  # Transform the NGINX_ALLOW_IPS into Nginx allow directives
  local ip_list=""
  for ip in $(echo "$NGINX_ALLOW_IPS" | tr ',' ' '); do
    ip_list="$ip_list\nallow $ip;"
  done

  echo "Processing IP allow list"
  envsubst '$ip_list' < "$template_file" | sed "s/\${NGINX_ALLOW_IPS}/$ip_list/" > "$output_file"
  echo "Created IP allow list config: $output_file"
}

# Clear existing configs in sites-enabled
rm -f /etc/nginx/sites-enabled/*

# Process the allow IPs configuration
process_allow_ips

# Process each profile template
any_processed=false
for profile in $PROFILES; do
  case "$profile" in
    llm)
      process_template "/etc/nginx/sites-available/selfhost-llm.conf.template"
      any_processed=true
      ;;
    speech)
      process_template "/etc/nginx/sites-available/selfhost-speech.conf.template"
      any_processed=true
      ;;
    video)
      process_template "/etc/nginx/sites-available/selfhost-video.conf.template"
      any_processed=true
      ;;
    image)
      process_template "/etc/nginx/sites-available/selfhost-image.conf.template"
      any_processed=true
      ;;
    default)
      echo "Using default configuration"
      ;;
    *)
      echo "Invalid PROFILE: $profile. Skipping."
      ;;
  esac
done

# If no profiles were processed, use the default configuration
if [ "$any_processed" = false ]; then
  echo "No profiles processed, using default configuration"
  cp /etc/nginx/sites-available/000-default.conf /etc/nginx/sites-enabled/000-default.conf
fi

# Start Nginx in the foreground
nginx -g 'daemon off;'

