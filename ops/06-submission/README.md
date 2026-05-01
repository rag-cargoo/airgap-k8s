# 06 Submission

이 단계는 제출용 통합 매뉴얼과 서버 설정 ZIP을 생성한다.

## Targets
```bash
make 06-submission-build
make 06-submission-verify
make 06-submission-script-verify
```

## Outputs
```text
delivery/submission/01-manual-source-convert-to-hwpx-pdf/
delivery/submission/02-server-config-zip-attach-this/
delivery/submission/03-final-email-attachments/
delivery/submission/04-verification-evidence/
```

## Scope
- 매뉴얼은 제출자 정보, 실습 환경 구성 안내, 폐쇄망 반입 방식, 기술 선택 설명, 원본 매뉴얼 본문을 하나로 묶는다.
- 서버 설정 ZIP은 Kubernetes/DB/모니터링 구축에 사용한 manifest, dashboard JSON, 설정, 스크립트만 포함한다.
- Terraform 코드, 대용량 다운로드 결과물, 개인키, `.env`, kubeconfig, state 파일은 제외한다.
