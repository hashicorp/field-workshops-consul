provider "google" {
  version = "~> 3.43.0"
  region  = "us-central1"
  project = var.gcp_project_id
}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${data.google_container_cluster.shared.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.shared.master_auth[0].cluster_ca_certificate,
  )
}

global:
  name: consul
  datacenter: gcp-us-central-1
  tls:
    enabled: true
    caCert:
      secretName: consul-federation
      secretKey: caCert
    caKey:
      secretName: consul-federation
      secretKey: caKey
  serverAdditionalDNSSANs:
  gossipEncryption:
    secretName: consul-federation
    secretKey: gossipEncryptionKey
  acls:
    manageSystemACLs: true
    replicationToken:
      secretName: consul-federation
      secretKey: replicationToken
  federation:
    enabled: true
ui:
  enabled: true
connectInject:
  enabled: true
server:
  extraVolumes:
    - type: secret
      name: consul-federation
      items:
        - key: serverConfigJSON
          path: config.json
      load: true
client:
  enabled: true
meshGateway:
  enabled: true
