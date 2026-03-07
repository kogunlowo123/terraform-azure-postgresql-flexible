provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-postgresql-basic"
  location = "East US"
}

module "postgresql" {
  source = "../../"

  name                = "psql-basic-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "GP_Standard_D2s_v3"
  storage_mb          = 32768
  postgresql_version  = "16"

  administrator_login    = "psqladmin"
  administrator_password = "P@ssw0rd1234!"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

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

  enable_threat_detection = false

  tags = {
    Environment = "dev"
  }
}

output "server_fqdn" {
  value = module.postgresql.server_fqdn
}
