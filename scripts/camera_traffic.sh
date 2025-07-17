#!/bin/bash

# Smart Camera Traffic Generator
# Simulates Hikvision-style IP camera behavior

echo "Starting Smart Camera Traffic Generator - ${DEVICE_MODEL}"
echo "MAC Address: ${DEVICE_MAC}"
echo "Device Type: ${DEVICE_TYPE}"

# Wait for network to be ready
sleep 10

# Get our IP address
MY_IP=$(hostname -i | awk '{print $1}')
echo "Camera IP: ${MY_IP}"

# Function to simulate camera heartbeat to NVR/cloud
simulate_heartbeat() {
    # Common camera management ports
    local ports=(80 554 8000 8080 443)
    local targets=("8.8.8.8" "1.1.1.1" "google.com" "amazonaws.com")
    
    while true; do
        for target in "${targets[@]}"; do
            # HTTP requests (camera status updates)
            curl -s --connect-timeout 5 http://${target} >/dev/null 2>&1 || true
            sleep $((RANDOM % 30 + 30))  # 30-60 seconds
            
            # RTSP-like traffic simulation
            nc -w 3 ${target} 554 >/dev/null 2>&1 || true
            sleep $((RANDOM % 60 + 60))  # 1-2 minutes
        done
    done
}

# Function to simulate video streaming
simulate_streaming() {
    while true; do
        # Simulate high bandwidth video upload (to cloud storage)
        local cloud_ips=("52.84.0.0" "13.107.42.14" "23.20.239.12")
        local cloud_ip=${cloud_ips[$RANDOM % ${#cloud_ips[@]}]}
        
        # Generate sustained traffic to simulate video upload
        timeout 120 iperf3 -c ${cloud_ip} -p 5201 -t 60 >/dev/null 2>&1 || true
        
        # Rest period between uploads
        sleep $((RANDOM % 300 + 300))  # 5-10 minutes
    done
}

# Function to simulate motion detection events
simulate_motion_events() {
    while true; do
        # Random motion detection events
        if [ $((RANDOM % 10)) -eq 0 ]; then
            echo "Motion detected - sending alerts"
            
            # Send notifications (HTTP POST to cloud services)
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"event":"motion","camera":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}' \
                >/dev/null 2>&1 || true
            
            # Higher bandwidth during motion (more detailed recording)
            timeout 60 hping3 -i u100 google.com >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 120 + 60))  # 1-3 minutes between checks
    done
}

# Function to simulate firmware updates and management
simulate_management() {
    while true; do
        # Check for firmware updates (every few hours)
        curl -s --connect-timeout 5 http://firmware.hikvision.com >/dev/null 2>&1 || true
        curl -s --connect-timeout 5 http://update.hikvision.com >/dev/null 2>&1 || true
        
        # NTP sync
        nslookup pool.ntp.org >/dev/null 2>&1 || true
        
        sleep $((RANDOM % 3600 + 7200))  # 2-3 hours
    done
}

# Start all processes in background
simulate_heartbeat &
simulate_streaming &
simulate_motion_events &
simulate_management &

# Keep the main process running
while true; do
    echo "Camera ${DEVICE_MODEL} active - $(date)"
    sleep 300  # Status update every 5 minutes
done 