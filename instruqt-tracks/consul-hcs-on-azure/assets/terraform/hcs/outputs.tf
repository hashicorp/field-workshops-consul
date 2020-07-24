output "consul_url" {
  value       = azurerm_managed_application.hcs.outputs["consul_url"]
  description = "URL of the HCS for Azure Consul Cluster API and UI."
}

# Fetch the data from HCS
resource "null_resource" "config" {
  depends_on = [azurerm_managed_application.hcs]
  provisioner "local-exec" {
    command = <<EOF
  az resource show \
  --ids "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${data.terraform_remote_state.vnet.outputs.resource_group_name}/providers/Microsoft.Solutions/applications/hcs/customconsulClusters/hashicorp-consul-cluster" \
  --api-version 2018-09-01-preview \
  > ${path.module}/config.json
  EOF
  }
}

resource "null_resource" "token" {
  depends_on = [azurerm_managed_application.hcs]
  provisioner "local-exec" {
    command = <<EOF
  az hcs create-token \
  --resource-group ${data.terraform_remote_state.vnet.outputs.resource_group_name} \
  --name hcs \
  > ${path.module}/token.json
  EOF
  }
}

data "local_file" "config" {
    depends_on = [null_resource.config]

    filename = "${path.module}/config.json"
}

data "local_file" "token" {
    depends_on = [null_resource.token]

    filename = "${path.module}/token.json"
}

output "hcs_config" {
  value = {
    private_url = jsondecode(data.local_file.config.content).properties.consulPrivateEndpointUrl
    public_url = jsondecode(data.local_file.config.content).properties.consulExternalEndpointUrl
    ca_file = jsondecode(data.local_file.config.content).properties.consulCaFile
    consulConfigFile = jsondecode(data.local_file.config.content).properties.consulConfigFile
    acl_token = jsondecode(data.local_file.token.content).masterToken.secretId
  }
}