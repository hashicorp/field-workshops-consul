data "aws_region" "current" {}

data "aws_vpc" "consul_vpc" {
  id = var.vpc_id
}

data aws_ami "immutable" {
  count       = var.ami_id == "" ? 1 : 0
  most_recent = true
  owners      = ["self"]
  name_regex  = "${var.ami_prefix}.*"

  filter {
    name   = "tag:OS"
    values = [var.ami_os]
  }

  filter {
    name   = "tag:OS-Version"
    values = [var.ami_os_release]
  }

  filter {
    name   = "tag:Owner"
    values = [var.ami_owner]
  }

  filter {
    name   = "tag:Release"
    values = [var.ami_release]
  }
}

locals {
  ami_id = var.ami_id == "" ? data.aws_ami.immutable[0].id : var.ami_id
}

resource "random_id" "environment_name" {
  byte_length = 4
  prefix      = "${var.name_prefix}-"
}

resource "aws_autoscaling_group" "consul" {
  name                      = aws_launch_configuration.consul.name
  launch_configuration      = aws_launch_configuration.consul.name
  availability_zones        = split(",", var.availability_zones)
  min_size                  = var.consul_nodes
  max_size                  = var.consul_nodes
  desired_capacity          = var.consul_nodes
  wait_for_capacity_timeout = "480s"
  health_check_grace_period = 15
  health_check_type         = "EC2"
  target_group_arns         = ["${aws_lb_target_group.consul_http.arn}","${aws_lb_target_group.consul_https.arn}"]
  vpc_zone_identifier       = var.subnets
  initial_lifecycle_hook {
    name                 = "consul_health"
    default_result       = "ABANDON"
    heartbeat_timeout    = 7200
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }

  tags = [
    {
      key                 = "Role"
      value               = "consul"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "${random_id.environment_name.hex}-consul-${var.consul_cluster_version}"
      propagate_at_launch = true
    },
    {
      key                 = "Cluster-Version"
      value               = var.consul_cluster_version
      propagate_at_launch = true
    },
    {
      key                 = "Environment-Name"
      value               = "${random_id.environment_name.hex}-consul"
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = var.owner
      propagate_at_launch = true
    },
    {
      key                 = "ttl"
      value               = var.ttl
      propagate_at_launch = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "consul" {
  name                        = "${random_id.environment_name.hex}-consul-${var.consul_cluster_version}"
  image_id                    = local.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  security_groups             = flatten([aws_security_group.consul.id, var.additional_security_group_ids])
  user_data                   = templatefile("${path.module}/scripts/install_hashitools_consul.sh.tpl", local.install_consul_tpl)
  associate_public_ip_address = var.public_ip
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name
  dynamic "root_block_device" {
    for_each = var.performance_mode ? [local.disk_consul_io1] : [local.disk_consul_gp2]
    content {
      volume_type = root_block_device.value.volume_type
      volume_size = root_block_device.value.volume_size
      iops        = root_block_device.value.volume_type == "io1" ? root_block_device.value.iops : "0"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  disk_consul_io1 = {
    volume_type = "io1"
    volume_size = 100
    iops        = "5000"
  }
  disk_consul_gp2 = {
    volume_type = "gp2"
    volume_size = 100
  }
  install_consul_tpl = {
    ami                    = local.ami_id
    environment_name       = random_id.environment_name.hex
    datacenter             = data.aws_region.current.name
    bootstrap_expect       = var.redundancy_zones ? length(split(",", var.availability_zones)) : var.consul_nodes
    total_nodes            = var.consul_nodes
    gossip_key             = random_id.consul_gossip_encryption_key.b64_std
    master_token           = random_uuid.consul_master_token.result
    agent_server_token     = random_uuid.consul_agent_server_token.result
    snapshot_token         = random_uuid.consul_snapshot_token.result
    consul_cluster_version = var.consul_cluster_version
    asg_name               = "${random_id.environment_name.hex}-consul-${var.consul_cluster_version}"
    redundancy_zones       = var.redundancy_zones
    bootstrap              = var.bootstrap
    enable_connect         = var.enable_connect
    performance_mode       = var.performance_mode
    enable_snapshots       = var.enable_snapshots
    snapshot_interval      = var.snapshot_interval
    snapshot_retention     = var.snapshot_retention
    consul_config          = var.consul_config
    consul_ca_cert         = var.consul_tls_config.ca_cert
    consul_cert            = var.consul_tls_config.cert
    consul_key             = var.consul_tls_config.key
  }
}

resource "aws_lb_target_group" "consul_http" {
  port                 = 8500
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  deregistration_delay = "15"
  
  stickiness {
      enabled = false
      type = "lb_cookie"
  }
  
  health_check {
    path     = "/v1/status/leader"
    port     = "8500"
    protocol = "HTTP"
  }
  
}

resource "aws_lb_target_group" "consul_https" {
  port                 = 8501
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  deregistration_delay = "15"

  stickiness {
      enabled = false
      type = "lb_cookie"
  }
  
  health_check {
    path     = "/v1/status/leader"
    port     = "8501"
    protocol = "HTTPS"
  }
  
}
