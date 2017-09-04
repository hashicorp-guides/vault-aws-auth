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
  default     = "3"
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

variable "instance_type" {
  default     = "m4.large"
  description = "AWS instance type to use eg m4.large"
}

variable "region" {
  default     = "us-west-1"
  description = "Region to deploy consul cluster ie us-west-1"
}

## Outputs

# network-aws outputs
output "vpc_id" {
  value = "${module.network-aws-simple.vpc_id}"
}

output "subnet_public_ids" {
  value = ["${module.network-aws-simple.subnet_public_ids}"]
}

output "security_group_egress_id" {
  value = "${module.network-aws-simple.security_group_apps}"
}

# hashistack-aws outputs
output "hashistack_autoscaling_group_id" {
  value = "${module.hashistack-aws.asg_id}"
}

output "consul_client_sg_id" {
  value = "${module.hashistack-aws.consul_client_sg_id}"
}

output "hashistack_server_sg_id" {
  value = "${module.hashistack-aws.hashistack_server_sg_id}"
}

output "environment_name" {
  value = "${random_id.environment_name.hex}"
}

# ssh-keypair-aws outputs
# Uncomment below to output private key contents
#output "private_key_data" {
#  value = "${module.ssh-keypair-aws.private_key_data}"
#}

output "ssh_key_name" {
  value = "${module.ssh-keypair-aws.ssh_key_name}"
}
