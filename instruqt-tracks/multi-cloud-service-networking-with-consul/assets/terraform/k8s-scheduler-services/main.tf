provider "google" {
  version = "~> 3.45.0"
  region  = "us-central1"
  project = var.gcp_project_id
}

provider "kubernetes" {
  load_config_file = false
  alias            = "graphql"

  host  = "https://${google_container_cluster.graphql.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.graphql.master_auth[0].cluster_ca_certificate,
  )
}

provider "kubernetes" {
  load_config_file = false
  alias            = "react"

  host  = "https://${google_container_cluster.react.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.react.master_auth[0].cluster_ca_certificate,
  )
}

data "google_client_config" "provider" {}

data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../infra/terraform.tfstate"
  }
}

data "terraform_remote_state" "iam" {
  backend = "local"

  config = {
    path = "../iam/terraform.tfstate"
  }
}
