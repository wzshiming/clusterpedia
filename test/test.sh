#!/usr/bin/env bash

function build_image() {
    VERSION=test REGISTRY=localtest make images
}

function create_cluster() {
    kind create cluster
    kind load docker-image localtest/clustersynchro-manager-amd64:test
    kind load docker-image localtest/apiserver-amd64:test
    kind load docker-image docker.io/bitnami/postgresql:11.15.0-debian-10-r14
}

function install_clusterpedia() {
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm dependency build
    helm install clusterpedia ./charts \
        --namespace clusterpedia-system \
        --create-namespace \
        --set persistenceMatchNode=None \
        --set installCRDs=true \
        --set clustersynchroManager.image.registry=localtest \
        --set clustersynchroManager.image.repository=clustersynchro-manager-amd64 \
        --set clustersynchroManager.image.tag=test \
        --set apiserver.image.registry=localtest \
        --set apiserver.image.repository=apiserver-amd64 \
        --set apiserver.image.tag=test
}

function import_cluster() {
    local name="${1}"
    local kubeconfig="${2}"
    kubeconfig="$(echo "${kubeconfig}" | base64 | tr -d "\n")"
    cat <<EOF
apiVersion: cluster.clusterpedia.io/v1alpha2
kind: PediaCluster
metadata:
  name: ${name}
spec:
  kubeconfig: "${kubeconfig}"
  syncResources:
  - group: ""
    resources:
     - namespaces
     - pods
EOF
}

HOST_IP=""
function host_docker_internal() {
    if [[ "${HOST_IP}" == "" ]]; then
        # Need Docker 18.03
        HOST_IP=$(docker run --rm docker.io/library/alpine sh -c "nslookup host.docker.internal | grep 'Address' | grep -v '#' | grep -v ':53' | awk '{print \$2}' | head -n 1")

        if [[ "${HOST_IP}" == "" ]]; then
            # For Docker running on Linux used 172.17.0.1 which is the Docker-host in Docker’s default-network.
            HOST_IP="172.17.0.1"
        fi
    fi
    echo "${HOST_IP}"
}


TMPDIR="${TMPDIR:-/tmp/}"
function fake_k8s() {
    if [[ ! -f fake-k8s.sh ]]; then
        wget https://github.com/wzshiming/fake-k8s/raw/v0.1.0/fake-k8s.sh -O "${TMPDIR}/fake-k8s.sh"
    fi
    KUBE_IMAGE_PREFIX=registry.aliyuncs.com/google_containers bash "${TMPDIR}/fake-k8s.sh" "${@}"
}

function main() {
    local context=default
    local kubeconfig

    build_image
    create_cluster
    install_clusterpedia

    fake_k8s create --name "${context}"

    kubeconfig="$(kubectl --context="fake-k8s-${context}" config view --minify --raw | sed "s/127.0.0.1:/$(host_docker_internal):/")"

    import_cluster "${context}" "${kubeconfig}" | kubectl apply -f -

    kubectl get pediacluster
    kubectl --cluster default api-resources
}

main "${*}"
