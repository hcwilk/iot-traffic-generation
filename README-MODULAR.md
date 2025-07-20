# Modular Traffic Generator

A modular network traffic generation system that can simulate both IoT device traffic and realistic user traffic patterns, with integrated firewall user mapping via XML API.

## 🏗️ Project Structure

```
traffic-generator/
├── common/                          # Shared components
│   └── Dockerfile                   # Common container image
├── iot/                            # IoT traffic generation
│   ├── docker compose.yml          # IoT-only containers
│   ├── scripts/                    # IoT device scripts
│   └── device_macs.txt             # IoT MAC addresses
├── user/                           # User traffic generation
│   ├── docker compose.yml          # User-only containers
│   ├── scripts/                    # User traffic scripts
│   │   ├── firewall_api_utils.sh   # Firewall XML API utilities
│   │   ├── remote_worker_traffic.sh
│   │   ├── gamer_traffic.sh
│   │   ├── student_traffic.sh
│   │   ├── business_user_traffic.sh
│   │   └── family_user_traffic.sh
│   └── user_profiles.txt           # User profile definitions
├── docker compose.combined.yml     # Run both IoT and users
├── traffic-manager.sh              # Modular management script
├── .env.template                   # Environment configuration template
└── [legacy files...]              # Original files (still functional)
```

## 🚀 Quick Start

### 1. Initial Setup
```bash
# Run the modular setup
./traffic-manager.sh setup

# Edit your firewall credentials
nano .env
```

### 2. Configure Firewall Access
Edit the `.env` file with your firewall details:
```bash
FIREWALL_HOST=192.168.1.1
FIREWALL_USER=admin
FIREWALL_PASS=your_password
```

### 3. Start Traffic Generators

**Start only IoT devices:**
```bash
./traffic-manager.sh start iot
```

**Start only user devices:**
```bash
./traffic-manager.sh start user
```

**Start everything:**
```bash
./traffic-manager.sh start all
```

## 🤖 IoT Traffic Generation

The IoT module simulates various smart devices with realistic traffic patterns:

- **Smart Camera** (HIK-DS2CD2042WD): Video streaming, heartbeats
- **Smart Thermostat** (Nest-Learning-T3): Status updates, scheduling
- **Smart Plug** (TP-Link-HS100): Power monitoring, controls
- **Smart TV** (Samsung-UN55MU8000): Streaming, app usage
- **Smart Doorbell** (Ring-Video-Doorbell-Pro): Motion alerts, video
- **Smart Light** (Philips-Hue-A19): Status updates, automation
- **Smart Speaker** (Amazon-Echo-Dot-3rd): Voice commands, streaming
- **Smart Lock** (August-Smart-Lock-Pro): Access logs, status

### IoT-Only Operations
```bash
cd iot/
docker compose up -d                 # Start IoT devices
docker compose logs smart-camera-01  # View camera logs
docker compose down                  # Stop IoT devices
```

## 👤 User Traffic Generation

The user module simulates realistic human internet usage patterns and automatically registers users with your firewall:

### User Types

1. **Remote Worker** (`john.doe.remote`)
   - Video conferencing (Zoom, Teams, Google Meet)
   - Cloud storage sync (Dropbox, Drive, OneDrive)
   - Development tools (GitHub, npm, PyPI)
   - Heavy web browsing

2. **Gaming User** (`mike.wilson.gamer`)
   - Gaming servers (Valorant, CS2, League of Legends)
   - Game downloads and updates
   - Live streaming (Twitch, YouTube)
   - Voice chat (Discord)

3. **Student** (`alice.smith.student`)
   - Video streaming (Netflix, YouTube, Hulu)
   - Social media (Instagram, TikTok, Reddit)
   - Academic research (Google Scholar, JSTOR)
   - Online learning platforms

4. **Business User** (`bob.johnson.business`)
   - Email (Outlook, Office365)
   - CRM/Business apps (Salesforce, Slack)
   - Light web browsing
   - Document collaboration

5. **Family Device** (`family.tablet.shared`)
   - Family streaming services
   - Shopping websites
   - Social media browsing
   - Kids' content

### User-Only Operations
```bash
cd user/
docker compose --env-file="../.env" up -d  # Start user devices
docker compose logs user-gamer              # View gamer logs
docker compose down                         # Stop user devices
```

## 🔥 Firewall Integration

### XML API Features

Each user container automatically:
1. **Registers** the user profile with the firewall
2. **Maps** its IP address to the user ID
3. **Maintains** a heartbeat to keep the session active
4. **Cleans up** registration on container exit

### Firewall Configuration

The system uses your firewall's XML API to:
- Create user entries with names, departments, and email addresses
- Establish IP-to-user mappings for traffic attribution
- Enable user-based policies and reporting

### API Calls Examples

