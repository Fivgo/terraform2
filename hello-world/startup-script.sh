#!/bin/bash

# Install necessary packages
sudo apt-get update
sudo apt-get install -y jq

# Create the idle shutdown script
cat << 'EOF' > /usr/local/bin/idle-shutdown.sh
#!/bin/bash

# Set the idle timeout in seconds (15 minutes)
IDLE_TIMEOUT=100

# Get the instance name and zone
INSTANCE_NAME=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name)
ZONE=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone | awk -F/ '{print $4}')

# Check for idle time
while true; do
  IDLE_TIME=$(xprintidle)
  if [ "$IDLE_TIME" -ge "$IDLE_TIMEOUT" ]; then
    echo "Instance $INSTANCE_NAME in zone $ZONE is idle for $IDLE_TIMEOUT seconds. Shutting down..."
    gcloud compute instances stop $INSTANCE_NAME --zone=$ZONE
    break
  fi
  sleep 60
done
EOF

# Make the script executable
chmod +x /usr/local/bin/idle-shutdown.sh

# Add the idle shutdown script to crontab
(crontab -l 2>/dev/null; echo "@reboot /usr/local/bin/idle-shutdown.sh") | crontab -