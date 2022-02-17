#!/bin/bash -xe

#dir
echo "Starting Vault setup..."
cd /root/terraform/vault

#get endpoints
echo "Getting Vault endpoints..."
AWS_VAULT_IP=$(terraform output -state /root/terraform/vault/terraform.tfstate aws_vault_ip)
AZURE_VAULT_IP=$(terraform output -state /root/terraform/vault/terraform.tfstate azure_vault_ip)

#aws init - not safe for prod
echo "Initializing AWS Vault..."
export VAULT_ADDR=http://${AWS_VAULT_IP}:8200
vault operator init -recovery-shares=1 -recovery-threshold=1 -format=json | jq . > /root/aws_vault_keys.json
sleep 15

#azure init - not safe for prod
echo "Initializing Azure Vault..."
export VAULT_ADDR=http://${AZURE_VAULT_IP}:8200
vault operator init -recovery-shares=1 -recovery-threshold=1 -format=json | jq . > /root/azure_vault_keys.json
sleep 15

#start performance replication on the AWS primary
echo "Starting performance Replication on AWS Primary..."
export VAULT_ADDR=http://${AWS_VAULT_IP}:8200
export VAULT_TOKEN=$(cat /root/aws_vault_keys.json | jq -r .root_token)
vault write sys/replication/performance/primary/enable primary_cluster_addr="http://${AWS_VAULT_IP}:8201"
sleep 30

#generate the secondary tokens & enable the performance secondaries
echo "Generating secondary replication token..."
AZURE_REPLICATION_TOKEN=$(vault write /sys/replication/performance/primary/secondary-token id="azure-west-us-2" -format=json | jq -r .wrap_info.token)
sleep 5

#azure
echo "Enabling secondary replication on Azure Vault..."
export VAULT_ADDR=http://${AZURE_VAULT_IP}:8200
export VAULT_TOKEN=$(cat /root/azure_vault_keys.json | jq -r .root_token)
vault write sys/replication/performance/secondary/enable token="${AZURE_REPLICATION_TOKEN}" primary_api_addr="http://${AWS_VAULT_IP}:8200"
sleep 60

#vault config
export VAULT_ADDR=http://${AWS_VAULT_IP}:8200
export VAULT_TOKEN=$(cat /root/aws_vault_keys.json | jq -r .root_token)

#vault policies
echo "Writing Vault policies..."
cd /root/policies/vault
vault policy write admin admin.hcl
vault policy write nomad-server nomad-server.hcl
vault policy write connect connect.hcl
vault policy write consul consul.hcl
vault policy write vault vault.hcl
vault policy write payments payments.hcl
vault policy write product-api product-api.hcl
vault policy write payments-developer payments-developer.hcl
vault policy write product-developer product-developer.hcl
vault policy write frontend-developer frontend-developer.hcl
curl  https://nomadproject.io/data/vault/nomad-cluster-role.json -O -s -L
vault write /auth/token/roles/nomad-cluster @nomad-cluster-role.json

#vault users - not for production
echo "Writing Vault user..."
vault auth enable userpass
vault write auth/userpass/users/admin \
    password=admin \
    policies=admin
vault write auth/userpass/users/payments-developer \
    password=payments \
    policies=payments-developer
vault write auth/userpass/users/product-developer \
    password=product \
    policies=product-developer
vault write auth/userpass/users/frontend-developer \
    password=frontend \
    policies=frontend-developer

#auth methods & secrets engines
echo "Configuring Vault auth methods and secret engines..."
vault secrets enable transit
vault write -f transit/keys/payments
vault auth enable aws
vault auth enable azure
vault write auth/azure/config \
    tenant_id="$(az account show | jq -r .tenantId)" \
    resource="https://management.azure.com/"
vault secrets enable -version=2 kv
vault secrets enable pki
private_key=$(vault write -field private_key pki/root/generate/exported\
    common_name="HashiCorp CA" \
    key_type="ec" \
    key_bits="521" \
    ttl=8760h)
vault kv put kv/pki private_key="${private_key}"
vault write pki/roles/consul \
    allowed_domains=consul,internal \
    allow_subdomains=true \
    max_ttl=72h

#vault trust - lab servers
echo "Creating cloud trust with Vault Servers"
AWS_VAULT_IAM_ROLE_ARN=$(terraform output -state /root/terraform/vault/terraform.tfstate aws_vault_iam_role_arn)
vault write auth/aws/role/vault \
  auth_type=iam \
  bound_iam_principal_arn="${AWS_VAULT_IAM_ROLE_ARN}" \
  policies=vault,consul ttl=30m
AZURE_VAULT_SERVICE_PRINCIPAL_ID=$(terraform output -state /root/terraform/vault/terraform.tfstate azure_vault_user_assigned_identity_principal_id)
vault write auth/azure/role/vault \
  bound_service_principal_ids="${AZURE_VAULT_SERVICE_PRINCIPAL_ID}" \
  policies=vault,consul ttl=30m

#consul trust - lab servers
echo "Creating cloud trust with Consul Servers"
AWS_CONSUL_IAM_ROLE_ARN=$(terraform output -state /root/terraform/iam/terraform.tfstate aws_consul_iam_role_arn)
AWS_CTS_IAM_ROLE_ARN=$(terraform output -state /root/terraform/iam/terraform.tfstate aws_cts_iam_role_arn)
vault write auth/aws/role/consul auth_type=iam \
  bound_iam_principal_arn="${AWS_CONSUL_IAM_ROLE_ARN}","${AWS_CTS_IAM_ROLE_ARN}" \
  policies=consul,admin ttl=30m
AZURE_CONSUL_SERVICE_PRINCIPAL_ID=$(terraform output -state /root/terraform/iam/terraform.tfstate azure_consul_user_assigned_identity_principal_id)
vault write auth/azure/role/consul \
  policies=consul,admin ttl=30m \
  bound_service_principal_ids="${AZURE_CONSUL_SERVICE_PRINCIPAL_ID}"

#nomad trust - lab servers
echo "Creating cloud trust with Nomad Servers"
AWS_NOMAD_IAM_ROLE_ARN=$(terraform output -state /root/terraform/iam/terraform.tfstate aws_nomad_iam_role_arn)
vault write auth/aws/role/nomad auth_type=iam \
  bound_iam_principal_arn="${AWS_NOMAD_IAM_ROLE_ARN}" \
  policies=nomad-server,consul,admin ttl=30m

#app trust - lab servers
echo "Creating cloud trust with Application Servers"
AZURE_PRODUCT_API_SERVICE_PRINCIPAL_ID=$(terraform output -state /root/terraform/iam/terraform.tfstate azure_product_api_user_assigned_identity_principal_id)
vault write auth/azure/role/product-api \
  policies=product-api ttl=30m \
  bound_service_principal_ids="${AZURE_PRODUCT_API_SERVICE_PRINCIPAL_ID}"

cd /root/terraform/vault
echo "Vault setup complete"

exit 0
