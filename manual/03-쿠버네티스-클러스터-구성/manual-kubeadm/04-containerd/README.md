# 03-02-04. containerd 설치

## 대응 경로
- `ops/03-kubernetes-cluster/manual-kubeadm/04-containerd/`

## 실행 순서
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
cd ops/03-kubernetes-cluster
make step-03-02-04-containerd-run
make step-03-02-04-containerd-verify
```

설명: `containerd`, `runc`, CNI/CRI 도구를 오프라인 RPM 기준으로 설치하고 런타임 설정을 확인한다.

## 관련 스크립트
- `ops/03-kubernetes-cluster/manual-kubeadm/04-containerd/scripts/04-01-run-containerd.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/04-containerd/scripts/04-01-verify-containerd.sh`

## 검증 기준
```text
[RESULT] SUCCESS
```
