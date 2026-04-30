# 03-02. 수동 kubeadm 설치 단계

## 대응 경로
- `ops/03-kubernetes-cluster/manual-kubeadm/`

## 단계 구조
1. `01-node-baseline`
2. `02-containerd`
3. `03-kubernetes-packages`
4. `04-control-plane-init`
5. `05-calico`
6. `06-worker-join`

설명: 수동 설치는 위 6개 단계 번호를 기준으로 진행한다. 현재는 `03-01` 공통 사전점검까지 완료했고, 이 문서의 실제 명령은 다음 작업에서 채운다.

## OS 기준
- 대상 노드 OS는 `Amazon Linux 2023`
- 패키지 방식은 `rpm/dnf`
- container runtime은 `containerd`
