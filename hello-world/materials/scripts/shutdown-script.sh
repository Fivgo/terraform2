# Get VM name from metadata server
# echo "getting vm name"
# VM_NAME=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name | sed 's/app-vm-//')

 echo "VM_NAME: $VM_NAME"
# BUCKET_NAME="e1015-bucket-$VM_NAME"

echo "BUCKET_NAME: $BUCKET_NAME"

MAPNAME=${1:-"world"}
TIMESTAMP=$(date +%Y%m%d%H%M%S)



echo "TIMESTAMP: $TIMESTAMP. saving world to bucket"
screen -S minecraft -X stuff 'save-all\r'

screen -S minecraft -X stuff 'say attempting to save...\r'

echo "RIGHTHEREfile path is $BUCKET_NAME/backups/$MAPNAME-$TIMESTAMP"

cd /landing/Server-Files-2.20

zip -r $MAPNAME-$TIMESTAMP.zip world

gsutil cp -r $MAPNAME-$TIMESTAMP.zip $BUCKET_NAME/backups/$MAPNAME-$TIMESTAMP

rm $MAPNAME-$TIMESTAMP.zip

screen -S minecraft -X stuff 'say "should" be saved...\r'

screen -S minecraft -X stuff 'say shuttingdownin60seconds\r'

sleep 60

screen -S minecraft -X stuff 'stop\r'

if [ $SERVER_TYPE = "minecraft" ]; then
    echo "Minecraft server is shutting down"
    bash mc-backup.sh
    
    
fi

sleep 10






