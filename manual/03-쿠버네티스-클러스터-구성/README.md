# 03. 쿠버네티스 클러스터 구성

## 문서 구성
- `manual-kubeadm/`: [수동 kubeadm 설치 단계](./manual-kubeadm/README.md)
- `manual-kubeadm/01-access-and-transfer/`: [접속 및 반입](./manual-kubeadm/01-access-and-transfer/README.md)
- `manual-kubeadm/02-preflight/`: [kubeadm 사전점검](./manual-kubeadm/02-preflight/README.md)
- `manual-kubeadm/03-node-baseline/`: [노드 기본값](./manual-kubeadm/03-node-baseline/README.md)
- `manual-kubeadm/04-containerd/`: [containerd 설치](./manual-kubeadm/04-containerd/README.md)
- `manual-kubeadm/05-kubernetes-packages/`: [Kubernetes 패키지 설치](./manual-kubeadm/05-kubernetes-packages/README.md)
- `manual-kubeadm/06-image-import/`: [이미지 import](./manual-kubeadm/06-image-import/README.md)
- `manual-kubeadm/07-control-plane-init/`: [control-plane 초기화](./manual-kubeadm/07-control-plane-init/README.md)
- `manual-kubeadm/08-calico/`: [Calico 적용](./manual-kubeadm/08-calico/README.md)
- `manual-kubeadm/09-worker-join/`: [worker join](./manual-kubeadm/09-worker-join/README.md)
- `manual-kubeadm/10-cluster-verify/`: [클러스터 검증](./manual-kubeadm/10-cluster-verify/README.md)
- `storageclass/`: [StorageClass 구성 기준](./storageclass/README.md), [StorageClass 운영 매뉴얼](./storageclass/operations.md)
- `ansible-kubeadm/`: [Ansible kubeadm 설치 단계](./ansible-kubeadm/README.md)
- `calico/`: [Calico 적용 기준](./calico/README.md)

## ops 매칭
| 매뉴얼 디렉터리 | ops 디렉터리 | 주요 target |
| --- | --- | --- |
| `manual-kubeadm/` | `ops/03-kubernetes-cluster/manual-kubeadm/` | `03-02-manual-kubeadm-*`, `step-03-02-01..10-*` |
| `storageclass/` | `ops/03-kubernetes-cluster/storageclass/` | `03-03-storageclass-*`, `step-03-03-01..03-*` |
| `ansible-kubeadm/` | `ops/03-kubernetes-cluster/ansible-kubeadm/` | `03-04-ansible-kubeadm-*` 예정 |
| `calico/` | `ops/03-kubernetes-cluster/calico/` | `03-02-08-calico-*`에서 사용 |

## 03-01. 환경변수 로드
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
```

설명: bastion, master, worker 접속에 필요한 환경변수를 현재 셸에 로드한다.

## 03-02. target 확인
```bash
cd ops/03-kubernetes-cluster
make help
```

설명: 수동 설치는 `manual-kubeadm/01..10` 단원과 1:1로 대응되는 `step-03-02-*` target을 사용한다. `03-01-preflight-*` target은 하위 호환용 alias이며 실제 preflight 스크립트는 `manual-kubeadm/02-preflight/`에 있다.

## 03-03. bastion 실행 원본 번들 생성
```bash
cd <프로젝트-루트>
make ops-runtime-bundle-run
make ops-runtime-bundle-verify
```

설명: bastion에서 `kubectl`, `helm`, `ansible-playbook`를 실행할 수 있도록 작성 원본 번들 `delivery/ops-runtime.tar.gz`를 준비한다.

## 03-04. 수동 kubeadm 전체 실행
```bash
cd <프로젝트-루트>/ops/03-kubernetes-cluster
make 03-02-manual-kubeadm-run
make 03-02-manual-kubeadm-verify
```

설명: 전체 실행 target은 `manual-kubeadm/01-access-and-transfer`부터 `10-cluster-verify`까지 순서대로 실행/검증한다.

## 03-05. 단계별 실행
```bash
make step-03-02-01-access-and-transfer-run
make step-03-02-01-access-and-transfer-verify
make step-03-02-02-preflight-run
make step-03-02-02-preflight-verify
make step-03-02-03-node-baseline-run
make step-03-02-03-node-baseline-verify
make step-03-02-04-containerd-run
make step-03-02-04-containerd-verify
make step-03-02-05-kubernetes-packages-run
make step-03-02-05-kubernetes-packages-verify
make step-03-02-06-image-import-run
make step-03-02-06-image-import-verify
make step-03-02-07-control-plane-init-run
make step-03-02-07-control-plane-init-verify
make step-03-02-08-calico-run
make step-03-02-08-calico-verify
make step-03-02-09-worker-join-run
make step-03-02-09-worker-join-verify
make step-03-02-10-cluster-verify
```

설명: 각 단원 디렉터리의 `scripts/` 아래에 번호가 붙은 실행/검증 스크립트가 있다. 상위 `manual-kubeadm/scripts/` 공용 설치 본체는 사용하지 않는다.

## 03-06. 작성 스크립트 확인
```bash
find ops/03-kubernetes-cluster/manual-kubeadm -path '*/scripts/*.sh' | sort
make 03-02-manual-kubeadm-script-verify
```

설명: 파일명은 `01-01`, `01-02`, `02-01`, `02-02`처럼 `단원-세부순서-역할` 접두어를 사용한다. 문법 검증은 `03-02-manual-kubeadm-script-verify`로 수행한다.

## 03-07. preflight 호환 target
```bash
make 03-01-preflight-run
make 03-01-preflight-verify
```

설명: 기존 문서와 상위 `all-verify` 호환을 위해 남긴 이름이다. 내부적으로는 `step-03-02-02-preflight-run/verify`를 호출한다.

## 03-08. 상태 초기화
```bash
make 03-01-preflight-clear
make 03-02-manual-kubeadm-clear
```

설명: 상태 마커만 제거한다. 노드 설정, 패키지, Kubernetes 클러스터 자체를 되돌리지는 않는다.

## 03-09. 장애 진단
```bash
make 03-02-manual-kubeadm-troubleshoot
```

설명: 전송, 패키지, 이미지 import, Calico, 노드 Ready 상태가 불명확하면 이 target으로 현재 상태를 먼저 확인한다.

## 03-03. StorageClass 확인
```bash
kubectl get storageclass
kubectl get pvc -A
```

설명: kubeadm과 Calico는 스토리지 프로비저너를 설치하지 않는다. `kubectl get storageclass` 결과가 비어 있으면 04 서비스 배포 전에 [StorageClass 구성 기준](./storageclass/README.md)에 따라 기본 StorageClass를 먼저 구성한다.

```bash
make 03-03-storageclass-run
make 03-03-storageclass-verify
```

설명: `03-03-storageclass-run`은 local-path-provisioner 이미지를 master/worker에 import하고 manifest를 적용한다. `03-03-storageclass-verify`는 테스트 PVC와 Pod로 동적 PV 생성까지 확인한다.

단계별 실행이 필요하면 아래 순서로 실행한다.

```bash
make step-03-03-01-storageclass-assets-run
make step-03-03-01-storageclass-assets-verify
make step-03-03-02-storageclass-image-import-run
make step-03-03-02-storageclass-image-import-verify
make step-03-03-03-storageclass-apply-run
make step-03-03-03-storageclass-apply-verify
```

설명: StorageClass도 `03-03-01`, `03-03-02`, `03-03-03` 세부 단계로 나누고, 각 세부 단계마다 같은 번호의 verify를 둔다.
