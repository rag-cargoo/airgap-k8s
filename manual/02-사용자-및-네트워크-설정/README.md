# 02. 사용자 및 네트워크 설정

## 02-01.1. 환경변수 로드
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
```

설명: SSH 키 경로, bastion IP, master IP, worker IP를 현재 셸에 로드한다.

```bash
cd ops/02-user-network
make help
```

설명: `02-01` 세부 실행/검증/초기화 타깃은 `ops/02-user-network/Makefile` 기준으로 확인한다.

## 02-01.2. 로컬 스크립트 준비 검증
```bash
make 02-01-user-network-scripts-verify
```

설명: 실제 노드 적용 전에 사용자/네트워크 설정 스크립트의 문법과 실행 스크립트 구성을 검증한다.

## 02-01.3. 실제 적용 실행
```bash
make 02-01-user-network-run
```

설명: master/worker에 스크립트를 전송하고, `configure-node-user-network.sh` 실행 후 `verify-node-user-network.sh`를 즉시 호출한다. 이 단계가 성공하면 `02-01-user-network-apply.done` 상태 마커를 기록한다.

## 02-01.4. 실제 적용 재검증
```bash
make 02-01-user-network-verify
```

설명: 이미 적용된 master/worker 상태를 다시 읽어 `devops`, sudo 그룹, hostname, `/etc/hosts` 결과를 재검증한다. `all-verify`도 이 verify target을 실제로 다시 실행한다.

## 02-01.5. 상태 초기화
```bash
make 02-01-user-network-clear
```

설명: `02-01` 실제 적용 상태 마커만 제거한다. 노드 설정 자체를 되돌리지는 않는다.

## 02-01.6. 검증 기준
```text
[OK]   통과
[WARN] 수동 확인 필요
[FAIL] 수정 필요
```

설명: `02-01-user-network-run` 또는 `02-01-user-network-verify` 마지막 결과가 `[RESULT] SUCCESS`여야 다음 장으로 진행한다.
