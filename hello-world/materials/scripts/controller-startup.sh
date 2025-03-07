sudo apt-get update
sudo apt-get install -y python3-pip
sudo pip3 install google-auth google-api-python-client
sudo pip3 install -U discord.py


MANAGER_FILE="/usr/local/bin/manage_vms.py"
BOT_FILE="/usr/local/bin/bot.py"

if [ ! -f "$MANAGER_FILE" ]; then
    # Get VM name from metadata server
    echo "getting vm name"
    VM_NAME="vm-controller"

    echo "VM_NAME: $VM_NAME. setting bucket name"
    BUCKET_NAME="e1015-bucket-con"

    gsutil cp gs://$BUCKET_NAME/manage_vms.py $MANAGER_FILE

    chmod +x $MANAGER_FILE
fi

if [ ! -f "$BOT_FILE" ]; then
    # Get VM name from metadata server
    echo "getting vm name"
    VM_NAME="vm-controller"

    echo "VM_NAME: $VM_NAME. setting bucket name"
    BUCKET_NAME="e1015-bucket-con"

    gsutil cp gs://$BUCKET_NAME/bot.py $BOT_FILE

    chmod +x $BOT_FILE
fi

python3 /usr/local/bin/bot.py


# To stop a VM:
#python3 /usr/local/bin/manage-vms.py --project CLIENT_PROJECT_ID --zone ZONE --instance VM_NAME --action stop

# To start a VM:
#python3 /usr/local/bin/manage-vms.py --project CLIENT_PROJECT_ID --zone ZONE --instance VM_NAME --action start