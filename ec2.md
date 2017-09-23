# AWS Authentication guide - EC2 Example


## Estimated Time to Complete
10 minutes

## Prerequisites
- Vault Cluster Guide
- Vault Initialization Guide
- Basic understanding of Terraform

## Challenge
Launch a Vault cluster using Terraform code. Provision an instance (or resource) that authenticates to Vault via EC2 method such that the resource can access secrets to which it was granted access.

## Solution

Deploy cluster, provision instance, validate that it can retrieve secrets after authentication.


## Steps
Instructions have following assumptions:
- Use current directory as working directory
- Terraform installed locally
- [AWS credentials configured within local environment](https://www.terraform.io/docs/providers/aws/)
(envchain is useful on OS X)

---  

### Download all Terraform plugins and modules
`make init`

## Provision Vault cluster  
This workspace will provision a Vault + Consul cluster.  

### Terraform plan Vault
`make plan_vault`

### Terraform apply Vault
`make apply_vault`

---  

## Provision admin node for Vault configuration
This workspace will provision an instance that will initialize, unseal, and configure Vault.  It can also be used for Vault administration.

### Terraform plan admin
`make plan_admin`

### Terraform apply admin
`make apply_admin`

---  

## Provision application instance
This workspace will provision an example application instance that can authenticate to Vault using AWS EC2 details, obtaining a valid token to retrieve secrets and interact with Vault.   

### plan app
`make app`

### apply app
`make app`

---  

See output from Terraform executions to connect to servers via SSH.

For example:
`ssh_info = connect to app node with the following command: ssh ec2-user@ec2-54-183-250-69.us-west-1.compute.amazonaws.com -i vault/vault-aws-auth-1cd48cf7.pem`

1. Connect to this instance via ssh
2. Switch to root user `sudo su -`
3. Execute `awsauth.sh`
4. Read secrets  
```
curl --silent --header "X-Vault-Token: $(cat /var/token)" \
       http://active.vault.service.consul:8200/v1/secret/foo | jq '.'
{
  "request_id": "0667e33f-aaca-2664-34c5-c494d527e1c1",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 2764800,
  "data": {
    "secret": "SUPER_SECRET_PASSWORD"
  },
  "wrap_info": null,
  "warnings": null,
  "auth": null
}
```


TODO:
- systemd-ify the awsauth script for initial login and token maintenance
- need to create example app that fetches and uses secrets
