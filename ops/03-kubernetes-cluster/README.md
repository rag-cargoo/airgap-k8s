# 03 Kubernetes Cluster

- Kubernetes 공식 문서의 `kubeadm` 절차를 기준으로 구성한다.
- 폐쇄망 환경에서는 공식 절차의 온라인 다운로드와 image pull 단계를 `offline-assets` 반입 자산으로 치환한다.
- Kubernetes 설치 시 참조하는 작업 원본 자산 경로는 `assets/offline-assets/kubernetes/`다.
- bastion 실행 원본은 `delivery/ops-runtime.tar.gz`로 별도 묶어 `/opt/airgap-k8s-ops`에 배치한다.
- `common/`은 수동/Ansible 공통 변수, 사전점검, 반입 경로 기준을 둔다.
- `manual-kubeadm/`은 수동 `kubeadm` 설치 자산을 둔다.
- `ansible-kubeadm/`은 같은 절차를 자동화한 playbook 자산을 둔다.
- `calico/`는 Calico 적용 자산을 둔다.
- 두 모드는 같은 절차의 수동/자동화 버전이어야 한다.
- 대상 환경이 바뀌어도 공통 원칙은 같다. bastion 경유든 폐쇄망 내부 control node든 SSH 대상, inventory, ProxyCommand, node IP만 맞추면 같은 자산 구조를 재사용할 수 있어야 한다.

## Stage Alignment
- 공통
  - `01-access-and-transfer/`
  - `02-preflight/`
- 수동
  - `01-node-baseline/`
  - `02-containerd/`
  - `03-kubernetes-packages/`
  - `04-control-plane-init/`
  - `05-calico/`
  - `06-worker-join/`
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
