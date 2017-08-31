.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

get: ## Download all required Terraform modules
	@terraform get vault
	@terraform get client_automated


plan_vault:  ## Terraform plan Vault cluster
	@terraform plan vault
apply_vault: ## Terraform apply Vault cluster
	@terraform apply -state=vault.tfstate vault
destroy_vault: ## Terraform destroy Vault cluster
	@terraform destroy -state=vault.tfstate -force vault


plan_client_automated: ## Terraform plan client
		@terraform plan client_automated
apply_client_automated: ## Terraform apply client
		@terraform apply -state=client_automated.tfstate client_automated
destroy_client_automated: ## Terraform destroy client
		@terraform destroy -state=client_automated.tfstate -force client_automated


plan_app: ## Terraform plan app
		@terraform plan app
apply_app: ## Terraform apply app
		@terraform apply -state=app.tfstate app
destroy_app: ## Terraform destroy app
		@terraform destroy -state=app.tfstate -force app

destroy_all: ## Destroy all environments
		@terraform destroy -state=vault.tfstate -force vault
		@terraform destroy -state=client_automated.tfstate -force client_automated
		@terraform destroy -state=app.tfstate -force app
		
clean: ## cleaning up all artifacts
		@echo "Cleaning up"
		@rm -rf .terraform/ *.tfstate* *.pem
