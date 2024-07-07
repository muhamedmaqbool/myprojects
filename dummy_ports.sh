#!/bin/bash

# List of ports to run services on
PORTS=(8090 6002 9100 9182)

# Start services in the background
for port in "${PORTS[@]}"; do
    screen -S "service_$port" -dm bash -c "python3 -m http.server $port; exec bash"
done

echo "Services started on ports: ${PORTS[@]}"

