import argparse
from google.oauth2 import service_account
from googleapiclient import discovery

def manage_vm(project_id, zone, instance, action):
    compute = discovery.build('compute', 'v1')
    request = compute.instances().get(project=project_id, zone=zone, instance=instance)
    
    if action == 'start':
        request = compute.instances().start(project=project_id, zone=zone, instance=instance)
    elif action == 'stop':
        request = compute.instances().stop(project=project_id, zone=zone, instance=instance)
    
    request.execute()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--project', required=True)
    parser.add_argument('--zone', required=True)
    parser.add_argument('--instance', required=True)
    parser.add_argument('--action', choices=['start', 'stop'], required=True)
    args = parser.parse_args()
    
    manage_vm(args.project, args.zone, args.instance, args.action)

# To stop a VM:
#python3 /usr/local/bin/manage-vms.py --project CLIENT_PROJECT_ID --zone ZONE --instance VM_NAME --action stop
#python3 /usr/local/bin/manage-vms.py --project clie2-id --zone us-west1-a --instance vm-controller --action stop
# To start a VM:
#python3 /usr/local/bin/manage-vms.py --project CLIENT_PROJECT_ID --zone ZONE --instance VM_NAME --action start
#python3 /usr/local/bin/manage-vms.py --project clie2-id --zone us-west1-a --instance vm-controller --action start
#python3 /manage-vms.py --project clie2-id --zone us-west1-a --instance app-vm-clie2 --action start