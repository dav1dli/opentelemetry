# resource "azurerm_container_app" "otel_collector" {
#   name                         = "otel-collector"
#   container_app_environment_id = data.azurerm_container_app_environment.aca_environment.id
#   resource_group_name          = local.rg_name
#   revision_mode                = "Single"
#   workload_profile_name        = "Consumption"

#   template {
#     container {
#       name   = "otel-collector"
#       image  = "otel/opentelemetry-collector-contrib:latest"
#       cpu    = 0.5
#       memory = "1Gi"
#       readiness_probe {
#         transport = "TCP"
#         port      = 4317
#         initial_delay = 60
#         failure_count_threshold = 20
#         timeout = 60
#       }
#       liveness_probe {
#         transport = "TCP"
#         port      = 4317
#         initial_delay = 60
#         failure_count_threshold = 20
#         timeout = 60
#       }
#       env {
#         name  = "OTEL_CONFIG"
#         value = <<EOF
# receivers:
#   otlp:
#     protocols:
#       grpc:
#         endpoint: 0.0.0.0:4317
#       http:
#         endpoint: 0.0.0.0:4318
# processors:
#   batch:
# exporters:
#   otlp_http/jaeger:
#     endpoint: "http://jaeger:4318"
#     tls:
#       insecure: true
#   debug:
#     verbosity: detailed
# service:
#   pipelines:
#     traces:
#       receivers: [otlp]
#       processors: [batch]
#       exporters: [otlp_http/jaeger, debug]
# EOF
#       }
#       command = ["/otelcol-contrib", "--config=env:OTEL_CONFIG"]
#     }
#     min_replicas = 1
#     max_replicas = 1
#   }

#   ingress {
#     allow_insecure_connections = false
#     external_enabled           = false
#     target_port                = 4317
#     transport                  = "tcp"

#     traffic_weight {
#       percentage      = 100
#       latest_revision = true
#     }
#   }
# }

# resource "azapi_update_resource" "collector_extra_ports" {
#   count       = length(var.collector_additional_port_mappings) > 0 ? 1 : 0   
#   type        = "Microsoft.App/containerApps@2024-03-01"
#   resource_id = azurerm_container_app.otel_collector.id

#   body = {
#     properties = {
#       configuration = {
#         ingress = {
#           additionalPortMappings = var.collector_additional_port_mappings
#         }
#       }
#     }
#   }
# }