module "test" {
  source = "../"

  name                = "psql-flex-test"
  resource_group_name = "rg-postgresql-test"
  location            = "eastus2"
  sku_name            = "GP_Standard_D2s_v3"
  storage_mb          = 32768
  postgresql_version  = "16"

  administrator_login    = "psqladmin"
  administrator_password = "T3stP@ssw0rd!2024"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  databases = {
    appdb = {
      charset   = "UTF8"
      collation = "en_US.utf8"
    }
  }

  firewall_rules = {
    allow-azure-services = {
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    }
  }

  maintenance_window = {
    day_of_week  = 0
    start_hour   = 3
    start_minute = 0
  }

  enable_threat_detection      = false
  enable_active_directory_auth = false

  tags = {
    environment = "test"
    managed_by  = "terraform"
  }
}
