variable "location" {
    description = "Azure region for resources"
    type        = string
    default     = "Southeast Asia"
}
# resource group setup
variable "resource_group_name" {
    description = "Name of the Azure resource group"
    type        = string
    default     = "ACA-KEDA-RG"
}
# aca environment setup
variable "aca_env_name" {
    description = "Name of the Azure environment"
    type        = string
    default     = "ACA-KEDA-ENV"
}
#log analytics workspace setup
variable "log_analytics_workspace_name" {
    description = "Name of the Log Analytics workspace"
    type        = string
    default     = "ACA-KEDA-LOG"
}
# azure storage setup
variable "storage_account_name" {
    description = "Name of the Azure Storage Account"
    type        = string
    default     = "acakedastorage"
}
variable "queue_storage_name" {
    description = "Name of the Azure Storage Queue"
    type        = string
    default     = "aca-queue"
}

# sql database setup
variable "sql_server_name" {
  description = "The name of the SQL server."
  type        = string
  default     = "azuresqlproserver"
}
variable "sql_userlogin" {
  description = "The administrator login for the SQL server."
  type        = string
  default     = "azureadmin"
}
variable "sql_password" {
  type        = string
  description = "Nhập mật khẩu Database của bạn tại đây"
  sensitive   = true # Quan trọng: Ngăn mật khẩu hiện ra màn hình console (hiện dấu *)
}
variable "database_name" {
  description = "The name of the SQL database."
  type        = string
  default     = "sinhvien_db"
}