# Environment
variable "location" {
  type = string
  description = "Azure Region where resources will be provisioned"
  default = "westeurope"
}
variable "environment" {
  type = string
  description = "Environment"
  default = ""
}
variable "project" {
  type = string
  description = "Application project"
  default = ""
}
variable "region" {
  type = string
  description = "Environment region"
  default = "EUR-WW"
}
variable "tags" {
  description = "Specifies tags for all the resources"
  default     = {
    createdWith = "Terraform"
  }
}
# Resources
variable "rg_name" {
  description = "Resource group name"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_name" {
  description = "Optional override for the Log Analytics workspace name"
  type        = string
  default     = ""
}

# Network
variable "vnet_name" {
  description = "Specifies the name of the VNET"
  type        = string
  default     = ""
}
variable "vnet_address_space" {
  description = "Specifies the network addresses space of the VNET"
  default     =  ["10.0.0.0/16"]
  type        = list(string)
}
variable "aca_subnet_name" {
  description = "Specifies the name of the subnet that hosts container apps"
  type        = string
  default     = ""
}

variable "aca_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts container apps"
  default     =  ["10.0.0.0/23"]
  type        = list(string)
}
variable "pep_subnet_name" {
  description = "Specifies the name of the subnet that hosts private endpoints"
  type        = string
  default     = ""
}
variable "pep_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts private endpoints"
  default     =  ["10.0.2.0/25"]
  type        = list(string)
}
# ACR
variable "acr_public" {
  description = "Allow ACR public access"
  default     = true
  type        = bool
}
variable "network_rule_set" {
  description = "Network rule set configuration for the ACR"
  type = object({
    default_action = string
    ip_rule = optional(list(object({
      action   = string
      ip_range = string
    })))
  })
  default = null
}