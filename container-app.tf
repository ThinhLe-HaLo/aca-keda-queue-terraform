resource "azurerm_container_app_environment" "aca-keda-environment" {
  name                       = var.aca_env_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.aca-resource-group.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aca-log-analytics-workspace.id
}

resource "azurerm_container_app" "hello-world-aca" {
  name                         = "hello-world-app"
  container_app_environment_id = azurerm_container_app_environment.aca-keda-environment.id
  resource_group_name          = azurerm_resource_group.aca-resource-group.name
  revision_mode                = "Single"
  identity {
    type = "SystemAssigned"
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    transport        = "auto"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    container {
      name   = "hello-world-container"
      image  = "docker.io/lethinhlk/helloweb:1.0"
      cpu    = 0.25
      memory = "0.5Gi"
    }
    # Cấu hình KEDA Rule sử dụng Identity thay vì Connection String
    custom_scale_rule {
      name             = "storage-queue-autoscaling"
      custom_rule_type = "azure-queue"
      metadata = {
        queueName     = azurerm_storage_queue.queue.name
        queueLength   = "3"
        accountName   = "acakedastorage"
      }
  }
 }
  lifecycle {
    ignore_changes = [
      template[0].custom_scale_rule,
      template[0].azure_queue_scale_rule
    ]
  }
}

# Đây là "Robot" tự động tick Managed Identity
resource "null_resource" "enable_mi_for_scale_rule" {
  depends_on = [azurerm_container_app.hello-world-aca]

  triggers = {
    aca_id = azurerm_container_app.hello-world-aca.id
  }

  provisioner "local-exec" {
    # Thay chữ 'custom' bằng 'azureQueue' (chú ý chữ Q viết hoa theo đúng báo lỗi của Azure)
    command = "az resource update --ids ${azurerm_container_app.hello-world-aca.id} --set properties.template.scale.rules[0].azureQueue.identity=System"
  }
}