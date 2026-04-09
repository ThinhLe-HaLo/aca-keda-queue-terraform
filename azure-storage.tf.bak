resource "azurerm_storage_account" "azure_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.aca-resource-group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_queue" "queue" {
  name                 = var.queue_storage_name
 //storage_account_name = azurerm_storage_account.azure_storage.name
  storage_account_id   = azurerm_storage_account.azure_storage.id
}

resource "azurerm_role_assignment" "queue_reader" {
  scope                = azurerm_storage_account.azure_storage.id
  # Role này cho phép đọc, thêm, xóa message trong queue
  role_definition_name = "Storage Queue Data Reader" 
  principal_id         = azurerm_container_app.hello-world-aca.identity[0].principal_id
}