output "vm_id" {
  value = azurerm_linux_virtual_machine.worker1.id
}

output "vm_principal_id" {
  value = azurerm_linux_virtual_machine.worker1.identity[0].principal_id
}

output "vm_nic_id" {
  value = azurerm_network_interface.worker1_nic.id
}
