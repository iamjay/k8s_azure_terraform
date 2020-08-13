variable "resource_group" {
  type = string
  default = "k8s_cluster"
}

variable "location" {
  type = string
  default = "westus2"
}

variable "master_size" {
  type = string
  default = "Standard_B1ms"
}

variable "worker_size" {
  type = string
  default = "Standard_B1s"
}

variable "join_token" {
  type = string
  default = "vzdl11.imyylrrz2xwcn44t"
}

variable "network_address_space" {
  type = string
  default = "10.0.0.0/16"
}

variable "pod_subnet" {
  type = string
  default = "10.0.0.0/24"
}

variable "master_node_ip" {
  type = string
  default = "10.0.0.4"
}
