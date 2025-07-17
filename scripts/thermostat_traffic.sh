#!/bin/bash

# Smart Thermostat Traffic Generator
# Simulates Nest-style smart thermostat behavior

echo "Starting Smart Thermostat Traffic Generator - ${DEVICE_MODEL}"
echo "MAC Address: ${DEVICE_MAC}"
echo "Device Type: ${DEVICE_TYPE}"

# Wait for network to be ready
sleep 10

MY_IP=$(hostname -i | awk '{print $1}')
echo "Thermostat IP: ${MY_IP}"

# Function to simulate cloud connectivity
simulate_cloud_sync() {
    local cloud_endpoints=("nest.com" "google.com" "googleapis.com")
    
    while true; do
        for endpoint in "${cloud_endpoints[@]}"; do
            # Regular status updates to cloud
            curl -s --connect-timeout 5 https://${endpoint} >/dev/null 2>&1 || true
            
            # Send temperature readings
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"temperature":'$((RANDOM % 10 + 65))',"humidity":'$((RANDOM % 20 + 40))',"device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}' \
                >/dev/null 2>&1 || true
        done
        
        sleep $((RANDOM % 120 + 180))  # 3-5 minutes
    done
}

# Function to simulate weather data fetching
simulate_weather_check() {
    while true; do
        # Fetch weather data for smart scheduling
        local weather_apis=("openweathermap.org" "weather.com" "weatherapi.com")
        local api=${weather_apis[$RANDOM % ${#weather_apis[@]}]}
        
        curl -s --connect-timeout 5 http://${api} >/dev/null 2>&1 || true
        
        sleep $((RANDOM % 1800 + 1800))  # 30-60 minutes
    done
}

# Function to simulate mobile app connectivity
simulate_mobile_app() {
    while true; do
        # Respond to mobile app requests
        local mobile_endpoints=("nest.com" "nestlabs.com")
        
        for endpoint in "${mobile_endpoints[@]}"; do
            # App polling for status
            curl -s --connect-timeout 5 https://${endpoint}/api/status >/dev/null 2>&1 || true
            
            # Send current settings
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"current_temp":'$((RANDOM % 5 + 68))',"target_temp":'$((RANDOM % 6 + 70))',"mode":"auto","device":"'${DEVICE_MODEL}'"}' \
                >/dev/null 2>&1 || true
        done
        
        sleep $((RANDOM % 300 + 60))  # 1-6 minutes
    done
}

# Function to simulate firmware updates
simulate_updates() {
    while true; do
        # Check for firmware updates
        curl -s --connect-timeout 5 http://software-update.nest.com >/dev/null 2>&1 || true
        curl -s --connect-timeout 5 http://update.nestlabs.com >/dev/null 2>&1 || true
        
        sleep $((RANDOM % 7200 + 21600))  # 6-8 hours
    done
}

# Function to simulate energy usage reporting
simulate_energy_reports() {
    while true; do
        # Send energy usage data
        curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
            -H "Content-Type: application/json" \
            -d '{"energy_usage":'$((RANDOM % 100 + 50))',"runtime_minutes":'$((RANDOM % 120 + 30))',"device":"'${DEVICE_MODEL}'","report_type":"hourly"}' \
            >/dev/null 2>&1 || true
        
        sleep 3600  # Every hour
    done
}

# Function to simulate local network discovery
simulate_local_discovery() {
    while true; do
        # mDNS/Bonjour-style discovery
        nslookup _googlecast._tcp.local >/dev/null 2>&1 || true
        nslookup _nest._tcp.local >/dev/null 2>&1 || true
        
        # Scan for other smart home devices
        nmap -sn ${MY_IP%.*}.0/24 >/dev/null 2>&1 || true
        
        sleep $((RANDOM % 1800 + 3600))  # 1-2 hours
    done
}

# Start all processes in background
simulate_cloud_sync &
simulate_weather_check &
simulate_mobile_app &
simulate_updates &
simulate_energy_reports &
simulate_local_discovery &

# Keep the main process running
while true; do
    echo "Thermostat ${DEVICE_MODEL} active - Temp: $((RANDOM % 5 + 68))°F - $(date)"
    sleep 300  # Status update every 5 minutes
done 