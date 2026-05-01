.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

PROJECT_ROOT := $(abspath $(CURDIR)/../..)
BANNER := ops/common/scripts/run-result-banner.sh
STATE := ops/common/scripts/stage-state.sh

SERVICE_SCRIPTS := $(shell cd "$(PROJECT_ROOT)" && find ops/04-services-monitoring -path '*/scripts/*.sh' | sort)

.PHONY: help \
	04-services-monitoring-run 04-services-monitoring-verify 04-services-monitoring-clear 04-services-monitoring-script-verify \
	04-01-mysql-or-mariadb-run 04-01-mysql-or-mariadb-verify \
	04-02-mongodb-run 04-02-mongodb-verify \
	04-03-prometheus-run 04-03-prometheus-verify \
	04-04-grafana-run 04-04-grafana-verify \
	04-05-grafana-alloy-run 04-05-grafana-alloy-verify \
	04-06-services-verify \
	step-04-01-01-mysql-or-mariadb-download-assets step-04-01-02-mysql-or-mariadb-verify-assets step-04-01-03-mysql-or-mariadb-transfer-files step-04-01-04-mysql-or-mariadb-import-images step-04-01-05-mysql-or-mariadb-run step-04-01-06-mysql-or-mariadb-verify \
	step-04-02-01-mongodb-download-assets step-04-02-02-mongodb-verify-assets step-04-02-03-mongodb-transfer-files step-04-02-04-mongodb-import-images step-04-02-05-mongodb-run step-04-02-06-mongodb-verify \
	step-04-03-01-prometheus-download-assets step-04-03-02-prometheus-verify-assets step-04-03-03-prometheus-transfer-files step-04-03-04-prometheus-import-images step-04-03-05-prometheus-run step-04-03-06-prometheus-verify \
	step-04-04-01-grafana-download-assets step-04-04-02-grafana-verify-assets step-04-04-03-grafana-transfer-files step-04-04-04-grafana-import-images step-04-04-05-grafana-run step-04-04-06-grafana-verify \
	step-04-05-01-grafana-alloy-download-assets step-04-05-02-grafana-alloy-verify-assets step-04-05-03-grafana-alloy-transfer-files step-04-05-04-grafana-alloy-import-images step-04-05-05-grafana-alloy-run step-04-05-06-grafana-alloy-verify

help:
	@printf "Targets:\n\n"
	@printf "[04 Services Monitoring]\n"
	@printf "  04-services-monitoring-run       Run 04-01..04-05 services and 04-06 verify\n"
	@printf "  04-services-monitoring-verify    Verify deployed 04 services\n"
	@printf "  04-services-monitoring-clear     Clear 04 state marker only\n"
	@printf "  04-services-monitoring-script-verify Verify 04 scripts syntax\n\n"
	@printf "[Service targets]\n"
	@printf "  04-01-mysql-or-mariadb-run / verify\n"
	@printf "  04-02-mongodb-run / verify\n"
	@printf "  04-03-prometheus-run / verify\n"
	@printf "  04-04-grafana-run / verify\n"
	@printf "  04-05-grafana-alloy-run / verify\n"
	@printf "  04-06-services-verify\n\n"
	@printf "[Step example]\n"
	@printf "  step-04-01-01-mysql-or-mariadb-download-assets\n"
	@printf "  step-04-01-02-mysql-or-mariadb-verify-assets\n"
	@printf "  step-04-01-03-mysql-or-mariadb-transfer-files\n"
	@printf "  step-04-01-04-mysql-or-mariadb-import-images\n"
	@printf "  step-04-01-05-mysql-or-mariadb-run\n"
	@printf "  step-04-01-06-mysql-or-mariadb-verify\n"

