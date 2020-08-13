resource "azurerm_public_ip" "master1_public_ip" {
  name = "master1_public_ip"
  location = azurerm_resource_group.k8s_cluster.location
  resource_group_name = azurerm_resource_group.k8s_cluster.name
  allocation_method = "Dynamic"
}

module "master1" {
  source = "./k8s_node"

  name = "master1"
  location = azurerm_resource_group.k8s_cluster.location
  resource_group_name = azurerm_resource_group.k8s_cluster.name

  node_size = var.master_size
  private_ip_address = var.master_node_ip
  public_ip_address_id = azurerm_public_ip.master1_public_ip.id
  subnet_id = (azurerm_virtual_network.k8s_net.subnet[*].id)[0]
  security_group_id = azurerm_network_security_group.net_sg_master.id

  custom_data = base64encode(<<EOF
${file("${path.module}/cloud-init.txt")}
  - kubeadm init --token ${var.join_token} --ignore-preflight-errors=NumCPU
EOF
  )
}
