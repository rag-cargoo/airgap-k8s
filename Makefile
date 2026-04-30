.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

OPS01_DIR := ops/01-airgap-linux-environment
OPS02_DIR := ops/02-user-network
OPS03_DIR := ops/03-kubernetes-cluster
OPSCOMMON_DIR := ops/common

.PHONY: help \
	00-01-project-root-check \
	01-01-terraform-run 01-01-terraform-verify \
	01-02-env-file-create 01-02-env-file-verify 01-02-env-vars-verify 01-02-env-file-clear \
	01-03-offline-assets-run 01-03-offline-assets-verify 01-03-offline-assets-clear \
	ops-runtime-bundle-run ops-runtime-bundle-verify ops-runtime-bundle-clear \
	all-verify \
	02-01-user-network-run 02-01-user-network-verify 02-01-user-network-clear 02-01-user-network-scripts-verify \
	03-01-preflight-run 03-01-preflight-verify 03-01-preflight-clear 03-01-preflight-script-verify \
	03-02-manual-kubeadm-run 03-02-manual-kubeadm-verify 03-02-manual-kubeadm-clear \
	03-02-local-kubectl-start 03-02-local-kubectl-stop 03-02-local-kubectl-status 03-02-local-kubectl-prepare 03-02-local-kubectl-install 03-02-local-kubectl-setup 03-02-local-kubectl-default

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
	@printf "[Common Delivery Runtime]\n"
	@printf "  ops-runtime-bundle-run         Build bastion runtime source bundle\n"
	@printf "  ops-runtime-bundle-verify      Verify bastion runtime source bundle\n"
	@printf "  ops-runtime-bundle-clear       Clear bastion runtime generated outputs\n"
	@printf "  Detail: cd $(OPSCOMMON_DIR) && make help\n\n"
	@printf "[Overall Readiness]\n"
	@printf "  all-verify                     Run each implemented stage verify target\n\n"
	@printf "[02-01 User And Network]\n"
	@printf "  02-01-user-network-run             Run actual user/network apply + verify\n"
	@printf "  02-01-user-network-verify          Re-run actual user/network verify\n"
	@printf "  02-01-user-network-clear           Clear 02-01 actual state marker\n"
	@printf "  02-01-user-network-scripts-verify  Verify node user/network scripts syntax\n"
	@printf "  Detail: cd $(OPS02_DIR) && make help\n\n"
	@printf "[03-01 Preflight]\n"
	@printf "  03-01-preflight-run             Run remote master/worker preflight\n"
	@printf "  03-01-preflight-verify          Re-run remote preflight verify\n"
	@printf "  03-01-preflight-clear           Clear 03-01 actual state marker\n"
	@printf "  03-01-preflight-script-verify  Verify kubeadm preflight script syntax\n"
	@printf "  03-02-manual-kubeadm-run       Run manual kubeadm installation stage\n"
	@printf "  03-02-manual-kubeadm-verify    Verify manual kubeadm installation stage\n"
	@printf "  03-02-manual-kubeadm-clear     Clear 03-02 actual state marker\n"
	@printf "  03-02-local-kubectl-start      Start local PC kubectl tunnel via bastion/master SSH\n"
	@printf "  03-02-local-kubectl-stop       Stop local PC kubectl tunnel\n"
	@printf "  03-02-local-kubectl-status     Check local PC kubectl tunnel\n"
	@printf "  03-02-local-kubectl-prepare    Fetch local PC kubeconfig only\n"
	@printf "  03-02-local-kubectl-install    Install kubectl to ~/.local/bin without sudo\n"
	@printf "  03-02-local-kubectl-setup      Merge ~/.kube/config and start tunnel for plain kubectl\n"
	@printf "  03-02-local-kubectl-default    Alias of 03-02-local-kubectl-setup\n"
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

ops-runtime-bundle-run:
	@$(MAKE) -C "$(OPSCOMMON_DIR)" ops-runtime-bundle-run

ops-runtime-bundle-verify:
	@$(MAKE) -C "$(OPSCOMMON_DIR)" ops-runtime-bundle-verify

ops-runtime-bundle-clear:
	@$(MAKE) -C "$(OPSCOMMON_DIR)" ops-runtime-bundle-clear

all-verify:
	@cd "$(OPSCOMMON_DIR)" && chmod +x scripts/run-all-verify.sh
	@./ops/common/scripts/run-all-verify.sh

02-01-user-network-run:
	@$(MAKE) -C "$(OPS02_DIR)" 02-01-user-network-run

02-01-user-network-verify:
	@$(MAKE) -C "$(OPS02_DIR)" 02-01-user-network-verify

02-01-user-network-clear:
	@$(MAKE) -C "$(OPS02_DIR)" 02-01-user-network-clear

02-01-user-network-scripts-verify:
	@$(MAKE) -C "$(OPS02_DIR)" 02-01-user-network-scripts-verify

03-01-preflight-run:
	@$(MAKE) -C "$(OPS03_DIR)" 03-01-preflight-run

03-01-preflight-verify:
	@$(MAKE) -C "$(OPS03_DIR)" 03-01-preflight-verify

03-01-preflight-clear:
	@$(MAKE) -C "$(OPS03_DIR)" 03-01-preflight-clear

03-01-preflight-script-verify:
	@$(MAKE) -C "$(OPS03_DIR)" 03-01-preflight-script-verify

03-02-manual-kubeadm-run:
	@$(MAKE) -C "$(OPS03_DIR)" 03-02-manual-kubeadm-run

03-02-manual-kubeadm-verify:
	@$(MAKE) -C "$(OPS03_DIR)" 03-02-manual-kubeadm-verify

03-02-manual-kubeadm-clear:
	@$(MAKE) -C "$(OPS03_DIR)" 03-02-manual-kubeadm-clear

03-02-local-kubectl-start:
	@$(MAKE) -C "$(OPS03_DIR)" 03-02-local-kubectl-start

03-02-local-kubectl-stop:
	@$(MAKE) -C "$(OPS03_DIR)" 03-02-local-kubectl-stop

03-02-local-kubectl-status:
	@$(MAKE) -C "$(OPS03_DIR)" 03-02-local-kubectl-status

03-02-local-kubectl-prepare:
	@$(MAKE) -C "$(OPS03_DIR)" 03-02-local-kubectl-prepare

03-02-local-kubectl-install:
	@$(MAKE) -C "$(OPS03_DIR)" 03-02-local-kubectl-install

03-02-local-kubectl-setup:
	@$(MAKE) -C "$(OPS03_DIR)" 03-02-local-kubectl-setup

03-02-local-kubectl-default: 03-02-local-kubectl-setup
