resource "azurerm_container_app" "node_frontend" {
  name                         = "node-frontend"
  container_app_environment_id = data.azurerm_container_app_environment.aca_environment.id
  resource_group_name          = local.rg_name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"
  identity {
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.aca_user_identity.id
    ]
  }

  registry {
    server   = "${local.acr_name}.azurecr.io"
    identity = data.azurerm_user_assigned_identity.aca_user_identity.id
  }

  template {
    container {
      name   = "node-frontend"
      image  = "${local.acr_name}.azurecr.io/node-frontend:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "GATEWAY_URL"
        value = "http://python-service-gateway"
      }

      env {
        name  = "PORT"
        value = "8080"
      }
      env {
        name  = "OTEL_SERVICE_NAME"
        value = "node-frontend"
      }
      env {
        name  = "OTEL_TRACES_EXPORTER"
        value = "otlp"
      }
      env {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://jaeger:4318" 
      }
      env {
        name  = "NODE_OPTIONS"
        value = "--require @opentelemetry/auto-instrumentations-node/register"
      }
      readiness_probe {
        port      = 8080
        transport = "HTTP"
        path      = "/health"
      }
    }
    min_replicas = 1
    max_replicas = 2
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 8080
    transport                  = "auto"

    # IP Whitelisting / Access Restrictions
    ip_security_restriction {
      name                = "MyIP"
      action              = "Allow"
      ip_address_range    = "147.161.254.0/24"
      description         = "Only allow access from the specified IP"
    }

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}