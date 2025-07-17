# Use a small base image
FROM alpine:latest

# Install necessary tools for traffic generation and network simulation
RUN apk update && apk add --no-cache \
    nmap \
    curl \
    wget \
    tcpdump \
    netcat-openbsd \
    bind-tools \
    iperf3 \
    hping3 \
    bash \
    iproute2 \
    net-tools

# Create app directory
WORKDIR /app

# Create scripts directory
RUN mkdir -p /app/scripts

# Copy traffic generation scripts
COPY scripts/ /app/scripts/

# Make scripts executable
RUN chmod +x /app/scripts/*.sh

# Keep the container running
CMD ["sleep", "infinity"]
