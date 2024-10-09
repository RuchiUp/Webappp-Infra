variable "profile" {
  type = string
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block"
}

variable "create_cidr" {
  type = bool
}

variable "VpcName" {
  default = "myVPC1"
}

variable "VpcCIDR" {
  default = "10.0.0.0/16"
}

variable "Subnet1CIDR" {
  default = "10.0.1.0/24"
}

variable "Subnet2CIDR" {
  default = "10.0.2.0/24"
}

variable "Subnet3CIDR" {
  default = "10.0.3.0/24"
}

variable "public_subnet_cidr_blocks" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr_blocks" {
  type    = list(any)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}


variable "enable_dns_hostnames" {
  type = bool
}

variable "enable_dns_support" {
  type = bool
}

variable "public_subnet_count" {
  type = number
}

variable "private_subnet_count" {
  type = number
}

variable "key_name" {
  type = string
}

variable "ssh_port" {
  type = number
}

variable "http_port" {
  type = number
}

variable "https_port" {
  type = number
}

variable "application_port" {
  type = number
}

variable "database_port" {
  type = number
}

variable "lb_listener_port" {
  type = number
}

variable "aws_account_id" {
  type = number
}

variable "asg_maxsize" {
  type = number
}

variable "asg_minsize" {
  type = number
}

variable "timeout" {
  type = number
}

variable "interval" {
  type = number
}

variable "healthy_threshold" {
  type = number
}

variable "unhealthy_threshold" {
  type = number
}

variable "DatabaseInstanceClass" {
  type = string
}

variable "DatabaseInstanceIdentifier" {
  type = string
}

variable "DatabaseName" {
  type = string
}

variable "DatabaseUsername" {
  type = string
}

variable "DatabasePassword" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance-name" {
  type = string

}


variable "instance_type" {
  type = string
}



variable "volume_size" {
  type = number
}


variable "health_check_grace_period" {
  type = number
}

variable "desired_capacity" {
  type = number
}

variable "default_cooldown" {
  type = number
}

variable "cooldown" {
  type = number
}


variable "volume_type" {
  type = string
}

variable "adjustment_type" {
  type = string
}

variable "domain" {
  type = string
}

variable "device_name" {
  type = string
}

variable "route_53_type" {
  type = string
}

variable "path" {
  type = string
}

variable "lb_listener_protocol" {
  type = string
}

variable "cert" {
  type = string
}

variable "high_threshold" {
  type = string
}

variable "low_threshold" {
  type = string
}

variable "metric_name" {
  type = string
}

variable "evaluation_periods" {
  type = string

}

variable "period" {
  type = string

}

variable "statistic" {
  type = string

}

locals {
  public_subnet  = var.create_cidr ? [for i in range(1, var.public_subnet_count + 1) : cidrsubnet(var.vpc_cidr_block, 8, i)] : var.public_subnet_cidr_blocks
  private_subnet = var.create_cidr ? [for i in range(1, var.private_subnet_count + 1) : cidrsubnet(var.vpc_cidr_block, 8, i + var.public_subnet_count)] : var.private_subnet_cidr_blocks
}
