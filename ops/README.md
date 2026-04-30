# Ops Assets

- 이 디렉터리는 실행 자산을 ClickUp 과제문 작업 순서 기준으로 정리한다.
- `manual/`은 제출 문서이고, `ops/`는 실제 실행 파일과 설정 자산을 둔다.
- 디렉터리명은 ASCII/영문으로 유지한다.
- 매뉴얼 파일명은 한글로 유지한다.
- 기존 Terraform 자산은 `01-airgap-linux-environment/aws-terraform-simulation/` 아래에 둔다.
- Kubernetes 클러스터 구성은 `manual-kubeadm/`과 `ansible-kubeadm/`으로 분리한다.

## Structure
- `01-airgap-linux-environment/`: 인터넷 불가능 네트워크 환경 및 리눅스 기본 구성
- `02-user-network/`: `devops`, sudo, hostname, `/etc/hosts`
- `03-kubernetes-cluster/`: master + worker, Calico 또는 Flannel
- `04-services-monitoring/`: MySQL/MariaDB, MongoDB, Prometheus, Grafana, Grafana Alloy
- `05-prometheus-grafana-external-access/`: Prometheus + Grafana 외부 접근 설정
- `06-submission/`: 제출용 매뉴얼 변환 및 설정 파일 압축
