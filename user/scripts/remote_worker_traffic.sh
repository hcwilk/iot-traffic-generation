#!/bin/bash

# Remote Worker Traffic Generator
# Simulates heavy web usage, video calls, cloud services typical of remote workers

echo "Starting Remote Worker Traffic Generator - ${USER_NAME}"
echo "User ID: ${USER_ID}"
echo "Department: ${DEPARTMENT}"
echo "MAC Address: ${DEVICE_MAC}"

# Source firewall API utilities
source /app/scripts/firewall_api_utils.sh

# Wait for network to be ready
sleep 15

# Get our IP address
MY_IP=$(hostname -i | awk '{print $1}')
echo "Remote Worker IP: ${MY_IP}"

# Register user with firewall
register_user_with_firewall "$USER_ID" "$USER_NAME" "$MY_IP" "$DEPARTMENT" "$DEVICE_MAC"
register_ip_user_mapping "$USER_ID" "$MY_IP"

# Setup cleanup on exit
trap 'cleanup_user_registration "$USER_ID"' EXIT

# Function to simulate video conferencing traffic
simulate_video_calls() {
    local platforms=("zoom.us" "teams.microsoft.com" "meet.google.com" "webex.cisco.com")
    
    while true; do
        # Random video call session (30-120 minutes)
        local duration=$((RANDOM % 5400 + 1800))  # 30-120 minutes
        local platform=${platforms[$RANDOM % ${#platforms[@]}]}
        
        echo "Starting video call session with $platform for $((duration/60)) minutes"
        
        # High bandwidth usage during call (simulated with iperf3 to cloud endpoints)
        timeout $duration iperf3 -c 8.8.8.8 -p 5201 -t $duration >/dev/null 2>&1 &
        
        # Concurrent web browsing during call
        for i in {1..5}; do
            curl -s --connect-timeout 5 "https://${platform}" >/dev/null 2>&1 &
            sleep $((RANDOM % 60 + 30))
        done
        
        # Wait for call to end
        wait
        
        # Break between calls (15-60 minutes)
        local break_time=$((RANDOM % 2700 + 900))
        echo "Call ended, next call in $((break_time/60)) minutes"
        sleep $break_time
    done
}

# Function to simulate cloud storage sync
simulate_cloud_sync() {
    local services=("dropbox.com" "drive.google.com" "onedrive.live.com" "box.com")
    
    while true; do
        local service=${services[$RANDOM % ${#services[@]}]}
        echo "Syncing with $service"
        
        # Simulate file uploads/downloads
        for i in {1..3}; do
            # Upload simulation
            timeout 60 iperf3 -c 1.1.1.1 -p 5202 -t 30 >/dev/null 2>&1 &
            
            # API calls for sync status
            curl -s --connect-timeout 5 "https://${service}" >/dev/null 2>&1
            sleep $((RANDOM % 30 + 15))
        done
        
        # Sync interval (every 10-30 minutes)
        sleep $((RANDOM % 1200 + 600))
    done
}

# Function to simulate web browsing
simulate_web_browsing() {
    local sites=("stackoverflow.com" "github.com" "docs.microsoft.com" "aws.amazon.com" 
                 "atlassian.com" "slack.com" "notion.so" "figma.com")
    
    while true; do
        local site=${sites[$RANDOM % ${#sites[@]}]}
        
        # Browse site with multiple requests
        for i in {1..3}; do
            curl -s --connect-timeout 10 "https://${site}" >/dev/null 2>&1
            sleep $((RANDOM % 5 + 1))
        done
        
        # Time between browsing sessions
        sleep $((RANDOM % 300 + 60))  # 1-5 minutes
    done
}

# Function to simulate development tools traffic
simulate_dev_traffic() {
    local repos=("api.github.com" "registry.npmjs.org" "pypi.org" "hub.docker.com")
    
    while true; do
        local repo=${repos[$RANDOM % ${#repos[@]}]}
        echo "Accessing development resource: $repo"
        
        # Simulate git operations, package downloads
        for i in {1..2}; do
            curl -s --connect-timeout 10 "https://${repo}" >/dev/null 2>&1
            sleep $((RANDOM % 10 + 5))
        done
        
        # Development work cycles (every 20-45 minutes)
        sleep $((RANDOM % 1500 + 1200))
    done
}

# Function to send heartbeat to firewall
heartbeat_loop() {
    while true; do
        send_user_heartbeat "$USER_ID" "$MY_IP"
        sleep 300  # Every 5 minutes
    done
}

echo "Remote worker ${USER_NAME} is online and working from IP ${MY_IP}"

# Start all traffic simulation functions in background
simulate_video_calls &
simulate_cloud_sync &
simulate_web_browsing &
simulate_dev_traffic &
heartbeat_loop &

# Keep the script running
wait 