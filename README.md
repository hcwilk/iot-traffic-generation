# IoT Traffic Generator

A comprehensive tool for generating realistic IoT device traffic to test network security solutions, particularly IoT security subscriptions and firewalls. This tool simulates various IoT appliances with authentic MAC addresses, traffic patterns, and behaviors.

## Overview

This project creates multiple Docker containers, each spoofing different IoT devices and generating realistic network traffic patterns. Each device has its own IP address and MAC address from real IoT manufacturers, making them appear as genuine IoT appliances on your network.

## Supported IoT Devices

| Device Type | Brand/Model | Traffic Patterns |
|-------------|-------------|------------------|
| **Smart Camera** | Hikvision DS-2CD2042WD | Video streaming, motion events, cloud uploads, NVR communication |
| **Smart Thermostat** | Nest Learning T3 | Weather data, mobile app sync, energy reporting, cloud connectivity |
| **Smart Plug** | TP-Link HS100 | Energy monitoring, scheduling, mobile control, cloud status updates |
| **Smart TV** | Samsung UN55MU8000 | Streaming services, app platform sync, advertising, voice control |
| **Smart Doorbell** | Ring Video Doorbell Pro | Motion detection, video uploads, live streaming, neighbor network |
| **Smart Light** | Philips Hue A19 | Bridge communication, entertainment sync, scheduling, scene changes |
| **Smart Speaker** | Amazon Echo Dot 3rd | Voice commands, music streaming, smart home hub, Alexa skills |
| **Smart Lock** | August Smart Lock Pro | Lock/unlock events, proximity detection, guest access, security monitoring |

## Features

- **Authentic MAC Addresses**: Uses real manufacturer OUIs (Organizationally Unique Identifiers)
- **Realistic Traffic Patterns**: Each device generates traffic typical of its real-world counterpart
- **Scalable Architecture**: Easy to scale up/down the number of each device type
- **Network Integration**: Devices get real IP addresses on your network via DHCP
- **Comprehensive Logging**: Detailed activity logs for each simulated device
- **Easy Management**: Simple scripts for setup, management, and monitoring

## Prerequisites

- **Linux Server**: Ubuntu 18.04+ or similar (tested on Ubuntu)
- **Docker**: Version 20.10+ 
- **Docker Compose**: Version 1.29+
- **Network Access**: DHCP server capable of assigning IP addresses to containers
- **Firewall**: PANW or similar firewall with IoT device detection capabilities (for testing)

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd traffic-generator

# Run the setup script (may require sudo for network configuration)
sudo ./setup.sh
```

### 2. Start IoT Devices

```bash
# Start all IoT devices
./manage.sh start

# Check device status
./manage.sh status
```

### 3. Monitor Activity

```bash
# View logs from all devices
./manage.sh logs

# View logs from specific device
./manage.sh logs smart-camera-01

# Show device statistics
./manage.sh stats
```

## Installation Details

### Network Configuration

The setup script creates a `macvlan` Docker network called `sec_net` that allows containers to get IP addresses directly from your network's DHCP server. This makes them appear as real devices on your network.

**Network Requirements:**
- DHCP server with available IP addresses
- Firewall/router that can assign IPs to new MAC addresses
- Network subnet with sufficient address space

### MAC Address Generation

The tool generates unique MAC addresses using real IoT manufacturer OUIs:

- **Hikvision**: `00:11:32:XX:XX:XX` (Security cameras)
- **Nest Labs**: `18:B4:30:XX:XX:XX` (Thermostats)
- **TP-Link**: `50:C7:BF:XX:XX:XX` (Smart plugs/routers)
- **Samsung**: `04:5E:A4:XX:XX:XX` (Smart TVs/appliances)
- **Ring/Amazon**: `B0:7F:B9:XX:XX:XX` (Doorbells/cameras)
- **Philips**: `00:17:88:XX:XX:XX` (Smart lighting)
- **Amazon**: `68:37:E9:XX:XX:XX` (Echo devices)
- **August Home**: `D8:F1:5B:XX:XX:XX` (Smart locks)

## Usage Examples

### Basic Operations

```bash
# Setup (run once)
sudo ./setup.sh

# Start all devices
./manage.sh start

# Scale to 3 instances of each device type
./manage.sh scale 3

# Stop all devices
./manage.sh stop

# Complete cleanup
./manage.sh cleanup
```

### Monitoring and Debugging

```bash
# Show overall status
./manage.sh status

# Monitor live logs
./manage.sh logs

# Monitor specific device
./manage.sh logs smart-thermostat-01

# Show resource usage
./manage.sh stats

# Access device shell
./manage.sh exec smart-camera-01
```

### Advanced Configuration

#### Custom Device Count

Edit `docker compose.yml` to add more instances:

```yaml
smart-camera-02:
  build: .
  container_name: iot-camera-02
  hostname: HIK-Camera-02
  networks:
    sec_net:
      mac_address: "00:11:32:XX:XX:02"  # Generate unique MAC
  environment:
    - DEVICE_TYPE=camera
    - DEVICE_MODEL=HIK-DS2CD2042WD-02
    - DEVICE_MAC=00:11:32:XX:XX:02
  volumes:
    - ./scripts:/app/scripts
  command: ["/app/scripts/camera_traffic.sh"]
