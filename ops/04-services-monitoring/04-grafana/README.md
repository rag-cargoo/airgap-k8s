# Grafana

- Grafana 배포 manifest, values, datasource/dashboard 설정을 둔다.
- 서비스 사용 여부를 독립적으로 선택할 수 있도록 자산 준비와 배포 스크립트를 이 디렉터리 안에서 관리한다.

## Layout
- `assets/images.txt`: 필요한 컨테이너 이미지 목록
- `assets/charts.txt`: Helm 사용 시 필요한 chart 목록
- `manifests/`: Namespace, Secret, ConfigMap, PVC, Service, workload manifest
- `values/`: Helm values 파일
- `scripts/`: 다운로드, 검증, 전송, 이미지 import, 배포, 검증 스크립트

## Target Draft
- `04-04-grafana-run`
- `04-04-grafana-verify`
