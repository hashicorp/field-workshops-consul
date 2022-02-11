data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.22.0"

  cluster_name    = "${data.terraform_remote_state.hcp.outputs.hcp_cluster_id}-eks-dev"
  cluster_version = "1.21"
  subnets         = data.terraform_remote_state.hcp.outputs.eks_dev_public_subnets
  vpc_id          = data.terraform_remote_state.hcp.outputs.aws_vpc_eks_dev_id

  node_groups = {
    application = {
      name_prefix      = "hashicups"
      instance_types   = ["t3a.large"]
      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 3
    }
  }
}

module "eks_consul_client" {
#  source  = "hashicorp/hcp-consul/aws//modules/hcp-eks-client"
  source  = "./modules/hcp-eks-client"

  cluster_id       = data.terraform_remote_state.hcp.outputs.hcp_cluster_id
  consul_hosts     = [substr(data.terraform_remote_state.hcp.outputs.hcp_consul_private_endpoint_url, 8, -1)]
  k8s_api_endpoint = module.eks.cluster_endpoint
  consul_version   = data.terraform_remote_state.hcp.outputs.hcp_consul_version

#  boostrap_acl_token    = hcp_consul_cluster_root_token.token.secret_id
  boostrap_acl_token    = data.terraform_remote_state.hcp.outputs.hcp_acl_token.secret_id
  consul_ca_file        = base64decode(data.terraform_remote_state.hcp.outputs.hcp_consul_ca_file)
  datacenter            = data.terraform_remote_state.hcp.outputs.consul_datacenter
  gossip_encryption_key = jsondecode(base64decode(data.terraform_remote_state.hcp.outputs.hcp_consul_config_file))["encrypt"]

  # The EKS node group will fail to create if the clients are
  # created at the same time. This forces the client to wait until
  # the node group is successfully created.
  depends_on = [module.eks]
}

module "demo_app" {
  source  = "./modules/eks-services"
#  version = "~> 0.4.2"

  depends_on = [module.eks_consul_client]
}

#module "demo_app" {
#  source  = "hashicorp/hcp-consul/aws//modules/k8s-demo-app"
#  version = "~> 0.4.2"
#
#  depends_on = [module.eks_consul_client]
#}