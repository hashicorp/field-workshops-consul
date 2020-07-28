variable "bootstrap" {
  type        = bool
  default     = true
  description = "Initial Bootstrap configurations"
}

variable "redundancy_zones" {
  type        = bool
  default     = false
  description = "Leverage Redundancy Zones within Consul for additional non-voting nodes."
}

variable "performance_mode" {
  type        = bool
  description = "High IOPS provisioning and production raft performance factors."
  default     = true
}

variable "ami_prefix" {
  default     = "is-aws-immutable-consul-"
  description = "AMI prefix name(From Packer) to target in the filter"
}

variable "ami_release" {
  default     = "0.0.1"
  description = "AMI release version to target in the filter"
}

variable "ami_os" {
  default     = "centos"
  description = "AMI operating system to target in the filter"
}

variable "ami_os_release" {
  default     = "7"
  description = "AMI OS version to target in the filter"
}

variable "ami_owner" {
  description = "AMI owner to target in the filter"
}

variable "ami_id" {
  default     = ""
  description = "AMI ID to target. Overrides filter."
}

variable "region" {
  description = "AWS Region to target for deployment"
}

variable "name_prefix" {
  default     = "hashicorp"
  description = "prefix used in resource names"
}

variable "availability_zones" {
  default     = "us-east-2a,us-east-2b,us-east-2c"
  description = "Availability zones for launching the instances"
}

variable "public_ip" {
  type        = bool
  default     = false
  description = "should ec2 instance have public ip?"
}

variable "instance_type" {
  default     = "m5.large"
  description = "Instance type for Consul instances"
}

variable "key_name" {
  default     = "default"
  description = "SSH key name for Consul instances"
}

variable "consul_nodes" {
  default     = "5"
  description = "number of Consul instances"
}

variable "subnets" {
  description = "list of subnets to launch Consul within"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "owner" {
  description = "value of owner tag on EC2 instances"
}

variable "ttl" {
  description = "value of ttl tag on EC2 instances"
}

variable "consul_cluster_version" {
  default     = "0.0.1"
  description = "Custom Version Tag for Upgrade Migrations"
}

variable "enable_connect" {
  type        = bool
  description = "Whether Consul Connect should be enabled on the cluster"
  default     = false
}

variable "enable_snapshots" {
  type        = bool
  description = "Whether the Consul Snapshot agent should be enabled on the cluster"
  default     = true
}

variable "snapshot_interval" {
  type        = string
  description = "The consul snapshot agent archival interval"
  default     = "30m"
}

variable "snapshot_retention" {
  type        = number
  description = "The consul snapshot agent archival interval"
  default     = 336
}

variable "consul_config" {
  description = "HCL Object with additional configuration overrides supplied to the consul servers.  This is converted to JSON before rendering via the template."
  default     = {}
}

variable "additional_security_group_ids" {
  description = "A list of additional SGs."
  default     = []
}

variable "consul_tls_config" {
  type = object({
    ca_cert = string,
    cert    = string,
    key     = string
  })
  default = {
    ca_cert = "",
    cert    = "",
    key     = ""
  }
  description = "Object containing the server TLS config to inject"
}


