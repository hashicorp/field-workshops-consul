provider "aws" {
  version = "~> 3.0"
  region  = "us-east-1"
}

provider "google" {
  version = "~> 3.3.0"
  project     = "my-project-id"
  region      = "us-central1"
}
