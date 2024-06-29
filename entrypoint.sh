#!/bin/sh

rm -f /etc/nginx/sites-enabled/*

if [ "$VIDEO" = "1" ]; then
    envsubst < /etc/nginx/sites-available/selfhost-video.conf.template > /etc/nginx/sites-available/selfhost-video.conf
    ln -sf /etc/nginx/sites-available/selfhost-video.conf /etc/nginx/sites-enabled/selfhost-video.conf
fi

if [ "$IMAGE" = "1" ]; then
    envsubst < /etc/nginx/sites-available/selfhost-image.conf.template > /etc/nginx/sites-available/selfhost-image.conf
    ln -sf /etc/nginx/sites-available/selfhost-image.conf /etc/nginx/sites-enabled/selfhost-image.conf
fi

if [ "$SPEECH" = "1" ]; then
    envsubst < /etc/nginx/sites-available/selfhost-speech.conf.template > /etc/nginx/sites-available/selfhost-speech.conf
    ln -sf /etc/nginx/sites-available/selfhost-speech.conf /etc/nginx/sites-enabled/selfhost-speech.conf
fi

if [ "$LLM" = "1" ]; then
    envsubst < /etc/nginx/sites-available/selfhost-llm.conf.template > /etc/nginx/sites-available/selfhost-llm.conf
    ln -sf /etc/nginx/sites-available/selfhost-llm.conf /etc/nginx/sites-enabled/selfhost-llm.conf
fi

# Start Nginx
nginx -g 'daemon off;'
