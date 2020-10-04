output "env" {
  value = random_string.env.result
}

output "aws_shared_svcs_vpc" {
  value = module.aws-vpc-shared-svcs.vpc_id
}

output "aws_shared_svcs_public_subnets" {
  value = module.aws-vpc-shared-svcs.public_subnets
}
