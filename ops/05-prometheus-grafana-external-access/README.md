# 05 Prometheus Grafana External Access

- 과제 항목: Prometheus + Grafana 외부 접근 설정
- Prometheus와 Grafana 배포 자체는 `04-services-monitoring/`에서 관리한다.
- 외부 접근용 Service, Ingress, NodePort, 접근 검증 자료만 이 단계에 둔다.
- 작성 원본은 bastion 실행용 `delivery/ops-runtime.tar.gz`에 포함된다.
- 이 단계의 기본 구조는 `MetalLB + ingress-nginx + Ingress`다.
- MetalLB는 bare-metal/VM LAN 환경에서 `Service type=LoadBalancer`에 IP를 할당하고, ingress-nginx는 Host 기반 HTTP 라우팅을 담당한다.
- AWS private subnet simulation에서는 admission webhook 통신을 위해 Calico `VXLAN` encapsulation을 전제로 한다.

## Directories
- `prometheus/`: Prometheus 외부 접근 설정
- `grafana/`: Grafana 외부 접근 설정
- `assets/`: 05에서 필요한 컨테이너 이미지 목록
- `manifests/`: MetalLB address pool, ingress-nginx Service override, monitoring Ingress template
- `scripts/`: offline download/transfer/import/apply/verify scripts

## Flow
```bash
make 05-prometheus-grafana-external-access-run
make 05-prometheus-grafana-external-access-verify
make 05-prometheus-grafana-browser-tunnel-start
```

Default access hosts:
- `grafana.airgap.local`
- `prometheus.airgap.local`

Default MetalLB address pool:
- `10.10.20.240-10.10.20.250`

Local browser tunnel defaults:
- Grafana: `http://127.0.0.1:13000`
- Prometheus: `http://127.0.0.1:19090`
- Ingress: `http://grafana.airgap.local:18080` after hosts mapping
