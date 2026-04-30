.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

OPS01_DIR := ops/01-airgap-linux-environment
OPS02_DIR := ops/02-user-network
OPS03_DIR := ops/03-kubernetes-cluster

.PHONY: help \
	00-01-project-root-check \
	01-01-terraform-run 01-01-terraform-verify \
	01-02-env-file-create 01-02-env-file-verify 01-02-env-vars-verify 01-02-env-file-clear \
	01-03-offline-assets-run 01-03-offline-assets-verify 01-03-offline-assets-clear \
	02-01-user-network-scripts-verify \
	03-01-preflight-script-verify

help:
	@printf "Targets:\n\n"
	@printf "[00-01 Project Root]\n"
	@printf "  00-01-project-root-check        Run project-root directory check\n\n"
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
	@printf "  Detail: cd $(OPS01_DIR) && make help\n\n"
	@printf "[02-01 User And Network]\n"
	@printf "  02-01-user-network-scripts-verify  Verify node user/network scripts syntax\n"
	@printf "  Detail: cd $(OPS02_DIR) && make help\n\n"
	@printf "[03-01 Preflight]\n"
	@printf "  03-01-preflight-script-verify  Verify kubeadm preflight script syntax\n"
	@printf "  Detail: cd $(OPS03_DIR) && make help\n"

00-01-project-root-check:
	@pwd
	@ls
	@test -d manual
	@test -d ops
	@test -d assets
	@test -d delivery
	@printf "[OK] project root directories verified\n"

01-01-terraform-run:
	@$(MAKE) -C "$(OPS01_DIR)" 01-01-terraform-run

01-01-terraform-verify:
	@$(MAKE) -C "$(OPS01_DIR)" 01-01-terraform-verify

01-02-env-file-create:
	@$(MAKE) -C "$(OPS01_DIR)" 01-02-env-file-create

01-02-env-file-verify:
	@$(MAKE) -C "$(OPS01_DIR)" 01-02-env-file-verify

01-02-env-vars-verify:
	@$(MAKE) -C "$(OPS01_DIR)" 01-02-env-vars-verify

01-02-env-file-clear:
	@$(MAKE) -C "$(OPS01_DIR)" 01-02-env-file-clear

01-03-offline-assets-run:
	@$(MAKE) -C "$(OPS01_DIR)" 01-03-offline-assets-run

01-03-offline-assets-verify:
	@$(MAKE) -C "$(OPS01_DIR)" 01-03-offline-assets-verify

01-03-offline-assets-clear:
	@$(MAKE) -C "$(OPS01_DIR)" 01-03-offline-assets-clear

02-01-user-network-scripts-verify:
	@$(MAKE) -C "$(OPS02_DIR)" 02-01-user-network-scripts-verify

03-01-preflight-script-verify:
	@$(MAKE) -C "$(OPS03_DIR)" 03-01-preflight-script-verify
