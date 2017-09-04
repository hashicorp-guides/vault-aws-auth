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

#
cat << 'SCRIPT' > /usr/local/bin/awsauth.sh
#!/usr/bin/env bash

token_path=/var/token
nonce_path=/var/nonce

# if curl pkcs7 fails, exit with error logged

token_exists () {
if [ -f $token_path ]; then
  return 0
else
  return 1
fi
}

token_is_valid() {
#  https://www.vaultproject.io/api/auth/token/index.html#lookup-a-token-self-
  echo "Checking token validity"
  token_lookup=$(curl -X POST \
       -H "X-Vault-Token: $(cat $token_path)" \
       -w %{http_code} \
       --silent \
       --output /dev/null \
       $vault_addr/v1/auth/token/lookup-self)
  if [ "$token_lookup" == "200" ]; then
    echo "$0 - Valid token found, exiting"
    return 0
  else
    echo "$0 - Invalid token found"
    return 1
  fi
}

main () {
if ! token_exists; then
  aws_login ""
elif token_exists && ! token_is_valid; then
  aws_login "$(cat $nonce_path)"
elif token_exists && token_is_valid; then
  logger $0 "current vault token is still valid"
  exit 0
fi
}

aws_login () {
pkcs7=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7 | tr -d '\n')

if [ -z "$1" ]; then
# do not load nonce if initial login
login_payload=$(cat <<EOF
{
  "role": "test",
  "pkcs7": "$${pkcs7}"
}
EOF
)
else
# load nonce in payload for reauthentication
login_payload=$(cat <<EOF
{
  "role": "test",
  "pkcs7": "$${pkcs7}",
  "nonce": "$1"
}
EOF
)
fi

curl \
    --silent \
    --request POST \
    --data "$${login_payload}" \
    http://active.vault.service.consul:8200/v1/auth/aws/login | tee \
    >(jq -r .auth.client_token > $token_path) \
    >(jq -r .auth.metadata.nonce > $nonce_path)
}

main
SCRIPT


chmod +x /usr/local/bin/awsauth.sh
