# 03-02-10. 트러블슈팅

## 03-05.1. 진행 상태가 30분 이상 멈춘 것처럼 보일 때
```bash
cd <프로젝트-루트>/ops/03-kubernetes-cluster
make 03-02-manual-kubeadm-troubleshoot
```

설명: `03-02-manual-kubeadm-run`은 `offline-assets.tar.gz` 전송, RPM 설치, 이미지 import, `kubeadm init`, Calico rollout, worker join을 순서대로 수행한다. 오래 걸리면 먼저 진단 타깃으로 현재 위치를 확인한다.

## 03-05.2. 대용량 자산 전송 지연
증상:
```text
[STEP] Stage offline-assets archive on bastion
```

원인:
```text
delivery/offline-assets.tar.gz 크기가 크고, plain scp는 진행률과 재개 처리가 약하다.
문제 발생 당시 번들은 약 677M였고, 누락 Calico 이미지 보강 후 현재 번들은 약 778M다.
```

조치:
```bash
rsync -a --partial --inplace --info=progress2 \
  -e "ssh -p ${AIRGAP_SSH_PORT} -i ${AIRGAP_SSH_KEY_PATH}" \
  delivery/offline-assets.tar.gz \
  ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}:/home/${AIRGAP_SSH_USER}/airgap-transfer/offline-assets.tar.gz
```

설명: 실제 실행 스크립트는 bastion staging 경로를 `/home/ec2-user/airgap-transfer`로 두고, `rsync --partial --inplace`로 재시도 가능한 전송을 수행한다.

## 03-05.3. bastion `/tmp` 용량 부족 또는 전송 정체
확인:
```bash
ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" \
  "${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" \
  "df -h / /tmp /home/${AIRGAP_SSH_USER}/airgap-transfer 2>/dev/null || df -h / /tmp"
```

조치:
```bash
ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" \
  "${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" \
  "rm -f /tmp/offline-assets.tar.gz /tmp/airgap-offline-transfer-key.pem"
```

설명: 이번 검증에서는 `/tmp/offline-assets.tar.gz`가 약 `583M`에서 멈춘 이력이 있었다. 이후 staging 경로를 `/home/ec2-user/airgap-transfer`로 변경했다.

## 03-05.4. Amazon Linux repo 패키지 충돌
증상:
```text
package amazon-linux-repo-s3 conflicts with amazon-linux-repo-cdn
```

원인:
```text
노드에는 amazon-linux-repo-s3가 이미 설치돼 있는데, 오프라인 자산 목록에 amazon-linux-repo-cdn RPM이 같이 포함돼 있었다.
```

조치:
```bash
find /opt/offline-assets/kubernetes/packages/container-runtime \
  -maxdepth 1 -type f -name "*.rpm" ! -name "amazon-linux-repo-cdn-*" | sort
```

설명: 실행 스크립트는 `amazon-linux-repo-cdn-*` RPM을 설치 입력에서 제외하고, 이미 설치된 `containerd`, `runc`, `kubeadm`, `kubelet`, `kubectl`, `kubernetes-cni`, `cri-tools`가 있으면 해당 설치를 건너뛴다.

## 03-05.5. dnf release metadata timeout
증상:
```text
Unable to retrieve release info data
Connection timed out after 30000 milliseconds
```

원인:
```text
폐쇄망 노드에서 Amazon Linux release metadata를 외부 S3에서 확인하려고 시도했다.
```

판정:
```text
RPM 설치가 완료되고 다음 단계로 넘어가면 경고성 지연으로 본다.
```

설명: 현재 스크립트는 `--disablerepo="*"`로 로컬 RPM만 설치한다. 다만 Amazon Linux의 release update 확인 때문에 30초 timeout 메시지가 출력될 수 있다.

## 03-05.6. Calico CRD annotation size 초과
증상:
```text
The CustomResourceDefinition "installations.operator.tigera.io" is invalid:
metadata.annotations: Too long: may not be more than 262144 bytes
```

원인:
```text
client-side kubectl apply가 큰 CRD 전체를 last-applied annotation에 저장하려고 했다.
```

조치:
```bash
sudo KUBECONFIG=/etc/kubernetes/admin.conf \
  kubectl apply --server-side=true --force-conflicts \
  -f /opt/offline-assets/kubernetes/manifests/operator-crds.yaml
```

설명: 실행 스크립트는 Calico CRD에 server-side apply를 사용한다. `tigera-operator.yaml`과 `custom-resources.yaml`은 일반 apply로 적용한다.

## 03-05.7. 부분 성공 후 재실행
확인:
```bash
ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" \
  -o "ProxyCommand=ssh -i ${AIRGAP_SSH_KEY_PATH} -p ${AIRGAP_SSH_PORT} -W %h:%p ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" \
  "${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}" \
  "sudo test -f /etc/kubernetes/admin.conf && echo initialized || echo pending"
```

설명: `/etc/kubernetes/admin.conf`가 있으면 `kubeadm init`은 이미 완료된 상태다. 실행 스크립트는 이 파일이 있으면 `kubeadm init`을 건너뛰고 Calico 적용과 worker join 이후 검증을 계속한다.

## 03-05.8. Calico 이미지 누락
증상:
```text
calico-system csi-node-driver ImagePullBackOff
calico-system goldmane ImagePullBackOff
calico-system whisker ErrImagePull
```

원인:
```text
Calico custom-resources.yaml이 Goldmane, Whisker, CSI 관련 Pod를 생성하지만 오프라인 이미지 목록에 해당 이미지가 빠져 있었다.
```

추가 이미지:
```text
quay.io/calico/csi:v3.31.4
quay.io/calico/node-driver-registrar:v3.31.4
quay.io/calico/goldmane:v3.31.4
quay.io/calico/whisker:v3.31.4
quay.io/calico/whisker-backend:v3.31.4
```

조치:
```bash
cd <프로젝트-루트>
make 01-03-offline-assets-run
cd ops/03-kubernetes-cluster
make 03-02-manual-kubeadm-run
make 03-02-manual-kubeadm-verify
```

설명: 다운로드 스크립트는 위 5개 이미지를 포함하도록 보정했다. 이미 클러스터가 구성된 상태라면 누락 이미지를 각 노드의 containerd에 import한 뒤 `03-02-manual-kubeadm-verify`로 `ImagePullBackOff`가 없는지 확인한다.

## 03-05.9. 최종 검증
```bash
cd <프로젝트-루트>/ops/03-kubernetes-cluster
make 03-02-manual-kubeadm-verify
```

성공 기준:
```text
[RESULT] SUCCESS
k8s-master Ready
k8s-worker1 Ready
Calico components reached rollout success
no image pull failures detected
```
