#!/bin/bash

# Smart Plug Traffic Generator
# Simulates TP-Link style smart plug behavior

echo "Starting Smart Plug Traffic Generator - ${DEVICE_MODEL}"
echo "MAC Address: ${DEVICE_MAC}"
echo "Device Type: ${DEVICE_TYPE}"

# Wait for network to be ready
sleep 10

MY_IP=$(hostname -i | awk '{print $1}')
echo "Smart Plug IP: ${MY_IP}"

# Current state variables
PLUG_STATE="ON"
POWER_CONSUMPTION=$((RANDOM % 500 + 100))  # 100-600 watts

# Function to simulate cloud connectivity
simulate_cloud_connection() {
    local cloud_endpoints=("tplinkcloud.com" "kasa.tp-link.com" "tplink.com")
    
    while true; do
        for endpoint in "${cloud_endpoints[@]}"; do
            # Send device status to cloud
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"device_id":"'${DEVICE_MODEL}'","state":"'${PLUG_STATE}'","power":'${POWER_CONSUMPTION}',"timestamp":"'$(date -Iseconds)'"}' \
                >/dev/null 2>&1 || true
            
            # Heartbeat to cloud service
            curl -s --connect-timeout 5 https://${endpoint}/api/heartbeat >/dev/null 2>&1 || true
        done
        
        sleep $((RANDOM % 60 + 30))  # 30-90 seconds
    done
}

# Function to simulate mobile app communication
simulate_app_communication() {
    while true; do
        # App polling for current status
        curl -s --connect-timeout 5 http://kasa.tp-link.com/api/device/status >/dev/null 2>&1 || true
        
        # Simulate receiving commands from app
        if [ $((RANDOM % 20)) -eq 0 ]; then
            if [ "$PLUG_STATE" = "ON" ]; then
                PLUG_STATE="OFF"
                POWER_CONSUMPTION=0
                echo "Plug turned OFF via app"
            else
                PLUG_STATE="ON"
                POWER_CONSUMPTION=$((RANDOM % 500 + 100))
                echo "Plug turned ON via app - Power: ${POWER_CONSUMPTION}W"
            fi
            
            # Acknowledge command
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"command":"state_change","new_state":"'${PLUG_STATE}'","device":"'${DEVICE_MODEL}'"}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 120 + 60))  # 1-3 minutes
    done
}

# Function to simulate energy monitoring
simulate_energy_monitoring() {
    while true; do
        if [ "$PLUG_STATE" = "ON" ]; then
            # Vary power consumption slightly
            POWER_CONSUMPTION=$((POWER_CONSUMPTION + RANDOM % 20 - 10))
            if [ $POWER_CONSUMPTION -lt 50 ]; then
                POWER_CONSUMPTION=50
            elif [ $POWER_CONSUMPTION -gt 800 ]; then
                POWER_CONSUMPTION=800
            fi
        else
            POWER_CONSUMPTION=0
        fi
        
        # Send energy data to cloud
        curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
            -H "Content-Type: application/json" \
            -d '{"energy_reading":{"power":'${POWER_CONSUMPTION}',"voltage":120,"current":'$(echo "scale=2; $POWER_CONSUMPTION/120" | bc 2>/dev/null || echo "1.0")',"device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
            >/dev/null 2>&1 || true
        
        sleep 60  # Every minute
    done
}

# Function to simulate local network discovery
simulate_local_discovery() {
    while true; do
        # Respond to UPnP discovery
        echo "Responding to UPnP discovery requests"
        
        # Broadcast presence on local network
        hping3 -1 -c 1 ${MY_IP%.*}.255 >/dev/null 2>&1 || true
        
        # Look for other smart home devices
        nmap -sn ${MY_IP%.*}.0/24 >/dev/null 2>&1 || true
        
        sleep $((RANDOM % 600 + 300))  # 5-15 minutes
    done
}

# Function to simulate firmware updates
simulate_firmware_updates() {
    while true; do
        # Check for firmware updates
        curl -s --connect-timeout 5 http://update.tplink.com >/dev/null 2>&1 || true
        curl -s --connect-timeout 5 http://firmware.kasasmart.com >/dev/null 2>&1 || true
        
        sleep $((RANDOM % 3600 + 10800))  # 3-4 hours
    done
}

# Function to simulate scheduling
simulate_scheduling() {
    while true; do
        # Check for scheduled operations
        current_hour=$(date +%H)
        
        # Example: Turn off at 11 PM, turn on at 6 AM
        if [ "$current_hour" -eq 23 ] && [ "$PLUG_STATE" = "ON" ]; then
            PLUG_STATE="OFF"
            POWER_CONSUMPTION=0
            echo "Scheduled OFF at 11 PM"
        elif [ "$current_hour" -eq 6 ] && [ "$PLUG_STATE" = "OFF" ]; then
            PLUG_STATE="ON"
            POWER_CONSUMPTION=$((RANDOM % 500 + 100))
            echo "Scheduled ON at 6 AM - Power: ${POWER_CONSUMPTION}W"
        fi
        
        sleep 1800  # Check every 30 minutes
    done
}

# Function to simulate usage statistics
simulate_usage_stats() {
    while true; do
        # Send daily usage statistics
        curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
            -H "Content-Type: application/json" \
            -d '{"daily_stats":{"on_time_hours":'$((RANDOM % 12 + 8))',"total_energy_kwh":'$(echo "scale=2; $(($RANDOM % 10 + 5))/10" | bc 2>/dev/null || echo "0.5")',"device":"'${DEVICE_MODEL}'","date":"'$(date +%Y-%m-%d)'"}}' \
            >/dev/null 2>&1 || true
        
        sleep 86400  # Once per day
    done
}

# Start all processes in background
simulate_cloud_connection &
simulate_app_communication &
simulate_energy_monitoring &
simulate_local_discovery &
simulate_firmware_updates &
simulate_scheduling &
simulate_usage_stats &

# Keep the main process running
while true; do
    echo "Smart Plug ${DEVICE_MODEL} - State: ${PLUG_STATE}, Power: ${POWER_CONSUMPTION}W - $(date)"
    sleep 300  # Status update every 5 minutes
done 