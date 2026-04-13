resource "azurerm_container_app" "node_service_blue" {
  name                         = "node-service-blue"
  container_app_environment_id = data.azurerm_container_app_environment.aca_environment.id
  resource_group_name          = local.rg_name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"
  
  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.aca_user_identity.id]
  }

  registry {
    server   = "${local.acr_name}.azurecr.io"
    identity = data.azurerm_user_assigned_identity.aca_user_identity.id
  }

  template {
    container {
      name   = "node-service-blue"
      image  = "${local.acr_name}.azurecr.io/node-service-blue:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "DB_URI"
        value = local.db_uri
      }
      env {
        name  = "PORT"
        value = "3020"
      }
      env {
        name  = "OTEL_SERVICE_NAME"
        value = "node-service-blue"
      }
      env {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://jaeger:4318"
      }
      env {
        name  = "OTEL_PROPAGATORS"
        value = "tracecontext,baggage"
      }

      readiness_probe {
        port      = 3020
        transport = "HTTP"
        path      = "/health"
      }
      liveness_probe {
        port             = 3020
        transport        = "TCP"
        initial_delay    = 15
        interval_seconds = 10
        timeout          = 5
      }
    }
    min_replicas = 1
    max_replicas = 2
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = false
    target_port                = 3020
    transport                  = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}