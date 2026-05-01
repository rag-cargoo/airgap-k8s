# 05. 프로메테우스 그라파나 외부 접근 설정

이 장은 `MetalLB + ingress-nginx + Ingress` 방식으로 Prometheus와 Grafana 외부 접근을 구성한다.

bastion 기준 작성 원본 경로는 `/opt/airgap-k8s-ops/ops/05-prometheus-grafana-external-access/`이다.

## 05-01. 구성 방식
MetalLB는 온프레미스/VM LAN Kubernetes에서 `Service type=LoadBalancer`에 사용할 IP를 할당한다.
ingress-nginx는 MetalLB가 할당한 LoadBalancer IP로 HTTP 트래픽을 받고, Host 헤더 기준으로 Grafana와 Prometheus에 라우팅한다.

기본 Host:
- `grafana.airgap.local`
- `prometheus.airgap.local`

기본 MetalLB IP pool:
- `10.10.20.240-10.10.20.250`

필요하면 `.env`에서 아래 값을 변경한다.

```bash
AIRGAP_CALICO_ENCAPSULATION=VXLAN
AIRGAP_METALLB_ADDRESS_POOL=10.10.20.240-10.10.20.250
AIRGAP_GRAFANA_HOST=grafana.airgap.local
AIRGAP_PROMETHEUS_HOST=prometheus.airgap.local
AIRGAP_INGRESS_HTTP_NODE_PORT=30080
AIRGAP_INGRESS_HTTPS_NODE_PORT=30443
```

AWS private subnet 시뮬레이션에서는 Calico를 `VXLAN`으로 둔다. `VXLANCrossSubnet`이면 같은 subnet의 pod 트래픽이 캡슐화되지 않아 kube-apiserver가 worker node의 admission webhook pod에 접근하지 못할 수 있다.

## 05-02. 실행
```bash
make 05-prometheus-grafana-external-access-run
```

설명: MetalLB native manifest, ingress-nginx controller, MetalLB address pool, ingress-nginx LoadBalancer Service, Grafana/Prometheus Ingress를 순서대로 적용한다.

## 05-03. 검증
```bash
make 05-prometheus-grafana-external-access-verify
```

검증 기준:
- `metallb-system` controller와 speaker가 Ready다.
- `ingress-nginx-controller` Service가 `LoadBalancer` 타입이고 MetalLB IP를 받는다.
- `monitoring` namespace에 `grafana`, `prometheus` Ingress가 존재한다.
- `grafana.airgap.local`과 `prometheus.airgap.local` Host 라우팅이 성공한다.

## 05-04. DNS 또는 hosts 등록
온프레미스 환경에서는 내부 DNS 또는 관리자 PC의 `/etc/hosts`에 아래 형식으로 등록한다.

```text
<METALLB_INGRESS_IP> grafana.airgap.local prometheus.airgap.local
```

현재 AWS private subnet 시뮬레이션은 일반 L2 LAN과 다르므로, MetalLB IP를 인터넷 공개 LoadBalancer로 설명하지 않는다. 브라우저 검증이 필요하면 bastion/master SSH tunnel을 사용해 private node 경로에서 접근한다.

검증 완료 기준 값:
- `ingress-nginx-controller` LoadBalancer IP: `10.10.20.240`
- Grafana: `http://grafana.airgap.local`
- Prometheus: `http://prometheus.airgap.local`

## 05-05. 로컬 브라우저 터널
관리자 PC에서 private subnet IP에 직접 접근할 수 없으면 아래 터널을 사용한다.

```bash
make 05-prometheus-grafana-browser-tunnel-start
make 05-prometheus-grafana-browser-tunnel-status
```

터널 기본 URL:
- Grafana direct: `http://127.0.0.1:13000`
- Prometheus direct: `http://127.0.0.1:19090`
- Grafana login: `admin / airgap-grafana-pass`

Ingress 경로까지 브라우저로 확인하려면 관리자 PC의 hosts에 아래 값을 추가한 뒤 `http://grafana.airgap.local:18080`로 접근한다.

```text
127.0.0.1 grafana.airgap.local prometheus.airgap.local
```

터널 종료:

```bash
make 05-prometheus-grafana-browser-tunnel-stop
```
