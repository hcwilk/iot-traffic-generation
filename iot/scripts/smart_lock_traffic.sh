#!/bin/bash

# Smart Lock Traffic Generator
# Simulates August-style smart lock behavior

echo "Starting Smart Lock Traffic Generator - ${DEVICE_MODEL}"
echo "MAC Address: ${DEVICE_MAC}"
echo "Device Type: ${DEVICE_TYPE}"

# Wait for network to be ready
sleep 10

MY_IP=$(hostname -i | awk '{print $1}')
echo "Smart Lock IP: ${MY_IP}"

# Lock state variables
LOCK_STATE="locked"
BATTERY_LEVEL=$((RANDOM % 40 + 60))  # 60-100%
AUTO_LOCK_ENABLED="true"
GUEST_ACCESS_ACTIVE="false"

# Function to simulate cloud connectivity
simulate_cloud_connectivity() {
    local cloud_services=("august.com" "api.august.com" "connect.august.com")
    
    while true; do
        for service in "${cloud_services[@]}"; do
            # Send lock status to cloud
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"lock_status":{"state":"'${LOCK_STATE}'","battery":'${BATTERY_LEVEL}',"auto_lock":'${AUTO_LOCK_ENABLED}',"device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
            
            # Cloud service heartbeat
            curl -s --connect-timeout 5 https://${service} >/dev/null 2>&1 || true
        done
        
        sleep $((RANDOM % 180 + 120))  # 2-5 minutes
    done
}

# Function to simulate lock/unlock events
simulate_lock_events() {
    while true; do
        # Random lock/unlock events (more common during business hours)
        local hour=$(date +%H)
        local event_chance=15
        
        # Higher chance during active hours (6 AM - 11 PM)
        if [ $hour -ge 6 ] && [ $hour -le 23 ]; then
            event_chance=8
        fi
        
        if [ $((RANDOM % event_chance)) -eq 0 ]; then
            local lock_methods=("mobile_app" "keypad" "key_fob" "auto_unlock" "auto_lock")
            local method=${lock_methods[$RANDOM % ${#lock_methods[@]}]}
            
            case $method in
                "mobile_app")
                    if [ "$LOCK_STATE" = "locked" ]; then
                        LOCK_STATE="unlocked"
                        echo "Lock UNLOCKED via mobile app"
                    else
                        LOCK_STATE="locked"
                        echo "Lock LOCKED via mobile app"
                    fi
                    ;;
                "keypad")
                    if [ "$LOCK_STATE" = "locked" ]; then
                        LOCK_STATE="unlocked"
                        echo "Lock UNLOCKED via keypad entry"
                    fi
                    ;;
                "key_fob")
                    if [ "$LOCK_STATE" = "locked" ]; then
                        LOCK_STATE="unlocked"
                        echo "Lock UNLOCKED via key fob"
                    fi
                    ;;
                "auto_unlock")
                    if [ "$LOCK_STATE" = "locked" ] && [ "$AUTO_LOCK_ENABLED" = "true" ]; then
                        LOCK_STATE="unlocked"
                        echo "Lock AUTO-UNLOCKED (proximity detected)"
                    fi
                    ;;
                "auto_lock")
                    if [ "$LOCK_STATE" = "unlocked" ] && [ "$AUTO_LOCK_ENABLED" = "true" ]; then
                        LOCK_STATE="locked"
                        echo "Lock AUTO-LOCKED (timeout)"
                    fi
                    ;;
            esac
            
            # Send lock event to cloud
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"lock_event":{"action":"'${method}'","new_state":"'${LOCK_STATE}'","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'","user":"primary"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 1800 + 900))  # 15-45 minutes
    done
}

