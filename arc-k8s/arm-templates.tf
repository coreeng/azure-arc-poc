resource "azurerm_template_deployment" "deployment_template_core_platform_edge" {
  name                = "deployment_template_core_platform_edge_d001"
  resource_group_name = data.azurerm_resource_group.existing.name

  template_body = file("arm-templates/aks.json")

  parameters_body = file("arm-templates/parameters.json")

  deployment_mode = "Incremental"
}
