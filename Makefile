.PHONY: check apply plan destroy configure destroy-full

check:
	@echo "Checking and formatting Terraform configurations"
	terraform -chdir=./infra init -backend=false -upgrade && \
	terraform -chdir=./infra fmt -write=true -recursive  && \
	terraform -chdir=./infra validate -json -no-color  

apply:
	@echo "Applying Terraform configurations"
	TF_LOG=DEBUG terraform -chdir=./infra apply -auto-approve tfplan

plan:
	@echo "Terraform Plan"
	terraform -chdir=./infra init -upgrade
	TF_LOG=DEBUG terraform -chdir=./infra plan -out=tfplan

destroy:
	terraform -chdir=./infra init -upgrade
	TF_LOG=DEBUG terraform -chdir=./infra destroy -target=module.kubernetes-e2e

destroy-full:
	terraform -chdir=./infra init -upgrade
	TF_LOG=DEBUG terraform -chdir=./infra destroy

configure:
	aws eks --region $(terraform -chdir=./infra output -raw region) update-kubeconfig --name $(terraform -chdir=./infra output -raw cluster_name)

