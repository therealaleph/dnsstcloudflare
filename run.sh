#!/bin/bash

# Cloudflare DNS Setup Script
# Creates a random single-character A record and NS record
# Works on Linux, macOS, and Windows (Git Bash/WSL)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Cloudflare API endpoint
API_BASE="https://api.cloudflare.com/client/v4"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Cloudflare DNS Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required commands
if ! command_exists curl; then
    echo -e "${RED}Error: curl is not installed${NC}"
    echo "Please install curl first:"
    echo "  macOS: brew install curl"
    echo "  Linux: apt-get install curl or yum install curl"
    echo "  Windows: Already included in Git Bash"
    exit 1
fi

if ! command_exists jq; then
    echo -e "${YELLOW}Warning: jq is not installed. JSON parsing will be basic.${NC}"
    echo "Install jq for better output:"
    echo "  macOS: brew install jq"
    echo "  Linux: apt-get install jq or yum install jq"
    echo "  Windows: Download from https://stedolan.github.io/jq/"
    echo ""
    USE_JQ=false
else
    USE_JQ=true
fi

# Get Cloudflare credentials
echo -e "${YELLOW}Cloudflare API Credentials:${NC}"
read -p "Enter your Cloudflare Email: " CF_EMAIL
read -sp "Enter your Cloudflare API Key: " CF_API_KEY
echo ""

if [ -z "$CF_EMAIL" ] || [ -z "$CF_API_KEY" ]; then
    echo -e "${RED}Error: Email and API Key are required${NC}"
    exit 1
fi

# Get all zones and let user select
echo ""
echo -e "${BLUE}Fetching your domains...${NC}"
ZONES_RESPONSE=$(curl -s -X GET "${API_BASE}/zones" \
    -H "X-Auth-Email: ${CF_EMAIL}" \
    -H "X-Auth-Key: ${CF_API_KEY}" \
    -H "Content-Type: application/json")

if [ "$USE_JQ" = true ]; then
    SUCCESS=$(echo "$ZONES_RESPONSE" | jq -r '.success')
    if [ "$SUCCESS" != "true" ]; then
        ERROR_MSG=$(echo "$ZONES_RESPONSE" | jq -r '.errors[0].message // "Unknown error"')
        echo -e "${RED}Error getting zones: $ERROR_MSG${NC}"
        exit 1
    fi
    ZONE_COUNT=$(echo "$ZONES_RESPONSE" | jq -r '.result | length')
else
    # Basic parsing without jq
    if echo "$ZONES_RESPONSE" | grep -q '"success":true'; then
        ZONE_COUNT=$(echo "$ZONES_RESPONSE" | grep -o '"name":"[^"]*"' | wc -l | tr -d ' ')
    else
        echo -e "${RED}Error: Failed to get zones${NC}"
        echo "Response: $ZONES_RESPONSE"
        exit 1
    fi
fi

if [ "$ZONE_COUNT" -eq 0 ]; then
    echo -e "${RED}Error: No zones found in your Cloudflare account${NC}"
    exit 1
fi

# Display zones as numbered list
echo ""
echo -e "${YELLOW}Available domains:${NC}"
echo ""

if [ "$USE_JQ" = true ]; then
    # Use jq to parse and display
    echo "$ZONES_RESPONSE" | jq -r '.result[] | "\(.id)|\(.name)"' > /tmp/zones_list.txt
    ZONE_COUNT=$(wc -l < /tmp/zones_list.txt | tr -d ' ')
    COUNTER=1
    while IFS='|' read -r zone_id zone_name; do
        echo -e "  ${GREEN}$COUNTER${NC}. $zone_name"
        COUNTER=$((COUNTER + 1))
    done < /tmp/zones_list.txt
else
    # Parse without jq - extract zone names
    echo "$ZONES_RESPONSE" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 > /tmp/zone_names.txt
    echo "$ZONES_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4 > /tmp/zone_ids.txt
    ZONE_COUNT=$(wc -l < /tmp/zone_names.txt | tr -d ' ')
    COUNTER=1
    while read -r zone_name; do
        echo -e "  ${GREEN}$COUNTER${NC}. $zone_name"
        COUNTER=$((COUNTER + 1))
    done < /tmp/zone_names.txt
fi

echo ""
read -p "Select domain by number (1-$ZONE_COUNT): " SELECTION

# Validate selection
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -gt "$ZONE_COUNT" ]; then
    echo -e "${RED}Error: Invalid selection${NC}"
    exit 1
fi

# Get selected domain and zone ID
if [ "$USE_JQ" = true ]; then
    SELECTED_LINE=$(sed -n "${SELECTION}p" /tmp/zones_list.txt)
    DOMAIN=$(echo "$SELECTED_LINE" | cut -d'|' -f2)
    ZONE_ID=$(echo "$SELECTED_LINE" | cut -d'|' -f1)
    rm -f /tmp/zones_list.txt
else
    DOMAIN=$(sed -n "${SELECTION}p" /tmp/zone_names.txt)
    ZONE_ID=$(sed -n "${SELECTION}p" /tmp/zone_ids.txt)
    rm -f /tmp/zone_names.txt /tmp/zone_ids.txt
fi

echo -e "${GREEN}✓ Selected domain: $DOMAIN${NC}"
echo -e "${GREEN}✓ Zone ID: $ZONE_ID${NC}"
echo ""

# Get server IP
read -p "Enter server IP address: " SERVER_IP

