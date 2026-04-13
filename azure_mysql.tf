resource "azurerm_mysql_flexible_server" "mysql" {
    name = var.sql_server_name
    resource_group_name = azurerm_resource_group.aca-resource-group.name
    location = var.location
    administrator_login = var.sql_userlogin
    administrator_password = var.sql_password
    sku_name = "B_Standard_B1ms"
    version = "8.0.21"
    zone = "1"
    storage {
        size_gb = 20
    }
    identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mysql_identity.id]
  }
}

resource "azurerm_user_assigned_identity" "mysql_identity" {
  name                = "mysql-managed-identity"
  location            = var.location
  resource_group_name = azurerm_resource_group.aca-resource-group.name
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure_services" {
    name = "allow-azure-services"
    resource_group_name = azurerm_resource_group.aca-resource-group.name
    server_name = azurerm_mysql_flexible_server.mysql.name
    start_ip_address    = "0.0.0.0"  # Special range for Azure services
    end_ip_address      = "0.0.0.0"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_vm" {
    name = "allow-local_vm"
    resource_group_name = azurerm_resource_group.aca-resource-group.name
    server_name = azurerm_mysql_flexible_server.mysql.name
    start_ip_address    = "0.0.0.0"  # Special range for local_vm
    end_ip_address      = "255.255.255.255"
}

resource "azurerm_mysql_flexible_database" "mysql_db" {
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
  name                = var.database_name
  resource_group_name = azurerm_resource_group.aca-resource-group.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
}

resource "azurerm_mysql_flexible_server_configuration" "disable_ssl" {
  name                = "require_secure_transport"
  resource_group_name = azurerm_resource_group.aca-resource-group.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  value               = "OFF"
}