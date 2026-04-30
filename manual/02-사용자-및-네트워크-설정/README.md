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

설명: `02-01` 세부 스크립트와 검증 타깃은 `ops/02-user-network/Makefile` 기준으로 확인한다.

## 02-01.2. 사용자 및 네트워크 설정 스크립트 업로드
```bash
scp -i "${AIRGAP_SSH_KEY_PATH}" \
  ops/02-user-network/scripts/configure-node-user-network.sh \
  "${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}:/tmp/configure-node-user-network.sh"

scp -i "${AIRGAP_SSH_KEY_PATH}" \
  ops/02-user-network/scripts/verify-node-user-network.sh \
  "${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}:/tmp/verify-node-user-network.sh"
```

설명: bastion 또는 관리용 경유지에 사용자/hostname/hosts 설정 스크립트를 업로드한다.

## 02-01.3. master 노드에 스크립트 전달
```bash
scp -i "${AIRGAP_SSH_KEY_PATH}" \
  -o ProxyCommand="ssh -i ${AIRGAP_SSH_KEY_PATH} -W %h:%p ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" \
  ops/02-user-network/scripts/configure-node-user-network.sh \
  ops/02-user-network/scripts/verify-node-user-network.sh \
  "${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}:/tmp/"
```

설명: master 노드에서 바로 실행할 수 있게 `/tmp`로 스크립트를 전달한다.

## 02-01.4. worker 노드에 스크립트 전달
```bash
scp -i "${AIRGAP_SSH_KEY_PATH}" \
  -o ProxyCommand="ssh -i ${AIRGAP_SSH_KEY_PATH} -W %h:%p ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" \
  ops/02-user-network/scripts/configure-node-user-network.sh \
  ops/02-user-network/scripts/verify-node-user-network.sh \
  "${AIRGAP_SSH_USER}@${AIRGAP_WORKER1_PRIVATE_IP}:/tmp/"
```

설명: worker 노드에서 바로 실행할 수 있게 `/tmp`로 스크립트를 전달한다.

## 02-01.5. master 노드에서 사용자 및 네트워크 설정 실행
```bash
ssh -i "${AIRGAP_SSH_KEY_PATH}" \
  -o ProxyCommand="ssh -i ${AIRGAP_SSH_KEY_PATH} -W %h:%p ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" \
  "${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}"

chmod +x /tmp/configure-node-user-network.sh /tmp/verify-node-user-network.sh

sudo /tmp/configure-node-user-network.sh \
  --hostname k8s-master \
  --self-ip "${AIRGAP_MASTER_PRIVATE_IP}" \
  --self-name k8s-master \
  --peer-ip "${AIRGAP_WORKER1_PRIVATE_IP}" \
  --peer-name k8s-worker1

sudo /tmp/verify-node-user-network.sh \
  --expected-hostname k8s-master \
  --self-ip "${AIRGAP_MASTER_PRIVATE_IP}" \
  --self-name k8s-master \
  --peer-ip "${AIRGAP_WORKER1_PRIVATE_IP}" \
  --peer-name k8s-worker1
```

설명: `devops` 사용자 생성, sudo 권한 부여, hostname 설정, `/etc/hosts` 등록을 master 노드에 적용하고 바로 검증한다.

## 02-01.6. worker 노드에서 사용자 및 네트워크 설정 실행
```bash
ssh -i "${AIRGAP_SSH_KEY_PATH}" \
  -o ProxyCommand="ssh -i ${AIRGAP_SSH_KEY_PATH} -W %h:%p ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" \
  "${AIRGAP_SSH_USER}@${AIRGAP_WORKER1_PRIVATE_IP}"

chmod +x /tmp/configure-node-user-network.sh /tmp/verify-node-user-network.sh

sudo /tmp/configure-node-user-network.sh \
  --hostname k8s-worker1 \
  --self-ip "${AIRGAP_WORKER1_PRIVATE_IP}" \
  --self-name k8s-worker1 \
  --peer-ip "${AIRGAP_MASTER_PRIVATE_IP}" \
  --peer-name k8s-master

sudo /tmp/verify-node-user-network.sh \
  --expected-hostname k8s-worker1 \
  --self-ip "${AIRGAP_WORKER1_PRIVATE_IP}" \
  --self-name k8s-worker1 \
  --peer-ip "${AIRGAP_MASTER_PRIVATE_IP}" \
  --peer-name k8s-master
```

설명: worker 노드에도 같은 항목을 적용하고 바로 검증한다.

## 02-01.7. 검증 기준
```text
[OK]   통과
[WARN] 수동 확인 필요
[FAIL] 수정 필요
```

설명: 두 노드 모두 `devops`, hostname, `/etc/hosts` 검증이 `FAIL` 없이 끝나야 다음 장으로 진행한다.
