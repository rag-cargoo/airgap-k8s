# 04 Services and Monitoring

- DB, MongoDB, Prometheus, Grafana, Alloy 배포 자산을 이 단계 아래에 둔다.
- 서비스별 사용 여부를 독립적으로 선택할 수 있도록 각 서비스 단원을 분리한다.
- 작성 원본은 bastion 실행용 `delivery/ops-runtime.tar.gz`에 포함된다.

## Directories
- `01-mysql-or-mariadb/`
- `02-mongodb/`
- `03-prometheus/`
- `04-grafana/`
- `05-grafana-alloy/`
- `06-services-verify/`

## Service Unit Layout
```text
<service>/
  assets/
    images.txt
    charts.txt
  manifests/
  values/
  scripts/
```

## Execution Policy
- 서비스별 다운로드, 검증, 전송, 이미지 import, 배포, 검증은 각 서비스 디렉터리의 scripts가 담당한다.
- 전체 묶음 target은 선택 편의용으로만 둔다.
- 실제 제출 매뉴얼에는 각 서비스의 배포와 검증이 끝난 뒤 결과 기준으로 반영한다.
