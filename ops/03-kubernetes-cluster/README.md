# 03 Kubernetes Cluster

- Kubernetes 공식 문서의 `kubeadm` 절차를 기준으로 구성한다.
- 폐쇄망 환경에서는 공식 절차의 온라인 다운로드와 image pull 단계를 `offline-assets` 반입 자산으로 치환한다.
- Kubernetes 설치 시 참조하는 작업 원본 자산 경로는 `assets/offline-assets/kubernetes/`다.
- `manual-kubeadm/`은 수동 `kubeadm` 설치 자산을 둔다.
- `ansible-kubeadm/`은 같은 절차를 자동화한 playbook 자산을 둔다.
- `cni-calico-or-flannel/`은 Calico 또는 Flannel manifest를 둔다.
- 두 모드는 같은 절차의 수동/자동화 버전이어야 한다.

## Official References
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
- https://kubernetes.io/docs/setup/production-environment/container-runtimes/
- https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/