# Function to simulate mobile app connectivity
simulate_mobile_app() {
    while true; do
        # August app connectivity
        curl -s --connect-timeout 5 http://august.com/api/status >/dev/null 2>&1 || true
        
        # App polling for lock status
        curl -X GET -s --connect-timeout 5 http://httpbin.org/get >/dev/null 2>&1 || true
        
        # Simulate app-based settings changes
        if [ $((RANDOM % 30)) -eq 0 ]; then
            local settings=("auto_lock_toggle" "guest_access" "notification_settings")
            local setting=${settings[$RANDOM % ${#settings[@]}]}
            
            case $setting in
                "auto_lock_toggle")
                    if [ "$AUTO_LOCK_ENABLED" = "true" ]; then
                        AUTO_LOCK_ENABLED="false"
                        echo "Auto-lock DISABLED via app"
                    else
                        AUTO_LOCK_ENABLED="true"
                        echo "Auto-lock ENABLED via app"
                    fi
                    ;;
                "guest_access")
                    if [ "$GUEST_ACCESS_ACTIVE" = "false" ]; then
                        GUEST_ACCESS_ACTIVE="true"
                        echo "Guest access ENABLED via app"
                    else
                        GUEST_ACCESS_ACTIVE="false"
                        echo "Guest access DISABLED via app"
                    fi
                    ;;
                "notification_settings")
                    echo "Notification settings updated via app"
                    ;;
            esac
            
            # Send settings update to cloud
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"settings_update":{"setting":"'${setting}'","auto_lock":'${AUTO_LOCK_ENABLED}',"guest_access":'${GUEST_ACCESS_ACTIVE}',"device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 300 + 180))  # 3-8 minutes
    done
}

# Function to simulate guest access
simulate_guest_access() {
    while true; do
        if [ "$GUEST_ACCESS_ACTIVE" = "true" ] && [ $((RANDOM % 25)) -eq 0 ]; then
            echo "Guest access used"
            
            if [ "$LOCK_STATE" = "locked" ]; then
                LOCK_STATE="unlocked"
                
                # Send guest access event
                curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                    -H "Content-Type: application/json" \
                    -d '{"guest_access":{"action":"unlock","user":"guest_user","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'","access_method":"temporary_code"}}' \
                    >/dev/null 2>&1 || true
                
                # Auto-lock after guest access
                sleep 300  # 5 minutes
                if [ "$LOCK_STATE" = "unlocked" ]; then
                    LOCK_STATE="locked"
                    echo "Lock AUTO-LOCKED after guest access"
                fi
            fi
        fi
        
        sleep $((RANDOM % 3600 + 1800))  # 30-90 minutes
    done
}

# Function to simulate proximity detection
simulate_proximity_detection() {
    while true; do
        # Bluetooth/WiFi proximity detection
        if [ $((RANDOM % 20)) -eq 0 ] && [ "$AUTO_LOCK_ENABLED" = "true" ]; then
            if [ "$LOCK_STATE" = "locked" ]; then
                echo "Proximity detected - preparing for auto-unlock"
                
                # Send proximity event
                curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                    -H "Content-Type: application/json" \
                    -d '{"proximity_event":{"detected":true,"signal_strength":-45,"device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'","auto_unlock_ready":true}}' \
                    >/dev/null 2>&1 || true
            fi
        fi
        
        sleep $((RANDOM % 600 + 300))  # 5-15 minutes
    done
}

# Function to simulate security monitoring
simulate_security_monitoring() {
    while true; do
        # Door sensor monitoring (if equipped)
        if [ $((RANDOM % 40)) -eq 0 ]; then
            local door_events=("door_opened" "door_closed" "forced_entry_attempt")
            local event=${door_events[$RANDOM % ${#door_events[@]}]}
            
            case $event in
                "door_opened")
                    echo "Door opened detected"
                    ;;
                "door_closed")
                    echo "Door closed detected"
                    ;;
                "forced_entry_attempt")
                    echo "SECURITY ALERT: Forced entry attempt detected!"
                    
                    # Send security alert
                    curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                        -H "Content-Type: application/json" \
                        -d '{"security_alert":{"type":"forced_entry","severity":"high","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'","action_required":true}}' \
                        >/dev/null 2>&1 || true
                    ;;
            esac
            
            # Log door sensor event
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"door_sensor":{"event":"'${event}'","lock_state":"'${LOCK_STATE}'","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 1200 + 600))  # 10-30 minutes
    done
}

# Function to simulate firmware updates and battery monitoring
simulate_maintenance() {
    while true; do
        # Check for firmware updates
        curl -s --connect-timeout 5 http://updates.august.com >/dev/null 2>&1 || true
        
        # Battery level monitoring (gradually decreases)
        BATTERY_LEVEL=$((BATTERY_LEVEL - RANDOM % 3))
        if [ $BATTERY_LEVEL -lt 15 ]; then
            echo "LOW BATTERY WARNING: ${BATTERY_LEVEL}%"
            
            # Send low battery alert
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"battery_alert":{"level":'${BATTERY_LEVEL}',"status":"low","device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'","action_required":true}}' \
                >/dev/null 2>&1 || true
        fi
        
        # Reset battery if it gets too low (simulating battery replacement)
        if [ $BATTERY_LEVEL -lt 5 ]; then
            BATTERY_LEVEL=$((RANDOM % 40 + 60))
            echo "Battery replaced - new level: ${BATTERY_LEVEL}%"
        fi
        
        sleep $((RANDOM % 7200 + 10800))  # 3-5 hours
    done
}

# Function to simulate activity logs
simulate_activity_logging() {
    while true; do
        # Send periodic activity summary
        curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
            -H "Content-Type: application/json" \
            -d '{"activity_summary":{"lock_operations_24h":'$((RANDOM % 10 + 2))',"battery_level":'${BATTERY_LEVEL}',"auto_lock_events":'$((RANDOM % 5))',"device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
            >/dev/null 2>&1 || true
        
        sleep 3600  # Every hour
    done
}

# Function to simulate integration with smart home systems
simulate_smart_home_integration() {
    while true; do
        # HomeKit/SmartThings integration
        nslookup _homekit._tcp.local >/dev/null 2>&1 || true
        nslookup _smartthings._tcp.local >/dev/null 2>&1 || true
        
        # Send status to smart home hub
        if [ $((RANDOM % 20)) -eq 0 ]; then
            curl -X POST -s --connect-timeout 5 http://httpbin.org/post \
                -H "Content-Type: application/json" \
                -d '{"smart_home_update":{"device_type":"smart_lock","state":"'${LOCK_STATE}'","available":true,"device":"'${DEVICE_MODEL}'","timestamp":"'$(date -Iseconds)'"}}' \
                >/dev/null 2>&1 || true
        fi
        
        sleep $((RANDOM % 900 + 900))  # 15-30 minutes
    done
}

# Start all processes in background
simulate_cloud_connectivity &
simulate_lock_events &
simulate_mobile_app &
simulate_guest_access &
simulate_proximity_detection &
simulate_security_monitoring &
simulate_maintenance &
simulate_activity_logging &
simulate_smart_home_integration &

# Keep the main process running
while true; do
    echo "Smart Lock ${DEVICE_MODEL} - State: ${LOCK_STATE}, Battery: ${BATTERY_LEVEL}%, Auto-lock: ${AUTO_LOCK_ENABLED}, Guest: ${GUEST_ACCESS_ACTIVE} - $(date)"
    sleep 300  # Status update every 5 minutes
done 