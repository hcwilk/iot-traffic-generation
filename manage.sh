#!/bin/bash

# IoT Traffic Generator Management Script

set -e

COMPOSE_FILE="docker-compose.yml"
PROJECT_NAME="iot-traffic-gen"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================${NC}"
}

# Function to check if setup has been run
check_setup() {
    if [ ! -f "device_macs.txt" ]; then
        print_error "Setup has not been run. Please run ./setup.sh first."
        exit 1
    fi
    
    if ! docker network ls | grep -q "sec_net"; then
        print_error "Network 'sec_net' does not exist. Please run ./setup.sh first."
        exit 1
    fi
    
    if ! docker images | grep -q "traffic-gen"; then
        print_error "Docker image 'traffic-gen' not found. Please run ./setup.sh first."
        exit 1
    fi
}

# Function to start all IoT devices
start_devices() {
    print_header "Starting IoT Traffic Generator"
    
    check_setup
    
    print_status "Starting all IoT devices..."
    docker-compose -p $PROJECT_NAME up -d
    
    if [ $? -eq 0 ]; then
        print_status "All devices started successfully!"
        echo ""
        show_status
    else
        print_error "Failed to start devices"
        exit 1
    fi
}

# Function to stop all IoT devices
stop_devices() {
    print_header "Stopping IoT Traffic Generator"
    
    print_status "Stopping all IoT devices..."
    docker-compose -p $PROJECT_NAME down
    
    if [ $? -eq 0 ]; then
        print_status "All devices stopped successfully!"
    else
        print_error "Failed to stop devices"
        exit 1
    fi
}

# Function to restart all devices
restart_devices() {
    print_header "Restarting IoT Traffic Generator"
    
    stop_devices
    sleep 2
    start_devices
}

# Function to show device status
show_status() {
    print_header "IoT Device Status"
    
    echo ""
    echo "Container Status:"
    docker-compose -p $PROJECT_NAME ps
    
    echo ""
    echo "Network Information:"
    docker network inspect sec_net --format '{{range .Containers}}{{.Name}}: {{.IPv4Address}}{{"\n"}}{{end}}' 2>/dev/null || echo "No containers on sec_net"
    
    echo ""
    echo "Device Activity (last 10 lines per device):"
    for container in $(docker-compose -p $PROJECT_NAME ps -q); do
        container_name=$(docker inspect --format='{{.Name}}' $container | cut -c2-)
        echo ""
        echo "--- $container_name ---"
        docker logs --tail 5 $container 2>/dev/null || echo "No logs available"
    done
}

# Function to show logs
show_logs() {
    local device=$1
    
    if [ -z "$device" ]; then
        print_header "All Device Logs"
        docker-compose -p $PROJECT_NAME logs -f
    else
        print_header "Logs for $device"
        if docker-compose -p $PROJECT_NAME ps | grep -q $device; then
            docker-compose -p $PROJECT_NAME logs -f $device
        else
            print_error "Device '$device' not found"
            echo "Available devices:"
            docker-compose -p $PROJECT_NAME ps --services
            exit 1
        fi
    fi
}

# Function to scale devices
scale_devices() {
    local scale_factor=$1
    
    if [ -z "$scale_factor" ] || ! [[ "$scale_factor" =~ ^[0-9]+$ ]]; then
        print_error "Please provide a valid scale factor (number of instances per device type)"
        echo "Usage: $0 scale <number>"
        echo "Example: $0 scale 3  # Creates 3 instances of each device type"
        exit 1
    fi
    
    print_header "Scaling IoT Devices to $scale_factor instances each"
    
    check_setup
    
    # Scale each service
    services=$(docker-compose -p $PROJECT_NAME config --services)
    for service in $services; do
        print_status "Scaling $service to $scale_factor instances..."
        docker-compose -p $PROJECT_NAME up -d --scale $service=$scale_factor $service
    done
    
    print_status "Scaling complete!"
    echo ""
    show_status
}

