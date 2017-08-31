#!/bin/bash

instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
new_hostname="hashistack-$${instance_id}"

# stop consul and nomad so they can be configured correctly
systemctl stop nomad
systemctl stop vault
systemctl stop consul

# clear the consul and nomad data directory ready for a fresh start
rm -rf /opt/consul/data/*
rm -rf /opt/nomad/data/*
rm -rf /opt/vault/data/*

# set the hostname (before starting consul and nomad)
hostnamectl set-hostname "$${new_hostname}"

# ensure dnsmasq is part of name resolution
sudo sed '1 i nameserver 127.0.0.1' -i /etc/resolv.conf

# add the consul group to the config with jq
jq ".retry_join_ec2 += {\"tag_key\": \"Environment-Name\", \"tag_value\": \"${environment_name}\"}" < /etc/consul.d/consul-default.json > /tmp/consul-default.json.tmp
sed -i -e "s/127.0.0.1/$${local_ipv4}/" /tmp/consul-default.json.tmp
mv /tmp/consul-default.json.tmp /etc/consul.d/consul-default.json
chown consul:consul /etc/consul.d/consul-default.json

# remove consul servers specific stuff
rm -f /etc/consul.d/consul-server.json

# start consul once it is configured correctly
systemctl start consul

# currently no additional configuration required for vault
# todo: support TLS in hashistack and pass in {vault_use_tls} once available

# remove this when dan fixes the images
sleep 120

# init Vault
VAULT_HOST=$(curl -s http://127.0.0.1:8500/v1/catalog/service/vault | jq -r '.[0].Address')
curl \
    --silent \
    --request PUT \
    --data '{"secret_shares": 1, "secret_threshold": 1}' \
    http://$${VAULT_HOST}:8200/v1/sys/init | tee \
    >(jq -r .root_token > /tmp/root_token) \
    >(jq -r .keys[0] > /tmp/key)

# unseal Vault
key=$(cat /tmp/key)
for v in $(curl -s http://127.0.0.1:8500/v1/catalog/service/vault | jq -r '.[].Address') ; do
  curl \
       --silent \
       --request PUT \
       --data '{"key": "'"$$key"'"}' \
       http://$${v}:8200/v1/sys/unseal
done

# write some secrets
VAULT_TOKEN=$(cat /tmp/root_token)
curl \
    --header "X-Vault-Token:$${VAULT_TOKEN}" \
    --request POST \
    --data '{"secret":"SUPER_SECRET_PASSWORD"}' \
    http://active.vault.service.consul:8200/v1/secret/foo

# write a policy
echo '
path "secret/foo" {
  capabilities = ["list", "read"]
}
path "supersecret/*" {
  capabilities = ["list", "read"]
}' > policy.payload

curl \
    --silent \
    --header "X-Vault-Token:$${VAULT_TOKEN}" \
    --request POST \
    --data @policy.payload \
    http://active.vault.service.consul:8200/v1/sys/policy/test

####
## Setup AWS authentication
####

# Enable AWS authentication backend
echo '
{
  "type": "aws",
  "description": "AWS authentication setup"
}' > aws_auth.payload

curl \
    --silent \
    --header "X-Vault-Token:$${VAULT_TOKEN}" \
    --request POST \
    --data @aws_auth.payload \
    http://active.vault.service.consul:8200/v1/sys/auth/aws

# Configure AWS credentials in Vault
echo '
{
  "access_key": "${aws_access_key}",
  "secret_key": "${aws_secret_key}"
}' > aws_creds.payload

curl \
    --silent \
    --header "X-Vault-Token:$${VAULT_TOKEN}" \
    --request POST \
    --data @aws_creds.payload \
    http://active.vault.service.consul:8200/v1/auth/aws/config/client

shred aws_creds.payload

# Configure AWS auth role
echo '
{
  "bound_region": "${region}",
  "bound_vpc_id": "${vpc_id}",
  "bound_subnet_id": "${subnet_id}",
  "role_tag": "",
  "policies": ["test"],
  "max_ttl": 1800000,
  "disallow_reauthentication": false,
  "allow_instance_migration": false
}' > test_role.payload

curl \
    --silent \
    --header "X-Vault-Token:$${VAULT_TOKEN}" \
    --request POST \
    --data @test_role.payload \
    http://active.vault.service.consul:8200/v1/auth/aws/role/test
