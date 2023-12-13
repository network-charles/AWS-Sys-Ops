import boto3
import datetime
import time

# Initialize the AWS clients
source_region = 'eu-west-2'
destination_region = 'eu-west-1'
ec2_source = boto3.client('ec2')
ec2_destination = boto3.client('ec2', region_name=destination_region)
dynamo = boto3.client('dynamodb')

table_name = 'AMI_Table'
key = {
    'PK': {
        'S': 'Partition_Key'
    }
}

# Get ami_id value from dynamodb AMI_Table
get_ami_id = dynamo.get_item(TableName=table_name, Key=key)

# Pass the value to a new variable
source_region_ami_id = get_ami_id['Item']['SOURCE_REGION_AMI_ID']['S']

destination_region_ami_id = get_ami_id['Item']['DESTINATION_REGION_AMI_ID']['S']

# Function to create a new AMI
def create_ami(InstanceId):
    # Get the current time to use as the AMI name
    # current_time = datetime.datetime.now().strftime('%Y-%m-   %d-%H-%M-%S')
    current_time = datetime.datetime.now().strftime('%Y-%m-%d / %H-%M')
    # Declare source_region_ami_id as a global variable
    global source_region_ami_id
    try:
        create_image = ec2_source.create_image(
            InstanceId=InstanceId,
            # Use the current time as the image name
            Name=f'{current_time}_AMI'
        )
        # Update the global source_region_ami_id variable
        source_region_ami_id = create_image['ImageId']
        # Store the source_region_ami_id value as a state in a dynamodb ami_table
        update_ami_id = dynamo.update_item(
            TableName=table_name,
            Key=key,
            #  (:) in :source_region_ami_id is used to define a placeholder for
            # attribute name or a value that will be set.
            UpdateExpression="SET SOURCE_REGION_AMI_ID = :source_region_ami_id",
            # Use :source_region_ami_id as a placeholder, its actual value is desired_state.
            ExpressionAttributeValues={
                ':source_region_ami_id': {
                    'S': source_region_ami_id
                }
            }
        )
        # Return the value so when the function is passed to a variable, a value exists.
        return source_region_ami_id
    except Exception as e:
        return f"Error creating AMI: {str(e)}"


def copy_ami(source_region_ami_id):
    # Get the current time to use as the AMI name
    current_time = datetime.datetime.now().strftime('%Y-%m-%d / %H-%M')
    # Declare destination_region_ami_id as a global variable
    global destination_region_ami_id
    # Copy the source_region_ami_id into another region using the 'ec2_destination' client
    copy_response = ec2_destination.copy_image(
        SourceImageId=source_region_ami_id,
        SourceRegion=source_region,
        Name=f'{current_time}_AMI_Copy'
    )
    # Get the copied image id
    destination_region_ami_id = copy_response['ImageId']
    # Store the destination_region_ami_id value as a state in a dynamodb ami_table
    update_copied_ami_id = dynamo.update_item(
        TableName=table_name,
        Key=key,
        #  (:) in :destination_region_ami_id is used to define a placeholder for
        # attribute name or a value that will be set.
        UpdateExpression="SET DESTINATION_REGION_AMI_ID = :destination_region_ami_id",
        # Use :destination_region_ami_id as a placeholder, its actual value is desired_state.
        ExpressionAttributeValues={
            ':destination_region_ami_id': {
                'S': destination_region_ami_id
            }
        }
    )

# Function to delete the existing and copied AMI
def delete_ami(source_region_ami_id, destination_region_ami_id, source_region, destination_region):
    try:
        # Deregister the original AMI in the destination region
        # Get the original snapshot ID associated with the AMI
        original_ami_info = ec2_source.describe_images(
            ImageIds=[source_region_ami_id])
        original_snapshot_id = original_ami_info['Images'][0]['BlockDeviceMappings'][0]['Ebs']['SnapshotId']
        print(f"Original Snapshot ID: {original_snapshot_id}")

        # Deregister the original AMI in the source region
        deregister_ami = ec2_source.deregister_image(
            ImageId=source_region_ami_id)
        print(
            f'Deregistered original AMI in {source_region}: {source_region_ami_id}')

        # Delete the associated original snapshot
        delete_original_snapshot = ec2_source.delete_snapshot(
            SnapshotId=original_snapshot_id)
        print(
            f'Deleted original snapshot in {source_region}: {original_snapshot_id}')
        ######################################################################################
        # Deregister the copied AMI in the destination region
        # Get the copied snapshot ID associated with the AMI
        copied_ami_info = ec2_destination.describe_images(
            ImageIds=[destination_region_ami_id])
        copied_snapshot_id = copied_ami_info['Images'][0]['BlockDeviceMappings'][0]['Ebs']['SnapshotId']
        print(f"Copied Snapshot ID: {copied_snapshot_id}")

        # Deregister the copied AMI in the destination region
        deregister_copied_ami = ec2_destination.deregister_image(
            ImageId=destination_region_ami_id)
        print(
            f'Deregistered copied AMI in {destination_region}: {destination_region_ami_id}')

        # Delete the associated copied snapshot
        delete_copied_snapshot = ec2_destination.delete_snapshot(
            SnapshotId=copied_snapshot_id)
        print(
            f'Deleted copied snapshot in {destination_region}: {copied_snapshot_id}')

    except Exception as e:
        raise Exception(str(e))

