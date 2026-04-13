data "azurerm_resource_group" "rg" {
  name = azurerm_resource_group.aca-resource-group.name
}

# 1. Cấp quyền ở cấp độ RESOURCE GROUP trước
resource "azurerm_role_assignment" "tf_runner_rg_role" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Key Vault Administrator" # Cấp quyền cao nhất quản lý Secret/Key
  principal_id         = data.azurerm_client_config.current.object_id
}
# 2. Đợi 2 phút để Azure đồng bộ quyền này cho Resource Group
resource "time_sleep" "wait_for_rg_rbac" {
  depends_on      = [azurerm_role_assignment.tf_runner_rg_role]
  create_duration = "2m"
}

resource "azurerm_key_vault" "aca-keyvault" {
  name                        = "tl-keyvault-10041517" # Tên này phải là duy nhất trên toàn cầu
  location                    = var.location
  resource_group_name         = azurerm_resource_group.aca-resource-group.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  rbac_authorization_enabled   = true
}

resource "azurerm_role_assignment" "tf_runner_kv_role" {
  scope                = azurerm_key_vault.aca-keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "time_sleep" "wait_for_rbac" {
  depends_on      = [azurerm_role_assignment.tf_runner_kv_role]
  create_duration = "3m"
}

resource "azurerm_key_vault_secret" "mysql_password_secret" {
  name         = "mysql-db-password"
  value        = var.sql_password # Lấy từ biến bạn nhập thủ công
  key_vault_id = azurerm_key_vault.aca-keyvault.id
  depends_on   = [azurerm_role_assignment.tf_runner_kv_role]
}

resource "null_resource" "assign_kv_role_cli" {
  # Trigger để lệnh này chạy mỗi khi file chạy (hoặc tùy chỉnh điều kiện)
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "az role assignment create --role \"Key Vault Secrets Officer\" --assignee-object-id \"c85b8860-1e63-49e8-a95b-57931ed14082\" --assignee-principal-type \"User\" --scope \"/subscriptions/562667b3-e621-41af-a17b-bf1ad368bde2/resourceGroups/ACA-KEDA-RG/providers/Microsoft.KeyVault/vaults/tl-keyvault-10041517\""
  }
  # Đảm bảo Key Vault phải được tạo trước khi chạy lệnh CLI
  depends_on = [azurerm_key_vault.aca-keyvault]
}
/*
resource "time_sleep" "wait_for_rbac" {
  depends_on = [azurerm_role_assignment.aca_kv_role]
  create_duration = "3m"
}
*/
resource "azurerm_role_assignment" "aca_kv_role" {
  //depends_on = [time_sleep.wait_for_rbac]
  scope                = azurerm_key_vault.aca-keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_container_app.hello-world-aca.identity[0].principal_id
}

resource "azurerm_role_assignment" "mysql_role" {
  //depends_on = [time_sleep.wait_for_rbac]
  scope                = azurerm_key_vault.aca-keyvault.id
  role_definition_name = "Key Vault Administrator"
  # Chỉ định ID của MySQL Flexible Server
  principal_id         = azurerm_user_assigned_identity.mysql_identity.principal_id
}