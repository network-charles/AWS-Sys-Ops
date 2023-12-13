resource "aws_dynamodb_table" "Create_Delete_Image" {
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  name         = "AMI_Table"

  attribute {
    name = "PK"
    type = "S"
  }

  tags = {
    "Name" = "Create_Delete_Image"
  }
}

resource "aws_dynamodb_table_item" "Create_Delete_Image" {
  table_name = aws_dynamodb_table.Create_Delete_Image.name
  hash_key   = aws_dynamodb_table.Create_Delete_Image.hash_key

  item = jsonencode({
    "PK" : { "S" : "Partition_Key" },
    "SOURCE_REGION_AMI_ID" : { "S" : "ami-123" },
    "DESTINATION_REGION_AMI_ID" : { "S" : "ami-456" },
    "AMI_State" : { "S" : "Create_AMI" }
  })
}

resource "aws_instance" "Instance" {
  ami             = "ami-0b2287cff5d6be10f" #Amaon Linux 2
  instance_type   = "t3.micro"
  tenancy         = "default"
  security_groups = [aws_security_group.SG.id]
  subnet_id       = aws_subnet.public_subnet.id

  iam_instance_profile = aws_iam_instance_profile.SSMInstanceProfile.name

  tags = {
    "Name" = "Instance"
  }
}

resource "aws_lambda_function" "ssm_lambda" {
  filename      = "./script.zip"
  function_name = "ssm_lambda"
  role          = aws_iam_role.EC2_Role.arn
  handler       = "script.lambda_handler"
  runtime       = "python3.11"
  timeout       = 900
  memory_size   = 512

  ephemeral_storage {
    size = 1024 # Min 512 MB and the Max 10240 MB
  }

  tags = {
    "Name" = "ssm_lambda"
  }
}
