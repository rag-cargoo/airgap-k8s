.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

PROJECT_ROOT := $(abspath $(CURDIR)/../..)
BANNER := ops/common/scripts/run-result-banner.sh
SUBMISSION_SCRIPTS := $(shell cd "$(PROJECT_ROOT)" && find ops/06-submission/scripts -name '*.sh' | sort)

.PHONY: help \
	06-submission-build 06-submission-verify 06-submission-clear 06-submission-script-verify \
	step-06-01-01-build-manual step-06-01-02-build-server-configs-zip step-06-01-03-verify-submission-package

help:
	@printf "Targets:\n\n"
	@printf "[06 Submission]\n"
	@printf "  06-submission-build          Build manual outputs and server config ZIP\n"
	@printf "  06-submission-verify         Verify submission outputs and ZIP exclusions\n"
	@printf "  06-submission-clear          Clear generated submission outputs\n"
	@printf "  06-submission-script-verify  Verify 06 scripts syntax\n\n"
	@printf "[Steps]\n"
	@printf "  step-06-01-01-build-manual\n"
	@printf "  step-06-01-02-build-server-configs-zip\n"
	@printf "  step-06-01-03-verify-submission-package\n"

06-submission-build:
	@cd "$(PROJECT_ROOT)" && chmod +x $(BANNER) $(SUBMISSION_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./$(BANNER) "06-submission-build" "run" bash -lc '\
		$(MAKE) -C "$(CURDIR)" step-06-01-01-build-manual && \
		$(MAKE) -C "$(CURDIR)" step-06-01-02-build-server-configs-zip && \
		$(MAKE) -C "$(CURDIR)" step-06-01-03-verify-submission-package'

06-submission-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(BANNER) $(SUBMISSION_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./$(BANNER) "06-submission-verify" "verify" bash -lc '\
		$(MAKE) -C "$(CURDIR)" step-06-01-03-verify-submission-package'

06-submission-clear:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/06-submission/scripts/06-01-04-clear-submission-package.sh
	@cd "$(PROJECT_ROOT)" && ./ops/06-submission/scripts/06-01-04-clear-submission-package.sh

06-submission-script-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(BANNER)
	@cd "$(PROJECT_ROOT)" && ./$(BANNER) "06-submission-script-verify" "verify" bash -lc '\
		for script in $(SUBMISSION_SCRIPTS); do bash -n "$$script"; done && \
		printf "[OK] 06 submission scripts verified\n"'

step-06-01-01-build-manual:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/06-submission/scripts/06-01-01-build-submission-manual.sh
	@cd "$(PROJECT_ROOT)" && ./ops/06-submission/scripts/06-01-01-build-submission-manual.sh

step-06-01-02-build-server-configs-zip:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/06-submission/scripts/06-01-02-build-server-configs-zip.sh
	@cd "$(PROJECT_ROOT)" && ./ops/06-submission/scripts/06-01-02-build-server-configs-zip.sh

step-06-01-03-verify-submission-package:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/06-submission/scripts/06-01-03-verify-submission-package.sh
	@cd "$(PROJECT_ROOT)" && ./ops/06-submission/scripts/06-01-03-verify-submission-package.sh
