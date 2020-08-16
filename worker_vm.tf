module "workers" {
  count = 3

  source = "./k8s_node"

  name = "worker${count.index}"
  location = azurerm_resource_group.k8s_cluster.location
  resource_group_name = azurerm_resource_group.k8s_cluster.name
  availability_set_id = azurerm_availability_set.k8s_as.id

  node_size = var.worker_size
  subnet_id = (azurerm_virtual_network.k8s_net.subnet[*].id)[0]

  custom_data = base64encode(<<EOF
${file("${path.module}/cloud-init.txt")}
  - kubeadm join 10.0.0.4:6443 --token ${var.join_token} --discovery-token-unsafe-skip-ca-verification

write_files:
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
EOF
  )

  depends_on = [ module.master1.vm_id ]
}

resource "azurerm_role_assignment" "workers_role" {
  count = length(module.workers)

  scope = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.k8s_cluster.name}"
  role_definition_name = "Reader"
  principal_id = module.workers[count.index].vm_principal_id
}
