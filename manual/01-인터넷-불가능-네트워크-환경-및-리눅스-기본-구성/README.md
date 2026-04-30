# 01. 인터넷 불가능 네트워크 환경 및 리눅스 기본 구성

## 01-01.1. Terraform 실습 환경 파일 확인
```bash
find ops/01-airgap-linux-environment/aws-terraform-simulation -maxdepth 1 -type f | sort
```

설명: AWS로 폐쇄망 실습 환경을 재현할 때 사용하는 Terraform 파일을 확인한다.

## 01-01.2. Terraform 변수 파일 생성
```bash
cp ops/01-airgap-linux-environment/aws-terraform-simulation/terraform.tfvars.example \
  ops/01-airgap-linux-environment/aws-terraform-simulation/terraform.tfvars
```

설명: 실제 AWS 값은 `terraform.tfvars`에만 기록하고 제출본에는 마스킹한다.

## 01-01.3. Terraform 포맷 정리
```bash
cd ops/01-airgap-linux-environment
make tf-fmt
```

설명: Terraform 파일 형식을 정리한다.

## 01-01.4. Terraform 초기화
```bash
cd ops/01-airgap-linux-environment
make tf-init
```

설명: provider plugin을 준비한다. 이 단계는 준비망 또는 인터넷 가능한 관리 환경에서 수행한다.

## 01-01.5. Terraform 구성 검증
```bash
cd ops/01-airgap-linux-environment
make tf-validate
```

설명: Terraform 문법과 리소스 참조 오류를 확인한다.

## 01-01.6. Terraform 실행 계획 생성
```bash
cd ops/01-airgap-linux-environment
make tf-plan
```

설명: bastion만 public subnet에 있고 master/worker는 private subnet에 있는지 확인한다.

## 01-01.7. Terraform 적용
```bash
cd ops/01-airgap-linux-environment
make tf-apply
```

설명: bastion, master, worker 실습 환경을 생성한다.

## 01-02.1. 환경변수 파일 생성 및 로드
```bash
cd <프로젝트-루트>
make 01-02-env-file-create
vi .env
cd ops/01-airgap-linux-environment
make sync-env
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
```

설명: `.env`를 만든 뒤 SSH 키 경로를 입력하고, Terraform output으로 IP를 갱신한 뒤 현재 셸에 로드한다.

## 01-03.1. 쿠버네티스 설치용 자산 다운로드 문서 확인
```bash
sed -n '1,240p' manual/01-인터넷-불가능-네트워크-환경-및-리눅스-기본-구성/02-쿠버네티스-설치용-자산-다운로드.md
```

설명: Kubernetes 설치 전에 필요한 다운로드 기준, 저장 경로, 반입 경로를 확인한다.