# Function to clean up everything
cleanup() {
    print_header "Cleaning Up IoT Traffic Generator"
    
    print_warning "This will stop and remove all containers, and remove the Docker image."
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled."
        exit 0
    fi
    
    # Stop and remove containers
    docker-compose -p $PROJECT_NAME down -v --remove-orphans
    
    # Remove the Docker image
    docker rmi traffic-gen 2>/dev/null || true
    
    # Remove generated files (optional)
    read -p "Remove generated MAC addresses file? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f device_macs.txt
        print_status "MAC addresses file removed"
    fi
    
    print_status "Cleanup complete!"
}

# Function to generate additional devices
add_devices() {
    local device_type=$1
    local count=${2:-1}
    
    if [ -z "$device_type" ]; then
        print_error "Please specify device type"
        echo "Available types: camera, thermostat, plug, tv, doorbell, light, speaker, lock"
        exit 1
    fi
    
    print_header "Adding $count additional $device_type device(s)"
    
    # This would require dynamic Docker Compose generation
    # For now, show instruction for manual addition
    print_warning "To add devices, edit docker-compose.yml and add new service definitions"
    print_warning "Copy an existing $device_type service and change the container name and MAC address"
    echo ""
    echo "Example MAC addresses for common IoT manufacturers:"
    echo "Cameras (Hikvision): 00:11:32:XX:XX:XX"
    echo "Thermostats (Nest): 18:B4:30:XX:XX:XX"
    echo "Smart Plugs (TP-Link): 50:C7:BF:XX:XX:XX"
    echo "TVs (Samsung): 04:5E:A4:XX:XX:XX"
    echo "Doorbells (Ring): B0:7F:B9:XX:XX:XX"
    echo "Lights (Philips): 00:17:88:XX:XX:XX"
    echo "Speakers (Amazon): 68:37:E9:XX:XX:XX"
    echo "Locks (August): D8:F1:5B:XX:XX:XX"
}

# Function to show device statistics
show_stats() {
    print_header "IoT Device Statistics"
    
    # Container resource usage
    echo "Resource Usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" $(docker-compose -p $PROJECT_NAME ps -q) 2>/dev/null || echo "No running containers"
    
    echo ""
    echo "Network Traffic Summary (last 24 hours):"
    # This would require network monitoring tools in a real implementation
    print_warning "Network traffic monitoring requires additional tools (not implemented in this demo)"
    
    echo ""
    echo "Device Type Distribution:"
    docker-compose -p $PROJECT_NAME ps --format "table {{.Service}}\t{{.State}}" | tail -n +2 | sort | uniq -c
}

# Function to exec into a device container
exec_device() {
    local device=$1
    
    if [ -z "$device" ]; then
        print_error "Please specify device name"
        echo "Available devices:"
        docker-compose -p $PROJECT_NAME ps --services
        exit 1
    fi
    
    print_status "Connecting to $device..."
    docker-compose -p $PROJECT_NAME exec $device /bin/bash || docker-compose -p $PROJECT_NAME exec $device /bin/sh
}

# Function to show help
show_help() {
    echo "IoT Traffic Generator Management Script"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  start                 Start all IoT devices"
    echo "  stop                  Stop all IoT devices"
    echo "  restart               Restart all IoT devices"
    echo "  status                Show device status and network info"
    echo "  logs [device]         Show logs (all devices or specific device)"
    echo "  scale <number>        Scale each device type to specified number of instances"
    echo "  stats                 Show device statistics and resource usage"
    echo "  exec <device>         Execute shell in device container"
    echo "  add <type> [count]    Instructions for adding more devices"
    echo "  cleanup               Stop and remove everything"
    echo "  help                  Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start                    # Start all devices"
    echo "  $0 logs smart-camera-01     # Show logs for camera"
    echo "  $0 scale 5                  # Scale to 5 instances of each device"
    echo "  $0 exec smart-thermostat-01 # Open shell in thermostat"
    echo ""
}

# Main script logic
case "${1:-help}" in
    start)
        start_devices
        ;;
    stop)
        stop_devices
        ;;
    restart)
        restart_devices
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs $2
        ;;
    scale)
        scale_devices $2
        ;;
    stats)
        show_stats
        ;;
    exec)
        exec_device $2
        ;;
    add)
        add_devices $2 $3
        ;;
    cleanup)
        cleanup
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac 