# Get VM name from metadata server
echo "getting vm name"
VM_NAME=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name | sed 's/app-vm-//')

echo "VM_NAME: $VM_NAME. setting bucket name"
BUCKET_NAME="e1015-bucket-$VM_NAME"

echo "BUCKET_NAME: $BUCKET_NAME. setting timestamp name"
TIMESTAMP=$(date +%Y%m%d%H%M%S)

echo "TIMESTAMP: $TIMESTAMP. saving world to bucket"
screen -S minecraft -X stuff 'save-all\r'

screen -S minecraft -X stuff 'say attempting to save...\r'

echo "RIGHTHEREfile path is gs://$BUCKET_NAME/backups/world2_$TIMESTAMP"

cd /landing/Server-Files-2.20

zip -r world2_$TIMESTAMP.zip world2

gsutil cp -r world2_$TIMESTAMP.zip gs://e1015-bucket-$VM_NAME/backups/world2_$TIMESTAMP

rm world2_$TIMESTAMP.zip

screen -S minecraft -X stuff 'say "should" be saved...\r'

screen -S minecraft -X stuff 'say shuttingdownin60seconds\r'

sleep 60

screen -S minecraft -X stuff 'stop\r'

sleep 60






