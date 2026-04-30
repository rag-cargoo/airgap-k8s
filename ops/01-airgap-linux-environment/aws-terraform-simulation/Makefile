.DEFAULT_GOAL := help

TF ?= terraform
TFVARS ?= terraform.tfvars
PLAN_FILE ?= tfplan
VAR_FILE_ARG := $(if $(wildcard $(TFVARS)),-var-file=$(TFVARS),)

.PHONY: help init fmt validate plan apply destroy output

help:
	@printf "Terraform targets:\n"
	@printf "  init      terraform init\n"
	@printf "  fmt       terraform fmt -recursive\n"
	@printf "  validate  terraform validate\n"
	@printf "  plan      terraform plan\n"
	@printf "  apply     terraform apply tfplan\n"
	@printf "  destroy   terraform destroy\n"
	@printf "  output    terraform output\n"

init:
	$(TF) init

fmt:
	$(TF) fmt -recursive

validate:
	$(TF) validate

plan:
	$(TF) plan $(VAR_FILE_ARG) -out=$(PLAN_FILE)

apply:
	$(TF) apply $(PLAN_FILE)

destroy:
	$(TF) destroy $(VAR_FILE_ARG)

output:
	$(TF) output
