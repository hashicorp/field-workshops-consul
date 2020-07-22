#cloud-config
write_files:
  - path: /config/custom-config.sh
    permissions: 0755
    owner: root:root
    content: |
      #!/bin/bash

      # Wait for MCPD to be up before running tmsh commands
      source /usr/lib/bigstart/bigip-ready-functions
      wait_bigip_ready

      # Begin BIG-IP configuration
      tmsh modify auth user admin shell bash

      # disable gui idle timeout for lab
      tmsh modify sys httpd auth-pam-idle-timeout 86400
      tmsh modify sys global-settings gui-setup disabled

      # custom banner
      tmsh modify sys global-settings gui-security-banner-text "Provisioned via Terraform!"
      tmsh save /sys config
      bigstart restart httpd

tmos_declared:
  enabled: true
  icontrollx_trusted_sources: false
  icontrollx_package_urls:
    - ${TS_URL}
    - ${DO_URL}
    - ${AS3_URL}
  do_declaration:
    schemaVersion: 1.0.0
    class: Device
    async: true
    label: Cloudinit Onboarding
    Common:
      class: Tenant
      provisioningLevels:
        class: Provision
        ltm: nominal
        asm: nominal
  post_onboard_enabled: true
  post_onboard_commands:
    - /config/custom-config.sh &
    
    