if [ -z "$SERVER_IP" ]; then
    echo -e "${RED}Error: Server IP is required${NC}"
    exit 1
fi

# Validate IP format (basic check)
if ! [[ $SERVER_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo -e "${YELLOW}Warning: IP format may be invalid, continuing anyway...${NC}"
fi

echo ""
echo -e "${BLUE}Setting up DNS records...${NC}"
echo ""

# Generate random single character for A record (cross-platform compatible)
# Use a simple method that works everywhere
LETTERS="abcdefghijklmnopqrstuvwxyz"
if [ -n "$RANDOM" ]; then
    INDEX=$(($RANDOM % 26))
else
    # Fallback: use date + PID for randomness
    SEED=$(($(date +%s) + $$))
    INDEX=$(($SEED % 26))
fi
RANDOM_CHAR=$(echo "$LETTERS" | cut -c $((INDEX + 1)))
A_RECORD_NAME="${RANDOM_CHAR}.${DOMAIN}"

echo -e "${BLUE}Creating A record:${NC}"
echo "  Name: $A_RECORD_NAME"
echo "  Type: A"
echo "  Content: $SERVER_IP"
echo "  Proxied: false"
echo ""

# Create A record
A_RECORD_RESPONSE=$(curl -s -X POST "${API_BASE}/zones/${ZONE_ID}/dns_records" \
    -H "X-Auth-Email: ${CF_EMAIL}" \
    -H "X-Auth-Key: ${CF_API_KEY}" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"${A_RECORD_NAME}\",\"content\":\"${SERVER_IP}\",\"proxied\":false,\"ttl\":1}")

if [ "$USE_JQ" = true ]; then
    SUCCESS=$(echo "$A_RECORD_RESPONSE" | jq -r '.success')
    if [ "$SUCCESS" != "true" ]; then
        ERROR_MSG=$(echo "$A_RECORD_RESPONSE" | jq -r '.errors[0].message // "Unknown error"')
        echo -e "${RED}Error creating A record: $ERROR_MSG${NC}"
        exit 1
    fi
    A_RECORD_ID=$(echo "$A_RECORD_RESPONSE" | jq -r '.result.id')
else
    if echo "$A_RECORD_RESPONSE" | grep -q '"success":true'; then
        echo -e "${GREEN}✓ A record created successfully${NC}"
    else
        echo -e "${RED}Error: Failed to create A record${NC}"
        echo "Response: $A_RECORD_RESPONSE"
        exit 1
    fi
fi

echo -e "${GREEN}✓ A record created: $A_RECORD_NAME -> $SERVER_IP${NC}"
echo ""

# Generate another random single character for NS record (different from A record)
LETTERS="abcdefghijklmnopqrstuvwxyz"
# Make sure NS char is different from A record char
while true; do
    if [ -n "$RANDOM" ]; then
        INDEX=$(($RANDOM % 26))
    else
        # Fallback: use date + PID + microsecond for different seed
        SEED=$(($(date +%s) + $$ + $(date +%N 2>/dev/null | head -c2 || echo "0")))
        INDEX=$(($SEED % 26))
    fi
    NS_CHAR=$(echo "$LETTERS" | cut -c $((INDEX + 1)))
    if [ "$NS_CHAR" != "$RANDOM_CHAR" ]; then
        break
    fi
done

NS_RECORD_NAME="${NS_CHAR}.${DOMAIN}"

echo -e "${BLUE}Creating NS record:${NC}"
echo "  Name: $NS_RECORD_NAME"
echo "  Type: NS"
echo "  Content: $A_RECORD_NAME"
echo "  Proxied: false"
echo ""

# Create NS record
NS_RECORD_RESPONSE=$(curl -s -X POST "${API_BASE}/zones/${ZONE_ID}/dns_records" \
    -H "X-Auth-Email: ${CF_EMAIL}" \
    -H "X-Auth-Key: ${CF_API_KEY}" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"NS\",\"name\":\"${NS_RECORD_NAME}\",\"content\":\"${A_RECORD_NAME}\",\"proxied\":false,\"ttl\":1}")

if [ "$USE_JQ" = true ]; then
    SUCCESS=$(echo "$NS_RECORD_RESPONSE" | jq -r '.success')
    if [ "$SUCCESS" != "true" ]; then
        ERROR_MSG=$(echo "$NS_RECORD_RESPONSE" | jq -r '.errors[0].message // "Unknown error"')
        echo -e "${RED}Error creating NS record: $ERROR_MSG${NC}"
        exit 1
    fi
else
    if echo "$NS_RECORD_RESPONSE" | grep -q '"success":true'; then
        echo -e "${GREEN}✓ NS record created successfully${NC}"
    else
        echo -e "${RED}Error: Failed to create NS record${NC}"
        echo "Response: $NS_RECORD_RESPONSE"
        exit 1
    fi
fi

echo -e "${GREEN}✓ NS record created: $NS_RECORD_NAME -> $A_RECORD_NAME${NC}"
echo ""

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}DNS Records Created:${NC}"
echo -e "  ${YELLOW}A Record:${NC}  $A_RECORD_NAME -> $SERVER_IP (unproxied)"
echo -e "  ${YELLOW}NS Record:${NC} $NS_RECORD_NAME -> $A_RECORD_NAME (unproxied)"
echo ""
echo -e "${BLUE}Use this DNS name for dnstt:${NC} $NS_RECORD_NAME"
echo ""
echo -e "${GREEN}All done!${NC}"
