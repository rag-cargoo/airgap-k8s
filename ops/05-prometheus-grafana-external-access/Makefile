.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

PROJECT_ROOT := $(abspath $(CURDIR)/../..)
BANNER := ops/common/scripts/run-result-banner.sh
STATE := ops/common/scripts/stage-state.sh
ACCESS_SCRIPTS := $(shell cd "$(PROJECT_ROOT)" && find ops/05-prometheus-grafana-external-access -path '*/scripts/*.sh' | sort)

.PHONY: help \
	05-prometheus-grafana-external-access-run 05-prometheus-grafana-external-access-verify 05-prometheus-grafana-external-access-clear 05-prometheus-grafana-external-access-script-verify \
	05-prometheus-grafana-browser-tunnel-start 05-prometheus-grafana-browser-tunnel-status 05-prometheus-grafana-browser-tunnel-stop \
	step-05-01-01-download-assets step-05-01-02-verify-assets step-05-01-03-transfer-files step-05-01-04-import-images \
	step-05-01-05-run-metallb step-05-01-06-run-ingress-nginx step-05-01-07-run-monitoring-ingress step-05-01-08-verify-external-access step-05-01-09-browser-tunnel

help:
	@printf "Targets:\n\n"
	@printf "[05 Prometheus Grafana External Access]\n"
	@printf "  05-prometheus-grafana-external-access-run       Run MetalLB + ingress-nginx + monitoring Ingress\n"
	@printf "  05-prometheus-grafana-external-access-verify    Verify external access routing\n"
	@printf "  05-prometheus-grafana-browser-tunnel-start      Open local browser tunnel\n"
	@printf "  05-prometheus-grafana-browser-tunnel-status     Check local browser tunnel\n"
	@printf "  05-prometheus-grafana-browser-tunnel-stop       Stop local browser tunnel\n"
	@printf "  05-prometheus-grafana-external-access-clear     Clear 05 state marker only\n"
	@printf "  05-prometheus-grafana-external-access-script-verify Verify 05 scripts syntax\n\n"
	@printf "[Steps]\n"
	@printf "  step-05-01-01-download-assets\n"
	@printf "  step-05-01-02-verify-assets\n"
	@printf "  step-05-01-03-transfer-files\n"
	@printf "  step-05-01-04-import-images\n"
	@printf "  step-05-01-05-run-metallb\n"
	@printf "  step-05-01-06-run-ingress-nginx\n"
	@printf "  step-05-01-07-run-monitoring-ingress\n"
	@printf "  step-05-01-08-verify-external-access\n"
	@printf "  step-05-01-09-browser-tunnel\n"

