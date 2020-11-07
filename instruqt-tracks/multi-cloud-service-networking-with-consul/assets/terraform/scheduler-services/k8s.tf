resource "google_container_cluster" "graphql" {
  name               = "graphql-${data.terraform_remote_state.infra.outputs.env}"
  location           = "us-central1-a"
  initial_node_count = 1

  network = "vpc-shared-svcs"
  subnetwork = "shared"

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    machine_type = "n1-standard-2"
  }

  enable_legacy_abac = true

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "kubernetes_service_account" "consul-graph" {
  provider = kubernetes.graphql

  automount_service_account_token = true
  metadata {
    name = "hashicorp-consul-connect-injector-authmethod-svc-account"
  }

}

resource "kubernetes_cluster_role" "consul-graph" {
  provider = kubernetes.graphql

  metadata {
    name = "hashicorp-consul-connect-injector-authmethod-role"
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts", "pods"]
    verbs      = ["get"]
  }
}

resource "kubernetes_cluster_role_binding" "consul-graph-auth-method" {
  provider = kubernetes.graphql

  metadata {
    name = "hashicorp-consul-connect-injector-authmethod-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "hashicorp-consul-connect-injector-authmethod-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "hashicorp-consul-connect-injector-authmethod-svc-account"
  }
}

resource "kubernetes_cluster_role_binding" "consul-graph-auth-delegator" {
  provider = kubernetes.graphql

  metadata {
    name = "hashicorp-consul-connect-injector-authdelegator-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "hashicorp-consul-connect-injector-authmethod-svc-account"
  }
}

resource "google_container_cluster" "react" {
  name               = "react-${data.terraform_remote_state.infra.outputs.env}"
  location           = "us-central1-a"
  initial_node_count = 1

  network = "vpc-shared-svcs"
  subnetwork = "shared"

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    machine_type = "n1-standard-2"
  }

  enable_legacy_abac = true

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "kubernetes_service_account" "consul-react" {
  provider = kubernetes.react

  automount_service_account_token = true
  metadata {
    name = "hashicorp-consul-connect-injector-authmethod-svc-account"
  }
}

resource "kubernetes_cluster_role" "consul-react" {
  provider = kubernetes.react

  metadata {
    name = "hashicorp-consul-connect-injector-authmethod-role"
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts", "pods"]
    verbs      = ["get"]
  }
}

resource "kubernetes_cluster_role_binding" "consul-react-auth-method" {
  provider = kubernetes.react

  metadata {
    name = "hashicorp-consul-connect-injector-authmethod-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "hashicorp-consul-connect-injector-authmethod-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "hashicorp-consul-connect-injector-authmethod-svc-account"
  }
}

resource "kubernetes_cluster_role_binding" "consul-react-auth-delegator" {
  provider = kubernetes.react

  metadata {
    name = "hashicorp-consul-connect-injector-authdelegator-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "hashicorp-consul-connect-injector-authmethod-svc-account"
  }
}
