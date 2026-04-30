.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

PROJECT_ROOT := $(abspath $(CURDIR)/../..)
BANNER := ops/common/scripts/run-result-banner.sh
STATE := ops/common/scripts/stage-state.sh

MANUAL_SCRIPTS := \
	ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/scripts/01-01-render-env-from-survey-yaml.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/scripts/01-02-run-access-and-transfer.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/scripts/01-02-verify-access-and-transfer.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/scripts/02-01-kubeadm-preflight-check.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/scripts/02-02-run-preflight.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/scripts/02-02-verify-preflight.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/03-node-baseline/scripts/03-01-run-node-baseline.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/03-node-baseline/scripts/03-01-verify-node-baseline.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/04-containerd/scripts/04-01-run-containerd.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/04-containerd/scripts/04-01-verify-containerd.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/05-kubernetes-packages/scripts/05-01-run-kubernetes-packages.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/05-kubernetes-packages/scripts/05-01-verify-kubernetes-packages.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/06-image-import/scripts/06-01-run-image-import.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/06-image-import/scripts/06-01-verify-image-import.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/07-control-plane-init/scripts/07-01-run-control-plane-init.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/07-control-plane-init/scripts/07-01-verify-control-plane-init.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/08-calico/scripts/08-01-run-calico.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/08-calico/scripts/08-01-verify-calico.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/09-worker-join/scripts/09-01-run-worker-join.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/09-worker-join/scripts/09-01-verify-worker-join.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-01-verify-cluster.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-02-troubleshoot-cluster.sh \
	ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-03-local-kubectl-access.sh

.PHONY: help \
	03-01-preflight-run 03-01-preflight-verify 03-01-preflight-clear 03-01-preflight-script-verify \
	03-02-manual-kubeadm-run 03-02-manual-kubeadm-verify 03-02-manual-kubeadm-troubleshoot 03-02-manual-kubeadm-clear 03-02-manual-kubeadm-script-verify \
	03-02-local-kubectl-start 03-02-local-kubectl-stop 03-02-local-kubectl-status 03-02-local-kubectl-prepare 03-02-local-kubectl-install 03-02-local-kubectl-setup 03-02-local-kubectl-default \
	step-03-02-01-access-and-transfer-run step-03-02-01-access-and-transfer-verify \
	step-03-02-02-preflight-run step-03-02-02-preflight-verify \
	step-03-02-03-node-baseline-run step-03-02-03-node-baseline-verify \
	step-03-02-04-containerd-run step-03-02-04-containerd-verify \
	step-03-02-05-kubernetes-packages-run step-03-02-05-kubernetes-packages-verify \
	step-03-02-06-image-import-run step-03-02-06-image-import-verify \
	step-03-02-07-control-plane-init-run step-03-02-07-control-plane-init-verify \
	step-03-02-08-calico-run step-03-02-08-calico-verify \
	step-03-02-09-worker-join-run step-03-02-09-worker-join-verify \
	step-03-02-10-cluster-verify

help:
	@printf "Targets:\n\n"
	@printf "[03-02 Manual kubeadm]\n"
	@printf "  03-02-manual-kubeadm-run          Run manual kubeadm 01..10\n"
	@printf "  03-02-manual-kubeadm-verify       Run every manual kubeadm verify script\n"
	@printf "  03-02-manual-kubeadm-troubleshoot Print cluster diagnostics\n"
	@printf "  03-02-manual-kubeadm-clear        Clear manual kubeadm state markers\n"
	@printf "  03-02-manual-kubeadm-script-verify Verify manual kubeadm script syntax\n"
	@printf "  03-02-local-kubectl-start         Start local PC kubectl tunnel via bastion/master SSH\n"
	@printf "  03-02-local-kubectl-stop          Stop local PC kubectl tunnel\n"
	@printf "  03-02-local-kubectl-status        Check local PC kubectl tunnel\n"
	@printf "  03-02-local-kubectl-prepare       Fetch local PC kubeconfig only\n"
	@printf "  03-02-local-kubectl-install       Install kubectl to ~/.local/bin without sudo\n"
	@printf "  03-02-local-kubectl-setup         Merge ~/.kube/config and start tunnel for plain kubectl\n"
	@printf "  03-02-local-kubectl-default       Alias of 03-02-local-kubectl-setup\n"
	@printf "  step-03-02-01-access-and-transfer-run / verify\n"
	@printf "  step-03-02-02-preflight-run / verify\n"
	@printf "  step-03-02-03-node-baseline-run / verify\n"
	@printf "  step-03-02-04-containerd-run / verify\n"
	@printf "  step-03-02-05-kubernetes-packages-run / verify\n"
	@printf "  step-03-02-06-image-import-run / verify\n"
	@printf "  step-03-02-07-control-plane-init-run / verify\n"
	@printf "  step-03-02-08-calico-run / verify\n"
	@printf "  step-03-02-09-worker-join-run / verify\n"
	@printf "  step-03-02-10-cluster-verify\n\n"
	@printf "[Compatibility]\n"
	@printf "  03-01-preflight-run/verify call manual kubeadm step 02 preflight\n"

