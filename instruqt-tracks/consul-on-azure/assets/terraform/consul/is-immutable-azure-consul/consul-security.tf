resource "random_uuid" "consul_master_token" {}
resource "random_uuid" "consul_agent_server_token" {}
resource "random_uuid" "consul_snapshot_token" {}

resource "random_id" "consul_gossip_encryption_key" {
  byte_length = 32
}
