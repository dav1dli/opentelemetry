locals {
  rg_name                   = var.rg_name != "" ? var.rg_name : "RG-${var.region}-${var.environment}-${var.project}"
  tfstate_storage_account   = lower("sa${var.environment}${var.project}tfstate")
  tfstate_storage_container = "tfstate"
  vnet_name                 = "VNET-${var.region}-${var.environment}-${var.project}"
  aca_subnet_name           = var.aca_subnet_name != "" ? var.aca_subnet_name : "SBNT-ACA-${var.region}-${var.environment}-${var.project}"
  pep_subnet_name           = var.pep_subnet_name != "" ? var.pep_subnet_name : "SBNT-PEP-${var.region}-${var.environment}-${var.project}"
  acr_name                  = "ACR${var.environment}${var.project}"
  acr_pep_name              = "PEP-ACR-${var.region}-${var.environment}-${var.project}"
  #   redis_name                   = "RCA-${var.region}-${var.environment}-${var.project}"
  #   redis_pep_name               = "PEP-RCA-${var.region}-${var.environment}-${var.project}"
  aca_name = "ACA-${var.region}-${var.environment}-${var.project}"
  #   kv_name                      = "KV-${var.region}-${var.environment}-${var.project}"
  #   kv_pep_name                  = "PEP-KV-${var.region}-${var.environment}-${var.project}"
  log_analytics_workspace_name = var.log_analytics_workspace_name != "" ? var.log_analytics_workspace_name : "LA-${var.region}-${var.environment}-${var.project}"
  aca_user_identity            = "ACA-IDN-${var.region}-${var.environment}-${var.project}"
}