03-01-preflight-run: step-03-02-02-preflight-run
03-01-preflight-verify: step-03-02-02-preflight-verify
03-01-preflight-clear:
	@cd "$(PROJECT_ROOT)" && chmod +x $(STATE)
	@cd "$(PROJECT_ROOT)" && ./$(STATE) clear "03-02-02-manual-preflight"
03-01-preflight-script-verify: 03-02-manual-kubeadm-script-verify

03-02-manual-kubeadm-run:
	@cd "$(PROJECT_ROOT)" && chmod +x $(BANNER) $(STATE) $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./$(BANNER) "03-02-manual-kubeadm-run" "run" bash -lc '\
		$(MAKE) -C "$(CURDIR)" step-03-02-01-access-and-transfer-run && \
		$(MAKE) -C "$(CURDIR)" step-03-02-01-access-and-transfer-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-02-preflight-run && \
		$(MAKE) -C "$(CURDIR)" step-03-02-02-preflight-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-03-node-baseline-run && \
		$(MAKE) -C "$(CURDIR)" step-03-02-03-node-baseline-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-04-containerd-run && \
		$(MAKE) -C "$(CURDIR)" step-03-02-04-containerd-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-05-kubernetes-packages-run && \
		$(MAKE) -C "$(CURDIR)" step-03-02-05-kubernetes-packages-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-06-image-import-run && \
		$(MAKE) -C "$(CURDIR)" step-03-02-06-image-import-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-07-control-plane-init-run && \
		$(MAKE) -C "$(CURDIR)" step-03-02-07-control-plane-init-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-08-calico-run && \
		$(MAKE) -C "$(CURDIR)" step-03-02-08-calico-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-09-worker-join-run && \
		$(MAKE) -C "$(CURDIR)" step-03-02-09-worker-join-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-10-cluster-verify && \
		./ops/common/scripts/stage-state.sh set-success "03-manual-kubeadm-install"'

03-02-manual-kubeadm-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(BANNER) $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./$(BANNER) "03-02-manual-kubeadm-verify" "verify" bash -lc '\
		$(MAKE) -C "$(CURDIR)" step-03-02-01-access-and-transfer-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-02-preflight-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-03-node-baseline-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-04-containerd-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-05-kubernetes-packages-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-06-image-import-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-07-control-plane-init-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-08-calico-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-09-worker-join-verify && \
		$(MAKE) -C "$(CURDIR)" step-03-02-10-cluster-verify'

03-02-manual-kubeadm-troubleshoot:
	@cd "$(PROJECT_ROOT)" && chmod +x $(BANNER) $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./$(BANNER) "03-02-manual-kubeadm-troubleshoot" "verify" bash -lc '\
		./ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-02-troubleshoot-cluster.sh'

03-02-manual-kubeadm-clear:
	@cd "$(PROJECT_ROOT)" && chmod +x $(STATE)
	@cd "$(PROJECT_ROOT)" && ./$(STATE) clear "03-manual-kubeadm-install"
	@cd "$(PROJECT_ROOT)" && ./$(STATE) clear "03-02-02-manual-preflight"

