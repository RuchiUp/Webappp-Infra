data "aws_route53_zone" "main" {
  name = var.domain
}

#resource "aws_route53_record" "route53" {
#  name    = var.domain
#  type    = "A"
#  zone_id = data.aws_route53_zone.main.zone_id
#  ttl     = 60
#  records = [aws_instance.trainee-user.public_ip]
#}


#data "aws_lb" "csye6225-lb" {
#  name = "csye6225-lb"
#}

resource "aws_route53_record" "route53" {
  zone_id = data.aws_route53_zone.main.id
  name    = var.domain
  type    = var.route_53_type
  alias {
    name                   = aws_lb.csye6225-lb.dns_name
    zone_id                = aws_lb.csye6225-lb.zone_id
    evaluate_target_health = true
  }
}

