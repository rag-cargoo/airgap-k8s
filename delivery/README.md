# Delivery

- 서버 반입용 설치 번들과 bastion 실행 원본 번들을 정리하는 디렉터리다.
- `ops/`는 사람이 작성한 실행 원본을 관리하고, `delivery/`는 실제 전달용 묶음을 관리한다.

## Bundles
- `delivery/offline-assets/`, `delivery/offline-assets.tar.gz`
  - 폐쇄망 노드 설치에 필요한 `.deb`, image tar, manifest 반입 번들
  - 서버 기준 배치 경로: `/opt/offline-assets`
- `delivery/ops-runtime/`, `delivery/ops-runtime.tar.gz`
  - bastion에서 `kubectl`, `helm`, `ansible-playbook` 실행 시 필요한 작성 원본 번들
  - 포함 대상: `ops/common`, `ops/02-user-network`, `ops/03-kubernetes-cluster`, `ops/04-services-monitoring`, `ops/05-prometheus-grafana-external-access`
  - 서버 기준 배치 경로: `/opt/airgap-k8s-ops`
