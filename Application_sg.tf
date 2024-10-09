#create an application  security group
resource "aws_security_group" "webapp" {

  name   = "application"
  vpc_id = aws_vpc.example_vpc.id


  tags = {
    Name = "application"
    Role = "public"
  }
}

resource "aws_security_group_rule" "public_in_ssh" {
  type                     = "ingress"
  from_port                = var.ssh_port
  to_port                  = var.ssh_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.webapp.id
  source_security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "public_in_application" {
  type                     = "ingress"
  from_port                = var.application_port
  to_port                  = var.application_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.webapp.id
  source_security_group_id = aws_security_group.load_balancer.id
}
resource "aws_security_group_rule" "egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.webapp.id
  #source_security_group_id =aws_security_group.load_balancer.id 
}