provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

provider "google" {
  version = "~> 3.3.0"
  region  = "us-central1"
  project = var.gcp_project_id
}

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
