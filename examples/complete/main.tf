provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-postgresql-complete"
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
  name                = "complete.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  resource_group_name   = azurerm_resource_group.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_user_assigned_identity" "example" {
  name                = "id-postgresql-cmk"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_key_vault" "example" {
  name                       = "kv-psql-complete"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.example.principal_id

    key_permissions = [
      "Get", "List", "WrapKey", "UnwrapKey",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Recover", "Purge", "GetRotationPolicy",
    ]
  }
}

resource "azurerm_key_vault_key" "example" {
  name         = "psql-cmk-key"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["wrapKey", "unwrapKey"]
}

module "postgresql" {
  source = "../../"

  name                = "psql-complete-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "MO_Standard_E4s_v3"
  storage_mb          = 131072
  storage_tier        = "P30"
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
    reportingdb = {
      charset   = "UTF8"
      collation = "en_US.utf8"
    }
  }

  server_configurations = {
    "pgbouncer.enabled"                = "true"
    "pgbouncer.default_pool_size"      = "100"
    "pgbouncer.max_client_conn"        = "500"
    "pg_stat_statements.track"         = "all"
    "shared_preload_libraries"         = "pg_stat_statements"
    "azure.extensions"                 = "PG_STAT_STATEMENTS,PGCRYPTO,UUID-OSSP,POSTGIS"
    "log_checkpoints"                  = "on"
    "log_connections"                   = "on"
    "log_disconnections"                = "on"
    "log_duration"                      = "on"
    "connection_throttle.enable"        = "on"
  }

  enable_active_directory_auth = true
  ad_admin_object_id           = data.azurerm_client_config.current.object_id
  ad_admin_tenant_id           = data.azurerm_client_config.current.tenant_id

  customer_managed_key = {
    key_vault_key_id                  = azurerm_key_vault_key.example.id
    primary_user_assigned_identity_id = azurerm_user_assigned_identity.example.id
  }

  maintenance_window = {
    day_of_week  = 6
    start_hour   = 2
    start_minute = 0
  }

  enable_threat_detection = true

  tags = {
    Environment = "production"
    Project     = "data-platform"
    CostCenter  = "engineering"
    Compliance  = "SOC2"
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

output "database_ids" {
  value = module.postgresql.database_ids
}
