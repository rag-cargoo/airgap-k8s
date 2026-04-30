# 03-02-06. 이미지 import

## 대응 경로
- `ops/03-kubernetes-cluster/manual-kubeadm/06-image-import/`

## 실행 순서
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
cd ops/03-kubernetes-cluster
make step-03-02-06-image-import-run
make step-03-02-06-image-import-verify
```

설명: Kubernetes와 Calico 컨테이너 이미지 tar를 master/worker의 containerd에 import한다.

## 관련 스크립트
- `ops/03-kubernetes-cluster/manual-kubeadm/06-image-import/scripts/06-01-run-image-import.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/06-image-import/scripts/06-01-verify-image-import.sh`

## 검증 기준
```text
[RESULT] SUCCESS
```
