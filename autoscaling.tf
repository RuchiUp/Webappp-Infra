data "template_file" "user_data" {

  template = <<EOF
 #!/bin/bash
     cd /etc/systemd/system/
     mkdir ami.service.d
     cd ami.service.d/
     touch override.conf
     echo "[Service]" >> override.conf
     echo "Environment=\"MYSQL_PASSWORD=rootPass123\"" >> override.conf
     echo "Environment=\"MYSQL_USERNAME=csye6225\"" >> override.conf
     echo "Environment=\"MYSQL_URL=${aws_db_instance.main_db.endpoint}\"" >> override.conf
     echo "Environment=\"AWS_S3_BUCKET=${random_pet.bucket_name.id}\"" >> override.conf
     systemctl daemon-reload
     systemctl stop ami.service
     systemctl start ami.service
     systemctl enable ami.service
     sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/home/ec2-user/webappp/statsd/cloudwatch-config.json -s

 EOF

}

#data "aws_ami" "recent" {
#  most_recent = true
# owners      = ["self"]
#  filter {
#    name   = "root_device_name"
#    values = ["var.ami_id"]
#  }
#}

#output "root_device_name" {
#  value = data.aws_ami.recent.root_device_name
#}

resource "aws_launch_template" "lt" {
  name = "asg-launch-config"
  iam_instance_profile {
    name = "WebAppS3_profile"
  }
  #iam_instance_profile = "WebAppS3_profile"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.webapp.id]
  }
  #associate_public_ip_address = true
  #vpc_security_group_ids = [aws_security_group.webapp.id]
  block_device_mappings {
    device_name = var.device_name
    ebs {
      volume_size           = var.volume_size
      volume_type           = var.volume_type
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.kms-ec2.arn
    }

  }
  tags = {
    Name = "asg_launch_config"
  }
  user_data = base64encode(data.template_file.user_data.rendered)
}

#AS SECURITY GROUP

resource "aws_autoscaling_group" "asg" {
  #count = var.public_subnet_count

  name                      = "asg_launch_config"
  max_size                  = var.asg_maxsize
  min_size                  = var.asg_minsize
  health_check_grace_period = var.health_check_grace_period
  desired_capacity          = var.desired_capacity
  default_cooldown          = var.default_cooldown

  #launch_configuration =	"lt"
  vpc_zone_identifier = [for subnet in aws_subnet.public_subnet : subnet.id]

  tag {
    key                 = "Name"
    value               = "webapp-instance-csye6225-ec2"
    propagate_at_launch = true
  }

  launch_template {

    id = aws_launch_template.lt.id

    #version = aws_launch_template.lt.latest_version
    version = "$Latest"

  }

  target_group_arns = [

    aws_lb_target_group.alb_tg.arn

  ]
  depends_on = [
    aws_subnet.public_subnet,
    aws_launch_template.lt,
    aws_lb_target_group.alb_tg
  ]

}
#DEFINING POLICIES

resource "aws_autoscaling_policy" "scale_up_policy" {
  name = "scale_up_policy"
  #policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  cooldown               = var.cooldown
  adjustment_type        = var.adjustment_type
  scaling_adjustment     = 1
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name = "scale_down_policy"
  #policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  cooldown               = var.cooldown
  adjustment_type        = var.adjustment_type
  scaling_adjustment     = -1
}
# Define the autoscaling alarms
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name          = "cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = "AWS/EC2"
  period              = var.period
  statistic           = var.statistic
  threshold           = var.high_threshold
  alarm_description   = "Alarm when CPU exceeds 5% threshold"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  alarm_actions             = [aws_autoscaling_policy.scale_up_policy.arn]
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  alarm_name          = "cpu-utilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = "AWS/EC2"
  period              = var.period
  statistic           = var.statistic
  threshold           = var.low_threshold
  alarm_description   = "Alarm when CPU falls below 3% threshold"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  alarm_actions             = [aws_autoscaling_policy.scale_down_policy.arn]
  insufficient_data_actions = []
}



