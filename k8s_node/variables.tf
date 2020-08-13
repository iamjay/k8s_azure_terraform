variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "private_ip_address" {
  type = string
  default = null
}

variable "public_ip_address_id"  {
  type = string
  default = null
}

variable "pod_ip_count" {
  type = number
  default = 10
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "node_size" {
  type = string
}

variable "source_image" {
  type = object({
    publisher = string
    offer = string
    sku = string
    version = string
  })
  default = {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16_04_0-lts-gen2"
    version = "16.04.202008070"
  }
}

variable "custom_data" {
  type = string
}
