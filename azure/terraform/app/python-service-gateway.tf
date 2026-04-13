resource "azurerm_container_app" "python_service_gateway" {
  name                         = "python-service-gateway"
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
      name   = "python-service-gateway"
      image  = "${local.acr_name}.azurecr.io/python-service-gateway:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "UPSTREAM_SERVICES"
        value = "http://python-service-green,http://node-service-blue"
      }

      env {
        name  = "PORT"
        value = "5000"
      }
      env {
        name  = "OTEL_SERVICE_NAME"
        value = "python-service-gateway"
      }
      env {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://jaeger:4318"
      }
      env {
        name  = "OTEL_EXPORTER_OTLP_PROTOCOL"
        value = "http/protobuf"
      }
      # This ensures the trace context (Trace ID) is passed correctly 
      # from the Node frontend to this Python service
      env {
        name  = "OTEL_PROPAGATORS"
        value = "tracecontext,baggage"
      }
      # env {
      #   name  = "OTEL_LOGS_EXPORTER"
      #   value = "none"
      # }
      # env {
      #   name  = "OTEL_METRICS_EXPORTER"
      #   value = "none"
      # }

      readiness_probe {
        port      = 5000
        transport = "HTTP"
        path      = "/health"
      }
    }
    min_replicas = 1
    max_replicas = 2
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = false
    target_port                = 5000
    transport                  = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}