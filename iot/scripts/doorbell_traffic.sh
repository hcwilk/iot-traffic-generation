#!/bin/bash

# Smart Doorbell Traffic Generator
# Simulates Ring-style smart doorbell behavior

echo "Starting Smart Doorbell Traffic Generator - ${DEVICE_MODEL}"
echo "MAC Address: ${DEVICE_MAC}"
echo "Device Type: ${DEVICE_TYPE}"

# Wait for network to be ready
sleep 10

MY_IP=$(hostname -i | awk '{print $1}')
echo "Smart Doorbell IP: ${MY_IP}"

# Doorbell state variables
MOTION_SENSITIVITY="medium"
RECORDING_MODE="always"
BATTERY_LEVEL=$((RANDOM % 40 + 60))  # 60-100%

# Function to simulate cloud connectivity
simulate_cloud_connectivity() {
    local cloud_services=("ring.com" "api.ring.com" "amazonaws.com")
    
    while true; do
        for service in "${cloud_services[@]}"; do
            # Send heartbeat to Ring cloud
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"device_status":{"online":true,"battery":'${BATTERY_LEVEL}',"signal_strength":-45,"device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
            
            # Cloud service connectivity check
            curl -s --connect-timeout 5 https://${service} >/dev/null 2>&1 || true
        done
        
        sleep $((RANDOM % 120 + 60))  # 1-3 minutes
    done
}

# Function to simulate motion detection
simulate_motion_detection() {
    while true; do
        # Random motion events (more frequent during day)
        local hour=$(date +%H)
        local motion_chance=5
        
        # Higher chance during daytime hours (6 AM - 10 PM)
        if [ $hour -ge 6 ] && [ $hour -le 22 ]; then
            motion_chance=3
        fi
        
        if [ $((RANDOM % motion_chance)) -eq 0 ]; then
            echo "Motion detected at front door"
            
            # Send motion alert to cloud
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"event":"motion_detected","location":"front_door","sensitivity":"'${MOTION_SENSITIVITY}'","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'","recording_started":true}' \
                >/dev/null 2>&1 || true
            
            # Upload video snippet (simulated high bandwidth)
            timeout 30 hping3 -i u500 amazonaws.com >/dev/null 2>&1 || true
            
            # Send push notification
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"notification":{"type":"motion_alert","message":"Motion detected at your front door","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 300 + 180))  # 3-8 minutes
    done
}

# Function to simulate doorbell presses
simulate_doorbell_events() {
    while true; do
        # Random doorbell press events (less frequent than motion)
        if [ $((RANDOM % 20)) -eq 0 ]; then
            echo "Doorbell pressed!"
            
            # Send doorbell event to cloud
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"event":"doorbell_pressed","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'","video_recording":true,"audio_recording":true}' \
                >/dev/null 2>&1 || true
            
            # Start live video stream (high bandwidth)
            timeout 60 hping3 -i u200 amazonaws.com >/dev/null 2>&1 || true
            
            # Send push notification to all connected devices
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"notification":{"type":"doorbell_press","message":"Someone is at your front door","priority":"high","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 1800 + 900))  # 15-45 minutes
    done
}

# Function to simulate mobile app connectivity
simulate_mobile_app() {
    while true; do
        # App polling for device status
        curl -s --connect-timeout 5 http://api.ring.com/devices/status >/dev/null 2>&1 || true
        
        # Sync settings from mobile app
        if [ $((RANDOM % 25)) -eq 0 ]; then
            local settings=("motion_sensitivity" "recording_mode" "night_vision")
            local setting=${settings[$RANDOM % ${#settings[@]}]}
            
            case $setting in
                "motion_sensitivity")
                    local levels=("low" "medium" "high")
                    MOTION_SENSITIVITY=${levels[$RANDOM % ${#levels[@]}]}
                    echo "Motion sensitivity changed to: ${MOTION_SENSITIVITY}"
                    ;;
                "recording_mode")
                    local modes=("motion_only" "always" "scheduled")
                    RECORDING_MODE=${modes[$RANDOM % ${#modes[@]}]}
                    echo "Recording mode changed to: ${RECORDING_MODE}"
                    ;;
            esac
            
            # Acknowledge setting change
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"settings_update":{"'${setting}'":"'${MOTION_SENSITIVITY:-$RECORDING_MODE}'","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 240 + 120))  # 2-6 minutes
    done
}

# Function to simulate live view sessions
simulate_live_view() {
    while true; do
        # Random live view sessions from mobile app
        if [ $((RANDOM % 30)) -eq 0 ]; then
            echo "Live view session started"
            
            # High bandwidth live streaming
            timeout 180 hping3 -i u300 amazonaws.com >/dev/null 2>&1 || true
            
            # Log live view session
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"live_view":{"duration_seconds":180,"quality":"HD","device":"'${DEVICE_MODEL}'","user":"mobile_app","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 1800 + 600))  # 10-40 minutes
    done
}

# Function to simulate firmware updates
simulate_firmware_updates() {
    while true; do
        # Check for firmware updates
        curl -s --connect-timeout 5 http://updates.ring.com >/dev/null 2>&1 || true
        curl -s --connect-timeout 5 http://firmware.ring.com >/dev/null 2>&1 || true
        
        # Battery level reporting (slowly decreases)
        BATTERY_LEVEL=$((BATTERY_LEVEL - RANDOM % 2))
        if [ $BATTERY_LEVEL -lt 20 ]; then
            echo "Low battery warning: ${BATTERY_LEVEL}%"
            
            # Send low battery alert
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"alert":{"type":"low_battery","battery_level":'${BATTERY_LEVEL}',"device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 7200 + 10800))  # 3-5 hours
    done
}

# Function to simulate neighbor network
simulate_neighbor_network() {
    while true; do
        # Ring Neighborhood features
        curl -s --connect-timeout 5 http://neighbors.ring.com >/dev/null 2>&1 || true
        
        # Share crime and safety updates
        if [ $((RANDOM % 50)) -eq 0 ]; then
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"neighbor_update":{"type":"safety_alert","location":"nearby","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 3600 + 1800))  # 30-90 minutes
    done
}

# Function to simulate two-way audio
simulate_two_way_audio() {
    while true; do
        # Occasional two-way talk sessions
        if [ $((RANDOM % 40)) -eq 0 ]; then
            echo "Two-way audio session initiated"
            
            # Audio streaming (both directions)
            timeout 45 hping3 -i u1000 amazonaws.com >/dev/null 2>&1 || true
            
            # Log audio session
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"audio_session":{"duration_seconds":45,"type":"two_way_talk","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 2400 + 1200))  # 20-60 minutes
    done
}

# Start all processes in background
simulate_cloud_connectivity &
simulate_motion_detection &
simulate_doorbell_events &
simulate_mobile_app &
simulate_live_view &
simulate_firmware_updates &
simulate_neighbor_network &
simulate_two_way_audio &

# Keep the main process running
while true; do
    echo "Smart Doorbell ${DEVICE_MODEL} - Battery: ${BATTERY_LEVEL}%, Motion: ${MOTION_SENSITIVITY}, Recording: ${RECORDING_MODE} - $(date)"
    sleep 300  # Status update every 5 minutes
done 