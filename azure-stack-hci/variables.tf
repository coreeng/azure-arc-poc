variable "resource_group_name" {
  default = "HCIJumpBoxResourceGroup"
}

variable "location" {
  default = "West US"
}

variable "vm_size" {
  default = "Standard_D2s_v3"
}

variable "admin_username" {
  default = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "hci_network" {
  default = "10.0.0.0/16"
}

variable "subnet" {
  default = "10.0.1.0/24"
}

variable "public_ip_name" {
  default = "HCIJumpBoxPublicIP"
}

variable "dns_label" {
  default = "hci-jumpbox"
}


variable "aks_cluster_name" {
  default = "MyAKSCluster"
}

variable "node_count" {
  default = 2
}

variable "node_size" {
  default = "Standard_DS2_v2"
}
