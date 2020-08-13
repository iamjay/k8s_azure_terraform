resource "azurerm_network_interface" "worker1_nic" {
  name = "${var.name}_nic"
  location = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name = "internal"
    primary = true
    subnet_id = var.subnet_id
    private_ip_address_allocation = "%{ if var.private_ip_address == null }Dynamic%{ else }Static%{ endif }"
    private_ip_address = var.private_ip_address
    public_ip_address_id = var.public_ip_address_id
  }

  dynamic "ip_configuration" {
    for_each = range(0, var.pod_ip_count)
    content {
      name = "pod${ip_configuration.value}"
      subnet_id = var.subnet_id
      private_ip_address_allocation = "Dynamic"
    }
  }
}

resource "azurerm_network_interface_security_group_association" "worker1_nic_sg" {
  network_interface_id = azurerm_network_interface.worker1_nic.id
  network_security_group_id = var.security_group_id
}

resource "azurerm_linux_virtual_machine" "worker1" {
  name = var.name
  location = var.location
  resource_group_name = var.resource_group_name

  custom_data = var.custom_data
  admin_username = "azureuser"
  admin_ssh_key {
    username = "azureuser"
    public_key = file("${path.module}/../pki/node.key.pub")
  }
  network_interface_ids = [
    azurerm_network_interface.worker1_nic.id,
  ]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  size = var.node_size
  source_image_reference {
    publisher = var.source_image.publisher
    offer = var.source_image.offer
    sku = var.source_image.sku
    version = var.source_image.version
  }
}