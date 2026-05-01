#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SUBMISSION_DIR="${PROJECT_ROOT}/delivery/submission"
MANUAL_DIR="${SUBMISSION_DIR}/01-manual-source-convert-to-hwpx-pdf"
FINAL_DIR="${SUBMISSION_DIR}/03-final-email-attachments"
MANUAL_MD="${MANUAL_DIR}/airgap-k8s-manual.md"
MANUAL_HTML="${MANUAL_DIR}/airgap-k8s-manual.html"
CONVERSION_GUIDE="${MANUAL_DIR}/airgap-k8s-manual-hwpx-pdf-conversion-guide.txt"

SUBMITTER_NAME="${SUBMITTER_NAME:-홍구}"
SUBMITTER_PHONE="${SUBMITTER_PHONE:-010-6455-9777}"
SUBMITTER_EMAIL="${SUBMITTER_EMAIL:-akinux1004@gmail.com}"
GITHUB_URL="${GITHUB_URL:-https://github.com/rag-cargoo/airgap-k8s}"
SUBMISSION_DATE="${SUBMISSION_DATE:-$(date '+%Y-%m-%d')}"

mkdir -p "${MANUAL_DIR}" "${FINAL_DIR}"

write_preface() {
  cat <<EOF
# 서버 구축 테스트 제출 매뉴얼

## 제출자
- 이름: ${SUBMITTER_NAME}
- 연락처: ${SUBMITTER_PHONE}
- 이메일: ${SUBMITTER_EMAIL}
- GitHub: ${GITHUB_URL}
- 작성일: ${SUBMISSION_DATE}

## 실습 환경 구성 안내
본 과제는 온프레미스 폐쇄망 환경에서 Kubernetes와 모니터링 서비스를 구축하는 것을 목표로 작성했다.

초기에는 로컬 VM 기반으로 환경을 구성해 최종 검증까지 진행하려 했으나, 제한된 제출 일정 안에서 폐쇄망 네트워크와 서버 구성을 빠르게 반복 검증하기 위해 Terraform을 사용해 AWS 상에 폐쇄망 구조를 먼저 구성했다.

AWS에서는 EKS, RDS 같은 관리형 서비스를 사용하지 않았고, VPC, Subnet, Security Group, EC2만 사용해 인터넷 접근이 차단된 master/worker 서버 환경을 만들었다. 이후 Kubernetes 설치, Calico 구성, MariaDB, MongoDB, Prometheus, Grafana, Grafana Alloy, 외부 접근 설정은 모두 서버 내부에서 직접 수행했다.

따라서 Terraform은 인프라 골격을 빠르게 준비하기 위한 용도로만 사용했으며, 실제 서버 구축 절차와 설정 파일은 온프레미스 VM 환경에도 동일하게 적용할 수 있도록 분리해 작성했다. 다만 제출 일정상 동일 절차를 별도 VM 환경에서 다시 검증하는 단계까지는 완료하지 못했고, 최종 검증은 Terraform으로 구성한 AWS 폐쇄망 시뮬레이션 환경에서 수행했다.

## 폐쇄망 반입 방식
이 매뉴얼은 폐쇄망을 전제로 한다. 인터넷 가능한 준비 PC에서 필요한 패키지, 컨테이너 이미지, manifest, dashboard JSON을 먼저 수집하고, 검증 후 압축해서 폐쇄망 서버로 직접 옮긴다.

기본 경로는 아래와 같이 분리한다.

| 구분 | 경로 | 설명 |
| --- | --- | --- |
| 로컬 작업 원본 | \`assets/offline-assets/\` | 온라인 PC에서 다운로드한 원본 자산 |
| 서버 반입 번들 | \`delivery/offline-assets.tar.gz\` | 폐쇄망 서버로 옮기는 대용량 설치 자산 |
| 서버 배치 경로 | \`/opt/offline-assets\` | master/worker에서 실제 설치에 사용하는 경로 |
| 운영 스크립트 번들 | \`delivery/ops-runtime.tar.gz\` | bastion 또는 control node에서 실행할 작성 스크립트 |
| 운영 스크립트 배치 | \`/opt/airgap-k8s-ops\` | 폐쇄망 내부에서 Makefile과 스크립트를 실행하는 경로 |

제출 메일에는 대용량 다운로드 결과물 자체를 기본 첨부하지 않는다. 대신 다운로드 스크립트, 이미지 목록, chart 목록, manifest, dashboard JSON, 검증 스크립트를 \`airgap-k8s-server-configs.zip\`에 포함해 재현 가능하게 제출한다. 실제 설치 파일이 필요한 경우에는 \`make 01-03-offline-assets-run\`으로 \`delivery/offline-assets.tar.gz\`를 다시 생성한다.

## 기술 선택 설명

### Kubernetes 설치 방식
- \`kubeadm\` 기반으로 master 1대와 worker 1대를 구성했다.
- 관리형 Kubernetes를 사용하지 않고, control plane 초기화, kubelet/containerd 설정, worker join을 직접 수행했다.
- 폐쇄망을 고려해 설치 패키지와 컨테이너 이미지는 온라인 PC에서 먼저 수집한 뒤 서버로 반입했다.

### Calico 사용 이유
- 과제문은 Calico 또는 Flannel 중 하나를 요구한다.
- 이번 구성은 NetworkPolicy와 운영 사례가 많은 Calico를 선택했다.
- AWS private subnet 시뮬레이션에서는 kube-apiserver와 worker webhook pod 통신 안정성을 위해 Calico encapsulation을 \`VXLAN\`으로 고정했다.

### StorageClass 사용 이유
- \`kubeadm\`은 Kubernetes control plane과 node bootstrap을 담당하고, Calico는 Pod 네트워크를 담당한다.
- 둘 다 PVC를 자동으로 PV에 연결해 주는 스토리지 프로비저너를 설치하지 않는다.
- MariaDB, MongoDB, Prometheus, Grafana는 PVC를 사용하므로 기본 StorageClass가 없으면 PVC가 \`Pending\` 상태에 머물 수 있다.
- 이번 과제에서는 폐쇄망 반입물이 작고 실습 환경에 맞는 \`local-path-provisioner\`를 기본 StorageClass로 사용했다.
- \`local-path-provisioner\`는 노드 로컬 디스크 기반이므로 운영급 HA 스토리지는 아니며, 실제 운영 환경에서는 NFS provisioner, Longhorn, Rook-Ceph, SAN/NAS CSI Driver 등을 요구사항에 맞춰 검토한다.

### Prometheus 구성 이유
- 단순 Pod Running 확인이 아니라 실제 지표 수집을 보여주기 위해 Prometheus scrape target을 구성했다.
- Prometheus 자체 지표, node-exporter, kube-state-metrics, Kubernetes cAdvisor, Grafana Alloy self metrics를 수집한다.
- alert rule ConfigMap을 추가해 target down, node exporter 누락, root filesystem 사용률, workload replica, service endpoint 상태를 감시한다.

### Grafana dashboard 구성 이유
- 폐쇄망에서는 Grafana UI에서 dashboard ID를 입력해 런타임 다운로드하는 방식이 재현성이 낮다.
- Grafana.com community dashboard JSON을 온라인 PC에서 미리 확보하고, ConfigMap으로 반입해 자동 provisioning한다.
- 사용한 dashboard는 \`1860 Node Exporter Full\`, \`25091 Kube-State-Metrics Overview\`, \`17483 Kubernetes Cluster Monitoring via Prometheus\`다.

### Grafana Alloy 구성 이유
- 과제문에 Grafana Alloy 배포가 포함되어 있으므로 별도 Deployment와 Service로 배포했다.
- Alloy self metrics를 Prometheus가 scrape하고, Alloy 설정에는 Prometheus remote_write endpoint를 포함해 수집 파이프라인 구성을 보여준다.

### MetalLB와 ingress-nginx 사용 이유
- 온프레미스/VM Kubernetes에는 cloud LoadBalancer가 기본 제공되지 않는다.
- MetalLB는 bare-metal 또는 VM LAN 환경에서 \`Service type=LoadBalancer\`에 IP를 할당하는 역할을 한다.
- ingress-nginx는 MetalLB가 할당한 LoadBalancer IP로 HTTP 요청을 받고 Host 헤더 기준으로 Grafana와 Prometheus에 라우팅한다.
- 기본 Host는 \`grafana.airgap.local\`, \`prometheus.airgap.local\`이며, 내부 DNS 또는 관리자 PC \`/etc/hosts\`에 등록해 접근한다.
- AWS private subnet 시뮬레이션에서는 MetalLB IP를 인터넷 공개 AWS LoadBalancer로 설명하지 않고, private node 경로 또는 SSH tunnel로 검증한다.

## 제출 파일 구성
메일 첨부 대상은 아래 3개를 기준으로 한다.

1. \`airgap-k8s-manual.md\`: 제출 매뉴얼 원본
2. \`airgap-k8s-manual.html\`: 브라우저/프린트 확인용 변환본
3. \`airgap-k8s-server-configs.zip\`: 서버 구축 설정 파일 압축본

HWPX 또는 PDF 제출이 필요하면 \`airgap-k8s-manual.md\` 또는 \`airgap-k8s-manual.html\`을 한컴오피스에서 열고 \`다른 이름으로 저장\` 또는 \`PDF 내보내기\`로 변환한다. 변환 절차는 \`airgap-k8s-manual-hwpx-pdf-conversion-guide.txt\`에 적었다.

## 설정 ZIP 포함 범위
\`airgap-k8s-server-configs.zip\`에는 아래 항목을 포함한다.

- Kubernetes 설치/검증 스크립트
- Calico, StorageClass 관련 스크립트와 manifest
- MariaDB, MongoDB manifest
- Prometheus manifest, scrape 설정, alert rule
- Grafana manifest, datasource, dashboard provider, dashboard JSON
- Grafana Alloy manifest와 설정
- MetalLB, ingress-nginx, Grafana/Prometheus Ingress manifest template
- 오프라인 자산 다운로드 스크립트와 이미지/charts 목록
- Makefile과 README

아래 항목은 제외한다.

- Terraform 코드와 Terraform 변수/상태/plan 파일
- 다운로드된 대용량 패키지, 이미지 tar, \`offline-assets.tar.gz\`
- \`.env\`, \`.kube/\`, 개인키, 실제 kubeconfig
- \`.terraform/\`, \`terraform.tfvars\`, \`*.tfstate\`, \`tfplan\`, \`*.pem\`, \`*.key\`

---

# 원본 매뉴얼 본문

EOF
}

{
  write_preface
  while IFS= read -r file; do
    rel_path="${file#${PROJECT_ROOT}/}"
    printf '\n---\n\n'
    printf '# 문서: `%s`\n\n' "${rel_path}"
    sed -n '1,$p' "${file}"
    printf '\n'
  done < <(find "${PROJECT_ROOT}/manual" -type f -name '*.md' | sort)
} > "${MANUAL_MD}"

{
  printf '<!doctype html>\n<html lang="ko">\n<head>\n'
  printf '<meta charset="utf-8">\n'
  printf '<title>서버 구축 테스트 제출 매뉴얼</title>\n'
  printf '<style>body{font-family:Arial,"Noto Sans KR",sans-serif;line-height:1.55;margin:32px;} pre{white-space:pre-wrap;font-family:"D2Coding","Consolas",monospace;font-size:13px;} @media print{body{margin:18mm;}}</style>\n'
  printf '</head>\n<body>\n<pre>\n'
  sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "${MANUAL_MD}"
  printf '</pre>\n</body>\n</html>\n'
} > "${MANUAL_HTML}"

cat > "${CONVERSION_GUIDE}" <<'EOF'
HWPX/PDF 변환 안내

1. Hancom Office 또는 한글을 실행한다.
2. delivery/submission/01-manual-source-convert-to-hwpx-pdf/airgap-k8s-manual.md 또는 airgap-k8s-manual.html 파일을 연다.
3. 문단/페이지 나눔을 확인한다.
4. 파일 -> 다른 이름으로 저장 -> HWPX 형식으로 저장한다.
5. 파일 -> PDF로 저장 또는 내보내기를 실행한다.
6. 생성한 airgap-k8s-manual.hwpx와 airgap-k8s-manual.pdf를 아래 폴더에 넣는다.
   delivery/submission/03-final-email-attachments/

현재 자동 생성 파일:
- airgap-k8s-manual.md
- airgap-k8s-manual.html

주의:
- HWPX는 ZIP 기반 XML 문서 포맷이지만, 호환되는 HWPX를 직접 조립하려면 header.xml, section0.xml, mimetype, content.hpf 등의 구조와 참조 무결성이 맞아야 한다.
- 현재 작업 환경에는 Hancom Office, pandoc, LibreOffice 변환기가 없으므로 HWPX/PDF는 한컴오피스에서 최종 변환한다.
EOF

cat > "${FINAL_DIR}/README.txt" <<'EOF'
최종 메일 첨부 파일을 모으는 폴더입니다.

여기에 최종적으로 아래 3개 파일이 있으면 됩니다.
1. airgap-k8s-manual.hwpx
2. airgap-k8s-manual.pdf
3. airgap-k8s-server-configs.zip

현재 환경에서는 HWPX/PDF 변환기가 없으므로,
../01-manual-source-convert-to-hwpx-pdf/airgap-k8s-manual.md
또는
../01-manual-source-convert-to-hwpx-pdf/airgap-k8s-manual.html
을 한컴오피스에서 열어 HWPX/PDF로 저장한 뒤 이 폴더에 넣습니다.
EOF

printf '[SUMMARY] submission manual generated\n'
printf '  markdown: %s\n' "${MANUAL_MD}"
printf '  html: %s\n' "${MANUAL_HTML}"
printf '  conversion guide: %s\n' "${CONVERSION_GUIDE}"
printf '  final email attachments dir: %s\n' "${FINAL_DIR}"
