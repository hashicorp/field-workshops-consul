#!/bin/bash

#wait for box
sleep 30

#hashicorp packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

#azure packages
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo apt-key add -
AZ_REPO=$(lsb_release -cs)
sudo apt-add-repository "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main"

#install packages
sudo apt update -y
sudo apt install azure-cli consul-enterprise=$CONSUL_VERSION vault-enterprise=$VAULT_VERSION nomad-enterprise=$NOMAD_VERSION docker.io jq unzip -y

#pgk checks
#azure cli
az --version
if [ $? -ne 0 ]
then
  echo "Error checking Azure cli version"
  exit 1
fi
#consul
consul --version
if [ $? -ne 0 ]
then
  echo "Error checking Consul version"
  exit 1
fi
#vault
vault --version
if [ $? -ne 0 ]
then
  echo "Error checking Vault version"
  exit 1
fi
#nomad
nomad --version
if [ $? -ne 0 ]
then
  echo "Error checking Nomad version"
  exit 1
fi
#docker
docker --version
if [ $? -ne 0 ]
then
  echo "Error checking Docker version"
  exit 1
fi
#jq
jq --version
if [ $? -ne 0 ]
then
  echo "Error checking jq version"
  exit 1
fi
#unzip
unzip -v
if [ $? -ne 0 ]
then
  echo "Error checking unzip version"
  exit 1
fi

exit 0
