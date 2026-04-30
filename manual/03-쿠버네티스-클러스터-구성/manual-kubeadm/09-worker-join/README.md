# 03-02-09. worker join

## 대응 경로
- `ops/03-kubernetes-cluster/manual-kubeadm/09-worker-join/`

## 실행 순서
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
cd ops/03-kubernetes-cluster
make step-03-02-09-worker-join-run
make step-03-02-09-worker-join-verify
```

설명: master에서 join command를 생성하고 worker 노드를 클러스터에 join한다.

## 관련 스크립트
- `ops/03-kubernetes-cluster/manual-kubeadm/09-worker-join/scripts/09-01-run-worker-join.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/09-worker-join/scripts/09-01-verify-worker-join.sh`

## 검증 기준
```text
[RESULT] SUCCESS
```
