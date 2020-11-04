provider "google" {
  version = "~> 3.43.0"
  region  = "us-central1"
  project = var.gcp_project_id
}

data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../infra/terraform.tfstate"
  }
}