04-services-monitoring-run:
	@cd "$(PROJECT_ROOT)" && chmod +x $(BANNER) $(STATE) $(SERVICE_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./$(BANNER) "04-services-monitoring-run" "run" bash -lc '\
		$(MAKE) -C "$(CURDIR)" 04-01-mysql-or-mariadb-run && \
		$(MAKE) -C "$(CURDIR)" 04-02-mongodb-run && \
		$(MAKE) -C "$(CURDIR)" 04-03-prometheus-run && \
		$(MAKE) -C "$(CURDIR)" 04-04-grafana-run && \
		$(MAKE) -C "$(CURDIR)" 04-05-grafana-alloy-run && \
		$(MAKE) -C "$(CURDIR)" 04-06-services-verify && \
		./ops/common/scripts/stage-state.sh set-success "04-services-monitoring"'

04-services-monitoring-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(BANNER) $(SERVICE_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./$(BANNER) "04-services-monitoring-verify" "verify" bash -lc '\
		$(MAKE) -C "$(CURDIR)" 04-01-mysql-or-mariadb-verify && \
		$(MAKE) -C "$(CURDIR)" 04-02-mongodb-verify && \
		$(MAKE) -C "$(CURDIR)" 04-03-prometheus-verify && \
		$(MAKE) -C "$(CURDIR)" 04-04-grafana-verify && \
		$(MAKE) -C "$(CURDIR)" 04-05-grafana-alloy-verify && \
		$(MAKE) -C "$(CURDIR)" 04-06-services-verify'

04-services-monitoring-clear:
	@cd "$(PROJECT_ROOT)" && chmod +x $(STATE)
	@cd "$(PROJECT_ROOT)" && ./$(STATE) clear "04-services-monitoring"

04-services-monitoring-script-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(BANNER)
	@cd "$(PROJECT_ROOT)" && ./$(BANNER) "04-services-monitoring-script-verify" "verify" bash -lc '\
		for script in $(SERVICE_SCRIPTS); do bash -n "$$script"; done && \
		printf "[OK] 04 service scripts verified\n"'

04-01-mysql-or-mariadb-run:
	@$(MAKE) -C "$(CURDIR)" step-04-01-01-mysql-or-mariadb-download-assets
	@$(MAKE) -C "$(CURDIR)" step-04-01-02-mysql-or-mariadb-verify-assets
	@$(MAKE) -C "$(CURDIR)" step-04-01-03-mysql-or-mariadb-transfer-files
	@$(MAKE) -C "$(CURDIR)" step-04-01-04-mysql-or-mariadb-import-images
	@$(MAKE) -C "$(CURDIR)" step-04-01-05-mysql-or-mariadb-run
	@$(MAKE) -C "$(CURDIR)" step-04-01-06-mysql-or-mariadb-verify

04-01-mysql-or-mariadb-verify:
	@$(MAKE) -C "$(CURDIR)" step-04-01-02-mysql-or-mariadb-verify-assets
	@$(MAKE) -C "$(CURDIR)" step-04-01-06-mysql-or-mariadb-verify

04-02-mongodb-run:
	@$(MAKE) -C "$(CURDIR)" step-04-02-01-mongodb-download-assets
	@$(MAKE) -C "$(CURDIR)" step-04-02-02-mongodb-verify-assets
	@$(MAKE) -C "$(CURDIR)" step-04-02-03-mongodb-transfer-files
	@$(MAKE) -C "$(CURDIR)" step-04-02-04-mongodb-import-images
	@$(MAKE) -C "$(CURDIR)" step-04-02-05-mongodb-run
	@$(MAKE) -C "$(CURDIR)" step-04-02-06-mongodb-verify

04-02-mongodb-verify:
	@$(MAKE) -C "$(CURDIR)" step-04-02-02-mongodb-verify-assets
	@$(MAKE) -C "$(CURDIR)" step-04-02-06-mongodb-verify

04-03-prometheus-run:
	@$(MAKE) -C "$(CURDIR)" step-04-03-01-prometheus-download-assets
	@$(MAKE) -C "$(CURDIR)" step-04-03-02-prometheus-verify-assets
	@$(MAKE) -C "$(CURDIR)" step-04-03-03-prometheus-transfer-files
	@$(MAKE) -C "$(CURDIR)" step-04-03-04-prometheus-import-images
	@$(MAKE) -C "$(CURDIR)" step-04-03-05-prometheus-run
	@$(MAKE) -C "$(CURDIR)" step-04-03-06-prometheus-verify

04-03-prometheus-verify:
	@$(MAKE) -C "$(CURDIR)" step-04-03-02-prometheus-verify-assets
	@$(MAKE) -C "$(CURDIR)" step-04-03-06-prometheus-verify

04-04-grafana-run:
	@$(MAKE) -C "$(CURDIR)" step-04-04-01-grafana-download-assets
	@$(MAKE) -C "$(CURDIR)" step-04-04-02-grafana-verify-assets
	@$(MAKE) -C "$(CURDIR)" step-04-04-03-grafana-transfer-files
	@$(MAKE) -C "$(CURDIR)" step-04-04-04-grafana-import-images
	@$(MAKE) -C "$(CURDIR)" step-04-04-05-grafana-run
	@$(MAKE) -C "$(CURDIR)" step-04-04-06-grafana-verify

04-04-grafana-verify:
	@$(MAKE) -C "$(CURDIR)" step-04-04-02-grafana-verify-assets
	@$(MAKE) -C "$(CURDIR)" step-04-04-06-grafana-verify

04-05-grafana-alloy-run:
	@$(MAKE) -C "$(CURDIR)" step-04-05-01-grafana-alloy-download-assets
	@$(MAKE) -C "$(CURDIR)" step-04-05-02-grafana-alloy-verify-assets
	@$(MAKE) -C "$(CURDIR)" step-04-05-03-grafana-alloy-transfer-files
	@$(MAKE) -C "$(CURDIR)" step-04-05-04-grafana-alloy-import-images
	@$(MAKE) -C "$(CURDIR)" step-04-05-05-grafana-alloy-run
	@$(MAKE) -C "$(CURDIR)" step-04-05-06-grafana-alloy-verify

04-05-grafana-alloy-verify:
	@$(MAKE) -C "$(CURDIR)" step-04-05-02-grafana-alloy-verify-assets
	@$(MAKE) -C "$(CURDIR)" step-04-05-06-grafana-alloy-verify

04-06-services-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/06-services-verify/scripts/04-06-01-verify-services.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/06-services-verify/scripts/04-06-01-verify-services.sh

step-04-01-01-mysql-or-mariadb-download-assets:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/01-mysql-or-mariadb/scripts/04-01-01-download-assets.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/01-mysql-or-mariadb/scripts/04-01-01-download-assets.sh

step-04-01-02-mysql-or-mariadb-verify-assets:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/01-mysql-or-mariadb/scripts/04-01-02-verify-assets.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/01-mysql-or-mariadb/scripts/04-01-02-verify-assets.sh

step-04-01-03-mysql-or-mariadb-transfer-files:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/01-mysql-or-mariadb/scripts/04-01-03-transfer-files.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/01-mysql-or-mariadb/scripts/04-01-03-transfer-files.sh

step-04-01-04-mysql-or-mariadb-import-images:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/01-mysql-or-mariadb/scripts/04-01-04-import-images.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/01-mysql-or-mariadb/scripts/04-01-04-import-images.sh

step-04-01-05-mysql-or-mariadb-run:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/01-mysql-or-mariadb/scripts/04-01-05-run-mysql-or-mariadb.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/01-mysql-or-mariadb/scripts/04-01-05-run-mysql-or-mariadb.sh

step-04-01-06-mysql-or-mariadb-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/01-mysql-or-mariadb/scripts/04-01-06-verify-mysql-or-mariadb.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/01-mysql-or-mariadb/scripts/04-01-06-verify-mysql-or-mariadb.sh

step-04-02-01-mongodb-download-assets:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/02-mongodb/scripts/04-02-01-download-assets.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/02-mongodb/scripts/04-02-01-download-assets.sh

step-04-02-02-mongodb-verify-assets:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/02-mongodb/scripts/04-02-02-verify-assets.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/02-mongodb/scripts/04-02-02-verify-assets.sh

step-04-02-03-mongodb-transfer-files:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/02-mongodb/scripts/04-02-03-transfer-files.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/02-mongodb/scripts/04-02-03-transfer-files.sh

step-04-02-04-mongodb-import-images:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/02-mongodb/scripts/04-02-04-import-images.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/02-mongodb/scripts/04-02-04-import-images.sh

step-04-02-05-mongodb-run:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/02-mongodb/scripts/04-02-05-run-mongodb.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/02-mongodb/scripts/04-02-05-run-mongodb.sh

step-04-02-06-mongodb-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/02-mongodb/scripts/04-02-06-verify-mongodb.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/02-mongodb/scripts/04-02-06-verify-mongodb.sh

step-04-03-01-prometheus-download-assets:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/03-prometheus/scripts/04-03-01-download-assets.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/03-prometheus/scripts/04-03-01-download-assets.sh

step-04-03-02-prometheus-verify-assets:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/03-prometheus/scripts/04-03-02-verify-assets.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/03-prometheus/scripts/04-03-02-verify-assets.sh

step-04-03-03-prometheus-transfer-files:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/03-prometheus/scripts/04-03-03-transfer-files.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/03-prometheus/scripts/04-03-03-transfer-files.sh

step-04-03-04-prometheus-import-images:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/03-prometheus/scripts/04-03-04-import-images.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/03-prometheus/scripts/04-03-04-import-images.sh

step-04-03-05-prometheus-run:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/03-prometheus/scripts/04-03-05-run-prometheus.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/03-prometheus/scripts/04-03-05-run-prometheus.sh

step-04-03-06-prometheus-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/03-prometheus/scripts/04-03-06-verify-prometheus.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/03-prometheus/scripts/04-03-06-verify-prometheus.sh

step-04-04-01-grafana-download-assets:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/04-grafana/scripts/04-04-01-download-assets.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/04-grafana/scripts/04-04-01-download-assets.sh

step-04-04-02-grafana-verify-assets:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/04-grafana/scripts/04-04-02-verify-assets.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/04-grafana/scripts/04-04-02-verify-assets.sh

step-04-04-03-grafana-transfer-files:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/04-grafana/scripts/04-04-03-transfer-files.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/04-grafana/scripts/04-04-03-transfer-files.sh

step-04-04-04-grafana-import-images:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/04-grafana/scripts/04-04-04-import-images.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/04-grafana/scripts/04-04-04-import-images.sh

step-04-04-05-grafana-run:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/04-grafana/scripts/04-04-05-run-grafana.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/04-grafana/scripts/04-04-05-run-grafana.sh

step-04-04-06-grafana-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/04-grafana/scripts/04-04-06-verify-grafana.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/04-grafana/scripts/04-04-06-verify-grafana.sh

step-04-05-01-grafana-alloy-download-assets:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/05-grafana-alloy/scripts/04-05-01-download-assets.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/05-grafana-alloy/scripts/04-05-01-download-assets.sh

step-04-05-02-grafana-alloy-verify-assets:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/05-grafana-alloy/scripts/04-05-02-verify-assets.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/05-grafana-alloy/scripts/04-05-02-verify-assets.sh

step-04-05-03-grafana-alloy-transfer-files:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/05-grafana-alloy/scripts/04-05-03-transfer-files.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/05-grafana-alloy/scripts/04-05-03-transfer-files.sh

step-04-05-04-grafana-alloy-import-images:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/05-grafana-alloy/scripts/04-05-04-import-images.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/05-grafana-alloy/scripts/04-05-04-import-images.sh

step-04-05-05-grafana-alloy-run:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/05-grafana-alloy/scripts/04-05-05-run-grafana-alloy.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/05-grafana-alloy/scripts/04-05-05-run-grafana-alloy.sh

step-04-05-06-grafana-alloy-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/04-services-monitoring/05-grafana-alloy/scripts/04-05-06-verify-grafana-alloy.sh
	@cd "$(PROJECT_ROOT)" && ./ops/04-services-monitoring/05-grafana-alloy/scripts/04-05-06-verify-grafana-alloy.sh
