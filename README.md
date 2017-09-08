# Vault AWS Authentication Guide
The goal of this guide is to help Vault users learn how to utilize Vault’s AWS authentication backend. This backend allows a user with AWS credentials, a EC2 instance or any AWS resource with an IAM role to authenticate to Vault.

In such a situation, Amazon Web Services is leveraged as a trusted entity that provides Vault with verification of an instance or service. Once this verification is complete, a Vault token can be introduced to the instance. This token can be used to authenticate to Vault for retrieval of secrets.

There are two main methods of usage for the AWS authentication backend.
1. EC2 authentication  
Specifically used to authenticate EC2 instances using PKCS7 signature and other parameters (region, vpc, AMI ID, tags).
2. IAM based authentication  
This allows for IAM role information to be used for authentication purposes of EC2 instances as well as other services, such as ECS tasks (containers), Lambda functions, as well as users.

## EC2 example
[EC2 Example notes](ec2.md)  

## IAM example
TBD

#### Reference Content
[Blog post about AWS Authentication backend](https://www.hashicorp.com/blog/bridgewater-securing-their-aws-infrastructure-with-vault/)  
[Vault AWS authentication backend documentation](https://www.vaultproject.io/docs/auth/aws.html)  
[Vault AWS authentication backend - API documentation](https://www.vaultproject.io/api/auth/aws/index.html)  
[Vault pull request for enhanced AWS authentication backend with background details](https://github.com/hashicorp/vault/pull/2441)
