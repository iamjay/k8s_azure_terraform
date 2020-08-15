resource "azurerm_virtual_network" "k8s_net" {
  name = "k8s_net"
  location = azurerm_resource_group.k8s_cluster.location
  resource_group_name = azurerm_resource_group.k8s_cluster.name

  address_space = [ var.network_address_space ]
  subnet {
    name = "internal"
    address_prefix = var.pod_subnet
    security_group = azurerm_network_security_group.net_sg_k8s.id
  }
}

resource "azurerm_network_security_group" "net_sg_master" {
  name = "net_sg_master"
  location = azurerm_resource_group.k8s_cluster.location
  resource_group_name = azurerm_resource_group.k8s_cluster.name

  security_rule {
    name = "allow_ssh"
    protocol = "tcp"
    source_address_prefix = "*"
    source_port_range = "*"
    destination_address_prefix = "*"
    destination_port_range = "22"
    access = "Allow"
    priority = 100
    direction = "Inbound"
  }

  security_rule {
    name = "allow_k8s"
    protocol = "tcp"
    source_address_prefix = "*"
    source_port_range = "*"
    destination_address_prefix = "*"
    destination_port_range = "6443"
    access = "Allow"
    priority = 200
    direction = "Inbound"
  }
}

resource "azurerm_network_security_group" "net_sg_k8s" {
  name = "net_sg_k8s"
  location = azurerm_resource_group.k8s_cluster.location
  resource_group_name = azurerm_resource_group.k8s_cluster.name
}
