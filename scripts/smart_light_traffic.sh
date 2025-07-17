#!/bin/bash

# Smart Light Traffic Generator
# Simulates Philips Hue-style smart light behavior

echo "Starting Smart Light Traffic Generator - ${DEVICE_MODEL}"
echo "MAC Address: ${DEVICE_MAC}"
echo "Device Type: ${DEVICE_TYPE}"

# Wait for network to be ready
sleep 10

MY_IP=$(hostname -i | awk '{print $1}')
echo "Smart Light IP: ${MY_IP}"

# Light state variables
LIGHT_STATE="ON"
BRIGHTNESS=$((RANDOM % 70 + 30))  # 30-100%
COLOR_HUE=$((RANDOM % 360))       # 0-360 degrees
COLOR_SATURATION=$((RANDOM % 100))
COLOR_TEMP=$((RANDOM % 200 + 2000))  # 2000-4000K

# Function to simulate Hue Bridge connectivity
simulate_bridge_connectivity() {
    while true; do
        # Connect to local Hue Bridge
        local bridge_ip="${MY_IP%.*}.100"  # Assume bridge is at .100
        
        # Register with bridge and send status
        curl -X PUT -s --connect-timeout 5 http://${bridge_ip}/api/lights \
            -H "Content-Type: application/json" \
            -d '{"state":{"on":'$([ "$LIGHT_STATE" = "ON" ] && echo "true" || echo "false")',"bri":'$((BRIGHTNESS * 255 / 100))',"hue":'${COLOR_HUE}',"sat":'${COLOR_SATURATION}',"ct":'${COLOR_TEMP}'},"type":"Extended color light","name":"'${DEVICE_MODEL}'","modelid":"LCT015","manufacturername":"Philips"}' \
            >/dev/null 2>&1 || true
        
        # Heartbeat to bridge
        curl -s --connect-timeout 5 http://${bridge_ip}/api/config >/dev/null 2>&1 || true
        
        sleep $((RANDOM % 30 + 15))  # 15-45 seconds
    done
}

