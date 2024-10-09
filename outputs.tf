
output "endpoint" {
  value = aws_db_instance.main_db.endpoint
}

output "aws_kms_key_ebs" {
  value = aws_kms_key.kms-ec2.arn
}

output "aws_kms_key_rds" {
  value = aws_kms_key.rds_encrypt.arn
}