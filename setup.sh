#!/bin/bash

# IoT Traffic Generator Setup Script
# This script prepares the environment for running the IoT traffic generator

set -e

echo "================================================"
echo "IoT Traffic Generator Setup"
echo "================================================"

# Check if running as root (needed for some network operations)
if [[ $EUID -eq 0 ]]; then
   echo "Warning: Running as root. This is required for network configuration."
fi

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check for Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✓ Docker and Docker Compose are installed"

# Create or check the sec_net network
echo "Setting up Docker network 'sec_net'..."

if docker network ls | grep -q "sec_net"; then
    echo "✓ Network 'sec_net' already exists"
    
    # Show network details
    echo ""
    echo "Current network configuration:"
    docker network inspect sec_net | grep -E '"Name"|"Driver"|"IPAM"' -A 10
else
    echo "Creating macvlan network 'sec_net'..."
    
    # Get the default network interface
    DEFAULT_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
    
    if [ -z "$DEFAULT_INTERFACE" ]; then
        echo "Error: Could not determine default network interface"
        echo "Please create the network manually:"
        echo "docker network create -d macvlan --subnet=192.168.1.0/24 --gateway=192.168.1.1 -o parent=<your_interface> sec_net"
        exit 1
    fi
    
    # Get current IP info
    CURRENT_IP=$(ip addr show $DEFAULT_INTERFACE | grep -oP 'inet \K[\d.]+' | head -n1)
    SUBNET=$(echo $CURRENT_IP | cut -d. -f1-3).0/24
    GATEWAY=$(echo $CURRENT_IP | cut -d. -f1-3).1
    
    echo "Detected interface: $DEFAULT_INTERFACE"
    echo "Detected subnet: $SUBNET"
    echo "Detected gateway: $GATEWAY"
    echo ""
    echo "Creating macvlan network with these settings..."
    
    # Create macvlan network
    docker network create -d macvlan \
        --subnet=$SUBNET \
        --gateway=$GATEWAY \
        -o parent=$DEFAULT_INTERFACE \
        sec_net
    
    if [ $? -eq 0 ]; then
        echo "✓ Network 'sec_net' created successfully"
    else
        echo "Error: Failed to create network. You may need to run this script with sudo."
        echo "Or create the network manually with the correct subnet for your environment."
        exit 1
    fi
fi

# Generate unique MAC addresses if they don't exist
echo ""
echo "Generating unique MAC addresses for IoT devices..."

MAC_FILE="device_macs.txt"
if [ ! -f "$MAC_FILE" ]; then
    echo "# Generated MAC addresses for IoT devices" > $MAC_FILE
    echo "# Format: Device:MAC_Address:OUI_Manufacturer" >> $MAC_FILE
    echo "" >> $MAC_FILE
    
    # Generate MAC addresses using real IoT manufacturer OUIs
    echo "smart-camera-01:00:11:32:$(openssl rand -hex 3 | sed 's/\(..\)\(..\)\(..\)/\1:\2:\3/'):Hikvision" >> $MAC_FILE
    echo "smart-thermostat-01:18:B4:30:$(openssl rand -hex 3 | sed 's/\(..\)\(..\)\(..\)/\1:\2:\3/'):Nest_Labs" >> $MAC_FILE
    echo "smart-plug-01:50:C7:BF:$(openssl rand -hex 3 | sed 's/\(..\)\(..\)\(..\)/\1:\2:\3/'):TP_Link" >> $MAC_FILE
    echo "smart-tv-01:04:5E:A4:$(openssl rand -hex 3 | sed 's/\(..\)\(..\)\(..\)/\1:\2:\3/'):Samsung" >> $MAC_FILE
    echo "smart-doorbell-01:B0:7F:B9:$(openssl rand -hex 3 | sed 's/\(..\)\(..\)\(..\)/\1:\2:\3/'):Ring_Amazon" >> $MAC_FILE
    echo "smart-light-01:00:17:88:$(openssl rand -hex 3 | sed 's/\(..\)\(..\)\(..\)/\1:\2:\3/'):Philips" >> $MAC_FILE
    echo "smart-speaker-01:68:37:E9:$(openssl rand -hex 3 | sed 's/\(..\)\(..\)\(..\)/\1:\2:\3/'):Amazon" >> $MAC_FILE
    echo "smart-lock-01:D8:F1:5B:$(openssl rand -hex 3 | sed 's/\(..\)\(..\)\(..\)/\1:\2:\3/'):August_Home" >> $MAC_FILE
    
    echo "✓ Generated MAC addresses in $MAC_FILE"
else
    echo "✓ MAC addresses file already exists"
fi

# Update Docker Compose file with generated MAC addresses
echo ""
echo "Updating Docker Compose file with generated MAC addresses..."

# Read MAC addresses and update docker-compose.yml
while IFS=: read -r device mac_part1 mac_part2 mac_part3 mac_part4 mac_part5 mac_part6 manufacturer; do
    if [[ $device =~ ^[[:space:]]*# ]] || [[ -z $device ]]; then
        continue  # Skip comments and empty lines
    fi
    
    full_mac="${mac_part1}:${mac_part2}:${mac_part3}:${mac_part4}:${mac_part5}:${mac_part6}"
    
    # Update docker-compose.yml with actual MAC
    sed -i "s/mac_address: \".*XX:XX:[0-9][0-9]\".*# ${device}/mac_address: \"${full_mac}\"/g" docker-compose.yml 2>/dev/null || true
done < $MAC_FILE

echo "✓ Docker Compose file updated with unique MAC addresses"

# Build the Docker image
echo ""
echo "Building IoT device Docker image..."
docker build -t traffic-gen .

if [ $? -eq 0 ]; then
    echo "✓ Docker image built successfully"
else
    echo "Error: Failed to build Docker image"
    exit 1
fi

# Make all scripts executable
echo ""
echo "Setting script permissions..."
chmod +x scripts/*.sh
chmod +x *.sh
echo "✓ Script permissions set"

# Display summary
echo ""
echo "================================================"
echo "Setup Complete!"
echo "================================================"
echo ""
echo "Your IoT traffic generator is ready to use!"
echo ""
echo "Generated devices and their MAC addresses:"
cat $MAC_FILE | grep -v "^#" | grep -v "^$" | while IFS=: read -r device mac_parts; do
    echo "  $device"
done
echo ""
echo "Next steps:"
echo "1. Review the generated MAC addresses in: $MAC_FILE"
echo "2. Start the IoT devices: ./manage.sh start"
echo "3. Monitor device activity: ./manage.sh logs"
echo "4. Scale up devices: ./manage.sh scale 3"
echo ""
echo "For more information, see README.md"
echo "" 