variable "name" {
  description = "(Required) Specifies the name of the Container Registry. Changing this forces a new resource to be created."
  type        = string
}
variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Container Registry. Changing this forces a new resource to be created."
  type        = string
}
variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}
variable "admin_enabled" {
  description = "(Optional) Specifies whether the admin user is enabled."
  type        = string
  default     = true
}
variable "public_network_access_enabled" {
  description = "(Optional) Specifies whether the public network access is enabled."
  type        = string
  default     = false
}
variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(any)
  default     = {}
}
variable "log_analytics_workspace_id" {
  description = "(Required) The id of the Log Analiytics Workspace."
  type        = string
}

variable "account_kind" {
  description = "Specifies the account kind of the storage account"
  default     = "StorageV2"
  type        = string

   validation {
    condition = contains(["Storage", "StorageV2"], var.account_kind)
    error_message = "The account kind of the storage account is invalid."
  }
}

variable "account_tier" {
  description = "(Optional) Specifies the account tier of the storage account"
  default     = "Standard"
  type        = string

   validation {
    condition = contains(["Standard", "Premium"], var.account_tier)
    error_message = "The account tier of the storage account is invalid."
  }
}

variable "replication_type" {
  description = "(Optional) Specifies the replication type of the storage account"
  default     = "LRS"
  type        = string

  validation {
    condition = contains(["LRS", "ZRS", "GRS", "GZRS", "RA-GRS", "RA-GZRS"], var.replication_type)
    error_message = "The replication type of the storage account is invalid."
  }
}

variable "is_hns_enabled" {
  description = "(Optional) Specifies the replication type of the storage account"
  default     = false
  type        = bool
}

variable "default_action" {
    description = "Allow or disallow public access to all blobs or containers in the storage accounts. The default interpretation is true for this property."
    default     = "Allow"
    type        = string
}

variable "ip_rules" {
    description = "Specifies IP rules for the storage account"
    default     = []
    type        = list(string)
}

variable "virtual_network_subnet_ids" {
    description = "Specifies a list of resource ids for subnets"
    default     = []
    type        = list(string)
}
variable "retention_in_days" {
  description = " (Optional) Specifies the storage data retention in days"
  type        = number
  default     = 7
}