locals {
  consul_gossip_key = jsondecode(base64decode(data.terraform_remote_state.hcp.outputs.hcp_consul_cluster.consul_config_file))["encrypt"]
  hcp_acl_token     = data.terraform_remote_state.hcp.outputs.hcp_acl_token_secret_id
}

resource "aws_secretsmanager_secret" "bootstrap_token" {
  name                    = "${var.name}-bootstrap-token"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "bootstrap_token" {
  secret_id     = aws_secretsmanager_secret.bootstrap_token.id
  secret_string = local.hcp_acl_token
}

resource "aws_secretsmanager_secret" "gossip_key" {
  name                    = "${var.name}-gossip-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "gossip_key" {
  secret_id     = aws_secretsmanager_secret.gossip_key.id
  secret_string = local.consul_gossip_key
}

resource "aws_secretsmanager_secret" "consul_ca_cert" {
  name                    = "${var.name}-consul-ca-cert"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "consul_ca_cert" {
  secret_id     = aws_secretsmanager_secret.consul_ca_cert.id
  secret_string = file(var.consul_client_ca_path)
}