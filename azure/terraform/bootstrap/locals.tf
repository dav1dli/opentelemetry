locals {
  rg_name                   = var.rg_name != "" ? var.rg_name : "RG-${var.region}-${var.environment}-${var.project}"
  tfstate_storage_account   = lower("sa${var.environment}${var.project}tfstate")
  tfstate_storage_container = "tfstate"
}
