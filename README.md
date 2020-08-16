# Configure kubectl
```
$ kubectl config set users.admin.client-key-data `base64 -w0 pki/admin.key`
$ kubectl config set users.admin.client-certificate-data `base64 -w0 pki/admin.crt`

$ kubectl config set clusters.k8s.insecure-skip-tls-verify true
$ kubectl config set clusters.k8s.server https://<ip>:6443

$ kubectl config set contexts.k8s.cluster k8s
$ kubectl config set contexts.k8s.user admin
```

# Create a user certificate request and sign it
```
$ openssl genrsa -out jay.key 2048
$ openssl req -new -key jay.key -out jay.csr -subj /CN=jay
$ openssl x509 -req -in jay.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out jay.crt

$ kubectl create namespace ns-jay
$ kubectl create rolebinding jay-admin-binding --clusterrole=admin --user=jay --namespace=ns-jay

$ kubectl config set users.jay@k8s.client-certificate-data `base64 -w0 pki/jay.crt`
$ kubectl config set users.jay@k8s.client-key-data `base64 -w0 pki/jay.key`
$ kubectl config set contexts.jay@k8s.cluster k8s
$ kubectl config set contexts.jay@k8s.user jay@k8s
$ kubectl config set contexts.jay@k8s.namespace ns-jay
$ kubectl config use-context jay@k8s
```
