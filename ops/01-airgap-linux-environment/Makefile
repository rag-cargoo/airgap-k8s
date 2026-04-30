.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

PROJECT_ROOT := $(abspath $(CURDIR)/../..)
COMMON_BANNER := $(PROJECT_ROOT)/ops/common/scripts/run-result-banner.sh
TF_DIR := $(CURDIR)/aws-terraform-simulation

.PHONY: help \
	tf-init tf-fmt tf-validate tf-plan tf-apply tf-destroy tf-output tf-up tf-verify sync-env \
	01-01-terraform-run 01-01-terraform-verify \
	01-02-env-file-create 01-02-env-file-verify 01-02-env-vars-verify 01-02-env-file-clear \
	01-03-offline-assets-run 01-03-offline-assets-verify 01-03-offline-assets-clear \
	step-01-03-01-assets-tree-check \
	step-01-03-02-k8s-assets-download step-01-03-03-k8s-assets-verify step-01-03-02-k8s-assets-clear \
	step-01-03-04-bundle-create step-01-03-05-bundle-verify step-01-03-04-bundle-clear

help:
	@printf "Targets:\n\n"
	@printf "[Core Helpers]\n"
	@printf "  tf-init                        Initialize Terraform\n"
	@printf "  tf-fmt                         Format Terraform files\n"
	@printf "  tf-validate                    Validate Terraform configuration\n"
	@printf "  tf-plan                        Create Terraform plan\n"
	@printf "  tf-apply                       Apply Terraform plan\n"
	@printf "  tf-destroy                     Destroy Terraform-managed resources\n"
	@printf "  tf-output                      Show Terraform outputs\n"
	@printf "  tf-up                          Run init -> validate -> plan -> apply\n"
	@printf "  tf-verify                      Verify Terraform outputs after apply\n"
	@printf "  sync-env                       Update .env from Terraform outputs\n\n"
	@printf "[01-01 Terraform]\n"
	@printf "  01-01-terraform-run            Run Terraform bring-up\n"
	@printf "  01-01-terraform-verify         Verify Terraform outputs\n\n"
	@printf "[01-02 Environment]\n"
	@printf "  01-02-env-file-create          Create .env from .env.example if missing\n"
	@printf "  01-02-env-file-verify          Verify .env exists\n"
	@printf "  01-02-env-vars-verify          Verify AIRGAP_* variables in current shell\n"
	@printf "  01-02-env-file-clear           Remove .env for rerun\n\n"
	@printf "[01-03 Offline Assets]\n"
	@printf "  01-03-offline-assets-run       Run offline-assets full flow\n"
	@printf "  01-03-offline-assets-verify    Verify offline-assets full flow\n"
	@printf "  01-03-offline-assets-clear     Clear offline-assets generated outputs\n"
	@printf "  step-01-03-01-assets-tree-check\n"
	@printf "  step-01-03-02-k8s-assets-download\n"
	@printf "  step-01-03-03-k8s-assets-verify\n"
	@printf "  step-01-03-02-k8s-assets-clear\n"
	@printf "  step-01-03-04-bundle-create\n"
	@printf "  step-01-03-05-bundle-verify\n"
	@printf "  step-01-03-04-bundle-clear\n"

tf-init:
	@$(MAKE) -C "$(TF_DIR)" init

tf-fmt:
	@$(MAKE) -C "$(TF_DIR)" fmt

tf-validate:
	@$(MAKE) -C "$(TF_DIR)" validate

tf-plan:
	@$(MAKE) -C "$(TF_DIR)" plan

tf-apply:
	@$(MAKE) -C "$(TF_DIR)" apply

tf-destroy:
	@$(MAKE) -C "$(TF_DIR)" destroy

tf-output:
	@$(MAKE) -C "$(TF_DIR)" output

tf-up: tf-init tf-validate tf-plan tf-apply

tf-verify: tf-output

sync-env:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/01-airgap-linux-environment/scripts/sync-env-from-terraform.sh
	@cd "$(PROJECT_ROOT)" && ./ops/01-airgap-linux-environment/scripts/sync-env-from-terraform.sh

01-01-terraform-run:
	@chmod +x "$(COMMON_BANNER)"
	@cd "$(PROJECT_ROOT)" && "$(COMMON_BANNER)" "01-01-terraform-run" "run" bash -lc '\
		$(MAKE) -C "$(CURDIR)" tf-up'

01-01-terraform-verify:
	@chmod +x "$(COMMON_BANNER)"
	@cd "$(PROJECT_ROOT)" && "$(COMMON_BANNER)" "01-01-terraform-verify" "verify" bash -lc '\
		$(MAKE) -C "$(CURDIR)" tf-verify'

