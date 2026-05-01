# 06. 제출

## 06-01. 제출용 매뉴얼과 서버 설정 ZIP 생성
```bash
cd <프로젝트-루트>
SUBMITTER_NAME='홍구' \
SUBMITTER_PHONE='010-6455-9777' \
SUBMITTER_EMAIL='akinux1004@gmail.com' \
GITHUB_URL='https://github.com/rag-cargoo/airgap-k8s' \
make 06-submission-build
```

설명: `delivery/submission/` 아래에 제출용 통합 매뉴얼과 서버 설정 ZIP을 생성한다.

생성 파일:
- `delivery/submission/01-manual-source-convert-to-hwpx-pdf/airgap-k8s-manual.md`
- `delivery/submission/01-manual-source-convert-to-hwpx-pdf/airgap-k8s-manual.html`
- `delivery/submission/01-manual-source-convert-to-hwpx-pdf/airgap-k8s-manual-hwpx-pdf-conversion-guide.txt`
- `delivery/submission/02-server-config-zip-attach-this/airgap-k8s-server-configs.zip`
- `delivery/submission/03-final-email-attachments/airgap-k8s-server-configs.zip`

## 06-02. 제출용 매뉴얼 변환
```text
delivery/submission/01-manual-source-convert-to-hwpx-pdf/airgap-k8s-manual.md
delivery/submission/01-manual-source-convert-to-hwpx-pdf/airgap-k8s-manual.html
```

설명: 현재 작업 환경에는 Hancom Office, pandoc, LibreOffice 변환기가 없으므로 HWPX/PDF는 한컴오피스에서 최종 변환한다. 한컴오피스에서 `01-manual-source-convert-to-hwpx-pdf/airgap-k8s-manual.md` 또는 `01-manual-source-convert-to-hwpx-pdf/airgap-k8s-manual.html`을 열고 문단과 페이지 나눔을 확인한 뒤 `다른 이름으로 저장 -> HWPX`, `PDF 내보내기`를 수행한다. 변환한 `airgap-k8s-manual.hwpx`, `airgap-k8s-manual.pdf`는 `delivery/submission/03-final-email-attachments/`에 넣는다.

변환 안내:
```bash
sed -n '1,120p' delivery/submission/01-manual-source-convert-to-hwpx-pdf/airgap-k8s-manual-hwpx-pdf-conversion-guide.txt
```

## 06-03. 서버 설정 ZIP 포함 범위
`airgap-k8s-server-configs.zip`에는 서버 구축에 사용한 설정 파일과 재현 스크립트를 포함한다.

포함:
- Kubernetes 설치/검증 스크립트
- Calico와 StorageClass 관련 스크립트와 manifest
- MariaDB, MongoDB manifest
- Prometheus manifest, scrape 설정, alert rule
- Grafana manifest, datasource, dashboard provider, dashboard JSON
- Grafana Alloy manifest와 설정
- MetalLB, ingress-nginx, Grafana/Prometheus Ingress manifest template
- 오프라인 자산 다운로드 스크립트와 image/chart 목록
- Makefile과 README

제외:
- Terraform 코드와 Terraform 변수/상태/plan 파일
- 다운로드된 대용량 패키지, 이미지 tar, `offline-assets.tar.gz`
- `.env`, `.kube/`, 개인키, 실제 kubeconfig
- `.terraform/`, `terraform.tfvars`, `*.tfstate`, `tfplan`, `*.pem`, `*.key`

설명: Terraform 코드는 메일 첨부 ZIP에 넣지 않고 GitHub 링크로 확인하게 한다. 제출 ZIP은 Kubernetes/DB/모니터링 서버 구축 설정에 집중한다.

## 06-04. 폐쇄망 반입 자산 제출 기준
```text
delivery/offline-assets.tar.gz
delivery/ops-runtime.tar.gz
```

설명: `offline-assets.tar.gz`는 다운로드된 대용량 설치 자산이라 메일 첨부에 넣지 않는다. 필요하면 Google Drive 같은 외부 공유 링크로 별도 전달한다. 기본 제출은 다운로드 스크립트, 목록 파일, 검증 스크립트, manifest를 ZIP으로 제공하고, 매뉴얼에 `make 01-03-offline-assets-run` 재생성 절차를 남긴다.

## 06-05. 제출 패키지 검증
```bash
make 06-submission-verify
```

검증 기준:
- 제출 매뉴얼에 실습 환경 구성 안내, 폐쇄망 반입 방식, StorageClass, MetalLB, ingress-nginx, Grafana dashboard 설명이 포함된다.
- ZIP 안에 StorageClass, Prometheus, Grafana, Grafana Alloy, MetalLB, ingress-nginx, Ingress manifest와 dashboard JSON이 포함된다.
- ZIP 안에 `.env`, `.kube`, `.terraform`, `terraform.tfvars`, `tfstate`, `tfplan`, 개인키, 대용량 offline assets가 포함되지 않는다.
- ZIP 파일 크기가 일반 메일 첨부 기준인 25MB 이하인지 확인한다.

## 06-06. 제출 메일 구성
메일 첨부:
- `delivery/submission/03-final-email-attachments/airgap-k8s-manual.hwpx`
- `delivery/submission/03-final-email-attachments/airgap-k8s-manual.pdf`
- `delivery/submission/03-final-email-attachments/airgap-k8s-server-configs.zip`

메일 본문:
```text
안녕하세요.

서버 구축 테스트 과제 제출드립니다.

첨부:
1. 서버 구축 과정 상세 매뉴얼(HWPX/PDF)
2. 서버 구축 설정 파일 압축본

전체 소스 및 작업 이력:
https://github.com/rag-cargoo/airgap-k8s

대용량 오프라인 설치 자산은 메일 첨부 용량 제한으로 기본 첨부하지 않았고,
매뉴얼의 다운로드/검증/반입 절차와 첨부 ZIP의 스크립트로 재생성할 수 있도록 정리했습니다.
필요 시 offline-assets.tar.gz는 별도 공유 링크로 전달드리겠습니다.

감사합니다.

홍구
010-6455-9777
akinux1004@gmail.com
```
