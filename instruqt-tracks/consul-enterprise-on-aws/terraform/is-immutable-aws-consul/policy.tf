resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "${random_id.environment_name.hex}-consul"
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "${random_id.environment_name.hex}-consul"
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "cluster_discovery" {
  name   = "${random_id.environment_name.hex}-consul-cluster_discovery"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.cluster_discovery.json
}

data "aws_iam_policy_document" "cluster_discovery" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "autoscaling:CompleteLifecycleAction",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${random_id.environment_name.hex}-consul-data/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucketVersions",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${random_id.environment_name.hex}-consul-data"
    ]
  }

}
