.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

OPS01_DIR := ops/01-airgap-linux-environment
OPS02_DIR := ops/02-user-network
OPS03_DIR := ops/03-kubernetes-cluster
OPS04_DIR := ops/04-services-monitoring
OPS05_DIR := ops/05-prometheus-grafana-external-access
OPS06_DIR := ops/06-submission
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
	03-03-storageclass-run 03-03-storageclass-verify 03-03-storageclass-clear 03-03-storageclass-script-verify \
	03-02-local-kubectl-start 03-02-local-kubectl-stop 03-02-local-kubectl-status 03-02-local-kubectl-prepare 03-02-local-kubectl-install 03-02-local-kubectl-setup 03-02-local-kubectl-default \
	04-services-monitoring-run 04-services-monitoring-verify 04-services-monitoring-clear 04-services-monitoring-script-verify \
	04-01-mysql-or-mariadb-run 04-01-mysql-or-mariadb-verify \
	04-02-mongodb-run 04-02-mongodb-verify \
	04-03-prometheus-run 04-03-prometheus-verify \
	04-04-grafana-run 04-04-grafana-verify \
	04-05-grafana-alloy-run 04-05-grafana-alloy-verify \
	04-06-services-verify \
	05-prometheus-grafana-external-access-run 05-prometheus-grafana-external-access-verify 05-prometheus-grafana-external-access-clear 05-prometheus-grafana-external-access-script-verify \
	05-prometheus-grafana-browser-tunnel-start 05-prometheus-grafana-browser-tunnel-status 05-prometheus-grafana-browser-tunnel-stop \
	06-submission-build 06-submission-verify 06-submission-clear 06-submission-script-verify

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
	@printf "  03-03-storageclass-run         Apply local-path-provisioner and verify dynamic PVC\n"
	@printf "  03-03-storageclass-verify      Verify local-path-provisioner and dynamic PVC\n"
	@printf "  03-03-storageclass-clear       Clear 03-03 state marker\n"
	@printf "  03-03-storageclass-script-verify Verify StorageClass script syntax\n"
	@printf "  03-02-local-kubectl-start      Start local PC kubectl tunnel via bastion/master SSH\n"
	@printf "  03-02-local-kubectl-stop       Stop local PC kubectl tunnel\n"
	@printf "  03-02-local-kubectl-status     Check local PC kubectl tunnel\n"
	@printf "  03-02-local-kubectl-prepare    Fetch local PC kubeconfig only\n"
	@printf "  03-02-local-kubectl-install    Install kubectl to ~/.local/bin without sudo\n"
	@printf "  03-02-local-kubectl-setup      Merge ~/.kube/config and start tunnel for plain kubectl\n"
	@printf "  03-02-local-kubectl-default    Alias of 03-02-local-kubectl-setup\n"
	@printf "  Detail: cd $(OPS03_DIR) && make help\n"
	@printf "\n[04 Services And Monitoring]\n"
	@printf "  04-services-monitoring-run       Run 04-01..04-05 services and 04-06 verify\n"
	@printf "  04-services-monitoring-verify    Verify deployed 04 services\n"
	@printf "  04-services-monitoring-clear     Clear 04 state marker\n"
	@printf "  04-services-monitoring-script-verify Verify 04 scripts syntax\n"
	@printf "  04-01-mysql-or-mariadb-run / verify\n"
	@printf "  04-02-mongodb-run / verify\n"
	@printf "  04-03-prometheus-run / verify\n"
	@printf "  04-04-grafana-run / verify\n"
	@printf "  04-05-grafana-alloy-run / verify\n"
	@printf "  04-06-services-verify\n"
	@printf "  Detail: cd $(OPS04_DIR) && make help\n"
	@printf "\n[05 Prometheus Grafana External Access]\n"
	@printf "  05-prometheus-grafana-external-access-run       Run MetalLB + ingress-nginx + monitoring Ingress\n"
	@printf "  05-prometheus-grafana-external-access-verify    Verify external access routing\n"
	@printf "  05-prometheus-grafana-browser-tunnel-start      Open local browser tunnel\n"
	@printf "  05-prometheus-grafana-browser-tunnel-status     Check local browser tunnel\n"
	@printf "  05-prometheus-grafana-browser-tunnel-stop       Stop local browser tunnel\n"
	@printf "  05-prometheus-grafana-external-access-clear     Clear 05 state marker\n"
	@printf "  05-prometheus-grafana-external-access-script-verify Verify 05 scripts syntax\n"
	@printf "  Detail: cd $(OPS05_DIR) && make help\n"
	@printf "\n[06 Submission]\n"
	@printf "  06-submission-build          Build manual outputs and server config ZIP\n"
	@printf "  06-submission-verify         Verify generated submission package\n"
	@printf "  06-submission-clear          Clear generated submission outputs\n"
	@printf "  06-submission-script-verify  Verify 06 scripts syntax\n"
	@printf "  Detail: cd $(OPS06_DIR) && make help\n"

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

