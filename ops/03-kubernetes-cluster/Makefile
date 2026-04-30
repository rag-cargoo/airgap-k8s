.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

PROJECT_ROOT := $(abspath $(CURDIR)/../..)
COMMON_BANNER := $(PROJECT_ROOT)/ops/common/scripts/run-result-banner.sh

.PHONY: help 03-01-preflight-script-verify

help:
	@printf "Targets:\n\n"
	@printf "[03-01 Preflight]\n"
	@printf "  03-01-preflight-script-verify  Verify kubeadm preflight script syntax\n"

03-01-preflight-script-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "03-01-preflight-script-verify" "verify" bash -lc '\
		bash -n ops/03-kubernetes-cluster/scripts/kubeadm-preflight-check.sh && \
		printf "[OK] kubeadm preflight script verified\n"'
