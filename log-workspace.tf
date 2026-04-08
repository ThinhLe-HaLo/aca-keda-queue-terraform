resource "azurerm_log_analytics_workspace" "aca-log-analytics-workspace" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.aca-resource-group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}