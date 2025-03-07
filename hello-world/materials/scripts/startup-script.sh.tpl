#!/bin/bash

# Define the marker file
echo "making marker file"
MARKER_FILE="/var/tmp/startup-script-ran"

# Get VM name from metadata server
echo "getting vm name. Exported"
export VM_NAME=${cli_vm_name}

# Set the bucket name, set to export so it can be used in the mc-backup.sh script
echo "VM_NAME: $VM_NAME. setting bucket name. Exported"
export BUCKET_NAME="gs://${bucket_name}"

echo "BUCKET_NAME: $BUCKET_NAME"

export SERVER_TYPE=${server_type}

# Check if the marker file exists
if [ ! -f "$MARKER_FILE" ]; then
    ## Install necessary packages
    sudo apt-get update
    sudo apt-get install -y jq

    gsutil cp $BUCKET_NAME/mc-server/server.jar landing/server.jar

    gsutil cp $BUCKET_NAME/mc-server/eula.txt landing/eula.txt

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

# Schedule a shutdown at 11:30 PM, safety first
30 23 * * * root /usr/sbin/shutdown -h now

# Run the server jar (this will run every time)
screen -S minecraft -d -m java -jar landing/server.jar