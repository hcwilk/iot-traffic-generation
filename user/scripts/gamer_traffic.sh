#!/bin/bash

# Gaming User Traffic Generator
# Simulates gaming traffic, voice chat, streaming platforms, and large downloads

echo "Starting Gaming User Traffic Generator - ${USER_NAME}"
echo "User ID: ${USER_ID}"
echo "Gaming Platform Setup"

# Source firewall API utilities
source /app/scripts/firewall_api_utils.sh

# Wait for network to be ready
sleep 15

# Get our IP address
MY_IP=$(hostname -i | awk '{print $1}')
echo "Gamer IP: ${MY_IP}"

# Register user with firewall
register_user_with_firewall "$USER_ID" "$USER_NAME" "$MY_IP" "$DEPARTMENT" "$DEVICE_MAC"
register_ip_user_mapping "$USER_ID" "$MY_IP"

# Setup cleanup on exit
trap 'cleanup_user_registration "$USER_ID"' EXIT

# Function to simulate gaming sessions
simulate_gaming() {
    local game_servers=("52.40.124.0" "13.107.246.0" "23.218.212.0" "185.60.114.0")
    local games=("Valorant" "CS2" "League of Legends" "Overwatch" "Apex Legends")
    
    while true; do
        local game=${games[$RANDOM % ${#games[@]}]}
        local server=${game_servers[$RANDOM % ${#game_servers[@]}]}
        local session_duration=$((RANDOM % 7200 + 3600))  # 1-3 hour sessions
        
        echo "Starting gaming session: $game for $((session_duration/60)) minutes"
        
        # Simulate gaming traffic (consistent low-latency traffic)
        timeout $session_duration bash -c "
            while true; do
                # Gaming packets - small but frequent
                echo 'game_packet' | nc -u -w1 $server 3478 2>/dev/null
                echo 'game_packet' | nc -u -w1 $server 27015 2>/dev/null
                sleep 0.05  # 20 packets per second
            done
        " &
        
        # Concurrent voice chat during gaming
        timeout $session_duration bash -c "
            while true; do
                # Discord/voice chat simulation
                echo 'voice_data' | nc -u -w1 8.8.8.8 443 2>/dev/null
                sleep 0.1  # Voice packets
            done
        " &
        
        wait
        
        # Gaming break (30 minutes to 2 hours)
        local break_duration=$((RANDOM % 5400 + 1800))
        echo "Gaming session ended, next session in $((break_duration/60)) minutes"
        sleep $break_duration
    done
}

# Function to simulate game downloads/updates
simulate_game_updates() {
    local platforms=("steamcontent.com" "epicgames.com" "battle.net" "origin.com")
    
    while true; do
        local platform=${platforms[$RANDOM % ${#platforms[@]}]}
        echo "Downloading game update from $platform"
        
        # Large download simulation (game updates can be 10-50GB)
        local download_duration=$((RANDOM % 3600 + 1800))  # 30-90 minutes
        
        # High bandwidth sustained download
        timeout $download_duration iperf3 -c 1.1.1.1 -p 5201 -t $download_duration >/dev/null 2>&1
        
        # Downloads happen less frequently (every 1-3 days)
        local next_update=$((RANDOM % 172800 + 86400))  # 1-3 days
        echo "Game update complete, next update check in $((next_update/3600)) hours"
        sleep $next_update
    done
}

# Function to simulate streaming (watching/broadcasting)
simulate_streaming() {
    local platforms=("twitch.tv" "youtube.com" "kick.com" "discord.com")
    
    while true; do
        local platform=${platforms[$RANDOM % ${#platforms[@]}]}
        local is_broadcasting=$((RANDOM % 4))  # 25% chance of broadcasting
        
        if [ $is_broadcasting -eq 0 ]; then
            echo "Broadcasting gameplay to $platform"
            # Upload stream (broadcasting)
            timeout 3600 iperf3 -c 8.8.8.8 -p 5203 -R -t 3600 >/dev/null 2>&1 &
        else
            echo "Watching streams on $platform"
            # Download stream (watching)
            timeout 3600 iperf3 -c 8.8.8.8 -p 5203 -t 3600 >/dev/null 2>&1 &
        fi
        
        # Also browse the platform
        for i in {1..5}; do
            curl -s --connect-timeout 5 "https://${platform}" >/dev/null 2>&1
            sleep $((RANDOM % 60 + 30))
        done
        
        # Wait for stream to end, then break
        wait
        sleep $((RANDOM % 1800 + 600))  # 10-40 minute break
    done
}

# Function to simulate social gaming
simulate_social_gaming() {
    local social_platforms=("discord.com" "reddit.com" "steamcommunity.com")
    
    while true; do
        local platform=${social_platforms[$RANDOM % ${#social_platforms[@]}]}
        
        # Check messages, forums, friend activity
        for i in {1..3}; do
            curl -s --connect-timeout 5 "https://${platform}" >/dev/null 2>&1
            sleep $((RANDOM % 30 + 10))
        done
        
        # Social check interval
        sleep $((RANDOM % 900 + 300))  # 5-20 minutes
    done
}

# Function to send heartbeat to firewall
heartbeat_loop() {
    while true; do
        send_user_heartbeat "$USER_ID" "$MY_IP"
        sleep 300  # Every 5 minutes
    done
}

echo "Gamer ${USER_NAME} is online and ready to play from IP ${MY_IP}"

# Start all gaming simulation functions in background
simulate_gaming &
simulate_game_updates &
simulate_streaming &
simulate_social_gaming &
heartbeat_loop &

# Keep the script running
wait 