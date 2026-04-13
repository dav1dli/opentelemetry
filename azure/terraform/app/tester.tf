resource "azurerm_container_app" "network_tester" {
  name                         = "network-tester"
  container_app_environment_id = data.azurerm_container_app_environment.aca_environment.id
  resource_group_name          = local.rg_name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"
  template {
    container {
      name   = "netshoot"
      image  = "nicolaka/netshoot:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      # Keep the container running so you can exec into it
      command = ["/bin/sh", "-c", "sleep infinity"]
    }
  }

  # No ingress needed since we will use 'az containerapp exec'
}