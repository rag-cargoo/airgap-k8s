# 03-02-10. 클러스터 검증

## 대응 경로
- `ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/`

## 실행 순서
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
cd ops/03-kubernetes-cluster
make step-03-02-10-cluster-verify
make 03-02-manual-kubeadm-verify
```

설명: 노드 Ready, Calico rollout, image pull failure 여부를 최종 확인한다.

## 관련 스크립트
- `ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-01-verify-cluster.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-02-troubleshoot-cluster.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-03-local-kubectl-access.sh`

## 내 PC kubectl 접속
- [내 PC kubectl 접속](./local-kubectl-access.md)

## 장애 진단
```bash
make 03-02-manual-kubeadm-troubleshoot
```

상세: [트러블슈팅](./troubleshooting.md)

## 검증 기준
```text
[RESULT] SUCCESS
k8s-master Ready
k8s-worker1 Ready
no image pull failures detected
```
