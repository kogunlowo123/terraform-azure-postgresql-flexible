provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-postgresql-advanced"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-postgresql"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "snet-postgresql"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "postgresql-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "example" {
  name                = "example.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  resource_group_name   = azurerm_resource_group.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

module "postgresql" {
  source = "../../"

  name                = "psql-advanced-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "GP_Standard_D4s_v3"
  storage_mb          = 65536
  postgresql_version  = "16"

  administrator_login    = "psqladmin"
  administrator_password = "P@ssw0rd1234!"

  delegated_subnet_id = azurerm_subnet.example.id
  private_dns_zone_id = azurerm_private_dns_zone.example.id

  zone = "1"

  high_availability = {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }

  backup_retention_days        = 35
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = true

  databases = {
    appdb = {
      charset   = "UTF8"
      collation = "en_US.utf8"
    }
    analyticsdb = {
      charset   = "UTF8"
      collation = "en_US.utf8"
    }
  }

  server_configurations = {
    "pgbouncer.enabled"                = "true"
    "pgbouncer.default_pool_size"      = "50"
    "pg_stat_statements.track"         = "all"
    "shared_preload_libraries"         = "pg_stat_statements"
    "azure.extensions"                 = "PG_STAT_STATEMENTS,PGCRYPTO,UUID-OSSP"
  }

  maintenance_window = {
    day_of_week  = 0
    start_hour   = 3
    start_minute = 0
  }

  enable_threat_detection = true

  tags = {
    Environment = "staging"
    Project     = "data-platform"
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.example,
  ]
}

output "server_fqdn" {
  value = module.postgresql.server_fqdn
}

output "server_id" {
  value = module.postgresql.server_id
}
