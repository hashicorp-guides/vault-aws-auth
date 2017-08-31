terraform {
  required_version = ">= 0.9.3"
}

data "terraform_remote_state" "vault" {
  backend = "local"

  config {
    path = "${path.module}/../vault.tfstate"
  }
}

module "images-aws" {
  source         = "git@github.com:hashicorp-modules/images-aws.git?ref=2017-07-03"
  nomad_version  = "${var.nomad_version}"
  vault_version  = "${var.vault_version}"
  consul_version = "${var.consul_version}"
  aws_region     = "${var.region}"
  os             = "${var.os}"
  os_version     = "${var.os_version}"
}

resource "aws_iam_role" "vault_aws_auth_app" {
  name               = "Vault-AWS-Auth-App"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy" "vault_aws_auth_app" {
  name   = "SelfAssembly"
  role   = "${aws_iam_role.vault_aws_auth_app.id}"
  policy = "${data.aws_iam_policy_document.vault_aws_auth_app.json}"
}

resource "aws_iam_instance_profile" "vault_aws_auth_app" {
  name = "vault_aws_auth_app"
  role = "${aws_iam_role.vault_aws_auth_app.id}"
}

resource "aws_instance" "vault_aws_auth_app" {
  ami           = "${module.images-aws.hashistack_image}"
  instance_type = "t2.micro"
  count         = 1
  subnet_id     = "${data.terraform_remote_state.vault.subnet_public_ids.0}"
  key_name      = "${data.terraform_remote_state.vault.ssh_key_name}"

  security_groups = [
    "${data.terraform_remote_state.vault.consul_client_sg_id}",
    "${data.terraform_remote_state.vault.hashistack_server_sg_id}",
  ]

  associate_public_ip_address = false
  ebs_optimized               = false
  iam_instance_profile        = "${aws_iam_instance_profile.vault_aws_auth_app.id}"

  tags {
    Environment-Name = "${data.terraform_remote_state.vault.environment_name}"
  }

  user_data = "${data.template_file.client-vault-setup.rendered}"
}

data "template_file" "client-vault-setup" {
  template = "${file("${path.module}/app-setup.tpl")}"

  vars = {
    cluster_size     = "${var.cluster_size}"
    environment_name = "${data.terraform_remote_state.vault.environment_name}"
  }
}

data "template_file" "format_ssh" {
  template = "connect to client with the following command: ssh ec2-user@$${client_address} -i $${key}.pem"

  vars {
    client_address = "${aws_instance.vault_aws_auth_app.public_dns}"
    key            = "${data.terraform_remote_state.vault.ssh_key_name}"
  }
}
