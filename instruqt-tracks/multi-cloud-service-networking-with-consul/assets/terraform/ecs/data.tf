data "terraform_remote_state" "consul" {
  backend = "local"

  config = {
    path = "../aws-consul-primary/terraform.tfstate"
  }
}

data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../infra/terraform.tfstate"
  }
}
