# Optional variables
variable "environment_name_prefix" {
  default     = "vault-aws-auth"
  description = "Environment Name prefix eg my-hashistack-env"
}

# Required variables for hashistack-aws config
variable "os" {
  # case sensitive for AMI lookup
  default     = "RHEL"
  description = "Operating System to use ie RHEL or Ubuntu"
}

variable "os_version" {
  default     = "7.3"
  description = "Operating System version to use ie 7.3 (for RHEL) or 16.04 (for Ubuntu)"
}

# Optional variables for the hashistack-aws repo
variable "cluster_size" {
  default     = "1"
  description = "Number of instances to launch in the cluster"
}

variable "consul_version" {
  default     = "0.9.2"
  description = "Consul version to use ie 0.8.4"
}

variable "nomad_version" {
  default     = "0.6.2"
  description = "Nomad version to use ie 0.6.0"
}

variable "vault_version" {
  default     = "0.8.1"
  description = "Vault version to use ie 0.7.1"
}

variable "region" {
  default     = "us-west-1"
  description = "Region to deploy consul cluster ie us-west-1"
}

## Outputs

output "ssh_info" {
  value = "${data.template_file.format_ssh.rendered}"
}
