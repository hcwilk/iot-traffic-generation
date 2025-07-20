#!/bin/bash

# Family User Traffic Generator
# Simulates mixed family usage: streaming, social media, shopping, kids content

echo "Starting Family User Traffic Generator - ${USER_NAME}"
echo "User ID: ${USER_ID}"
echo "Family Device Active"

source /app/scripts/firewall_api_utils.sh

sleep 15

MY_IP=$(hostname -i | awk '{print $1}')
echo "Family Device IP: ${MY_IP}"

register_user_with_firewall "$USER_ID" "$USER_NAME" "$MY_IP" "$DEPARTMENT" "$DEVICE_MAC"
register_ip_user_mapping "$USER_ID" "$MY_IP"

trap 'cleanup_user_registration "$USER_ID"' EXIT

# Family streaming
simulate_family_streaming() {
    local platforms=("netflix.com" "youtube.com" "disneyplus.com" "pbskids.org")
    
    while true; do
        local platform=${platforms[$RANDOM % ${#platforms[@]}]}
        local duration=$((RANDOM % 7200 + 1800))
        
        echo "Family streaming on $platform for $((duration/60)) minutes"
        timeout $duration iperf3 -c 8.8.8.8 -p 5201 -t $duration >/dev/null 2>&1 &
        
        wait
        sleep $((RANDOM % 1800 + 600))
    done
}

# Shopping and social media
simulate_family_browsing() {
    local sites=("amazon.com" "facebook.com" "instagram.com" "pinterest.com" "target.com")
    
    while true; do
        local site=${sites[$RANDOM % ${#sites[@]}]}
        echo "Family browsing: $site"
        
        for i in {1..5}; do
            curl -s --connect-timeout 5 "https://${site}" >/dev/null 2>&1
            sleep $((RANDOM % 30 + 15))
        done
        
        sleep $((RANDOM % 1200 + 300))
    done
}

heartbeat_loop() {
    while true; do
        send_user_heartbeat "$USER_ID" "$MY_IP"
        sleep 300
    done
}

echo "Family device ${USER_NAME} is active from IP ${MY_IP}"

simulate_family_streaming &
simulate_family_browsing &
heartbeat_loop &

wait 