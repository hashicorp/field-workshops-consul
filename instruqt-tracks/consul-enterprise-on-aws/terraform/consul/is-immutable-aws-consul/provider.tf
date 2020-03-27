provider "aws" {
  region  = var.region
  version = "~> 2.5"
}
provider "random" {
  version = "~> 2.2"
}