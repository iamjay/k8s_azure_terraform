resource "azurerm_public_ip" "master1_public_ip" {
  name = "master1_public_ip"
  location = azurerm_resource_group.k8s_cluster.location
  resource_group_name = azurerm_resource_group.k8s_cluster.name
  allocation_method = "Dynamic"
}

locals {
  cloud_conf = <<EOF
{
    "cloud":"AzurePublicCloud",
    "tenantId": "${data.azurerm_subscription.current.tenant_id}",
    "subscriptionId": "${data.azurerm_subscription.current.subscription_id}",
    "resourceGroup": "${azurerm_resource_group.k8s_cluster.name}",
    "location": "${azurerm_resource_group.k8s_cluster.location}",
    "subnetName": "internal",
    "securityGroupName": "net_sg_k8s",
    "vnetName": "k8s_net",
    "vnetResourceGroup": "${azurerm_resource_group.k8s_cluster.name}",
    "routeTableName": "k8s_route",
    "cloudProviderBackoff": false,
    "useManagedIdentityExtension": true,
    "useInstanceMetadata": true
}
EOF

  kubeadm_yaml = <<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: ${var.join_token}
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: "azure"
    cloud-config: "/etc/kubernetes/cloud.conf"
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
apiServer:
  extraArgs:
    cloud-provider: "azure"
    cloud-config: "/etc/kubernetes/cloud.conf"
  extraVolumes:
  - name: cloud
    hostPath: "/etc/kubernetes/cloud.conf"
    mountPath: "/etc/kubernetes/cloud.conf"
controllerManager:
  extraArgs:
    cloud-provider: "azure"
    cloud-config: "/etc/kubernetes/cloud.conf"
  extraVolumes:
  - name: cloud
    hostPath: "/etc/kubernetes/cloud.conf"
    mountPath: "/etc/kubernetes/cloud.conf"
EOF
}

module "master1" {
  source = "./k8s_node"

  name = "master1"
  location = azurerm_resource_group.k8s_cluster.location
  resource_group_name = azurerm_resource_group.k8s_cluster.name
  availability_set_id = azurerm_availability_set.k8s_as.id

  node_size = var.master_size
  private_ip_address = var.master_node_ip
  public_ip_address_id = azurerm_public_ip.master1_public_ip.id
  subnet_id = (azurerm_virtual_network.k8s_net.subnet[*].id)[0]

  custom_data = base64encode(<<EOF
${file("${path.module}/cloud-init.txt")}
  - kubeadm init --config /etc/kubernetes/kubeadm.yaml --ignore-preflight-errors=NumCPU

write_files:
  - path: /etc/kubernetes/kubeadm.yaml
    encoding: base64
    content: ${base64encode(local.kubeadm_yaml)}
  - path: /etc/kubernetes/cloud.conf
    encoding: base64
    content: ${base64encode(local.cloud_conf)}
  - path: /etc/docker/daemon.json
    content: |
      {
        "exec-opts": ["native.cgroupdriver=systemd"],
        "log-driver": "json-file",
        "log-opts": {
          "max-size": "100m"
        },
        "storage-driver": "overlay2"
      }
  - path: /etc/systemd/system/docker.service.d/.empty
  - path: /etc/cloud/cloud.cfg.d/99-azure.cfg
    content: |
      datasource:
        Azure:
          apply_network_config: false
  - path: /etc/kubernetes/pki/ca.crt
    encoding: base64
    content: ${filebase64("${path.module}/pki/ca.crt")}
  - path: /etc/kubernetes/pki/ca.key
    permissions: "0600"
    encoding: base64
    content: ${filebase64("${path.module}/pki/ca.key")}
  - path: /etc/kubernetes/pki/etcd/etcd.crt
    encoding: base64
    content: ${filebase64("${path.module}/pki/etcd/etcd.crt")}
  - path: /etc/kubernetes/pki/etcd/etcd.key
    permissions: "0600"
    encoding: base64
    content: ${filebase64("${path.module}/pki/etcd/etcd.key")}
  - path: /etc/kubernetes/pki/front-proxy-ca.crt
    encoding: base64
    content: ${filebase64("${path.module}/pki/front-proxy-ca.crt")}
  - path: /etc/kubernetes/pki/front-proxy-ca.key
    permissions: "0600"
    encoding: base64
    content: ${filebase64("${path.module}/pki/front-proxy-ca.key")}
  - path: /etc/kubernetes/pki/sa.key
    permissions: "0600"
    encoding: base64
    content: ${filebase64("${path.module}/pki/sa.key")}
  - path: /etc/kubernetes/pki/sa.pub
    encoding: base64
    content: ${filebase64("${path.module}/pki/sa.pub")}
EOF
  )
}

resource "azurerm_role_assignment" "master1_role" {
  scope = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.k8s_cluster.name}"
  role_definition_name = "Contributor"
  principal_id = module.master1.vm_principal_id
}