03-02-manual-kubeadm-script-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(BANNER)
	@cd "$(PROJECT_ROOT)" && ./$(BANNER) "03-02-manual-kubeadm-script-verify" "verify" bash -lc '\
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/scripts/01-01-render-env-from-survey-yaml.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/scripts/01-02-run-access-and-transfer.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/scripts/01-02-verify-access-and-transfer.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/scripts/02-01-kubeadm-preflight-check.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/scripts/02-02-run-preflight.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/scripts/02-02-verify-preflight.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/03-node-baseline/scripts/03-01-run-node-baseline.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/03-node-baseline/scripts/03-01-verify-node-baseline.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/04-containerd/scripts/04-01-run-containerd.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/04-containerd/scripts/04-01-verify-containerd.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/05-kubernetes-packages/scripts/05-01-run-kubernetes-packages.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/05-kubernetes-packages/scripts/05-01-verify-kubernetes-packages.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/06-image-import/scripts/06-01-run-image-import.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/06-image-import/scripts/06-01-verify-image-import.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/07-control-plane-init/scripts/07-01-run-control-plane-init.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/07-control-plane-init/scripts/07-01-verify-control-plane-init.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/08-calico/scripts/08-01-run-calico.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/08-calico/scripts/08-01-verify-calico.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/09-worker-join/scripts/09-01-run-worker-join.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/09-worker-join/scripts/09-01-verify-worker-join.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-01-verify-cluster.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-02-troubleshoot-cluster.sh && \
		bash -n ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-03-local-kubectl-access.sh && \
		printf "[OK] manual kubeadm scripts verified\n"'

03-02-local-kubectl-start:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-03-local-kubectl-access.sh start

03-02-local-kubectl-stop:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-03-local-kubectl-access.sh stop

03-02-local-kubectl-status:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-03-local-kubectl-access.sh status

03-02-local-kubectl-prepare:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-03-local-kubectl-access.sh prepare

03-02-local-kubectl-install:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-03-local-kubectl-access.sh install

03-02-local-kubectl-setup:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-03-local-kubectl-access.sh setup

03-02-local-kubectl-default: 03-02-local-kubectl-setup

step-03-02-01-access-and-transfer-run:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/scripts/01-02-run-access-and-transfer.sh

step-03-02-01-access-and-transfer-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/scripts/01-02-verify-access-and-transfer.sh

step-03-02-02-preflight-run:
	@cd "$(PROJECT_ROOT)" && chmod +x $(STATE) $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/scripts/02-02-run-preflight.sh

step-03-02-02-preflight-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(STATE) $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/scripts/02-02-verify-preflight.sh

step-03-02-03-node-baseline-run:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/03-node-baseline/scripts/03-01-run-node-baseline.sh

step-03-02-03-node-baseline-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/03-node-baseline/scripts/03-01-verify-node-baseline.sh

step-03-02-04-containerd-run:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/04-containerd/scripts/04-01-run-containerd.sh

step-03-02-04-containerd-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/04-containerd/scripts/04-01-verify-containerd.sh

step-03-02-05-kubernetes-packages-run:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/05-kubernetes-packages/scripts/05-01-run-kubernetes-packages.sh

step-03-02-05-kubernetes-packages-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/05-kubernetes-packages/scripts/05-01-verify-kubernetes-packages.sh

step-03-02-06-image-import-run:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/06-image-import/scripts/06-01-run-image-import.sh

step-03-02-06-image-import-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/06-image-import/scripts/06-01-verify-image-import.sh

step-03-02-07-control-plane-init-run:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/07-control-plane-init/scripts/07-01-run-control-plane-init.sh

step-03-02-07-control-plane-init-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/07-control-plane-init/scripts/07-01-verify-control-plane-init.sh

step-03-02-08-calico-run:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/08-calico/scripts/08-01-run-calico.sh

step-03-02-08-calico-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/08-calico/scripts/08-01-verify-calico.sh

step-03-02-09-worker-join-run:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/09-worker-join/scripts/09-01-run-worker-join.sh

step-03-02-09-worker-join-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/09-worker-join/scripts/09-01-verify-worker-join.sh

step-03-02-10-cluster-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(MANUAL_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-01-verify-cluster.sh
