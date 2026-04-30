# 03-02-02. kubeadm 사전점검

## 대응 경로
- `ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/`

## 실행 순서
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
cd ops/03-kubernetes-cluster
make step-03-02-02-preflight-run
make step-03-02-02-preflight-verify
```

설명: master/worker에 `02-01-kubeadm-preflight-check.sh`를 업로드하고, kubeadm 설치 전 필수 조건을 원격에서 점검한다.

## 호환 target
```bash
make 03-01-preflight-run
make 03-01-preflight-verify
```

설명: 위 target은 각각 `step-03-02-02-preflight-run`, `step-03-02-02-preflight-verify`를 호출한다.

## 관련 스크립트
- `ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/scripts/02-01-kubeadm-preflight-check.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/scripts/02-02-run-preflight.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/scripts/02-02-verify-preflight.sh`

## 검증 기준
```text
[RESULT] SUCCESS
```

설명: `step-03-02-02-preflight-verify` 결과가 `SUCCESS`여야 다음 설치 단계로 진행한다.
