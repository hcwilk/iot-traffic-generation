#!/bin/bash

# Business User Traffic Generator
# Simulates standard office traffic: email, CRM, document sharing, web browsing

echo "Starting Business User Traffic Generator - ${USER_NAME}"
echo "User ID: ${USER_ID}"
echo "Department: ${DEPARTMENT}"

# Source firewall API utilities
source /app/scripts/firewall_api_utils.sh

# Wait for network to be ready
sleep 15

MY_IP=$(hostname -i | awk '{print $1}')
echo "Business User IP: ${MY_IP}"

# Register user with firewall
register_user_with_firewall "$USER_ID" "$USER_NAME" "$MY_IP" "$DEPARTMENT" "$DEVICE_MAC"
register_ip_user_mapping "$USER_ID" "$MY_IP"

trap 'cleanup_user_registration "$USER_ID"' EXIT

# Business applications simulation
simulate_business_apps() {
    local business_sites=("office365.com" "salesforce.com" "slack.com" "zoom.us" "asana.com")
    
    while true; do
        local site=${business_sites[$RANDOM % ${#business_sites[@]}]}
        echo "Using business app: $site"
        
        for i in {1..4}; do
            curl -s --connect-timeout 5 "https://${site}" >/dev/null 2>&1
            sleep $((RANDOM % 60 + 30))
        done
        
        sleep $((RANDOM % 1800 + 600))  # 10-40 minutes between app usage
    done
}

# Email simulation
simulate_email() {
    while true; do
        echo "Checking email"
        
        # Email server requests
        for i in {1..3}; do
            curl -s --connect-timeout 5 "https://outlook.office365.com" >/dev/null 2>&1
            sleep $((RANDOM % 30 + 10))
        done
        
        sleep $((RANDOM % 600 + 300))  # Check every 5-15 minutes
    done
}

# Web browsing
simulate_web_browsing() {
    local sites=("google.com" "linkedin.com" "news.ycombinator.com" "bbc.com")
    
    while true; do
        local site=${sites[$RANDOM % ${#sites[@]}]}
        curl -s --connect-timeout 5 "https://${site}" >/dev/null 2>&1
        sleep $((RANDOM % 900 + 300))  # Light browsing
    done
}

# Heartbeat
heartbeat_loop() {
    while true; do
        send_user_heartbeat "$USER_ID" "$MY_IP"
        sleep 300
    done
}

echo "Business user ${USER_NAME} is working from IP ${MY_IP}"

simulate_business_apps &
simulate_email &
simulate_web_browsing &
heartbeat_loop &

wait 