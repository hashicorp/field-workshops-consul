provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

provider "google" {
  version = "~> 3.3.0"
  project = "my-project-id"
  region  = "us-central1"
}

provider "azurerm" {
  version = "=2.20.0"
  features {}
}

resource "random_string" "env" {
  length  = 4
  special = false
  upper   = false
  number  = false
}

#ssh
resource "tls_private_key" "main" {
  algorithm = "RSA"
}

resource "null_resource" "main" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.main.private_key_pem}\" > ../demo-key.pem"
  }

  provisioner "local-exec" {
    command = "chmod 600 ../demo-key.pem"
  }
}
