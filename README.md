

usage:

## download all modules
make get

## plan vault
make plan_vault

## apply vault
make apply_vault

## plan client_automated
make plan_client_automated

## apply client_automated
make apply_client_automated


ssh to host
ssh -i vault-aws-auth-aec3dcbc.pem ec2-user@ec2-54-215-209-48.us-west-1.compute.amazonaws.com


STATUS:
- Vault setup works
- client_automated works - spins up instance that bootstraps vault.
  Or at least it was working until I added the AWS setup bits.
- app - launch works, consul join works, still working on the awsauth.sh script.

script error:
{"errors":["failed to parse JSON input: invalid character '$' looking for beginning of value"]}