03-03-storageclass-run:
	@$(MAKE) -C "$(OPS03_DIR)" 03-03-storageclass-run

03-03-storageclass-verify:
	@$(MAKE) -C "$(OPS03_DIR)" 03-03-storageclass-verify

03-03-storageclass-clear:
	@$(MAKE) -C "$(OPS03_DIR)" 03-03-storageclass-clear

03-03-storageclass-script-verify:
	@$(MAKE) -C "$(OPS03_DIR)" 03-03-storageclass-script-verify

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

04-services-monitoring-run:
	@$(MAKE) -C "$(OPS04_DIR)" 04-services-monitoring-run

04-services-monitoring-verify:
	@$(MAKE) -C "$(OPS04_DIR)" 04-services-monitoring-verify

04-services-monitoring-clear:
	@$(MAKE) -C "$(OPS04_DIR)" 04-services-monitoring-clear

04-services-monitoring-script-verify:
	@$(MAKE) -C "$(OPS04_DIR)" 04-services-monitoring-script-verify

04-01-mysql-or-mariadb-run:
	@$(MAKE) -C "$(OPS04_DIR)" 04-01-mysql-or-mariadb-run

04-01-mysql-or-mariadb-verify:
	@$(MAKE) -C "$(OPS04_DIR)" 04-01-mysql-or-mariadb-verify

04-02-mongodb-run:
	@$(MAKE) -C "$(OPS04_DIR)" 04-02-mongodb-run

04-02-mongodb-verify:
	@$(MAKE) -C "$(OPS04_DIR)" 04-02-mongodb-verify

04-03-prometheus-run:
	@$(MAKE) -C "$(OPS04_DIR)" 04-03-prometheus-run

04-03-prometheus-verify:
	@$(MAKE) -C "$(OPS04_DIR)" 04-03-prometheus-verify

04-04-grafana-run:
	@$(MAKE) -C "$(OPS04_DIR)" 04-04-grafana-run

04-04-grafana-verify:
	@$(MAKE) -C "$(OPS04_DIR)" 04-04-grafana-verify

04-05-grafana-alloy-run:
	@$(MAKE) -C "$(OPS04_DIR)" 04-05-grafana-alloy-run

04-05-grafana-alloy-verify:
	@$(MAKE) -C "$(OPS04_DIR)" 04-05-grafana-alloy-verify

04-06-services-verify:
	@$(MAKE) -C "$(OPS04_DIR)" 04-06-services-verify

05-prometheus-grafana-external-access-run:
	@$(MAKE) -C "$(OPS05_DIR)" 05-prometheus-grafana-external-access-run

05-prometheus-grafana-external-access-verify:
	@$(MAKE) -C "$(OPS05_DIR)" 05-prometheus-grafana-external-access-verify

05-prometheus-grafana-browser-tunnel-start:
	@$(MAKE) -C "$(OPS05_DIR)" 05-prometheus-grafana-browser-tunnel-start

05-prometheus-grafana-browser-tunnel-status:
	@$(MAKE) -C "$(OPS05_DIR)" 05-prometheus-grafana-browser-tunnel-status

05-prometheus-grafana-browser-tunnel-stop:
	@$(MAKE) -C "$(OPS05_DIR)" 05-prometheus-grafana-browser-tunnel-stop

05-prometheus-grafana-external-access-clear:
	@$(MAKE) -C "$(OPS05_DIR)" 05-prometheus-grafana-external-access-clear

05-prometheus-grafana-external-access-script-verify:
	@$(MAKE) -C "$(OPS05_DIR)" 05-prometheus-grafana-external-access-script-verify

06-submission-build:
	@$(MAKE) -C "$(OPS06_DIR)" 06-submission-build

06-submission-verify:
	@$(MAKE) -C "$(OPS06_DIR)" 06-submission-verify

06-submission-clear:
	@$(MAKE) -C "$(OPS06_DIR)" 06-submission-clear

06-submission-script-verify:
	@$(MAKE) -C "$(OPS06_DIR)" 06-submission-script-verify
