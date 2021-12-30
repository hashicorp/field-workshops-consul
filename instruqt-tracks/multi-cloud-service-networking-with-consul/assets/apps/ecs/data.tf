data "terraform_remote_state" "iam" {
  backend = "local"

  config = {
    path = "../../terraform/iam/terraform.tfstate"
  }
}

data "terraform_remote_state" "ecs" {
  backend = "local"

  config = {
    path = "../../terraform/ecs/terraform.tfstate"
  }
}

data "terraform_remote_state" "consul" {
  backend = "local"

  config = {
    path = "../../terraform/aws-consul-primary/terraform.tfstate"
  }
}

data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../../terraform/infra/terraform.tfstate"
  }
}
