#  the load balancer security group
resource "aws_security_group" "load_balancer" {
  vpc_id = aws_vpc.example_vpc.id
  tags = {
    Name = "Load Balancer"
    Role = "Security Group"
  }
}

resource "aws_security_group_rule" "lb_in_http" {
  type              = "ingress"
  from_port         = var.http_port
  to_port           = var.http_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.load_balancer.id

}
resource "aws_security_group_rule" "lb_in_https" {
  type              = "ingress"
  from_port         = var.https_port
  to_port           = var.https_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "lb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.load_balancer.id

}

