#!/bin/bash

# Define the marker file
echo "making marker file"
MARKER_FILE="/var/tmp/startup-script-ran"

# Get VM name from metadata server
echo "getting vm name"
VM_NAME=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name | sed 's/app-vm-//')


echo "VM_NAME: $VM_NAME. setting bucket name"
BUCKET_NAME="e1015-bucket-$VM_NAME"


# Check if the marker file exists
if [ ! -f "$MARKER_FILE" ]; then
    ## Install necessary packages
    sudo apt-get update
    sudo apt-get install -y jq

    gsutil cp gs://$BUCKET_NAME/mc-server/server.jar landing/server.jar

    wget https://download.oracle.com/java/23/latest/jdk-23_linux-x64_bin.deb

    sudo dpkg -i jdk-23_linux-x64_bin.deb

    echo "LOOK HERE IM STARTING THE SERVER"

    cd landing

    java -jar server.jar

    sudo chmod 664 eula.txt

    sudo sed -i 's/false/true/' eula.txt

    # Create the marker file to indicate the script has run
    sudo touch "$MARKER_FILE"

    cd ..
fi

# Run the server jar (this will run every time)
cd landing
java -jar server.jar