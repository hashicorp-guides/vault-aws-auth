# Usage

### download all plugins and modules
`make init`

## Provision Vault cluster  
This workspace will provision a Vault + Consul cluster.  

### plan vault
`make plan_vault`

### apply vault
`make apply_vault`

## Provision client for Vault configuration
This workspace will provision an instance that will initialize, unseal, and configure Vault.  

### plan client_automated
`make plan_client_automated`

### apply client_automated
`make apply_client_automated`

## Provision application instance
This workspace will provision an example application instance that can authenticate to Vault using AWS EC2 details, obtaining a valid token to retrieve secrets and interact with Vault.   

### plan app
`make app`

### apply app
`make app`


See output from Terraform executions to connect to servers via SSH.

For example:
`ssh -i vault-aws-auth-aec3dcbc.pem ec2-user@ec2-54-215-209-48.us-west-1.compute.amazonaws.com`


TODO:
- systemd-ify the awsauth script for initial login and token maintenance
- modify awsauth script such that token validation function is not done executed multiple times per script execution
- need to create example app that fetches and uses secrets
