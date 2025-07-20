#!/bin/bash

# Test User Traffic Generator
# Simple test script to verify User-ID mapping functionality

echo "=============================================="
echo "Starting Test User Traffic Generator"
echo "=============================================="
echo "User ID: ${USER_ID}"
echo "User Name: ${USER_NAME}"  
echo "Department: ${DEPARTMENT}"
echo "Firewall Host: ${FIREWALL_HOST}"

# Source firewall API utilities
source /app/scripts/firewall_api_utils.sh

# Wait for network to be ready
sleep 15

# Get our IP address
MY_IP=$(hostname -i | awk '{print $1}')
echo "Test User IP: ${MY_IP}"

echo ""
echo "=============================================="
echo "Testing User-ID Mapping"
echo "=============================================="

# Test the User-ID mapping
register_ip_user_mapping "$USER_ID" "$MY_IP"

# Setup cleanup on exit
trap 'cleanup_user_registration "$USER_ID" "$MY_IP"' EXIT

echo ""
echo "=============================================="
echo "Starting Light Traffic Generation"  
echo "=============================================="

# Function to generate minimal web traffic
generate_test_traffic() {
    local sites=("google.com" "microsoft.com" "github.com")
    
    while true; do
        local site=${sites[$RANDOM % ${#sites[@]}]}
        echo "[Traffic] Browsing $site"
        
        # Simple HTTP request
        curl -s --connect-timeout 5 "https://${site}" >/dev/null 2>&1
        
        # Wait between requests (every 2-5 minutes for light traffic)
        sleep $((RANDOM % 180 + 120))
    done
}

# Function to send heartbeat to maintain User-ID mapping
heartbeat_loop() {
    while true; do
        echo "[Heartbeat] Refreshing User-ID mapping"
        send_user_heartbeat "$USER_ID" "$MY_IP"
        sleep 300  # Every 5 minutes
    done
}

echo "Test user ${USER_NAME} (${USER_ID}) is active from IP ${MY_IP}"
echo ""
echo "Press Ctrl+C to stop and cleanup mapping..."

# Start traffic and heartbeat in background
generate_test_traffic &
heartbeat_loop &

# Keep the script running
wait 