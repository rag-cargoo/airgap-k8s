.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

PROJECT_ROOT := $(abspath $(CURDIR)/../..)
COMMON_BANNER := $(PROJECT_ROOT)/ops/common/scripts/run-result-banner.sh

.PHONY: help 02-01-user-network-scripts-verify

help:
	@printf "Targets:\n\n"
	@printf "[02-01 User And Network]\n"
	@printf "  02-01-user-network-scripts-verify  Verify node user/network scripts syntax\n"

02-01-user-network-scripts-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "02-01-user-network-scripts-verify" "verify" bash -lc '\
		bash -n ops/02-user-network/scripts/configure-node-user-network.sh && \
		bash -n ops/02-user-network/scripts/verify-node-user-network.sh && \
		printf "[OK] user/network scripts verified\n"'