**User Registration:**
```xml
<request>
    <type>config</type>
    <action>set</action>
    <xpath>/config/devices/entry[@name='localhost.localdomain']/vsys/entry[@name='vsys1']/user/entry[@name='john.doe.remote']</xpath>
    <element>
        <full-name>John Doe</full-name>
        <email>john.doe.remote@company.local</email>
        <department>Engineering</department>
    </element>
</request>
```

**IP Mapping:**
```xml
<request>
    <type>config</type>
    <action>set</action>
    <xpath>/config/devices/entry[@name='localhost.localdomain']/vsys/entry[@name='vsys1']/user-id-agent</xpath>
    <element>
        <ip-user-mapping>
            <entry ip='192.168.1.100'>
                <user>john.doe.remote</user>
            </entry>
        </ip-user-mapping>
    </element>
</request>
```

## 🛠️ Management Commands

### Traffic Manager Script
```bash
./traffic-manager.sh [COMMAND] [OPTIONS]
```

**Commands:**
- `setup` - Initial setup and network creation
- `start iot` - Start only IoT traffic generators  
- `start user` - Start only user traffic generators
- `start all` - Start both IoT and user traffic generators
- `stop iot` - Stop IoT traffic generators
- `stop user` - Stop user traffic generators  
- `stop all` - Stop all traffic generators
- `status` - Show status of all containers
- `logs [iot|user] [name]` - Show logs for specific container
- `rebuild` - Rebuild all containers
- `clean` - Remove all containers and images

### Examples
```bash
./traffic-manager.sh setup              # Initial setup
./traffic-manager.sh start iot          # Start only IoT devices
./traffic-manager.sh start user         # Start only user devices  
./traffic-manager.sh logs iot iot-camera-01       # Show camera logs
./traffic-manager.sh logs user user-gamer         # Show gamer logs
./traffic-manager.sh status             # Show all container status
```

## 🔧 Advanced Configuration

### Adding New IoT Devices

1. Edit `iot/docker compose.yml` to add new device
2. Create device script in `iot/scripts/`
3. Add MAC address to `iot/device_macs.txt`

### Adding New User Types

1. Edit `user/docker compose.yml` to add new user
2. Create traffic script in `user/scripts/`
3. Add profile to `user/user_profiles.txt`
4. Follow the existing firewall integration pattern

### Environment Variables

```bash
# Required for user traffic with firewall integration
FIREWALL_HOST=192.168.1.1        # Your firewall IP
FIREWALL_USER=admin              # Firewall admin username  
FIREWALL_PASS=password           # Firewall admin password

# Optional network settings
SUBNET=192.168.1.0/24           # Network subnet
GATEWAY=192.168.1.1             # Network gateway
```

## 🔍 Monitoring and Debugging

### Container Logs
```bash
# IoT device logs
docker logs -f iot-camera-01
docker logs -f iot-thermostat-01

# User device logs  
docker logs -f user-remote-worker
docker logs -f user-gamer
```

### Network Inspection
```bash
# Check network connectivity
docker network inspect sec_net

# View container IPs
docker ps --format "table {{.Names}}\t{{.Networks}}\t{{.Ports}}"
```

### Firewall Verification
Check your firewall's user identification logs to verify:
- Users are being registered
- IP mappings are active  
- Traffic is properly attributed

## 🤝 Backward Compatibility

The original files remain functional:
- `docker compose.yml` - Original IoT-only setup
- `manage.sh` - Original management script
- `setup.sh` - Original network setup

You can continue using the original system or migrate to the modular approach.

## 🔐 Security Considerations

- Store firewall credentials securely in `.env` file (add to `.gitignore`)
- Use least-privilege firewall API accounts
- Monitor API usage and logs
- Consider using API keys instead of passwords where supported

## 📊 Traffic Patterns

### IoT Traffic Characteristics
- Low bandwidth, consistent heartbeats
- Periodic status updates
- Occasional high-bandwidth streaming (cameras, doorbells)
- Device-specific protocols and ports

### User Traffic Characteristics  
- Variable bandwidth based on activity
- Realistic browsing patterns
- Application-specific traffic flows
- Peak usage during certain hours

## 🚨 Troubleshooting

**Network Issues:**
```bash
# Recreate network
docker network rm sec_net
./traffic-manager.sh setup
```

**Firewall Connection Issues:**
- Verify credentials in `.env` file
- Check firewall API access is enabled
- Ensure network connectivity to firewall
- Check firewall logs for API errors

**Container Issues:**
```bash
# Rebuild everything
./traffic-manager.sh rebuild

# Clean start
./traffic-manager.sh clean
./traffic-manager.sh setup
```

This modular approach gives you complete flexibility to run IoT devices, user traffic, or both simultaneously while maintaining clean separation of concerns. 