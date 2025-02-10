#!/bin/bash

# Define the marker file
MARKER_FILE="/var/tmp/startup-script-ran"

# Check if the marker file exists
if [ ! -f "$MARKER_FILE" ]; then
    ## Install necessary packages
    sudo apt-get update
    sudo apt-get install -y jq

    gsutil cp gs://e-bucket-terraform-built/mc-server/server.jar landing/server.jar

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