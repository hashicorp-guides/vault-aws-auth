# Vault AWS Authentication Guide
The goal of this guide is to help Vault users learn how to utilize Vault’s AWS authentication backend. This backend allows a user with AWS credentials, a EC2 instance or any AWS resource with an IAM role to authenticate to Vault.


## Estimated Time to Complete
30 minutes

## Prerequisites
- [Vault Cluster Guide](https://www.vaultproject.io/guides/vault-cluster.html)
- [Vault Initialization Guide](https://www.vaultproject.io/guides/vault-init.html)

## Challenge
Launch a Vault cluster using Terraform code. Provision an instance (or resource) that authenticates to Vault via EC2 or IAM roles such that the resource can access secrets to which it was granted access.

## Solution
Deploy cluster, provision instance, validate that it can retrieve secrets after authentication.
## Steps

### Step 1

#### UI
##### Request

##### Response: 200 OK


#### cURL
##### Request

##### Response: 200 OK


#### CLI
##### Request

##### Response: 200 OK


#### Validation


#### Reference Content
[Blog post about AWS Authentication backend](https://www.hashicorp.com/blog/bridgewater-securing-their-aws-infrastructure-with-vault/)  
[Vault AWS authentication backend documentation](https://www.vaultproject.io/docs/auth/aws.html)  
[Vault AWS authentication backend - API documentation](https://www.vaultproject.io/api/auth/aws/index.html)  
[Vault pull request for enhanced AWS authentication backend with background details](https://github.com/hashicorp/vault/pull/2441)

## Next Steps
- [Unseal Vault](https://github.com/hashicorp-guides/vault-unseal)
