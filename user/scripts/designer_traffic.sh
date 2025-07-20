#!/bin/bash

# Designer Traffic Generator
# Simulates creative professional usage: design tools, inspiration, portfolios

echo "Starting Designer Traffic Generator - ${USER_NAME}"
echo "User ID: ${USER_ID}"
echo "Department: ${DEPARTMENT}"

# Source firewall API utilities
source /app/scripts/firewall_api_utils.sh

# Wait for network to be ready
sleep 15

MY_IP=$(hostname -i | awk '{print $1}')
echo "Designer IP: ${MY_IP}"

# Register user with firewall
register_ip_user_mapping "$USER_ID" "$MY_IP"

# Setup cleanup on exit
trap 'cleanup_user_registration "$USER_ID" "$MY_IP"' EXIT

# Function to simulate design tools usage
simulate_design_tools() {
    local tools=("figma.com" "adobe.com" "sketch.com" "invisionapp.com" 
                 "canva.com" "framer.com" "principle.design" "zeplin.io")
    
    while true; do
        local tool=${tools[$RANDOM % ${#tools[@]}]}
        echo "Using design tool: $tool"
        
        # Long design sessions with frequent saves/syncs
        local session_duration=$((RANDOM % 3600 + 1800))  # 30-90 minute sessions
        local end_time=$(($(date +%s) + session_duration))
        
        while [ $(date +%s) -lt $end_time ]; do
            curl -s --connect-timeout 8 "https://${tool}" >/dev/null 2>&1
            
            # Simulate file operations and syncing
            if [ $((RANDOM % 4)) -eq 0 ]; then
                # Simulate large file upload/download (cloud sync)
                timeout 30 iperf3 -c 1.1.1.1 -p 5201 -t 20 >/dev/null 2>&1 &
            fi
            
            sleep $((RANDOM % 180 + 60))  # 1-4 minutes between actions
        done
        
        echo "Design session completed, taking a break"
        sleep $((RANDOM % 1800 + 600))  # 10-40 minute breaks
    done
}

# Function to simulate inspiration and research
simulate_design_inspiration() {
    local inspiration_sites=("dribbble.com" "behance.net" "pinterest.com" "awwwards.com"
                             "designspiration.com" "muzli.substack.com" "designmodo.com"
                             "smashingmagazine.com" "abduzeedo.com" "css-tricks.com")
    
    while true; do
        local site=${inspiration_sites[$RANDOM % ${#inspiration_sites[@]}]}
        echo "Finding inspiration on $site"
        
        # Browsing inspiration - lots of image loading
        for i in {1..8}; do
            curl -s --connect-timeout 5 "https://${site}" >/dev/null 2>&1
            sleep $((RANDOM % 20 + 10))  # Quick browsing through designs
        done
        
        # Regular inspiration browsing
        sleep $((RANDOM % 1800 + 300))  # 5-35 minutes between sites
    done
}

# Function to simulate portfolio and client work
simulate_portfolio_work() {
    local portfolio_sites=("behance.net" "dribbble.com" "carbonmade.com" 
                           "portfoliobox.net" "squarespace.com" "wix.com")
    
    while true; do
        local site=${portfolio_sites[$RANDOM % ${#portfolio_sites[@]}]}
        echo "Working on portfolio at $site"
        
        # Portfolio updates and client presentations
        for i in {1..3}; do
            curl -s --connect-timeout 8 "https://${site}" >/dev/null 2>&1
            
            # Simulate large image uploads
            if [ $((RANDOM % 3)) -eq 0 ]; then
                timeout 60 iperf3 -c 8.8.8.8 -p 5202 -R -t 40 >/dev/null 2>&1 &
            fi
            
            sleep $((RANDOM % 300 + 120))  # 2-7 minutes per update
        done
        
        # Portfolio work happens less frequently
        sleep $((RANDOM % 7200 + 3600))  # 1-3 hours between portfolio updates
    done
}

# Function to simulate font and asset resources
simulate_resource_gathering() {
    local resource_sites=("fonts.google.com" "typekit.com" "dafont.com" 
                          "unsplash.com" "pexels.com" "shutterstock.com"
                          "iconmonstr.com" "flaticon.com" "noun-project.com")
    
    while true; do
        local site=${resource_sites[$RANDOM % ${#resource_sites[@]}]}
        echo "Gathering resources from $site"
        
        # Resource hunting and downloading
        for i in {1..4}; do
            curl -s --connect-timeout 6 "https://${site}" >/dev/null 2>&1
            sleep $((RANDOM % 60 + 15))
        done
        
        # Resource gathering sessions
        sleep $((RANDOM % 2400 + 1200))  # 20-60 minutes between resource hunts
    done
}

# Function to simulate design community and learning
simulate_design_community() {
    local community_sites=("stackoverflow.com" "reddit.com" "designer-hangout.slack.com"
                           "uxmastery.com" "nngroup.com" "uxbooth.com" "designernews.co")
    
    while true; do
        local site=${community_sites[$RANDOM % ${#community_sites[@]}]}
        echo "Engaging with design community: $site"
        
        # Community participation and learning
        for i in {1..3}; do
            curl -s --connect-timeout 5 "https://${site}" >/dev/null 2>&1
            sleep $((RANDOM % 90 + 30))
        done
        
        # Community engagement cycles
        sleep $((RANDOM % 3600 + 1800))  # 30-90 minutes between community visits
    done
}

# Function to simulate stock photo and video downloads
simulate_media_downloads() {
    local media_sites=("unsplash.com" "pexels.com" "pixabay.com" "videvo.net")
    
    while true; do
        local site=${media_sites[$RANDOM % ${#media_sites[@]}]}
        echo "Downloading media from $site"
        
        # Large media file downloads
        curl -s --connect-timeout 5 "https://${site}" >/dev/null 2>&1
        
        # Simulate large download
        timeout 120 iperf3 -c 1.1.1.1 -p 5203 -t 90 >/dev/null 2>&1
        
        # Downloads happen periodically
        sleep $((RANDOM % 5400 + 1800))  # 30-120 minutes between downloads
    done
}

# Function to send heartbeat to firewall
heartbeat_loop() {
    while true; do
        send_user_heartbeat "$USER_ID" "$MY_IP"
        sleep 300  # Every 5 minutes
    done
}

echo "Designer ${USER_NAME} is creating from IP ${MY_IP}"

# Start all designer simulation functions in background
simulate_design_tools &
simulate_design_inspiration &
simulate_portfolio_work &
simulate_resource_gathering &
simulate_design_community &
simulate_media_downloads &
heartbeat_loop &

# Keep the script running
wait 