01-02-env-file-create:
	@cd "$(PROJECT_ROOT)" && if [ -f .env ]; then \
		printf "[INFO] .env already exists: %s/.env\n" "$$(pwd)"; \
	else \
		cp .env.example .env; \
		printf "[OK] created .env from .env.example: %s/.env\n" "$$(pwd)"; \
	fi

01-02-env-file-verify:
	@chmod +x "$(COMMON_BANNER)"
	@cd "$(PROJECT_ROOT)" && "$(COMMON_BANNER)" "01-02-env-file-verify" "verify" bash -lc '\
		ls -l .env && \
		printf "[OK] .env exists\n"'

01-02-env-vars-verify:
	@chmod +x "$(COMMON_BANNER)"
	@cd "$(PROJECT_ROOT)" && "$(COMMON_BANNER)" "01-02-env-vars-verify" "verify" bash -lc '\
		env | grep '"'"'^AIRGAP_'"'"' && \
		test -n "$$AIRGAP_SSH_USER" && \
		test -n "$$AIRGAP_SSH_KEY_PATH" && \
		test -n "$$AIRGAP_BASTION_PUBLIC_IP" && \
		test -n "$$AIRGAP_MASTER_PRIVATE_IP" && \
		test -n "$$AIRGAP_WORKER1_PRIVATE_IP" && \
		printf "[OK] AIRGAP_* variables loaded in current shell\n"'

01-02-env-file-clear:
	@cd "$(PROJECT_ROOT)" && rm -f .env
	@printf "[OK] removed .env\n"

step-01-03-01-assets-tree-check:
	@cd "$(PROJECT_ROOT)" && find assets/offline-assets -maxdepth 3 -type d | sort
	@cd "$(PROJECT_ROOT)" && test -d assets/offline-assets/kubernetes
	@cd "$(PROJECT_ROOT)" && test -d assets/offline-assets/services
	@cd "$(PROJECT_ROOT)" && test -d assets/offline-assets/common
	@printf "[OK] offline-assets directory tree verified\n"

step-01-03-02-k8s-assets-download:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/01-airgap-linux-environment/scripts/download-k8s-offline-assets.sh
	@cd "$(PROJECT_ROOT)" && ./ops/01-airgap-linux-environment/scripts/download-k8s-offline-assets.sh

step-01-03-03-k8s-assets-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh ops/01-airgap-linux-environment/scripts/verify-k8s-offline-assets.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "step-01-03-03-k8s-assets-verify" "verify" bash -lc '\
		./ops/01-airgap-linux-environment/scripts/verify-k8s-offline-assets.sh'

step-01-03-02-k8s-assets-clear:
	@cd "$(PROJECT_ROOT)" && find assets/offline-assets/kubernetes -type f ! -name 'README.md' -delete
	@cd "$(PROJECT_ROOT)" && find assets/offline-assets/common/checksums -type f ! -name 'README.md' -delete
	@printf "[OK] removed generated Kubernetes offline assets\n"

step-01-03-04-bundle-create:
	@cd "$(PROJECT_ROOT)" && rsync -av assets/offline-assets/ delivery/offline-assets/
	@cd "$(PROJECT_ROOT)" && tar -czf delivery/offline-assets.tar.gz -C delivery offline-assets

step-01-03-05-bundle-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "step-01-03-05-bundle-verify" "verify" bash -lc '\
		set -e; \
		tar -tzf delivery/offline-assets.tar.gz | head && \
		printf "[OK] offline-assets bundle archive verified\n"'

step-01-03-04-bundle-clear:
	@cd "$(PROJECT_ROOT)" && rm -f delivery/offline-assets.tar.gz
	@cd "$(PROJECT_ROOT)" && find delivery/offline-assets -type f ! -name 'README.md' -delete
	@printf "[OK] removed generated delivery bundle files\n"

01-03-offline-assets-run:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh ops/01-airgap-linux-environment/scripts/run-offline-assets-flow.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "01-03-offline-assets-run" "run" bash -lc '\
		./ops/01-airgap-linux-environment/scripts/run-offline-assets-flow.sh'

01-03-offline-assets-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "01-03-offline-assets-verify" "verify" bash -lc '\
		$(MAKE) -C "$(CURDIR)" step-01-03-03-k8s-assets-verify && \
		$(MAKE) -C "$(CURDIR)" step-01-03-05-bundle-verify'

01-03-offline-assets-clear:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh ops/01-airgap-linux-environment/scripts/run-offline-assets-clear.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "01-03-offline-assets-clear" "clear" bash -lc '\
		./ops/01-airgap-linux-environment/scripts/run-offline-assets-clear.sh'
