#!/bin/bash -xe

#get endpoints
echo "Getting Vault endpoints..."
AWS_VAULT_IP=$(terraform output -state /root/terraform/vault/terraform.tfstate aws_vault_ip)
AZURE_VAULT_IP=$(terraform output -state /root/terraform/vault/terraform.tfstate azure_vault_ip)

echo "Resetting AWS Vault..."
ssh -t -T ubuntu@$AWS_VAULT_IP << CMD
  sudo service vault stop
  sleep 5
  sudo rm -rf /opt/vault/raft/*
  sleep 5
  sudo service vault start
  sleep 15
  sudo service vault status
CMD

echo "Resetting Azure Vault..."
ssh -t -T ubuntu@$AZURE_VAULT_IP << CMD
  sudo service vault stop
  sleep 5
  sudo rm -rf /opt/vault/raft/*
  sleep 5
  sudo service vault start
  sleep 15
  sudo service vault status
CMD

echo "Vault reset complete"

exit 0
