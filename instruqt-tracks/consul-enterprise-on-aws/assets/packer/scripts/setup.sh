#!/usr/bin/env bash
set -euxo pipefail

echo "Installing jq"
sudo curl --silent -Lo /bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
sudo chmod +x /bin/jq

echo "Configuring system time"
sudo timedatectl set-timezone UTC

echo "Installing Consul"
install_from_zip() {
  cd /tmp && {
    unzip -qq "${1}.zip"
    sudo mv "${1}" "/usr/local/bin/${1}"
    sudo chmod +x "/usr/local/bin/${1}"
    rm -rf "${1}.zip"
  }
}

echo "Adding Consul system users"

create_ids() {
  sudo /usr/sbin/groupadd --force --system ${1}
  if ! getent passwd ${1} >/dev/null ; then
    sudo /usr/sbin/adduser \
      --system \
      --gid ${1} \
      --home /srv/${1} \
      --no-create-home \
      --comment "${1} account" \
      --shell /bin/false \
      ${1}  >/dev/null
  fi
}

create_ids consul

echo "Configuring HashiCorp directories"
# Second argument specifies user/group for chown, as consul-snapshot does not have a corresponding user
directory_setup() {
  # create and manage permissions on directories
  sudo mkdir -pm 0750 /etc/${1}.d /opt/${1} /opt/${1}/data
  sudo mkdir -pm 0700 /opt/${1}/tls
  sudo chown -R ${2}:${2} /etc/${1}.d /opt/${1}
}

install_from_zip consul
directory_setup consul consul
directory_setup consul-snapshot consul

echo "Copy systemd services"

systemd_files() {
  sudo cp /tmp/files/$1 /etc/systemd/system
  sudo chmod 0664 /etc/systemd/system/$1
}

systemd_files consul.service
systemd_files consul-snapshot.service

echo "Setup Consul profile"
cat <<PROFILE | sudo tee /etc/profile.d/consul.sh
export CONSUL_ADDR=http://127.0.0.1:8500
PROFILE
