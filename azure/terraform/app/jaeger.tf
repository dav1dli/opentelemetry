resource "azurerm_container_app" "jaeger" {
  name                         = "jaeger"
  container_app_environment_id = data.azurerm_container_app_environment.aca_environment.id
  resource_group_name          = local.rg_name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  template {
    container {
      name   = "jaeger"
      image  = "jaegertracing/all-in-one:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "COLLECTOR_OTLP_ENABLED"
        value = "true"
      }
      env {
        name  = "COLLECTOR_OTLP_GRPC_HOST_PORT"
        value = "0.0.0.0:4317"
      }
      env {
        name  = "COLLECTOR_OTLP_HTTP_HOST_PORT"
        value = "0.0.0.0:4318"
      }

      readiness_probe {
        port      = 16686
        transport = "HTTP"
        path      = "/"
      }
    }
    min_replicas = 1
    max_replicas = 1
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 16686
    transport                  = "auto"

    ip_security_restriction {
      name                = "AllowMyIP"
      action              = "Allow"
      ip_address_range    = "147.161.254.0/24"
      description         = "Only allow access from my network"
    }

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azapi_update_resource" "jaeger_extra_ports" {
  count       = length(var.jaeger_additional_port_mappings) > 0 ? 1 : 0   
  type        = "Microsoft.App/containerApps@2024-03-01"
  resource_id = azurerm_container_app.jaeger.id

  body = {
    properties = {
      configuration = {
        ingress = {
          additionalPortMappings = var.jaeger_additional_port_mappings
        }
      }
    }
  }
}