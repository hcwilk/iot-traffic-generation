#!/bin/bash

# Student Traffic Generator
# Simulates student internet usage: streaming, social media, research, downloads

echo "Starting Student Traffic Generator - ${USER_NAME}"
echo "User ID: ${USER_ID}"
echo "Student Mode Active"

# Source firewall API utilities
source /app/scripts/firewall_api_utils.sh

# Wait for network to be ready
sleep 15

# Get our IP address
MY_IP=$(hostname -i | awk '{print $1}')
echo "Student IP: ${MY_IP}"

# Register user with firewall
register_ip_user_mapping "$USER_ID" "$MY_IP"

# Setup cleanup on exit
trap 'cleanup_user_registration "$USER_ID" "$MY_IP"' EXIT

# Function to simulate streaming services
simulate_streaming() {
    local platforms=("netflix.com" "youtube.com" "hulu.com" "disneyplus.com" "primevideo.com")
    
    while true; do
        local platform=${platforms[$RANDOM % ${#platforms[@]}]}
        local duration=$((RANDOM % 10800 + 1800))  # 30 minutes to 3 hours
        
        echo "Streaming on $platform for $((duration/60)) minutes"
        
        # High bandwidth video streaming
        timeout $duration iperf3 -c 8.8.8.8 -p 5201 -t $duration >/dev/null 2>&1 &
        
        # Concurrent platform browsing
        for i in {1..3}; do
            curl -s --connect-timeout 5 "https://${platform}" >/dev/null 2>&1
            sleep $((RANDOM % 300 + 60))
        done
        
        wait
        
        # Break between streaming sessions
        sleep $((RANDOM % 3600 + 600))  # 10-70 minutes break
    done
}

# Function to simulate social media usage
simulate_social_media() {
    local platforms=("instagram.com" "tiktok.com" "twitter.com" "snapchat.com" "reddit.com")
    
    while true; do
        local platform=${platforms[$RANDOM % ${#platforms[@]}]}
        
        echo "Checking $platform"
        
        # Multiple requests simulating scrolling/browsing
        for i in {1..8}; do
            curl -s --connect-timeout 3 "https://${platform}" >/dev/null 2>&1
            sleep $((RANDOM % 10 + 2))
        done
        
        # Frequent social media checks throughout the day
        sleep $((RANDOM % 1800 + 300))  # 5-35 minutes between sessions
    done
}

# Function to simulate academic research
simulate_research() {
    local academic_sites=("scholar.google.com" "jstor.org" "pubmed.ncbi.nlm.nih.gov" 
                          "arxiv.org" "researchgate.net" "springer.com" "sciencedirect.com")
    
    while true; do
        local site=${academic_sites[$RANDOM % ${#academic_sites[@]}]}
        
        echo "Researching on $site"
        
        # Deep browsing session for research
        for i in {1..5}; do
            curl -s --connect-timeout 10 "https://${site}" >/dev/null 2>&1
            sleep $((RANDOM % 30 + 15))
        done
        
        # Research sessions are less frequent but longer
        sleep $((RANDOM % 5400 + 1800))  # 30-120 minutes between sessions
    done
}

# Function to simulate file downloads (assignments, papers, software)
simulate_downloads() {
    local download_sites=("github.com" "drive.google.com" "dropbox.com" "mediafire.com")
    
    while true; do
        local site=${download_sites[$RANDOM % ${#download_sites[@]}]}
        echo "Downloading files from $site"
        
        # File download simulation (varied sizes)
        local download_duration=$((RANDOM % 600 + 60))  # 1-10 minute downloads
        timeout $download_duration iperf3 -c 1.1.1.1 -p 5202 -t $download_duration >/dev/null 2>&1
        
        # Downloads happen periodically
        sleep $((RANDOM % 7200 + 1800))  # 30 minutes to 2.5 hours between downloads
    done
}

# Function to simulate online learning platforms
simulate_online_learning() {
    local platforms=("coursera.org" "khanacademy.org" "edx.org" "udemy.com" "canvas.instructure.com")
    
    while true; do
        local platform=${platforms[$RANDOM % ${#platforms[@]}]}
        local session_duration=$((RANDOM % 3600 + 1800))  # 30-90 minute sessions
        
        echo "Online learning session on $platform for $((session_duration/60)) minutes"
        
        # Mixed content: videos and browsing
        timeout $session_duration bash -c "
            while true; do
                # Video content
                timeout 600 iperf3 -c 8.8.8.8 -p 5204 -t 600 >/dev/null 2>&1
                # Browse course materials
                curl -s --connect-timeout 5 'https://${platform}' >/dev/null 2>&1
                sleep 30
            done
        " &
        
        wait
        
        # Study breaks
        sleep $((RANDOM % 3600 + 1800))  # 30-90 minutes between study sessions
    done
}

# Function to send heartbeat to firewall
heartbeat_loop() {
    while true; do
        send_user_heartbeat "$USER_ID" "$MY_IP"
        sleep 300  # Every 5 minutes
    done
}

echo "Student ${USER_NAME} is online and studying from IP ${MY_IP}"

# Start all student simulation functions in background
simulate_streaming &
simulate_social_media &
simulate_research &
simulate_downloads &
simulate_online_learning &
heartbeat_loop &

# Keep the script running
wait 