#!/usr/bin/env bashio

# Start NGiNX
/etc/services.d/nginx/run &
bashio::log.info "Starting NGinx..."

exec nginx