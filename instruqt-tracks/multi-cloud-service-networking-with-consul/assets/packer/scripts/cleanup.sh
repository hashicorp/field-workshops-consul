#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


#remove artifacts
sudo rm -rf /var/lib/cloud/instances/*
sudo rm -f /root/.ssh/authorized_keys
sudo rm -f /etc/ssh/ssh_host_*
sudo rm -rf /tmp/*
history -c

exit 0
