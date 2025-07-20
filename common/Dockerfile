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

# Create scripts directory (will be populated by volume mounts)
RUN mkdir -p /app/scripts

# Keep the container running
CMD ["sleep", "infinity"]
