# terraform-azure-postgresql-flexible

Terraform module for deploying Azure Database for PostgreSQL Flexible Server with support for high availability, geo-redundant backups, read replicas, pgBouncer connection pooling, and private endpoint integration.

## Features

- PostgreSQL Flexible Server with configurable SKU and storage
- Zone-redundant and same-zone high availability
- Geo-redundant backups with configurable retention (up to 35 days)
- Storage auto-grow
- pgBouncer connection pooling via server configurations
- VNet integration with delegated subnet and private DNS zone
- Multiple database creation
- Server configuration management
- Firewall rule management
- Azure Active Directory authentication
- Customer-managed key (CMK) encryption
- Diagnostic settings for monitoring and threat detection
- Maintenance window configuration

## Usage

### Basic

```hcl
module "postgresql" {
  source = "github.com/kogunlowo123/terraform-azure-postgresql-flexible"

  name                = "my-psql-server"
  resource_group_name = "my-resource-group"
  location            = "East US"
  sku_name            = "GP_Standard_D2s_v3"
  storage_mb          = 32768

  administrator_login    = "psqladmin"
  administrator_password = var.db_password

  databases = {
    mydb = {
      charset   = "UTF8"
      collation = "en_US.utf8"
    }
  }
}
```

### With High Availability and pgBouncer

```hcl
module "postgresql" {
  source = "github.com/kogunlowo123/terraform-azure-postgresql-flexible"

  name                = "my-psql-ha"
  resource_group_name = "my-resource-group"
  location            = "East US"
  sku_name            = "GP_Standard_D4s_v3"
  storage_mb          = 65536
  zone                = "1"

  administrator_login    = "psqladmin"
  administrator_password = var.db_password

  high_availability = {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }

  server_configurations = {
    "pgbouncer.enabled"           = "true"
    "pgbouncer.default_pool_size" = "50"
  }
}
```

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.5.0  |
| azurerm   | >= 3.80.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | The name of the PostgreSQL Flexible Server | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| sku_name | The SKU name for the server | `string` | n/a | yes |
| storage_mb | Max storage in megabytes | `number` | n/a | yes |
| storage_tier | The storage tier | `string` | `null` | no |
| postgresql_version | PostgreSQL version | `string` | `"16"` | no |
| administrator_login | Administrator login | `string` | `null` | no |
| administrator_password | Administrator password | `string` | `null` | no |
| delegated_subnet_id | Delegated subnet ID for VNet integration | `string` | `null` | no |
| private_dns_zone_id | Private DNS zone ID | `string` | `null` | no |
| zone | Availability zone | `string` | `null` | no |
| high_availability | HA configuration (mode, standby_availability_zone) | `object` | `null` | no |
| backup_retention_days | Backup retention days (7-35) | `number` | `35` | no |
| geo_redundant_backup_enabled | Enable geo-redundant backups | `bool` | `true` | no |
| auto_grow_enabled | Enable storage auto-grow | `bool` | `true` | no |
| databases | Map of databases to create | `map(object)` | `{}` | no |
| server_configurations | Map of server configurations | `map(string)` | `{}` | no |
| firewall_rules | Map of firewall rules | `map(object)` | `{}` | no |
| enable_active_directory_auth | Enable AD authentication | `bool` | `false` | no |
| ad_admin_object_id | AD admin object ID | `string` | `null` | no |
| ad_admin_tenant_id | AD admin tenant ID | `string` | `null` | no |
| customer_managed_key | CMK encryption configuration | `object` | `null` | no |
| enable_threat_detection | Enable threat detection diagnostics | `bool` | `true` | no |
| maintenance_window | Maintenance window configuration | `object` | `null` | no |
| tags | Tags to assign to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| server_id | The ID of the PostgreSQL Flexible Server |
| server_name | The name of the server |
| server_fqdn | The FQDN of the server |
| server_location | The Azure region of the server |
| server_version | The PostgreSQL version |
| server_sku_name | The SKU name |
| administrator_login | The administrator login |
| database_ids | Map of database names to IDs |
| firewall_rule_ids | Map of firewall rule names to IDs |
| configuration_ids | Map of configuration names to IDs |
| public_network_access_enabled | Whether public network access is enabled |

## Examples

- [Basic](./examples/basic/) - Simple deployment with public access
- [Advanced](./examples/advanced/) - VNet integration, HA, pgBouncer
- [Complete](./examples/complete/) - Full-featured with CMK, AD auth, diagnostics

## License

MIT License. See [LICENSE](./LICENSE) for details.
