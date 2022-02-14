variable "prefix" {
  default = "f5-azure-consul-ws"
}

variable "environment" {
  default = "test"
}

variable "cidr" {
  default = "10.0.0.0/8"
}

variable "region" {
  default = "centralus"
}

variable instance_type { default = "Standard_DS3_v2" }
variable image_name { default = "f5-bigip-virtual-edition-25m-good-hourly" }
variable publisher { default = "f5-networks" }
variable product { default = "f5-big-ip-good" }
variable bigip_version { default = "latest" }
variable admin_username { default = "f5admin" }

variable DO_URL {
  description = "URL to download the BIG-IP Declarative Onboarding module"
  type        = string
  default     = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.11.0/f5-declarative-onboarding-1.11.0-1.noarch.rpm"
}
## Please check and update the latest AS3 URL from https://github.com/F5Networks/f5-appsvcs-extension/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable AS3_URL {
  description = "URL to download the BIG-IP Application Service Extension 3 (AS3) module"
  type        = string
  default     = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.20.0/f5-appsvcs-3.20.0-3.noarch.rpm"
} ## Please check and update the latest TS URL from https://github.com/F5Networks/f5-telemetry-streaming/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable TS_URL {
  description = "URL to download the BIG-IP Telemetry Streaming Extension (TS) module"
  type        = string
  default     = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.10.0/f5-telemetry-1.10.0-2.noarch.rpm"
}
variable "libs_dir" {
  description = "Directory on the BIG-IP to download the A&O Toolchain into"
  type        = string
  default     = "/config/cloud/aws/node_modules"
}

variable onboard_log {
  description = "Directory on the BIG-IP to store the cloud-init logs"
  type        = string
  default     = "/var/log/startup-script.log"
}

variable ASM_POLICY_URL {
  description = "URL to download the BIG-IP ASM Policy from"
  type        = string
  default     = "https://raw.githubusercontent.com/hashicorp/field-workshops-consul/f5-tf-consul-app-mod/instruqt-tracks/f5-on-azure-app-modernization-with-terraform-consul/assets/terraform/bigip/templates/asm_policy.xml"
}
