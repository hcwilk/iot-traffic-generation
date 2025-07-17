# Use Ubuntu base image for better networking tools support
FROM ubuntu:22.04

# Install necessary tools for traffic generation and network simulation
RUN apt-get update && apt-get install -y \
    nmap \
    curl \
    wget \
    tcpdump \
    netcat-openbsd \
    dnsutils \
    iperf3 \
    hping3 \
    bash \
    iproute2 \
    net-tools \
    iputils-ping \
    bc \
    openssl \
    && rm -rf /var/lib/apt/lists/*

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
