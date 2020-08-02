all: tf_vnet tf_vgw tf_vault tf_hcs tf_aks tf_vm
kill: tf_vm_kill tf_aks_kill tf_hcs_kill tf_vault_kill tf_vgw_kill tf_vnet_kill
	@echo Removed all resources

tf_vnet:	
	@echo Buidling Virtual Network
	cd vnet && terraform init
	cd vnet && terraform apply -auto-approve

tf_vnet_kill:	
	cd vnet && terraform destroy -auto-approve

tf_vgw:	
	@echo Buidling Virtual Network Gateway
	cd vgw && terraform init
	cd vgw && terraform apply -auto-approve

tf_vgw_kill:	
	cd vgw && terraform destroy -auto-approve

tf_vault:	
	@echo Buidling Vault
	cd vault && terraform init
	cd vault && terraform apply -auto-approve

tf_vault_kill:	
	cd vault && terraform destroy -auto-approve

tf_hcs:	
	@echo Buidling Vault
	cd hcs && terraform init
	cd hcs && terraform apply -auto-approve

tf_hcs_kill:	
	cd hcs && terraform destroy -auto-approve

tf_hcs_env:
	@cd hcs && terraform output -json | jq .hcs_config.value.ca_file -r | base64 -d > ../ca.pem
	@echo "export CONSUL_CACERT=./ca.pem"
	@echo "export CONSUL_HTTP_TOKEN=$(shell cd hcs && terraform output -json | jq .hcs_config.value.acl_token -r)"
	@echo "export CONSUL_HTTP_ADDR=$(shell cd hcs && terraform output -json | jq .hcs_config.value.public_url)"

tf_aks:	
	@echo Buidling Vault
	cd aks && terraform init
	cd aks && terraform apply -auto-approve

tf_aks_kill:	
	cd aks && terraform destroy -auto-approve

tf_vm:	
	@echo Buidling Vault
	cd vm && terraform init
	cd vm && terraform apply -auto-approve

tf_vm_kill:	
	cd vm && terraform destroy -auto-approve