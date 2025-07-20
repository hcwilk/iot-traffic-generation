#!/bin/bash

# Marketing User Traffic Generator
# Simulates marketing professional usage: social media, analytics, advertising tools

echo "Starting Marketing User Traffic Generator - ${USER_NAME}"
echo "User ID: ${USER_ID}"
echo "Department: ${DEPARTMENT}"

# Source firewall API utilities
source /app/scripts/firewall_api_utils.sh

# Wait for network to be ready
sleep 15

MY_IP=$(hostname -i | awk '{print $1}')
echo "Marketing User IP: ${MY_IP}"

# Register user with firewall
register_ip_user_mapping "$USER_ID" "$MY_IP"

# Setup cleanup on exit
trap 'cleanup_user_registration "$USER_ID" "$MY_IP"' EXIT

# Function to simulate social media management
simulate_social_media_work() {
    local platforms=("facebook.com" "instagram.com" "twitter.com" "linkedin.com" "tiktok.com" 
                     "youtube.com" "pinterest.com" "snapchat.com")
    
    while true; do
        local platform=${platforms[$RANDOM % ${#platforms[@]}]}
        echo "Managing social media on $platform"
        
        # Multiple requests simulating content creation and monitoring
        for i in {1..6}; do
            curl -s --connect-timeout 5 "https://${platform}" >/dev/null 2>&1
            sleep $((RANDOM % 30 + 10))
        done
        
        # Regular social media management throughout the day
        sleep $((RANDOM % 1200 + 600))  # 10-30 minutes between platforms
    done
}

# Function to simulate analytics and advertising tools
simulate_marketing_tools() {
    local tools=("analytics.google.com" "ads.google.com" "business.facebook.com" 
                 "analytics.twitter.com" "hootsuite.com" "buffer.com" "mailchimp.com"
                 "hubspot.com" "salesforce.com" "marketo.com")
    
    while true; do
        local tool=${tools[$RANDOM % ${#tools[@]}]}
        echo "Using marketing tool: $tool"
        
        # Deep session with marketing tools
        for i in {1..4}; do
            curl -s --connect-timeout 10 "https://${tool}" >/dev/null 2>&1
            sleep $((RANDOM % 45 + 15))
        done
        
        # Analytics and advertising work cycles
        sleep $((RANDOM % 2400 + 1200))  # 20-60 minutes between tools
    done
}

# Function to simulate content research
simulate_content_research() {
    local research_sites=("buzzsumo.com" "semrush.com" "ahrefs.com" "moz.com" 
                          "similarweb.com" "reddit.com" "medium.com" "canva.com")
    
    while true; do
        local site=${research_sites[$RANDOM % ${#research_sites[@]}]}
        echo "Researching content on $site"
        
        # Research browsing patterns
        for i in {1..3}; do
            curl -s --connect-timeout 8 "https://${site}" >/dev/null 2>&1
            sleep $((RANDOM % 60 + 20))
        done
        
        # Research happens less frequently but intensively
        sleep $((RANDOM % 3600 + 1800))  # 30-90 minutes between research sessions
    done
}

# Function to simulate email marketing
simulate_email_marketing() {
    local email_platforms=("mailchimp.com" "constantcontact.com" "sendgrid.com" 
                           "campaignmonitor.com" "aweber.com")
    
    while true; do
        local platform=${email_platforms[$RANDOM % ${#email_platforms[@]}]}
        echo "Working on email campaigns via $platform"
        
        # Campaign creation and monitoring
        for i in {1..5}; do
            curl -s --connect-timeout 5 "https://${platform}" >/dev/null 2>&1
            sleep $((RANDOM % 120 + 30))  # Longer sessions for campaign work
        done
        
        # Email marketing cycles
        sleep $((RANDOM % 4800 + 2400))  # 40-120 minutes between email work
    done
}

# Function to simulate competitor analysis
simulate_competitor_analysis() {
    local analysis_sites=("similarweb.com" "alexa.com" "compete.com" "quantcast.com")
    local competitor_sites=("apple.com" "microsoft.com" "amazon.com" "google.com" 
                            "meta.com" "netflix.com" "spotify.com")
    
    while true; do
        # Mix of analysis tools and competitor sites
        local sites=("${analysis_sites[@]}" "${competitor_sites[@]}")
        local site=${sites[$RANDOM % ${#sites[@]}]}
        echo "Analyzing competition: $site"
        
        curl -s --connect-timeout 5 "https://${site}" >/dev/null 2>&1
        
        # Competitive research patterns
        sleep $((RANDOM % 1800 + 600))  # 10-40 minutes between analysis
    done
}

# Function to send heartbeat to firewall
heartbeat_loop() {
    while true; do
        send_user_heartbeat "$USER_ID" "$MY_IP"
        sleep 300  # Every 5 minutes
    done
}

echo "Marketing user ${USER_NAME} is online and working from IP ${MY_IP}"

# Start all marketing simulation functions in background
simulate_social_media_work &
simulate_marketing_tools &
simulate_content_research &
simulate_email_marketing &
simulate_competitor_analysis &
heartbeat_loop &

# Keep the script running
wait 