05-prometheus-grafana-external-access-run:
	@cd "$(PROJECT_ROOT)" && chmod +x $(BANNER) $(STATE) $(ACCESS_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./$(BANNER) "05-prometheus-grafana-external-access-run" "run" bash -lc '\
		$(MAKE) -C "$(CURDIR)" step-05-01-01-download-assets && \
		$(MAKE) -C "$(CURDIR)" step-05-01-02-verify-assets && \
		$(MAKE) -C "$(CURDIR)" step-05-01-03-transfer-files && \
		$(MAKE) -C "$(CURDIR)" step-05-01-04-import-images && \
		$(MAKE) -C "$(CURDIR)" step-05-01-05-run-metallb && \
		$(MAKE) -C "$(CURDIR)" step-05-01-06-run-ingress-nginx && \
		$(MAKE) -C "$(CURDIR)" step-05-01-07-run-monitoring-ingress && \
		$(MAKE) -C "$(CURDIR)" step-05-01-08-verify-external-access && \
		./ops/common/scripts/stage-state.sh set-success "05-prometheus-grafana-external-access"'

05-prometheus-grafana-external-access-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(BANNER) $(ACCESS_SCRIPTS)
	@cd "$(PROJECT_ROOT)" && ./$(BANNER) "05-prometheus-grafana-external-access-verify" "verify" bash -lc '\
		$(MAKE) -C "$(CURDIR)" step-05-01-02-verify-assets && \
		$(MAKE) -C "$(CURDIR)" step-05-01-08-verify-external-access'

05-prometheus-grafana-external-access-clear:
	@cd "$(PROJECT_ROOT)" && chmod +x $(STATE)
	@cd "$(PROJECT_ROOT)" && ./$(STATE) clear "05-prometheus-grafana-external-access"

05-prometheus-grafana-external-access-script-verify:
	@cd "$(PROJECT_ROOT)" && chmod +x $(BANNER)
	@cd "$(PROJECT_ROOT)" && ./$(BANNER) "05-prometheus-grafana-external-access-script-verify" "verify" bash -lc '\
		for script in $(ACCESS_SCRIPTS); do bash -n "$$script"; done && \
		printf "[OK] 05 external access scripts verified\n"'

05-prometheus-grafana-browser-tunnel-start:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/05-prometheus-grafana-external-access/scripts/05-01-09-browser-tunnel.sh
	@cd "$(PROJECT_ROOT)" && ./ops/05-prometheus-grafana-external-access/scripts/05-01-09-browser-tunnel.sh start

05-prometheus-grafana-browser-tunnel-status:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/05-prometheus-grafana-external-access/scripts/05-01-09-browser-tunnel.sh
	@cd "$(PROJECT_ROOT)" && ./ops/05-prometheus-grafana-external-access/scripts/05-01-09-browser-tunnel.sh status

05-prometheus-grafana-browser-tunnel-stop:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/05-prometheus-grafana-external-access/scripts/05-01-09-browser-tunnel.sh
	@cd "$(PROJECT_ROOT)" && ./ops/05-prometheus-grafana-external-access/scripts/05-01-09-browser-tunnel.sh stop

step-05-01-01-download-assets:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/05-prometheus-grafana-external-access/scripts/05-01-01-download-assets.sh
	@cd "$(PROJECT_ROOT)" && ./ops/05-prometheus-grafana-external-access/scripts/05-01-01-download-assets.sh

step-05-01-02-verify-assets:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/05-prometheus-grafana-external-access/scripts/05-01-02-verify-assets.sh
	@cd "$(PROJECT_ROOT)" && ./ops/05-prometheus-grafana-external-access/scripts/05-01-02-verify-assets.sh

step-05-01-03-transfer-files:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/05-prometheus-grafana-external-access/scripts/05-01-03-transfer-files.sh
	@cd "$(PROJECT_ROOT)" && ./ops/05-prometheus-grafana-external-access/scripts/05-01-03-transfer-files.sh

step-05-01-04-import-images:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/05-prometheus-grafana-external-access/scripts/05-01-04-import-images.sh
	@cd "$(PROJECT_ROOT)" && ./ops/05-prometheus-grafana-external-access/scripts/05-01-04-import-images.sh

step-05-01-05-run-metallb:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/05-prometheus-grafana-external-access/scripts/05-01-05-run-metallb.sh
	@cd "$(PROJECT_ROOT)" && ./ops/05-prometheus-grafana-external-access/scripts/05-01-05-run-metallb.sh

step-05-01-06-run-ingress-nginx:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/05-prometheus-grafana-external-access/scripts/05-01-06-run-ingress-nginx.sh
	@cd "$(PROJECT_ROOT)" && ./ops/05-prometheus-grafana-external-access/scripts/05-01-06-run-ingress-nginx.sh

step-05-01-07-run-monitoring-ingress:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/05-prometheus-grafana-external-access/scripts/05-01-07-run-monitoring-ingress.sh
	@cd "$(PROJECT_ROOT)" && ./ops/05-prometheus-grafana-external-access/scripts/05-01-07-run-monitoring-ingress.sh

step-05-01-08-verify-external-access:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/05-prometheus-grafana-external-access/scripts/05-01-08-verify-external-access.sh
	@cd "$(PROJECT_ROOT)" && ./ops/05-prometheus-grafana-external-access/scripts/05-01-08-verify-external-access.sh

step-05-01-09-browser-tunnel:
	@cd "$(PROJECT_ROOT)" && chmod +x ops/05-prometheus-grafana-external-access/scripts/05-01-09-browser-tunnel.sh
	@cd "$(PROJECT_ROOT)" && ./ops/05-prometheus-grafana-external-access/scripts/05-01-09-browser-tunnel.sh start
