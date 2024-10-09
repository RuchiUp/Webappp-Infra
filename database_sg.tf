#create an application  security group
#  name   = "application"
# vpc_id = aws_vpc.example_vpc.id

#  tags = {
#   Name = "application"
#  Role = "public"
#}
#}

#resource "aws_security_group_rule" "public_in_ssh" {
# type              = "ingress"
#from_port         = var.ssh_port
# to_port           = var.ssh_port
# protocol          = "tcp"
# cidr_blocks       = ["0.0.0.0/0"]
# security_group_id = aws_security_group.public.id
#}

#resource "aws_security_group_rule" "public_in_http" {
#from_port         = var.http_port
#to_port           = var.http_port
#protocol          = "tcp"
#cidr_blocks       = ["0.0.0.0/0"]
#security_group_id = aws_security_group.public.id
#}

#resource "aws_security_group_rule" "public_in_https" {
# type              = "ingress"
# from_port         = var.https_port
# to_port           = var.https_port
# protocol          = "tcp"
# cidr_blocks       = ["0.0.0.0/0"]
# security_group_id = aws_security_group.public.id
#}

#resource "aws_security_group_rule" "public_in_application" {
# type              = "ingress"
# from_port         = var.application_port
# to_port           = var.application_port
# protocol          = "tcp"
# cidr_blocks       = ["0.0.0.0/0"]
#security_group_id = aws_security_group.public.id
#}
#resource "aws_security_group_rule" "egress_rule" {
#  type              = "egress"
#  from_port         = 0
#  to_port           = 0
# protocol          = "-1"
# cidr_blocks       = ["0.0.0.0/0"]
# security_group_id = aws_security_group.public.id
#}
#create a database security group
resource "aws_security_group" "database" {

  name   = "database"
  vpc_id = aws_vpc.example_vpc.id


  tags = {
    Name = "database"
    Role = "public"
  }

}

#adding rules to database security group where the port would be 3306 (mySQL) and the source of traffic would be application security group

resource "aws_security_group_rule" "database_rule" {
  type                     = "ingress"
  from_port                = var.database_port
  to_port                  = var.database_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.database.id
  source_security_group_id = aws_security_group.webapp.id
  #"sg-04a6911c84b2fe620"
}

#create a custom DB parameter group 
resource "aws_db_parameter_group" "parametergroup" {
  name        = "mysqlgroup"
  family      = "mysql8.0"
  description = "Custom parameter group for MySQL 8.0"
}

#create a subnet db group

resource "aws_db_subnet_group" "db_subnet" {
  name        = "subnet-group"
  description = " DB subnet group"

  subnet_ids = [
    aws_subnet.private-1.id,
    aws_subnet.private-2.id,
    aws_subnet.private-3.id,
  ]

  tags = {
    Name = "subnet-group"
  }
}