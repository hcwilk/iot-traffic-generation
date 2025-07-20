#!/bin/bash

# Standalone Firewall User-ID API Test Script
# Test the User-ID mapping functionality directly from your machine

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DEFAULT_USER_ID="testuser"
DEFAULT_USER_IP="192.168.1.100"
DEFAULT_FIREWALL_HOST=""
DEFAULT_API_KEY=""

show_usage() {
    echo "Firewall User-ID API Test Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --firewall-host HOST    Firewall IP or hostname (required)"
    echo "  --api-key KEY           API key for authentication (required)"
    echo "  --user-id ID            User ID to test with (default: testuser)"
    echo "  --user-ip IP            IP address to map (default: 192.168.1.100)"
    echo "  --test-login-only       Only test login (mapping) operation"
    echo "  --test-logout-only      Only test logout (unmapping) operation"
    echo "  --help                  Show this help message"
    echo ""
    echo "Environment Variables (alternative to command line options):"
    echo "  FIREWALL_HOST           Firewall IP or hostname"
    echo "  FIREWALL_API_KEY        API key for authentication"
    echo ""
    echo "Examples:"
    echo "  $0 --firewall-host 192.168.1.1 --api-key YOUR_API_KEY"
    echo "  $0 --firewall-host 192.168.1.1 --api-key YOUR_API_KEY --user-id john.doe --user-ip 192.168.1.50"
    echo ""
    echo "Or set environment variables and run:"
    echo "  export FIREWALL_HOST=192.168.1.1"
    echo "  export FIREWALL_API_KEY=YOUR_API_KEY"
    echo "  $0"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --firewall-host)
            FIREWALL_HOST="$2"
            shift 2
            ;;
        --api-key)
            FIREWALL_API_KEY="$2"
            shift 2
            ;;
        --user-id)
            USER_ID="$2"
            shift 2
            ;;
        --user-ip)
            USER_IP="$2"
            shift 2
            ;;
        --test-login-only)
            TEST_LOGIN_ONLY=true
            shift
            ;;
        --test-logout-only)
            TEST_LOGOUT_ONLY=true
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Set defaults if not provided
USER_ID="${USER_ID:-$DEFAULT_USER_ID}"
USER_IP="${USER_IP:-$DEFAULT_USER_IP}"
FIREWALL_HOST="${FIREWALL_HOST:-$DEFAULT_FIREWALL_HOST}"
FIREWALL_API_KEY="${FIREWALL_API_KEY:-$DEFAULT_API_KEY}"

# Check required parameters
if [ -z "$FIREWALL_HOST" ] || [ -z "$FIREWALL_API_KEY" ]; then
    echo -e "${RED}Error: Firewall host and API key are required${NC}"
    echo ""
    show_usage
    exit 1
fi

# Check if curl is available
if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is not installed. Please install curl to run this test.${NC}"
    exit 1
fi

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    Firewall User-ID API Test${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Firewall Host: $FIREWALL_HOST"
echo "  API Key: ${FIREWALL_API_KEY:0:8}********"
echo "  User ID: $USER_ID"
echo "  User IP: $USER_IP"
echo ""

# Source the firewall API utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_FILE="$SCRIPT_DIR/user/scripts/firewall_api_utils.sh"

if [ ! -f "$UTILS_FILE" ]; then
    echo -e "${RED}Error: Cannot find firewall API utilities at $UTILS_FILE${NC}"
    echo "Make sure you're running this script from the project root directory."
    exit 1
fi

echo -e "${BLUE}Loading firewall API utilities...${NC}"
source "$UTILS_FILE"
echo ""

# Test connectivity to firewall
echo -e "${BLUE}Testing connectivity to firewall...${NC}"
if curl -k -s --connect-timeout 5 "https://$FIREWALL_HOST/api/" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Firewall is reachable${NC}"
else
    echo -e "${RED}✗ Cannot reach firewall at https://$FIREWALL_HOST/api/${NC}"
    echo -e "${YELLOW}  This may be normal if the firewall blocks unauthenticated requests${NC}"
fi
echo ""

# Test User-ID mapping (login)
if [ "$TEST_LOGOUT_ONLY" != true ]; then
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}    Testing User-ID Mapping (Login)${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    register_ip_user_mapping "$USER_ID" "$USER_IP"
    
    echo ""
    echo -e "${GREEN}Login test completed!${NC}"
    echo ""
fi

# Wait between operations if testing both
if [ "$TEST_LOGIN_ONLY" != true ] && [ "$TEST_LOGOUT_ONLY" != true ]; then
    echo -e "${YELLOW}Waiting 5 seconds before testing logout...${NC}"
    sleep 5
    echo ""
fi

# Test User-ID unmapping (logout)
if [ "$TEST_LOGIN_ONLY" != true ]; then
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}    Testing User-ID Unmapping (Logout)${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    unregister_ip_user_mapping "$USER_ID" "$USER_IP"
    
    echo ""
    echo -e "${GREEN}Logout test completed!${NC}"
    echo ""
fi

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    Test Summary${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${YELLOW}What to check on your firewall:${NC}"
echo ""
echo "1. Check User-ID mappings in your firewall interface"
echo "   - Look for user '$USER_ID' mapped to IP '$USER_IP'"
echo "   - If you tested logout, the mapping should be removed"
echo ""
echo "2. Check firewall logs for User-ID events"
echo "   - Login events should show user mapping"
echo "   - Logout events should show user unmapping"
echo ""
echo "3. Monitor traffic from test IP"
echo "   - Generate some traffic from $USER_IP (if accessible)"
echo "   - Verify it shows as coming from user '$USER_ID' in logs"
echo ""

if [ "$TEST_LOGIN_ONLY" == true ]; then
    echo -e "${YELLOW}Note: Only login was tested. User mapping may still be active.${NC}"
    echo -e "${YELLOW}Run with --test-logout-only to clean up, or manually unmap.${NC}"
fi

echo -e "${GREEN}Test script completed successfully!${NC}" 