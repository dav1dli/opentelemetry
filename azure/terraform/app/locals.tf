locals {
  rg_name                   = var.rg_name != "" ? var.rg_name : "RG-${var.region}-${var.environment}-${var.project}"
  tfstate_storage_account   = lower("sa${var.environment}${var.project}tfstate")
  tfstate_storage_container = "tfstate"
  acr_name                  = lower("ACR${var.environment}${var.project}")
  aca_name                  = "ACA-${var.region}-${var.environment}-${var.project}"
  log_analytics_workspace_name = var.log_analytics_workspace_name != "" ? var.log_analytics_workspace_name : "LA-${var.region}-${var.environment}-${var.project}"
  aca_user_identity            = "ACA-IDN-${var.region}-${var.environment}-${var.project}"
  db_uri                       = "mongodb://mongodb:27017"
}
