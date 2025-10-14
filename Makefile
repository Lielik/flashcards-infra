# Instead of remembering long Terraform commands, you can now just type:

TF?=terraform
ENV?=dev

# make init
init:
	$(TF) init -backend-config=env/dev.backend.hcl

# make plan
plan:
	$(TF) plan -var-file=env/$(ENV).tfvars

# make apply
apply:
	$(TF) apply -var-file=env/$(ENV).tfvars

# make destroy
destroy:
	$(TF) destroy -var-file=env/$(ENV).tfvars

# make fmt
fmt:
	$(TF) fmt -recursive

# make validate
validate:
	$(TF) validate
