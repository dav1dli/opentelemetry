resource "azurerm_container_app" "mongodb" {
  name                         = "mongodb"
  container_app_environment_id = data.azurerm_container_app_environment.aca_environment.id
  resource_group_name          = local.rg_name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  template {
    container {
      name   = "mongodb"
      image  = "mongo:latest"
      cpu    = 0.5
      memory = "1Gi"
      args = [
        "--wiredTigerCacheSizeGB", "0.25"
      ]

      volume_mounts {
        name = "db-data"
        path = "/data/db"
      }

      # Translation of your Docker Healthcheck
      liveness_probe {
        port                    = 27017
        transport               = "TCP"
        initial_delay           = 15
        interval_seconds        = 10
      }
    }

    # volume {
    #   name         = "db-data"
    #   storage_name = data.azurerm_container_app_environment_storage.volume_db.name
    #   storage_type = "AzureFile"
    # }
    volume {
      name         = "db-data"
      storage_type = "EmptyDir" 
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = false # Internal only
    target_port                = 27017
    transport                  = "tcp" # Essential for DB protocols
    
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}