```

#### Custom Traffic Patterns

Modify the scripts in the `scripts/` directory to adjust traffic patterns:

- `scripts/camera_traffic.sh` - Camera behavior
- `scripts/thermostat_traffic.sh` - Thermostat behavior
- `scripts/smart_plug_traffic.sh` - Smart plug behavior
- etc.

## Traffic Patterns Explained

### Smart Camera
- **Video Streaming**: Continuous uploads to cloud storage
- **Motion Events**: Spike in traffic when motion detected
- **RTSP Streams**: Real-time streaming protocol traffic
- **Cloud Sync**: Regular status updates and configuration sync

### Smart Thermostat
- **Weather Data**: Regular API calls to weather services
- **Mobile App Sync**: Bi-directional communication with mobile apps
- **Energy Reporting**: Hourly energy usage statistics
- **Cloud Connectivity**: Continuous connection to Nest/Google cloud

### Smart Plug
- **Energy Monitoring**: Real-time power consumption data
- **Scheduling**: Time-based on/off operations
- **Mobile Control**: Remote control via smartphone apps
- **Cloud Status**: Regular status updates to manufacturer cloud

### Smart TV
- **Streaming Services**: High-bandwidth video from Netflix, YouTube, etc.
- **Platform Sync**: Communication with Samsung/TV platform services
- **Advertising**: Ad targeting and analytics traffic
- **Voice Control**: Audio processing for voice commands

### Smart Doorbell
- **Motion Detection**: Video uploads when motion detected
- **Live Streaming**: On-demand video streaming to mobile apps
- **Push Notifications**: Alert messages to cloud services
- **Two-way Audio**: Real-time audio communication

### Smart Light
- **Bridge Communication**: Local communication with Philips Hue bridge
- **Entertainment Sync**: Color synchronization with media
- **Mobile App Control**: Remote brightness/color changes
- **Automation**: Scheduled lighting changes

### Smart Speaker
- **Voice Processing**: Audio uploads for voice command processing
- **Music Streaming**: High-quality audio streaming
- **Smart Home Hub**: Communication with other IoT devices
- **Skill Updates**: Downloads of new Alexa skills

### Smart Lock
- **Lock Events**: Status updates for lock/unlock operations
- **Mobile App Sync**: Real-time status with mobile applications
- **Guest Access**: Temporary access code management
- **Security Monitoring**: Door sensor and security alerts

## Testing with Firewalls

### PANW (Palo Alto Networks) Configuration

1. **Enable IoT Security Subscription**
2. **Configure Device Identification**:
   - Navigate to Network → IoT Security
   - Enable device discovery
   - Configure policy rules for IoT devices

3. **Monitor Detection**:
   - Check Device → IoT Devices for discovered devices
   - Verify device classification and risk assessment
   - Review security recommendations

### Expected Results

When properly configured, your firewall should:
- Detect each container as a separate IoT device
- Classify devices by type (camera, thermostat, etc.)
- Show manufacturer information based on MAC addresses
- Generate security recommendations
- Display traffic patterns and communication flows

## Troubleshooting

### Common Issues

**1. Containers not getting IP addresses**
```bash
# Check network configuration
docker network inspect sec_net

# Verify DHCP server has available addresses
# Check firewall/router DHCP settings
```

**2. Permission denied during setup**
```bash
# Run setup with sudo
sudo ./setup.sh

# Check Docker permissions
sudo usermod -aG docker $USER
# Log out and back in
```

**3. MAC address conflicts**
```bash
# Regenerate MAC addresses
rm device_macs.txt
./setup.sh
```

**4. High resource usage**
```bash
# Check container resource usage
./manage.sh stats

# Scale down if needed
./manage.sh scale 1
```

### Log Analysis

Monitor device behavior:
```bash
# Check for errors
./manage.sh logs | grep -i error

# Monitor specific traffic type
./manage.sh logs smart-camera-01 | grep -i "motion\|upload"

# Check network connectivity
./manage.sh exec smart-thermostat-01
# Inside container:
ping google.com
curl -I https://nest.com
```

## Security Considerations

### Network Isolation

Consider isolating IoT traffic:
- Use VLANs to segment IoT devices
- Implement firewall rules for IoT traffic
- Monitor for unusual behavior patterns

### Resource Management

- Monitor system resources with large deployments
- Consider rate limiting for high-traffic devices
- Use resource constraints in Docker Compose if needed

### Data Privacy

- Traffic generation uses simulated data only
- No real personal information is transmitted
- Test endpoints use public APIs and test services

## Contributing

To add new IoT device types:

1. Create a new traffic generation script in `scripts/`
2. Add the device to `docker compose.yml`
3. Add appropriate MAC address OUI to `setup.sh`
4. Update documentation

Example device script structure:
```bash
#!/bin/bash
echo "Starting [Device Type] Traffic Generator - ${DEVICE_MODEL}"
# Device-specific traffic patterns
# Cloud connectivity simulation
# Mobile app communication
# Status reporting
```

## License

This project is intended for network security testing and educational purposes. Use responsibly and in compliance with your organization's security policies.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review container logs: `./manage.sh logs`
3. Verify network configuration
4. Check firewall/DHCP settings

---

**Disclaimer**: This tool is designed for testing IoT security solutions in controlled environments. Users are responsible for compliance with applicable laws and organizational policies. 