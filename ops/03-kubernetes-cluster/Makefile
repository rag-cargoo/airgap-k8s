.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

PROJECT_ROOT := $(abspath $(CURDIR)/../..)
COMMON_BANNER := $(PROJECT_ROOT)/ops/common/scripts/run-result-banner.sh

.PHONY: help \
	03-01-preflight-run 03-01-preflight-verify 03-01-preflight-clear \
	step-03-01-01-remote-preflight-run \
	03-01-preflight-script-verify

help:
	@printf "Targets:\n\n"
	@printf "[03-01 Common]\n"
	@printf "  03-01-preflight-run            Run remote master/worker preflight\n"
	@printf "  03-01-preflight-verify         Re-run remote master/worker preflight verify\n"
	@printf "  03-01-preflight-clear          Clear 03-01 stage state marker\n"
	@printf "  step-03-01-01-remote-preflight-run  Step: upload and run remote preflight\n"
	@printf "  03-01-preflight-script-verify  Verify kubeadm preflight script syntax\n"

03-01-preflight-run:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "03-01-preflight-run" "run" bash -lc '\
		$(MAKE) -C "$(CURDIR)" step-03-01-01-remote-preflight-run'

03-01-preflight-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh ops/03-kubernetes-cluster/common/scripts/verify-preflight-stage.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "03-01-preflight-verify" "verify" bash -lc '\
		source ops/01-airgap-linux-environment/scripts/load-project-env.sh && \
		./ops/03-kubernetes-cluster/common/scripts/verify-preflight-stage.sh'

03-01-preflight-clear:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/stage-state.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/stage-state.sh clear "03-01-remote-preflight"
	@printf "[OK] cleared 03-01 preflight state marker\n"

step-03-01-01-remote-preflight-run:
	@cd "$(PROJECT_ROOT)" && chmod +x \
		ops/common/scripts/stage-state.sh \
		ops/03-kubernetes-cluster/common/scripts/run-preflight-stage.sh \
		ops/03-kubernetes-cluster/common/scripts/kubeadm-preflight-check.sh \
		ops/03-kubernetes-cluster/common/scripts/verify-preflight-stage.sh
	@cd "$(PROJECT_ROOT)" && bash -lc '\
		source ops/01-airgap-linux-environment/scripts/load-project-env.sh && \
		./ops/03-kubernetes-cluster/common/scripts/run-preflight-stage.sh'

03-01-preflight-script-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "03-01-preflight-script-verify" "verify" bash -lc '\
		bash -n ops/03-kubernetes-cluster/common/scripts/kubeadm-preflight-check.sh && \
		bash -n ops/03-kubernetes-cluster/common/scripts/run-preflight-stage.sh && \
		bash -n ops/03-kubernetes-cluster/common/scripts/verify-preflight-stage.sh && \
		printf "[OK] kubeadm preflight script verified\n"'
