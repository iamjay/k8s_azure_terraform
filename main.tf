provider "azurerm" {
  version = "=2.22.0"
  features {}
}

resource "azurerm_resource_group" "k8s_cluster" {
  name = var.resource_group
  location = var.location
}

terraform {
  backend "local" {
  }
}

data "azurerm_subscription" "current" {
}

resource "azurerm_availability_set" "k8s_as" {
  name = "k8s_as"
  location = azurerm_resource_group.k8s_cluster.location
  resource_group_name = azurerm_resource_group.k8s_cluster.name
}
