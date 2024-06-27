# main.tf

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "existing" {
  name = "core-platform-edge-rg"
}

locals {
  custom_location_id = "/subscriptions/96f2411d-f661-4f6d-8e6c-69c3c3f2ac0f/resourceGroups/core-platform-edge-rg/providers/Microsoft.ExtendedLocation/customLocations/jumpstart"
  custom_location    = "West Europe"
}

#resource "azurerm_arc_kubernetes_cluster" "demo002" {
#  agent_public_key_certificate = filebase64("/Users/soumantrivedi/.ssh/aks-demo001.pub")
#  location                     = "westeurope"
#  name                         = "demo002"
#  resource_group_name          = data.azurerm_resource_group.existing.name
#
#  identity {
#    type = "SystemAssigned"
#  }
#
#  tags = {
#    ENV = "Test"
#  }
#}



# Output the AKS cluster kubeconfig
#output "agent_cert" {
#  value     = azurerm_arc_kubernetes_cluster.demo002.agent_public_key_certificate
#  sensitive = true
#}
