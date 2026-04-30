# AWS Terraform Simulation

## Purpose
- 이 디렉터리는 과제 01 작업인 `인터넷이 불가능한 네트워크 환경 및 리눅스 기본 구성`을 실습하기 위한 AWS 기반 air-gap simulation 인프라 골격을 관리한다.
- 범위는 `VPC`, `subnet`, `route table`, `security group`, `bastion`, `k8s-master`, `k8s-worker1`까지다.
- 목적은 bastion을 통한 관리자 접근만 허용하고, Kubernetes 노드는 인터넷 불가 private 환경에 두는 것이다.

## Structure
- `versions.tf`: Terraform / provider version constraints
- `providers.tf`: AWS provider configuration
- `variables.tf`: 입력 변수
- `network.tf`: VPC / subnet / route table
- `compute.tf`: security group / EC2
- `outputs.tf`: 핵심 출력값
- `terraform.tfvars.example`: 예시 변수 파일

## Usage
- 루트에서: `make tf-init`, `make tf-plan`
- 이 디렉터리에서: `make init`, `make plan`

## Notes
- private subnet에는 NAT를 두지 않는다.
- bastion만 public subnet + public IP를 가진다.
- 실제 설치 절차는 Terraform에 숨기지 않고 별도 매뉴얼에서 다룬다.
- 실제 `terraform.tfvars`는 로컬 전용 파일이며 Git 추적 대상이 아니다.
- SSH 개인키(`*.pem`)는 레포에 두지 않고, 기존 AWS key pair 이름은 로컬 `terraform.tfvars`에서만 관리한다.
