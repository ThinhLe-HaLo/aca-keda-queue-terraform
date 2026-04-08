resource "azurerm_resource_group" "aca-resource-group" {
    name     = var.resource_group_name
    location = var.location
}