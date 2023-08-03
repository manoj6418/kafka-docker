# Build stage
FROM debian:stretch-slim AS builder

# Set environment variables
ENV KAFKA_VERSION="2.13-2.8.0" \
    KAFKA_HOME="/opt/kafka"

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget openjdk-8-jdk-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and extract Kafka
RUN wget -q "https://downloads.apache.org/kafka/2.8.0/kafka_${KAFKA_VERSION}.tgz" -O "/tmp/kafka_${KAFKA_VERSION}.tgz" && \
    tar xfz "/tmp/kafka_${KAFKA_VERSION}.tgz" -C "/opt" && \
    rm "/tmp/kafka_${KAFKA_VERSION}.tgz"

# Copy startup script
COPY start-kafka.sh /start-kafka.sh
RUN chmod +x /start-kafka.sh

# Configure Kafka
RUN echo "advertised.listeners=PLAINTEXT://localhost:9092" >> "${KAFKA_HOME}/config/server.properties"


# Final stage
FROM scratch

# Copy files from builder stage
COPY --from=builder /opt /opt
COPY --from=builder /start-kafka.sh /start-kafka.sh
COPY --from=builder /usr/lib/jvm /usr/lib/jvm

# Set environment variables
ENV KAFKA_HOME="/opt/kafka" \
    PATH="${PATH}:${KAFKA_HOME}/bin:/usr/lib/jvm/java-8-openjdk-amd64/bin"


CMD ["/start-kafka.sh"]

