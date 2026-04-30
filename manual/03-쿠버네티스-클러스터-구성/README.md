# 03. 쿠버네티스 클러스터 구성

## 03-01.1. 환경변수 로드
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
```

설명: bastion, master, worker 접속에 필요한 환경변수를 현재 셸에 로드한다.

```bash
cd ops/03-kubernetes-cluster
make help
```

설명: `03-01` 세부 스크립트와 검증 타깃은 `ops/03-kubernetes-cluster/Makefile` 기준으로 확인한다.

## 03-01.2. bastion 접속 확인
```bash
ssh -i "${AIRGAP_SSH_KEY_PATH}" "${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}"
```

설명: bastion을 통해 private 노드로 이동할 수 있는지 먼저 확인한다.

## 03-01.3. 설치용 자산 반입
```bash
scp -i "${AIRGAP_SSH_KEY_PATH}" \
  delivery/offline-assets.tar.gz \
  "${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}:/tmp/offline-assets.tar.gz"
```

설명: 서버 반입용 압축본을 bastion에 업로드한다.

## 03-01.4. master 노드에 설치용 자산 배치
```bash
ssh -i "${AIRGAP_SSH_KEY_PATH}" \
  -o ProxyCommand="ssh -i ${AIRGAP_SSH_KEY_PATH} -W %h:%p ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" \
  "${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}"

sudo mkdir -p /opt
sudo tar -xzf /tmp/offline-assets.tar.gz -C /opt
```

설명: 설치 기준 경로 `/opt/offline-assets`를 master 노드에 준비한다.

## 03-01.5. worker 노드에 설치용 자산 배치
```bash
ssh -i "${AIRGAP_SSH_KEY_PATH}" \
  -o ProxyCommand="ssh -i ${AIRGAP_SSH_KEY_PATH} -W %h:%p ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" \
  "${AIRGAP_SSH_USER}@${AIRGAP_WORKER1_PRIVATE_IP}"

sudo mkdir -p /opt
sudo tar -xzf /tmp/offline-assets.tar.gz -C /opt
```

설명: worker 노드에도 같은 기준 경로 `/opt/offline-assets`를 준비한다.

## 03-01.6. kubeadm 설치 전 사전점검 스크립트 업로드
```bash
scp -i "${AIRGAP_SSH_KEY_PATH}" \
  -o ProxyCommand="ssh -i ${AIRGAP_SSH_KEY_PATH} -W %h:%p ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" \
  ops/03-kubernetes-cluster/scripts/kubeadm-preflight-check.sh \
  "${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}:/tmp/kubeadm-preflight-check.sh"

scp -i "${AIRGAP_SSH_KEY_PATH}" \
  -o ProxyCommand="ssh -i ${AIRGAP_SSH_KEY_PATH} -W %h:%p ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" \
  ops/03-kubernetes-cluster/scripts/kubeadm-preflight-check.sh \
  "${AIRGAP_SSH_USER}@${AIRGAP_WORKER1_PRIVATE_IP}:/tmp/kubeadm-preflight-check.sh"
```

설명: kubeadm 공식문서 기준 사전점검 스크립트를 두 노드에 업로드한다.

## 03-01.7. control-plane 노드 사전점검 실행
```bash
chmod +x /tmp/kubeadm-preflight-check.sh
/tmp/kubeadm-preflight-check.sh --role control-plane --peer "${AIRGAP_WORKER1_PRIVATE_IP}"
```

설명: control-plane 노드에서 OS, kernel, glibc, RAM, CPU, hostname, product_uuid, MAC, default route, 필수 포트, swap, peer 통신을 점검한다.

## 03-01.8. worker 노드 사전점검 실행
```bash
chmod +x /tmp/kubeadm-preflight-check.sh
/tmp/kubeadm-preflight-check.sh --role worker --peer "${AIRGAP_MASTER_PRIVATE_IP}"
```

설명: worker 노드에서 같은 항목을 점검한다.

## 03-01.9. 포트 확인 추가 검증
```bash
nc -zv -w 2 127.0.0.1 6443
nc -zv -w 2 127.0.0.1 10250
```

설명: kubeadm 공식문서 예시처럼 `nc`로 포트 상태를 추가 확인한다. 아직 kubeadm init 전이면 `connection refused`가 나와도 포트 점유 여부 확인 용도로 사용할 수 있다.

## 03-01.10. 사전점검 결과 확인
```text
[OK]   통과
[WARN] 수동 확인 필요
[FAIL] 설치 전 수정 필요
```

설명: `FAIL` 항목이 하나라도 있으면 containerd, kubeadm 설치 전에 먼저 수정한다.
