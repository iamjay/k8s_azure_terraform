module "worker1" {
  count = 2

  source = "./k8s_node"

  name = "worker${count.index}"
  location = azurerm_resource_group.k8s_cluster.location
  resource_group_name = azurerm_resource_group.k8s_cluster.name

  node_size = var.worker_size
  subnet_id = (azurerm_virtual_network.k8s_net.subnet[*].id)[0]
  security_group_id = azurerm_network_security_group.net_sg_worker.id

  custom_data = base64encode(<<EOF
${file("${path.module}/cloud-init.txt")}
  - kubeadm join 10.0.0.4:6443 --token ${var.join_token} --discovery-token-unsafe-skip-ca-verification
EOF
  )

  depends_on = [ module.master1.vm_id ]
}
