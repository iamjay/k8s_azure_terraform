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
