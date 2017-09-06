.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init: ## Download all required Terraform modules and plugins
	@cd vault; terraform init
	@cd client_automated; terraform init
	@cd app; terraform init

plan_vault:  ## Terraform plan Vault cluster
	@cd vault; terraform plan
apply_vault: ## Terraform apply Vault cluster
	@cd vault; terraform apply -state=vault.tfstate
destroy_vault: ## Terraform destroy Vault cluster
	@cd vault; terraform destroy -state=vault.tfstate -force


plan_client_automated: ## Terraform plan client
		@cd client_automated; terraform plan
apply_client_automated: ## Terraform apply client
		@cd client_automated; terraform apply -state=client_automated.tfstate
destroy_client_automated: ## Terraform destroy client
		@cd client_automated; terraform destroy -state=client_automated.tfstate -force


plan_app: ## Terraform plan app
		@cd app; terraform plan
apply_app: ## Terraform apply app
		@cd app; terraform apply -state=app.tfstate
destroy_app: ## Terraform destroy app
		@cd app; terraform destroy -state=app.tfstate -force

destroy_all: ## Destroy all environments
		@cd vault; terraform destroy -state=vault.tfstate -force
		@cd client_automated; terraform destroy -state=client_automated.tfstate -force
		@cd app; terraform destroy -state=app.tfstate -force

clean: ## cleaning up all artifacts
		@echo "Cleaning up"
		@rm -rf .terraform/ \
		        */.terraform/ \
		        *.tfstate* \
						*/*.tfstate* \
						*.pem \
						*/*.pem
