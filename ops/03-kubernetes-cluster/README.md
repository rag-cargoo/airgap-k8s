# 03 Kubernetes Cluster

- Kubernetes 공식 문서의 `kubeadm` 절차를 기준으로 구성한다.
- 폐쇄망 환경에서는 공식 절차의 온라인 다운로드와 image pull 단계를 `offline-assets` 반입 자산으로 치환한다.
- Kubernetes 설치 시 참조하는 작업 원본 자산 경로는 `assets/offline-assets/kubernetes/`다.
- bastion 실행 원본은 `delivery/ops-runtime.tar.gz`로 별도 묶어 `/opt/airgap-k8s-ops`에 배치한다.
- `manual-kubeadm/`은 수동 `kubeadm` 설치 자산과 단계별 실행/검증 스크립트를 둔다.
- `ansible-kubeadm/`은 같은 절차를 자동화한 playbook 자산을 둔다. Ansible 전용 preflight와 실행 스크립트는 이 디렉터리 안에서 별도로 관리한다.
- `calico/`는 Calico 적용 자산을 둔다.
- 두 모드는 같은 절차의 수동/자동화 버전이어야 한다.
- 제출 매뉴얼은 `manual/03-쿠버네티스-클러스터-구성/manual-kubeadm/01..10` 디렉터리로 이 구조와 1:1 대응한다.
- 대상 환경이 바뀌어도 공통 원칙은 같다. bastion 경유든 폐쇄망 내부 control node든 SSH 대상, inventory, ProxyCommand, node IP만 맞추면 같은 자산 구조를 재사용할 수 있어야 한다.

## Stage Alignment
- 수동
  - `01-access-and-transfer/`
  - `02-preflight/`
  - `03-node-baseline/`
  - `04-containerd/`
  - `05-kubernetes-packages/`
  - `06-image-import/`
  - `07-control-plane-init/`
  - `08-calico/`
  - `09-worker-join/`
  - `10-cluster-verify/`
- Ansible
  - `01-node-baseline/`
  - `02-containerd/`
  - `03-kubernetes-packages/`
  - `04-control-plane-init/`
  - `05-calico/`
  - `06-worker-join/`

## Official References
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
- https://kubernetes.io/docs/setup/production-environment/container-runtimes/
- https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/
