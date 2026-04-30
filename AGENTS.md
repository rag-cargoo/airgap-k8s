# AGENTS.md (airgap-k8s)

## Scope
- 이 프로젝트는 `서버 구축 테스트` 과제 대응용 독립 레포다.
- 목표: 과제 원문을 기준으로 폐쇄망 Kubernetes, DB, 모니터링, 제출물을 단계적으로 정리한다.
- 이 문서는 이 프로젝트에서 에이전트가 가장 먼저 따라야 하는 기본 진입점이다.

## Load Order
1. `./ASSIGNMENT.md`
2. `./README.md`
3. `prj-docs/projects/airgap-k8s/rules/aws-airgap-simulation-baseline.md`
4. `prj-docs/projects/airgap-k8s/task.md`
5. `prj-docs/projects/airgap-k8s/meeting-notes/README.md`
6. 최신 `prj-docs/projects/airgap-k8s/meeting-notes/*.md`
7. `prj-docs/projects/airgap-k8s/PROJECT_AGENT.md`

## Session Start
1. `git status --short`
2. `git branch --show-current`
3. `cat ./ASSIGNMENT.md`
4. `cat ./README.md`
5. `cat prj-docs/projects/airgap-k8s/rules/aws-airgap-simulation-baseline.md`
6. `cat prj-docs/projects/airgap-k8s/task.md`
7. 필요 시 `cat prj-docs/projects/airgap-k8s/PROJECT_AGENT.md`

## Development Rules
1. 과제 해석, 작업 순서, 방식 결정은 먼저 `meeting-notes/*.md`에 기록한다.
2. 실제 작업 시작 전까지 `task.md`는 과제 원문 체크리스트 중심으로 유지한다.
3. 실제 설정 파일/매니페스트는 필요해질 때만 추가한다.
4. 아직 직접 검증하지 않은 내용은 `planned`, `reference`, `unverified`로 표시한다.
5. `prj-docs/projects/airgap-k8s/PROJECT_AGENT.md`는 sidecar/session-reload 호환 규칙용으로만 유지한다.
6. AWS에서 작업하더라도 `prj-docs/projects/airgap-k8s/rules/aws-airgap-simulation-baseline.md`를 절대 기준으로 따른다.

## Document Index
- Project Intro: `./README.md`
- Assignment Source: `./ASSIGNMENT.md`
- AWS Air-Gap Baseline: `prj-docs/projects/airgap-k8s/rules/aws-airgap-simulation-baseline.md`
- Manual/Task Governance: `prj-docs/projects/airgap-k8s/rules/manual-task-governance.md`
- Submission Manual Overview: `./manual/00-제출-매뉴얼-개요/README.md`
- Submission Manual Directory: `./manual/`
- Assignment-Aligned Manual Chapters: `./manual/01-인터넷-불가능-네트워크-환경-및-리눅스-기본-구성/` ... `./manual/06-제출/`
- Root Makefile: `./Makefile`
- Terraform Code: `./ops/01-airgap-linux-environment/aws-terraform-simulation/`
- Task Board: `prj-docs/projects/airgap-k8s/task.md`
- Meeting Notes: `prj-docs/projects/airgap-k8s/meeting-notes/README.md`
- Sidecar Compat Rules: `prj-docs/projects/airgap-k8s/PROJECT_AGENT.md`
