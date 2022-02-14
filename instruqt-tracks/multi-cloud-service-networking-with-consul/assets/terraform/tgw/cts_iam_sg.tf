resource "aws_iam_instance_profile" "cts_iam" {
  name = "cts_iam-${data.terraform_remote_state.infra.outputs.env}"
  role = aws_iam_role.cts_iam_role.name
}

resource "aws_iam_role" "cts_iam_role" {
  name = "cts_iam_role-${data.terraform_remote_state.infra.outputs.env}" 
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

resource "aws_iam_policy" "cts_iam_policy" {
  name = "cts_iam_policy-${data.terraform_remote_state.infra.outputs.env}" 
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

resource "aws_iam_role_policy_attachment" "cts_iam_attachment" {
  role       = aws_iam_role.cts_iam_role.name
  policy_arn = aws_iam_policy.cts_iam_policy.arn
}


