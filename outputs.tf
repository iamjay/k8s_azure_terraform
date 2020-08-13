output "master_public_ip" {
  value = azurerm_public_ip.master1_public_ip.ip_address
}
