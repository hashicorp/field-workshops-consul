# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "hashicups_url" {
  value = "http://${data.kubernetes_service.ingress.status[0].load_balancer[0].ingress[0].hostname}"
}
