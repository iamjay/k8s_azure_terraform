#!/bin/bash

DIR=$(dirname $0)

mkdir -p ${DIR}/pki
pushd ${DIR}/pki

mkdir -p etcd

if ! [ -f ca.key ]; then
    openssl genrsa -out ca.key 2048
    openssl req -new -x509 -key ca.key -out ca.crt -subj /O=k8s/CN=kubernetes-ca

    openssl genrsa -out etcd/etcd.key 2048
    openssl req -new -x509 -key etcd/etcd.key -out etcd/etcd.crt -subj /O=k8s/CN=etcd-ca

    openssl genrsa -out front-proxy-ca.key 2048
    openssl req -new -x509 -key front-proxy-ca.key -out front-proxy-ca.crt -subj /O=k8s/CN=kubernetes-front-proxy-ca

    openssl genrsa -out sa.key 2048
    openssl rsa -in sa.key -pubout -out sa.pub

    openssl genrsa -out admin.key 2048
    openssl req -new -key admin.key -out admin.csr -subj /O=system:masters/CN=kubernetes-admin
    openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out admin.crt
fi

if ! [ -f node.key ]; then
    openssl genrsa -out node.key 2048
    ssh-keygen -f node.key -y > node.pub
fi

popd
