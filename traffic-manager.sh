#!/bin/bash

# Traffic Generator Manager - Modular IoT and User Traffic
# Handles separate IoT and User traffic generation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_usage() {
    echo "Traffic Generator Manager - Modular Version"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  setup                    Initial setup and network creation"
    echo "  start iot               Start only IoT traffic generators"
    echo "  start user              Start only user traffic generators" 
    echo "  start all               Start both IoT and user traffic generators"
    echo "  stop iot                Stop IoT traffic generators"
    echo "  stop user               Stop user traffic generators"
    echo "  stop all                Stop all traffic generators"
    echo "  status                  Show status of all containers"
    echo "  logs [iot|user] [name]  Show logs for specific container"
    echo "  rebuild                 Rebuild all containers"
    echo "  clean                   Remove all containers and images"
    echo ""
    echo "Examples:"
    echo "  $0 setup                          # Initial setup"
    echo "  $0 start iot                      # Start only IoT devices"
    echo "  $0 start user                     # Start only user devices"
    echo "  $0 start all                      # Start everything"
    echo "  $0 logs iot smart-camera-01       # Show camera logs"
    echo "  $0 logs user user-gamer            # Show gamer logs"
}

setup_environment() {
    echo "================================================"
    echo "Traffic Generator Setup - Modular Version"
    echo "================================================"
    
    # Run the original setup for network creation
    if [ -f "./setup.sh" ]; then
        echo "Running network setup..."
        bash ./setup.sh
    else
        echo "Warning: setup.sh not found, you may need to create the sec_net network manually"
    fi
    
    # Check for environment file
    if [ ! -f ".env" ]; then
        echo ""
        echo "⚠️  Environment file not found"
        echo "Creating .env from template..."
        cp .env.template .env
        echo ""
        echo "📝 Please edit .env file with your firewall credentials:"
        echo "   nano .env"
        echo ""
        echo "Required settings:"
        echo "   FIREWALL_HOST=your.firewall.ip"
        echo "   FIREWALL_API_KEY=your_api_key"
    fi
    
    echo "✅ Setup complete!"
}

start_traffic() {
    local type="$1"
    
    case "$type" in
        "iot")
            echo "🤖 Starting IoT traffic generators..."
            cd "$SCRIPT_DIR/iot"
            docker compose up -d
            ;;
        "user")
            echo "👤 Starting user traffic generators..."
            if [ ! -f "$SCRIPT_DIR/.env" ]; then
                echo "⚠️  Warning: .env file not found. User registration with firewall may fail."
                echo "   Run './traffic-manager.sh setup' to create environment file."
            fi
            cd "$SCRIPT_DIR/user"
            docker compose --env-file="../.env" up -d
            ;;
        "all")
            echo "🚀 Starting all traffic generators..."
            if [ ! -f "$SCRIPT_DIR/.env" ]; then
                echo "⚠️  Warning: .env file not found. User registration with firewall may fail."
                echo "   Run './traffic-manager.sh setup' to create environment file."
            fi
            cd "$SCRIPT_DIR"
            docker compose --env-file=".env" -f docker compose.combined.yml up -d
            ;;
        *)
            echo "❌ Invalid type. Use: iot, user, or all"
            exit 1
            ;;
    esac
    
    echo "✅ Started $type traffic generators"
    show_status
}

stop_traffic() {
    local type="$1"
    
    case "$type" in
        "iot")
            echo "⏹️  Stopping IoT traffic generators..."
            cd "$SCRIPT_DIR/iot"
            docker compose down
            ;;
        "user")
            echo "⏹️  Stopping user traffic generators..."
            cd "$SCRIPT_DIR/user"
            docker compose down
            ;;
        "all")
            echo "⏹️  Stopping all traffic generators..."
            cd "$SCRIPT_DIR"
            docker compose -f docker compose.combined.yml down
            # Also stop individual components in case they were started separately
            cd "$SCRIPT_DIR/iot"
            docker compose down 2>/dev/null || true
            cd "$SCRIPT_DIR/user"
            docker compose down 2>/dev/null || true
            ;;
        *)
            echo "❌ Invalid type. Use: iot, user, or all"
            exit 1
            ;;
    esac
    
    echo "✅ Stopped $type traffic generators"
}

show_status() {
    echo ""
    echo "📊 Container Status:"
    echo "===================="
    
    # Show IoT containers
    echo ""
    echo "🤖 IoT Devices:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=iot-"
    
    # Show User containers  
    echo ""
    echo "👤 User Devices:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=user-"
}

show_logs() {
    local type="$1"
    local container="$2"
    
    if [ -z "$container" ]; then
        echo "❌ Please specify container name"
        echo "Available containers:"
        if [ "$type" = "iot" ]; then
            docker ps --format "{{.Names}}" --filter "name=iot-"
        elif [ "$type" = "user" ]; then
            docker ps --format "{{.Names}}" --filter "name=user-"
        fi
        exit 1
    fi
    
    echo "📜 Showing logs for $container..."
    docker logs -f "$container"
}

rebuild_containers() {
    echo "🔨 Rebuilding all containers..."
    
    # Stop everything first
    stop_traffic "all"
    
    # Remove images
    echo "Removing old images..."
    docker rmi $(docker images --filter "reference=*traffic-generator*" -q) 2>/dev/null || true
    docker rmi $(docker images --filter "reference=*iot*" -q) 2>/dev/null || true
    docker rmi $(docker images --filter "reference=*user*" -q) 2>/dev/null || true
    
    # Build common image
    echo "Building common image..."
    cd "$SCRIPT_DIR/common"
    docker build -t traffic-generator-common .
    
    echo "✅ Rebuild complete!"
}

clean_all() {
    echo "🧹 Cleaning all containers and images..."
    
    # Stop everything
    stop_traffic "all"
    
    # Remove containers
    docker rm $(docker ps -aq --filter "name=iot-") 2>/dev/null || true
    docker rm $(docker ps -aq --filter "name=user-") 2>/dev/null || true
    
    # Remove images
    docker rmi $(docker images --filter "reference=*traffic-generator*" -q) 2>/dev/null || true
    
    echo "✅ Cleanup complete!"
}

# Main script logic
case "${1:-}" in
    "setup")
        setup_environment
        ;;
    "start")
        start_traffic "${2:-all}"
        ;;
    "stop")
        stop_traffic "${2:-all}"
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs "$2" "$3"
        ;;
    "rebuild")
        rebuild_containers
        ;;
    "clean")
        clean_all
        ;;
    "help"|"--help"|"-h")
        show_usage
        ;;
    *)
        echo "❌ Unknown command: ${1:-}"
        echo ""
        show_usage
        exit 1
        ;;
esac 