# Define the marker file
echo "making marker file"
MARKER_FILE="/var/tmp/startup-script-ran"

file_path="/landing/Server-Files-2.20/eula.txt"

file_path2="/landing/Server-Files-2.20/user_jvm_args.txt"


# Check if the marker file exists
if [ ! -f "$MARKER_FILE" ]; then
    ## Install necessary packages
    sudo apt-get update
    sudo apt-get install -y jq
    sudo apt-get install unzip
    sudo apt-get install zip

    wget https://download.oracle.com/java/23/latest/jdk-23_linux-x64_bin.deb

    sudo dpkg -i jdk-23_linux-x64_bin.deb

    mkdir landing

    cd landing

    wget https://mediafilez.forgecdn.net/files/6063/217/Server-Files-2.20.zip

    unzip Server-Files-2.20.zip

    cd Server-Files-2.20

    screen -S minecraft -d -m bash startserver.sh

    until [ -f "$file_path" ]; do
    echo "Waiting for file '$file_path' to exist..."
    sleep 1 # Check every second  
    done

    sudo sed -i 's/false/true/' eula.txt

    until [ -f "$file_path2" ]; do
    echo "Waiting for file '$file_path2' to exist..."
    sleep 1 # Check every second
    done

    sudo sed -i 's/Xms4G/Xms8G/' user_jvm_args.txt
    sudo sed -i 's/Xmx8G/Xmx12G/' user_jvm_args.txt

    # Create the marker file to indicate the script has run
    sudo touch "$MARKER_FILE"
    
else
    screen -S minecraft -d -m bash /landing/Server-Files-2.20/startserver.sh
    #sudo bash startserver.sh
fi
# cd Server-Files-2.20

# sudo sed -i 's/false/true/' eula.txt

# sudo screen -S minecraft -X stuff 'save-all\r'
# sudo screen -S minecraft -X stuff 'stop\r'

#cd /landing/Server-Files-2.20/
##sudo bash startserver.sh

#/save-all
#/stop