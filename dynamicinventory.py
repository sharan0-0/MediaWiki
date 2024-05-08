import boto3
import json

def get_running_ec2_private_ips():
    ec2_client = boto3.client('ec2')
    
    # Get the ID of the current VPC
    current_vpc_id = ec2_client.describe_instances().get('Reservations')[0].get('Instances')[0].get('VpcId')

    # Describe instances filtering by running state and current VPC ID
    response = ec2_client.describe_instances(
        Filters=[
            {'Name': 'instance-state-name', 'Values': ['running']},
            {'Name': 'vpc-id', 'Values': [current_vpc_id]}
        ]
    )

    private_ips = []

    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            private_ip = instance.get('PrivateIpAddress')
            if private_ip:
                private_ips.append(private_ip)

    return private_ips

if __name__ == "__main__":
    private_ips = get_running_ec2_private_ips()
    print(json.dumps(private_ips, indent=4))