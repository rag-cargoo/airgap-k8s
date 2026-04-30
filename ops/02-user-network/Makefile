.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

PROJECT_ROOT := $(abspath $(CURDIR)/../..)
COMMON_BANNER := $(PROJECT_ROOT)/ops/common/scripts/run-result-banner.sh
STATE_SCRIPT := $(PROJECT_ROOT)/ops/common/scripts/stage-state.sh

.PHONY: help \
	02-01-user-network-run 02-01-user-network-verify 02-01-user-network-clear \
	step-02-01-01-user-network-apply \
	02-01-user-network-scripts-verify

help:
	@printf "Targets:\n\n"
	@printf "[02-01 User And Network]\n"
	@printf "  02-01-user-network-run              Run actual node apply + verify\n"
	@printf "  02-01-user-network-verify           Re-run actual node verify only\n"
	@printf "  02-01-user-network-clear            Clear 02-01 stage state marker\n"
	@printf "  step-02-01-01-user-network-apply    Step: apply then verify on master/worker\n"
	@printf "  02-01-user-network-scripts-verify   Verify local script syntax\n"

02-01-user-network-run:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "02-01-user-network-run" "run" bash -lc '\
		$(MAKE) -C "$(CURDIR)" step-02-01-01-user-network-apply'

02-01-user-network-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh ops/02-user-network/scripts/verify-user-network-stage.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "02-01-user-network-verify" "verify" bash -lc '\
		source ops/01-airgap-linux-environment/scripts/load-project-env.sh && \
		./ops/02-user-network/scripts/verify-user-network-stage.sh'

02-01-user-network-clear:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/stage-state.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/stage-state.sh clear "02-01-user-network-apply"
	@printf "[OK] cleared 02-01 user/network state marker\n"

step-02-01-01-user-network-apply:
	@cd "$(PROJECT_ROOT)" && chmod +x \
		ops/common/scripts/stage-state.sh \
		ops/02-user-network/scripts/run-user-network-stage.sh \
		ops/02-user-network/scripts/configure-node-user-network.sh \
		ops/02-user-network/scripts/verify-node-user-network.sh
	@cd "$(PROJECT_ROOT)" && bash -lc '\
		source ops/01-airgap-linux-environment/scripts/load-project-env.sh && \
		./ops/02-user-network/scripts/run-user-network-stage.sh'

02-01-user-network-scripts-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "02-01-user-network-scripts-verify" "verify" bash -lc '\
		bash -n ops/02-user-network/scripts/configure-node-user-network.sh && \
		bash -n ops/02-user-network/scripts/verify-node-user-network.sh && \
		bash -n ops/02-user-network/scripts/run-user-network-stage.sh && \
		bash -n ops/02-user-network/scripts/verify-user-network-stage.sh && \
		printf "[OK] user/network scripts verified\n"'
