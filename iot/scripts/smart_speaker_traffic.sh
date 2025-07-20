#!/bin/bash

# Smart Speaker Traffic Generator
# Simulates Amazon Echo-style smart speaker behavior

echo "Starting Smart Speaker Traffic Generator - ${DEVICE_MODEL}"
echo "MAC Address: ${DEVICE_MAC}"
echo "Device Type: ${DEVICE_TYPE}"

# Wait for network to be ready
sleep 10

MY_IP=$(hostname -i | awk '{print $1}')
echo "Smart Speaker IP: ${MY_IP}"

# Speaker state variables
SPEAKER_STATE="idle"
VOLUME_LEVEL=$((RANDOM % 60 + 20))  # 20-80%
CURRENT_ACTIVITY="standby"
WAKE_WORD_SENSITIVITY="medium"

# Function to simulate Alexa cloud connectivity
simulate_alexa_cloud() {
    local alexa_services=("alexa.amazon.com" "api.amazonalexa.com" "avs-alexa-na.amazon.com")
    
    while true; do
        for service in "${alexa_services[@]}"; do
            # Send device status to Alexa cloud
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"device_status":{"state":"'${SPEAKER_STATE}'","volume":'${VOLUME_LEVEL}',"activity":"'${CURRENT_ACTIVITY}'","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
            
            # Alexa Voice Service connectivity
            curl -s --connect-timeout 5 https://${service} >/dev/null 2>&1 || true
        done
        
        sleep $((RANDOM % 120 + 60))  # 1-3 minutes
    done
}

# Function to simulate wake word detection and voice commands
simulate_voice_interactions() {
    while true; do
        # Random wake word activation
        if [ $((RANDOM % 20)) -eq 0 ]; then
            SPEAKER_STATE="listening"
            echo "Wake word detected - 'Alexa'"
            
            # Send wake word event
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"wake_word":{"detected":true,"confidence":0.92,"device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
            
            sleep 2
            
            # Simulate voice command processing
            local commands=("weather" "music" "smart_home" "timer" "shopping" "news" "question")
            local command=${commands[$RANDOM % ${#commands[@]}]}
            
            CURRENT_ACTIVITY=$command
            echo "Processing voice command: ${command}"
            
            case $command in
                "weather")
                    # Weather service requests
                    curl -s --connect-timeout 5 http://weather.com >/dev/null 2>&1 || true
                    SPEAKER_STATE="speaking"
                    ;;
                "music")
                    # Music streaming services
                    local music_services=("music.amazon.com" "spotify.com" "pandora.com")
                    local music_service=${music_services[$RANDOM % ${#music_services[@]}]}
                    curl -s --connect-timeout 5 https://${music_service} >/dev/null 2>&1 || true
                    SPEAKER_STATE="playing"
                    ;;
                "smart_home")
                    # Smart home device control
                    echo "Controlling smart home devices"
                    SPEAKER_STATE="processing"
                    ;;
                "timer")
                    echo "Setting timer"
                    SPEAKER_STATE="timer_active"
                    ;;
                "shopping")
                    # Amazon shopping requests
                    curl -s --connect-timeout 5 https://amazon.com >/dev/null 2>&1 || true
                    SPEAKER_STATE="speaking"
                    ;;
                "news")
                    # News service requests
                    curl -s --connect-timeout 5 http://news.amazon.com >/dev/null 2>&1 || true
                    SPEAKER_STATE="speaking"
                    ;;
                "question")
                    # Web search for answers
                    curl -s --connect-timeout 5 http://bing.com >/dev/null 2>&1 || true
                    SPEAKER_STATE="speaking"
                    ;;
            esac
            
            # Send voice command to cloud for processing
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"voice_command":{"type":"'${command}'","confidence":0.87,"device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
            
            # Response duration
            sleep $((RANDOM % 5 + 3))
            
            SPEAKER_STATE="idle"
            CURRENT_ACTIVITY="standby"
        fi
        
        sleep $((RANDOM % 600 + 300))  # 5-15 minutes between interactions
    done
}

# Function to simulate music streaming
simulate_music_streaming() {
    while true; do
        if [ "$SPEAKER_STATE" = "playing" ]; then
            # High quality audio streaming
            local streaming_services=("music.amazon.com" "spotify.com" "apple.com" "pandora.com")
            local service=${streaming_services[$RANDOM % ${#streaming_services[@]}]}
            
            # Simulate sustained audio streaming
            timeout 180 hping3 -i u2000 ${service} >/dev/null 2>&1 || true
            
            # Send music analytics
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"music_session":{"service":"'${service}'","duration_minutes":3,"quality":"high","volume":'${VOLUME_LEVEL}',"device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
            
            # Sometimes music stops
            if [ $((RANDOM % 10)) -eq 0 ]; then
                SPEAKER_STATE="idle"
                CURRENT_ACTIVITY="standby"
                echo "Music stopped"
            fi
        fi
        
        sleep 30
    done
}

# Function to simulate mobile app connectivity
simulate_mobile_app() {
    while true; do
        # Alexa app connectivity
        curl -s --connect-timeout 5 http://alexa.amazon.com/api/devices >/dev/null 2>&1 || true
        
        # Simulate app-based commands
        if [ $((RANDOM % 25)) -eq 0 ]; then
            local app_commands=("volume_change" "play_music" "set_alarm" "smart_home_control")
            local app_command=${app_commands[$RANDOM % ${#app_commands[@]}]}
            
            case $app_command in
                "volume_change")
                    VOLUME_LEVEL=$((RANDOM % 60 + 20))
                    echo "Volume changed to ${VOLUME_LEVEL}% via app"
                    ;;
                "play_music")
                    SPEAKER_STATE="playing"
                    CURRENT_ACTIVITY="music"
                    echo "Music started via app"
                    ;;
                "set_alarm")
                    CURRENT_ACTIVITY="alarm_set"
                    echo "Alarm set via app"
                    ;;
                "smart_home_control")
                    echo "Smart home device controlled via app"
                    ;;
            esac
            
            # Send app command acknowledgment
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"app_command":{"type":"'${app_command}'","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 240 + 180))  # 3-7 minutes
    done
}

# Function to simulate smart home hub functionality
simulate_smart_home_hub() {
    while true; do
        # Scan for and communicate with other smart devices
        nslookup _googlecast._tcp.local >/dev/null 2>&1 || true
        nslookup _hue._tcp.local >/dev/null 2>&1 || true
        nslookup _homekit._tcp.local >/dev/null 2>&1 || true
        
        # ZigBee/Z-Wave simulation (local network traffic)
        nmap -sn ${MY_IP%.*}.0/24 >/dev/null 2>&1 || true
        
        # Send smart home status updates
        if [ $((RANDOM % 30)) -eq 0 ]; then
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"smart_home_update":{"connected_devices":'$((RANDOM % 15 + 5))',"hub_status":"active","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 900 + 600))  # 10-25 minutes
    done
}

# Function to simulate firmware and skill updates
simulate_updates() {
    while true; do
        # Check for firmware updates
        curl -s --connect-timeout 5 http://amazon-device-update.s3.amazonaws.com >/dev/null 2>&1 || true
        
        # Alexa Skills Store connectivity
        curl -s --connect-timeout 5 http://alexa.amazon.com/skills >/dev/null 2>&1 || true
        
        # Download new skills
        if [ $((RANDOM % 100)) -eq 0 ]; then
            echo "Installing new Alexa skill"
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"skill_install":{"skill_name":"Smart Home Skill","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 7200 + 14400))  # 4-6 hours
    done
}

# Function to simulate drop-in and calling features
simulate_communication_features() {
    while true; do
        # Occasional drop-in or calling activity
        if [ $((RANDOM % 50)) -eq 0 ]; then
            local comm_types=("drop_in" "voice_call" "announcement")
            local comm_type=${comm_types[$RANDOM % ${#comm_types[@]}]}
            
            SPEAKER_STATE="communicating"
            CURRENT_ACTIVITY=$comm_type
            echo "Communication session: ${comm_type}"
            
            # Audio streaming for calls
            timeout 60 hping3 -i u1500 alexa.amazon.com >/dev/null 2>&1 || true
            
            # Log communication session
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"communication":{"type":"'${comm_type}'","duration_seconds":60,"device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
            
            SPEAKER_STATE="idle"
            CURRENT_ACTIVITY="standby"
        fi
        
        sleep $((RANDOM % 2400 + 1200))  # 20-60 minutes
    done
}

# Function to simulate routine automations
simulate_routines() {
    while true; do
        local hour=$(date +%H)
        
        # Morning routine
        if [ $hour -eq 7 ] && [ "$CURRENT_ACTIVITY" = "standby" ]; then
            CURRENT_ACTIVITY="morning_routine"
            echo "Running morning routine"
            
            # Weather check
            curl -s --connect-timeout 5 http://weather.com >/dev/null 2>&1 || true
            
            # News briefing
            curl -s --connect-timeout 5 http://news.amazon.com >/dev/null 2>&1 || true
            
            CURRENT_ACTIVITY="standby"
            
        # Evening routine
        elif [ $hour -eq 22 ] && [ "$CURRENT_ACTIVITY" = "standby" ]; then
            CURRENT_ACTIVITY="evening_routine"
            echo "Running evening routine"
            
            # Relaxing music
            SPEAKER_STATE="playing"
            
            CURRENT_ACTIVITY="standby"
        fi
        
        sleep 1800  # Check every 30 minutes
    done
}

# Start all processes in background
simulate_alexa_cloud &
simulate_voice_interactions &
simulate_music_streaming &
simulate_mobile_app &
simulate_smart_home_hub &
simulate_updates &
simulate_communication_features &
simulate_routines &

# Keep the main process running
while true; do
    echo "Smart Speaker ${DEVICE_MODEL} - State: ${SPEAKER_STATE}, Activity: ${CURRENT_ACTIVITY}, Volume: ${VOLUME_LEVEL}% - $(date)"
    sleep 300  # Status update every 5 minutes
done 