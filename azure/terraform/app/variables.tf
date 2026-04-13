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

variable "jaeger_additional_port_mappings" {
  description = "Additional ports that should be mapped to the container app"
  type        = list(object({
    external     = optional(bool, false),
    targetPort  = string,
    exposedPort = string,
    transport   = optional(string, "auto")
  }))
  default = [
    {
      targetPort  = "4318"
      exposedPort = "4318"
      external    = false
      transport = "auto"
    }
  ]
}

variable "collector_additional_port_mappings" {
  description = "Additional ports that should be mapped to the container app"
  type        = list(object({
    external     = optional(bool, false),
    targetPort  = string,
    exposedPort = string,
    transport   = optional(string, "auto")
  }))
  default = [
    {
      targetPort  = "4318"
      exposedPort = "4318"
      external    = false
      transport = "tcp"
    }
  ]
}