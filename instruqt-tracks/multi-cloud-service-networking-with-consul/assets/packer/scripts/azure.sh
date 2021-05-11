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
sudo apt install azure-cli consul-enterprise=1.9.4+ent vault-enterprise=1.7.1+ent nomad-enterprise=1.0.4+ent docker.io jq -y

#envoy
curl -sL 'https://getenvoy.io/gpg' | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://dl.bintray.com/tetrate/getenvoy-deb $(lsb_release -cs) stable"
sudo apt update -y && sudo apt install -y getenvoy-envoy=1.16.2.p0.ge98e41a-1p71.gbe6132a

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
#envoy
envoy --version
if [ $? -ne 0 ]
then
  echo "Error checking Envoy version"
  exit 1
fi

exit 0
