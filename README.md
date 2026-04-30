# 서버 구축 테스트

## 프로젝트 소개
- 이 레포는 `서버 구축 테스트` 과제 수행용 작업 공간이다.
- 폐쇄망 Kubernetes 구축 절차, 과제 해석, 작업 기록, 제출용 설정 파일을 정리하는 것을 목적으로 한다.
- 실습 환경은 `AWS 기반 air-gap simulation`을 기본으로 하되, 실제 설치 절차는 `온프레미스 폐쇄망과 동일한 오프라인 기준`을 따른다.

## 문서 안내
- 프로젝트용 에이전트 진입점: `./AGENTS.md`
- 과제 원문 기준 파일: `./ASSIGNMENT.md`
- 핵심 실습 기준: `prj-docs/projects/airgap-k8s/rules/aws-airgap-simulation-baseline.md`
- 문서/태스크 운영 기준: `prj-docs/projects/airgap-k8s/rules/manual-task-governance.md`
- 제출용 공통 개요: `./manual/00-제출-매뉴얼-개요/README.md`
- 제출용 매뉴얼 디렉터리: `./manual/`
- 현재 매뉴얼은 ClickUp 과제문 작업 순서 기준으로 `./manual/01-인터넷-불가능-네트워크-환경-및-리눅스-기본-구성/`부터 `./manual/06-제출/`까지 정렬돼 있다.
- 루트 실행 진입점: `./Makefile`
- Terraform 코드 경로: `./ops/01-airgap-linux-environment/aws-terraform-simulation/`
- 작업 체크리스트: `prj-docs/projects/airgap-k8s/task.md`
- 회의록: `prj-docs/projects/airgap-k8s/meeting-notes/`
