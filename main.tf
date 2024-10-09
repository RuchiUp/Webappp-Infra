data "aws_availability_zones" "zones" {
  state = "available"
}

resource "aws_vpc" "example_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "my_example_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "public_subnet" {
  count = var.public_subnet_count

  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = local.public_subnet[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.zones.names[count.index]

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = var.private_subnet_count

  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = local.private_subnet[count.index]
  availability_zone = data.aws_availability_zones.zones.names[count.index]

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.example_vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count = var.public_subnet_count

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_table_association" {
  count = length(aws_subnet.private_subnet)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_key_pair" "my_key_pair" {
  key_name   = var.key_name
  public_key = file("${abspath(path.cwd)}/pub/ec2.pub")
}

resource "aws_subnet" "private-1" {
  cidr_block = "10.0.7.0/24"
  vpc_id     = aws_vpc.example_vpc.id

  availability_zone = "us-west-2a"

  tags = {
    Name = "private-1"
  }
}

resource "aws_subnet" "private-2" {
  cidr_block = "10.0.8.0/24"
  vpc_id     = aws_vpc.example_vpc.id

  availability_zone = "us-west-2b"

  tags = {
    Name = "private-2"
  }
}

resource "aws_subnet" "private-3" {
  cidr_block = "10.0.9.0/24"
  vpc_id     = aws_vpc.example_vpc.id

  availability_zone = "us-west-2c"

  tags = {
    Name = "private-3"
  }
}

resource "aws_kms_key" "rds_encrypt" {
  description = "RDS encryption key"
}



#create an rds instance that follows the dbparameter group we made 
resource "aws_db_instance" "main_db" {
  allocated_storage    = 20
  db_name              = var.DatabaseName
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  engine               = "MySQL"
  identifier           = var.DatabaseInstanceIdentifier
  instance_class       = var.DatabaseInstanceClass
  #engine_version       = "5.7.31"
  multi_az               = false
  password               = var.DatabasePassword
  username               = var.DatabaseUsername
  parameter_group_name   = aws_db_parameter_group.parametergroup.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.database.id]
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_encrypt.arn


  tags = {
    createdBy = "Ruchi Upadhyay"
  }
  #output "db_instance_ip" {
  #value = aws_db_instance.main_db.address
}

resource "random_pet" "bucket_name" {
  length    = 4
  separator = "-"
  prefix    = "13032309"
}

#create a S3 bucket with randomly generated name based on environment

resource "aws_s3_bucket" "private_bucket" {
  bucket        = random_pet.bucket_name.id
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.private_bucket.id
  acl    = "private"
}

#adding lifecycle policy to shift to standard_ia after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "s3lifecycle" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {

    id = "30-days-transitioning"

    filter {}

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

#create webapps3 policy and iam role for ec2 instance 

resource "aws_iam_policy" "webapp_s3_policy" {
  name = "WebAppS3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListAllMyBuckets"
        ],
        "Resource" : "*"
      },
      {
        Action = [
          "s3:*"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.private_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.private_bucket.id}/*"
        ]
      }
    ]
  })
}

#create IAM role for ec2 instance 
resource "aws_iam_role" "ec2-csye6225" {
  name = "ec2-csye6225"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}





#attach policy to ec2 iam role 
resource "aws_iam_policy_attachment" "policies" {
  name = "policies"
  for_each = toset([

    "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])
  policy_arn = each.value
  roles      = [aws_iam_role.ec2-csye6225.name]
}

#attach WebAppS3 policy to ec2 iam role 
resource "aws_iam_policy_attachment" "WebAppS3-attachment" {
  name       = "WebAppS3-attachment"
  policy_arn = aws_iam_policy.webapp_s3_policy.arn
  roles      = [aws_iam_role.ec2-csye6225.name]
}


#profile to be attached to Ec2
resource "aws_iam_instance_profile" "WebAppS3_profile" {
  name = "WebAppS3_profile"
  role = aws_iam_role.ec2-csye6225.name

}


/*
resource "aws_instance" "trainee-user" {

#count = 1

# ami = var.ami_id

#instance_type               = var.instance_type
#iam_instance_profile        = aws_iam_instance_profile.WebAppS3_profile.name
#subnet_id                   = aws_subnet.public_subnet[1].id
#vpc_security_group_ids      = [aws_security_group.webapp.id]
#key_name                    = aws_key_pair.my_key_pair.key_name
#associate_public_ip_address = true
#user_data                   = file("setup_env.sh")
#user_data = file("setup_env.sh")
#user_data = <<EOF
#!/bin/bash
#  cd /etc/systemd/system/
#touch override.conf
#echo "[Service]" >> override.conf
#echo "Environment=\"MYSQL_PASSWORD=rootPass123\"" >> override.conf
#echo "Environment=\"MYSQL_USERNAME=csye6225\"" >> override.conf
#echo "Environment=\"MYSQL_URL=${aws_db_instance.main_db.endpoint}\"" >> override.conf
#echo "Environment=\"AWS_S3_BUCKET=${random_pet.bucket_name.id}\"" >> override.conf
#systemctl daemon-reload
#systemctl stop ami.service
#systemctl start ami.service
#ystemctl enable ami.service
#sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/home/ec2-user/webappp/statsd/cloudwatch-config.json -s
#EOF


#Configuration block to customize details about the root block device of the instance.
#root_block_device {
# volume_size           = var.volume_size
# volume_type           = var.volume_type
#  delete_on_termination = true
device_name				= var.device_name
 }*/