# Function to update the state
def update_state(desired_state):
    get_ami_state = dynamo.get_item(TableName=table_name, Key=key)
    # Update the value of AMI_state
    dynamo.update_item(
        TableName=table_name,
        Key=key,
        #  (:) in :new_state is used to define a placeholder for
        # attribute name or a value that will be set.
        UpdateExpression='SET AMI_State = :new_state',
        # Use :new_state as a placeholder, its actual value is desired_state.
        ExpressionAttributeValues={':new_state': {'S': desired_state}}
    )


# Lambda Function
def lambda_handler(event, context):
    try:
        # Read the dynamodb table
        db_read = dynamo.get_item(TableName=table_name, Key=key)
        # Get the AMI State from the dynamodb table
        ami_state = db_read['Item']['AMI_State']['S']

        if ami_state == 'Create_AMI':
            # Extract the InstanceId from the event dictionary
            InstanceId = event.get('InstanceId')
            # Check if InstanceId value exists
            if InstanceId:
                # Call the create_ami function and pass the InstanceId as a string.
                create_ami(InstanceId)
                # Wait for the AMI creation to complete
                waiter = ec2_source.get_waiter('image_available')
                waiter.wait(
                    Filters=[
                        {
                            'Name': 'image-id',
                            'Values': [source_region_ami_id]
                        }
                    ]
                )
                # Copy the ami from eu-west-2 into eu-west-1
                copy_ami(source_region_ami_id)
                # Wait for the AMI copy to complete
                waiter = ec2_destination.get_waiter('image_available')
                waiter.wait(
                    Filters=[
                        {
                            'Name': 'image-id',
                            'Values': [destination_region_ami_id]
                        }
                    ]
                )
                # Update the value of AMI_state
                update_state('Delete_AMI')
                return f'''Created new AMI: {source_region_ami_id}
                Copied {source_region_ami_id} to eu-west-1 with new ID of {destination_region_ami_id}'''

            # When InstanceId value does not exist
            else:
                raise ValueError('InstanceId not found in event data.')

        elif ami_state == 'Delete_AMI':
            # Check if source_region_ami_id value exists
            if source_region_ami_id:
                # Store the source_region_ami_id before deletion
                existing_ami_id = source_region_ami_id
                existing_copied_ami_id = destination_region_ami_id
                # Delete the existing and copied AMI across regions
                delete_ami(existing_ami_id, existing_copied_ami_id,
                           source_region, destination_region)
                # Extract the InstanceId from the event dictionary
                InstanceId = event.get('InstanceId')
                # Call the create_ami function
                new_ami_id = create_ami(InstanceId)
                # Wait for the AMI creation to complete
                waiter = ec2_source.get_waiter('image_available')
                waiter.wait(
                    Filters=[
                        {
                            'Name': 'image-id',
                            'Values': [source_region_ami_id]
                        }
                    ]
                )
                # Copy the new ami from eu-west-2 into eu-west-1
                copy_ami(source_region_ami_id)
                # Wait for the AMI copy to complete
                waiter = ec2_destination.get_waiter('image_available')
                waiter.wait(
                    Filters=[
                        {
                            'Name': 'image-id',
                            'Values': [destination_region_ami_id]
                        }
                    ]
                )
                return f'''Deleted existing AMI: {existing_ami_id} in eu-west-2 and created a new AMI: {new_ami_id}
                Deleted existing copied AMI {existing_copied_ami_id} in eu-west-1 and replaced it with a new ID of {destination_region_ami_id}'''

            else:
                return 'source_region_ami_id is not set, cannot delete AMI'
        else:
            raise ValueError('Invalid state')
    except Exception as e:
        raise Exception(str(e))
