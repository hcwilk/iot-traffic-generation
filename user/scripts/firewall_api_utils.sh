#!/bin/bash

# Firewall User-ID API Utilities
# Functions for mapping users to IP addresses using the User-ID API (matching Python implementation)

# Function to map user to IP using User-ID API (equivalent to login operation)
register_ip_user_mapping() {
    local user_id="$1"
    local user_ip="$2"
    
    echo "[*] Mapping on ${FIREWALL_HOST}: User '${user_id}' -> IP '${user_ip}'"
    
    # User-ID XML payload matching the Python script format exactly
    local xml_payload="<uid-message><version>1.0</version><type>update</type><payload><login><entry name=\"${user_id}\" ip=\"${user_ip}\"/></login></payload></uid-message>"
    
    if [ -n "$FIREWALL_HOST" ] && [ -n "$FIREWALL_API_KEY" ]; then
        local response
        
        # Use User-ID API endpoint with form data (matching Python implementation)
        response=$(curl -k -s \
            -X POST \
            -d "type=user-id" \
            -d "action=set" \
            -d "key=${FIREWALL_API_KEY}" \
            -d "cmd=${xml_payload}" \
            "https://${FIREWALL_HOST}/api/" 2>/dev/null)
        
        echo ""
        echo "--- Firewall Response ---"
        if echo "$response" | grep -q 'status="success"'; then
            echo "Status: success"
            echo "✓ IP-to-user mapping registered successfully"
        else
            echo "Status: failed"
            echo "⚠ IP mapping registration may have failed"
            echo "Response: $response"
        fi
    else
        echo "⚠ Firewall credentials not provided, skipping user mapping"
        echo "Set FIREWALL_HOST and FIREWALL_API_KEY environment variables"
    fi
}

# Function to unmap user from IP using User-ID API (equivalent to logout operation)
unregister_ip_user_mapping() {
    local user_id="$1"
    local user_ip="$2"
    
    echo "[*] Unmapping on ${FIREWALL_HOST}: User '${user_id}' -> IP '${user_ip}'"
    
    # User-ID XML payload for logout (unmapping)
    local xml_payload="<uid-message><version>1.0</version><type>update</type><payload><logout><entry name=\"${user_id}\" ip=\"${user_ip}\"/></logout></payload></uid-message>"
    
    if [ -n "$FIREWALL_HOST" ] && [ -n "$FIREWALL_API_KEY" ]; then
        local response
        
        response=$(curl -k -s \
            -X POST \
            -d "type=user-id" \
            -d "action=set" \
            -d "key=${FIREWALL_API_KEY}" \
            -d "cmd=${xml_payload}" \
            "https://${FIREWALL_HOST}/api/" 2>/dev/null)
        
        echo ""
        echo "--- Firewall Response ---"
        if echo "$response" | grep -q 'status="success"'; then
            echo "Status: success"
            echo "✓ User unmapped successfully"
        else
            echo "Status: failed"
            echo "⚠ User unmapping may have failed"
            echo "Response: $response"
        fi
    fi
}

# Function to send periodic user activity heartbeat (refresh the mapping)
send_user_heartbeat() {
    local user_id="$1"
    local user_ip="$2"
    
    # Refresh the mapping by sending the same login command
    local xml_payload="<uid-message><version>1.0</version><type>update</type><payload><login><entry name=\"${user_id}\" ip=\"${user_ip}\"/></login></payload></uid-message>"

    if [ -n "$FIREWALL_HOST" ] && [ -n "$FIREWALL_API_KEY" ]; then
        curl -k -s \
            -X POST \
            -d "type=user-id" \
            -d "action=set" \
            -d "key=${FIREWALL_API_KEY}" \
            -d "cmd=${xml_payload}" \
            "https://${FIREWALL_HOST}/api/" >/dev/null 2>&1
    fi
}

# Function to cleanup user registration on exit
cleanup_user_registration() {
    local user_id="$1"
    local user_ip="$2"
    
    echo "Cleaning up user registration for ${user_id}"
    
    # Properly unmap the user using logout
    if [ -n "$user_ip" ]; then
        unregister_ip_user_mapping "$user_id" "$user_ip"
    fi
    
    echo "User ${user_id} session ended"
} 