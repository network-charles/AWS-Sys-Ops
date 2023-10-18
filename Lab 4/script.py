import boto3
import datetime

# Initialize the AWS clients
ec2 = boto3.client('ec2')
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
image_id = get_ami_id['Item']['AMI_ID']['S']

# Function to create a new AMI


def create_ami(InstanceId):
    # Declare image_id as a global variable
    global image_id
    # Get the current time to use as the AMI name
    current_time = datetime.datetime.now().strftime('%Y-%m-   %d-%H-%M-%S')
    if InstanceId:
        create_image = ec2.create_image(
            InstanceId=InstanceId,
            # Use the current time as the image name
            Name=f'{current_time}_AMI'
        )
        # Update the global image_id variable
        image_id = create_image['ImageId']
        # Store the image_id value as a state in a dynamodb ami_table
        update_ami_id = dynamo.update_item(
            TableName=table_name,
            Key=key,
            #  (:) in :image_id is used to define a placeholder for 
            # attribute name or a value that will be set.
            UpdateExpression="SET AMI_ID = :image_id",
            # Use :image_id as a placeholder, its actual value is desired_state. 
            ExpressionAttributeValues={
                ':image_id': {
                    'S': image_id
                }
            }
        )
        # Return the value so when the function is passed to a variable, a value exists.
        return image_id
    else:
        return "InstanceId not found."

# Function to delete the existing AMI


def delete_ami(image_id):
    # Deregister the AMI
    deregister_ami = ec2.deregister_image(ImageId=image_id)
    # Get the snapshot ID associated with the AMI
    ami_info = ec2.describe_images(ImageIds=[image_id])
    snapshot_id = ami_info['Images'][0]['BlockDeviceMappings'][0]['Ebs']['SnapshotId']
    # Delete the associated snapshot
    delete_snapshot = ec2.delete_snapshot(SnapshotId=snapshot_id)

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
                # Update the value of AMI_state
                update_state('Delete_AMI')
                return f'Created new AMI: {image_id}'
            # When InstanceId value does not exist
            else:
                return 'InstanceId not found in event data.'

        elif ami_state == 'Delete_AMI':
            # Check if image_id value exists
            if image_id:
                # Store the image_id before deletion
                existing_ami_id = image_id
                # Delete the existing AMI
                delete_ami(existing_ami_id)
                # Extract the InstanceId from the event dictionary
                InstanceId = event.get('InstanceId')
                # Call the create_ami function
                new_ami_id = create_ami(InstanceId)
                return f'Deleted existing AMI: {existing_ami_id} and created a new AMI: {new_ami_id}'
            else:
                return 'image_id is not set, cannot delete AMI'
        else:
            return 'Invalid state'
    except Exception as e:
        return str(e)