# Function to simulate cloud connectivity
simulate_cloud_connectivity() {
    local cloud_services=("api.meethue.com" "hue.philips.com" "my.philips.com")
    
    while true; do
        for service in "${cloud_services[@]}"; do
            # Send status to Philips cloud
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"light_status":{"id":"'${DEVICE_MODEL}'","state":"'${LIGHT_STATE}'","brightness":'${BRIGHTNESS}',"color":{"hue":'${COLOR_HUE}',"saturation":'${COLOR_SATURATION}',"temperature":'${COLOR_TEMP}'},"timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
            
            # Cloud service heartbeat
            curl -s --connect-timeout 5 https://${service} >/dev/null 2>&1 || true
        done
        
        sleep $((RANDOM % 180 + 120))  # 2-5 minutes
    done
}

# Function to simulate mobile app control
simulate_app_control() {
    while true; do
        # Simulate commands from Philips Hue app
        if [ $((RANDOM % 15)) -eq 0 ]; then
            local commands=("toggle" "brightness_change" "color_change" "scene_change")
            local command=${commands[$RANDOM % ${#commands[@]}]}
            
            case $command in
                "toggle")
                    if [ "$LIGHT_STATE" = "ON" ]; then
                        LIGHT_STATE="OFF"
                        echo "Light turned OFF via app"
                    else
                        LIGHT_STATE="ON"
                        echo "Light turned ON via app"
                    fi
                    ;;
                "brightness_change")
                    BRIGHTNESS=$((RANDOM % 70 + 30))
                    echo "Brightness changed to ${BRIGHTNESS}% via app"
                    ;;
                "color_change")
                    COLOR_HUE=$((RANDOM % 360))
                    COLOR_SATURATION=$((RANDOM % 100))
                    echo "Color changed (Hue: ${COLOR_HUE}, Sat: ${COLOR_SATURATION}) via app"
                    ;;
                "scene_change")
                    # Predefined scene colors
                    local scenes=("Relax:25:14922:90:2131" "Energize:75:25500:65:2000" "Reading:95:33863:15:2732" "Concentrate:75:41869:12:4292")
                    local scene=${scenes[$RANDOM % ${#scenes[@]}]}
                    IFS=':' read -r scene_name scene_bright scene_hue scene_sat scene_temp <<< "$scene"
                    
                    BRIGHTNESS=$scene_bright
                    COLOR_HUE=$scene_hue
                    COLOR_SATURATION=$scene_sat
                    COLOR_TEMP=$scene_temp
                    echo "Scene changed to ${scene_name} via app"
                    ;;
            esac
            
            # Acknowledge command
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"command_response":{"command":"'${command}'","device":"'${DEVICE_MODEL}'","new_state":{"brightness":'${BRIGHTNESS}',"hue":'${COLOR_HUE}',"saturation":'${COLOR_SATURATION}',"temperature":'${COLOR_TEMP}'},"timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 300 + 180))  # 3-8 minutes
    done
}

# Function to simulate automation and scheduling
simulate_automation() {
    while true; do
        local hour=$(date +%H)
        local minute=$(date +%M)
        
        # Sunrise/sunset simulation (rough times)
        if [ $hour -eq 7 ] && [ $minute -eq 0 ] && [ "$LIGHT_STATE" = "OFF" ]; then
            LIGHT_STATE="ON"
            BRIGHTNESS=70
            COLOR_TEMP=2500  # Warm morning light
            echo "Automated sunrise - Light turned ON"
            
        elif [ $hour -eq 22 ] && [ $minute -eq 0 ] && [ "$LIGHT_STATE" = "ON" ]; then
            BRIGHTNESS=20
            COLOR_TEMP=2000  # Very warm evening light
            echo "Automated evening dimming"
            
        elif [ $hour -eq 23 ] && [ $minute -eq 30 ]; then
            LIGHT_STATE="OFF"
            echo "Automated bedtime - Light turned OFF"
        fi
        
        # Motion-activated scenarios
        if [ $((RANDOM % 25)) -eq 0 ] && [ "$LIGHT_STATE" = "OFF" ]; then
            LIGHT_STATE="ON"
            BRIGHTNESS=40
            echo "Motion detected - Light automatically turned ON"
            
            # Send motion event
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"automation_trigger":{"type":"motion_detected","action":"light_on","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep 60  # Check every minute
    done
}

# Function to simulate entertainment sync
simulate_entertainment_sync() {
    while true; do
        # Philips Hue Entertainment (sync with TV/music)
        if [ $((RANDOM % 50)) -eq 0 ] && [ "$LIGHT_STATE" = "ON" ]; then
            echo "Entertainment sync activated"
            
            # Rapid color changes for sync effect
            for i in {1..10}; do
                COLOR_HUE=$((RANDOM % 360))
                COLOR_SATURATION=$((RANDOM % 50 + 50))
                BRIGHTNESS=$((RANDOM % 40 + 60))
                
                # Send sync data
                curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                    -H "Content-Type: application/json" \
                    -d '{"entertainment_sync":{"hue":'${COLOR_HUE}',"saturation":'${COLOR_SATURATION}',"brightness":'${BRIGHTNESS}',"device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                    >/dev/null 2>&1 || true
                
                sleep 1
            done
            
            echo "Entertainment sync completed"
        fi
        
        sleep $((RANDOM % 1800 + 1200))  # 20-50 minutes
    done
}

# Function to simulate firmware updates
simulate_firmware_updates() {
    while true; do
        # Check for firmware updates
        curl -s --connect-timeout 5 http://update.philips.com >/dev/null 2>&1 || true
        curl -s --connect-timeout 5 http://firmware.meethue.com >/dev/null 2>&1 || true
        
        sleep $((RANDOM % 7200 + 21600))  # 6-8 hours
    done
}

# Function to simulate energy usage reporting
simulate_energy_reporting() {
    while true; do
        # Calculate power consumption based on state and brightness
        local power_consumption=0
        if [ "$LIGHT_STATE" = "ON" ]; then
            power_consumption=$((BRIGHTNESS * 9 / 100))  # Max 9W for LED bulb
        fi
        
        # Send energy usage data
        curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
            -H "Content-Type: application/json" \
            -d '{"energy_usage":{"power_watts":'${power_consumption}',"daily_hours":'$((RANDOM % 8 + 4))',"device":"'${DEVICE_MODEL}'","efficiency":"LED","timestamp":"'$(date -Iseconds)'"}}' \
            >/dev/null 2>&1 || true
        
        sleep 1800  # Every 30 minutes
    done
}

# Function to simulate network discovery
simulate_network_discovery() {
    while true; do
        # Look for Hue Bridge on network
        nslookup _hue._tcp.local >/dev/null 2>&1 || true
        
        # UPnP/SSDP discovery for smart home integration
        nslookup _upnp._tcp.local >/dev/null 2>&1 || true
        
        # Scan for other Hue lights
        nmap -p 80,443 ${MY_IP%.*}.0/24 >/dev/null 2>&1 || true
        
        sleep $((RANDOM % 1800 + 3600))  # 1-2 hours
    done
}

# Start all processes in background
simulate_bridge_connectivity &
simulate_cloud_connectivity &
simulate_app_control &
simulate_automation &
simulate_entertainment_sync &
simulate_firmware_updates &
simulate_energy_reporting &
simulate_network_discovery &

# Keep the main process running
while true; do
    local state_display="State: ${LIGHT_STATE}"
    if [ "$LIGHT_STATE" = "ON" ]; then
        state_display="${state_display}, Brightness: ${BRIGHTNESS}%, Hue: ${COLOR_HUE}°, Temp: ${COLOR_TEMP}K"
    fi
    
    echo "Smart Light ${DEVICE_MODEL} - ${state_display} - $(date)"
    sleep 300  # Status update every 5 minutes
done 