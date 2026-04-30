.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

PROJECT_ROOT := $(abspath $(CURDIR)/../..)
COMMON_BANNER := $(PROJECT_ROOT)/ops/common/scripts/run-result-banner.sh

.PHONY: help \
	ops-runtime-bundle-run ops-runtime-bundle-verify ops-runtime-bundle-clear \
	step-ops-runtime-01-build step-ops-runtime-02-verify step-ops-runtime-01-clear

help:
	@printf "Targets:\n\n"
	@printf "[Delivery Runtime]\n"
	@printf "  ops-runtime-bundle-run         Build bastion runtime source bundle\n"
	@printf "  ops-runtime-bundle-verify      Verify bastion runtime source bundle\n"
	@printf "  ops-runtime-bundle-clear       Clear bastion runtime generated outputs\n"
	@printf "  step-ops-runtime-01-build      Step: build delivery/ops-runtime.tar.gz\n"
	@printf "  step-ops-runtime-02-verify     Step: verify delivery/ops-runtime.tar.gz\n"
	@printf "  step-ops-runtime-01-clear      Step: clear delivery/ops-runtime outputs\n"

step-ops-runtime-01-build:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/build-ops-runtime-bundle.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/build-ops-runtime-bundle.sh

step-ops-runtime-02-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh ops/common/scripts/verify-ops-runtime-bundle.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "step-ops-runtime-02-verify" "verify" bash -lc '\
		./ops/common/scripts/verify-ops-runtime-bundle.sh'

step-ops-runtime-01-clear:
	@cd "$(PROJECT_ROOT)" && rm -f delivery/ops-runtime.tar.gz
	@cd "$(PROJECT_ROOT)" && rm -rf delivery/ops-runtime
	@printf "[OK] removed generated ops-runtime bundle outputs\n"

ops-runtime-bundle-run:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "ops-runtime-bundle-run" "run" bash -lc '\
		$(MAKE) -C "$(CURDIR)" step-ops-runtime-01-build && \
		$(MAKE) -C "$(CURDIR)" step-ops-runtime-02-verify'

ops-runtime-bundle-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "ops-runtime-bundle-verify" "verify" bash -lc '\
		$(MAKE) -C "$(CURDIR)" step-ops-runtime-02-verify'

ops-runtime-bundle-clear:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/common/scripts/run-result-banner.sh
	@cd "$(PROJECT_ROOT)" && ./ops/common/scripts/run-result-banner.sh "ops-runtime-bundle-clear" "clear" bash -lc '\
		$(MAKE) -C "$(CURDIR)" step-ops-runtime-01-clear'
