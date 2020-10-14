output "aws_consul_iam_role_arn" {
  value = aws_iam_role.consul.arn
}

output "aws_consul_iam_instance_profile_name" {
  value = aws_iam_instance_profile.consul.name
}
