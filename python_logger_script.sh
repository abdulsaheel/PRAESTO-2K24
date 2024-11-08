#!/bin/bash

# Define paths and filenames
SERVICE_NAME="random_logger.service"
PYTHON_SCRIPT="/opt/random_logger.py"
LOG_FILE="/var/log/random_logger.log"

# Step 1: Create the Python script
echo "Creating Python logging script..."
sudo mkdir -p /opt
sudo tee "$PYTHON_SCRIPT" > /dev/null <<EOF
import logging
import random
import time

# Configure logging
logging.basicConfig(
    filename="$LOG_FILE",
    format="%(asctime)s - %(levelname)s - %(message)s",
    level=logging.DEBUG,
)

# Create a logger
logger = logging.getLogger("RandomLogger")

# Sample log messages by level
DEBUG_MESSAGES = [
    "Debugging connection to the database.",
    "Querying database with parameters: {'user_id': 1234, 'filter': 'active'}",
    "Entering function: calculate_statistics()",
]

INFO_MESSAGES = [
    "Data processed successfully for user ID 4321.",
    "Scheduled task 'daily_backup' completed without errors.",
    "User session started for user ID 5678.",
]

WARNING_MESSAGES = [
    "API response time is slower than expected.",
    "Disk space running low: only 10% remaining.",
    "Memory usage is nearing the limit.",
]

ERROR_MESSAGES = [
    "Failed to load configuration file.",
    "Database connection lost. Retrying...",
    "Error processing user data for user ID 9876.",
]

CRITICAL_MESSAGES = [
    "System shutdown imminent: unable to recover from error.",
    "Data corruption detected in core database.",
    "Critical failure: unable to write to disk.",
]

# Function to log a random message from each level
def log_random_message():
    level = random.choice(['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'])
    if level == 'DEBUG':
        logger.debug(random.choice(DEBUG_MESSAGES))
    elif level == 'INFO':
        logger.info(random.choice(INFO_MESSAGES))
    elif level == 'WARNING':
        logger.warning(random.choice(WARNING_MESSAGES))
    elif level == 'ERROR':
        logger.error(random.choice(ERROR_MESSAGES))
    elif level == 'CRITICAL':
        logger.critical(random.choice(CRITICAL_MESSAGES))

# Infinite loop to keep logging
try:
    while True:
        log_random_message()
        time.sleep(0.5)  # Fixed pause of 0.5 seconds
except KeyboardInterrupt:
    logger.info("Logger service stopped by user.")
EOF

# Step 2: Create the systemd service file
echo "Creating systemd service..."
sudo tee "/etc/systemd/system/$SERVICE_NAME" > /dev/null <<EOF
[Unit]
Description=Random Logger Service
After=network.target

[Service]
ExecStart=/usr/bin/python3 $PYTHON_SCRIPT
StandardOutput=file:$LOG_FILE
StandardError=file:$LOG_FILE
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Step 3: Set permissions and create log file
echo "Setting permissions and creating log file..."
sudo chmod 644 "/etc/systemd/system/$SERVICE_NAME"
sudo touch "$LOG_FILE"
sudo chmod 666 "$LOG_FILE"

# Step 4: Reload systemd to recognize the new service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Step 5: Enable and start the service
echo "Enabling and starting the service..."
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

echo "Service created, enabled, and started successfully."
