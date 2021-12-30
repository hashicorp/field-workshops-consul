data "terraform_remote_state" "iam" {
  backend = "local"

  config = {
    path = "../iam/terraform.tfstate"
  }
}

data "terraform_remote_state" "ecs" {
  backend = "local"

  config = {
    path = "../ecs/terraform.tfstate"
  }
}

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
