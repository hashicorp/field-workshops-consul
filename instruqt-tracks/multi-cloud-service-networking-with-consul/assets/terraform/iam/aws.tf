resource "aws_iam_instance_profile" "consul" {
  name = "consul-${data.terraform_remote_state.infra.outputs.env}"
  role = aws_iam_role.consul.name
}

resource "aws_iam_role" "consul" {
  name = "consul-${data.terraform_remote_state.infra.outputs.env}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "consul" {
  name = "consul-${data.terraform_remote_state.infra.outputs.env}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeInstances",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "consul" {
  role       = aws_iam_role.consul.name
  policy_arn = aws_iam_policy.consul.arn
}

resource "aws_iam_instance_profile" "cts" {
  name = "cts-${data.terraform_remote_state.infra.outputs.env}"
  role = aws_iam_role.cts.name
}

resource "aws_iam_role" "cts" {
  name = "cts-${data.terraform_remote_state.infra.outputs.env}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cts" {
  name = "cts-${data.terraform_remote_state.infra.outputs.env}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeSecurityGroupRules",
        "ec2:DescribeSecurityGroups",
        "ec2:ModifySecurityGroupRules",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
        "ec2:UpdateSecurityGroupRuleDescriptionsIngress"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cts" {
  role       = aws_iam_role.cts.name
  policy_arn = aws_iam_policy.cts.arn
}

resource "aws_iam_instance_profile" "nomad" {
  name = "nomad-${data.terraform_remote_state.infra.outputs.env}"
  role = aws_iam_role.nomad.name
}

resource "aws_iam_role" "nomad" {
  name = "nomad-${data.terraform_remote_state.infra.outputs.env}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "nomad" {
  name = "nomad-${data.terraform_remote_state.infra.outputs.env}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeInstances",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "nomad" {
  role       = aws_iam_role.nomad.name
  policy_arn = aws_iam_policy.nomad.arn
}
