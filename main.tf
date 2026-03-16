resource "azurerm_postgresql_flexible_server" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.postgresql_version
  sku_name                      = var.sku_name
  storage_mb                    = var.storage_mb
  storage_tier                  = var.storage_tier
  administrator_login           = var.administrator_login
  administrator_password        = var.administrator_password
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = var.geo_redundant_backup_enabled
  auto_grow_enabled             = var.auto_grow_enabled
  zone                          = var.zone
  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = var.delegated_subnet_id != null && var.private_dns_zone_id != null ? var.private_dns_zone_id : null
  public_network_access_enabled = var.delegated_subnet_id != null && var.private_dns_zone_id != null ? false : true

  dynamic "high_availability" {
    for_each = var.high_availability != null ? [var.high_availability] : []
    content {
      mode                      = high_availability.value.mode
      standby_availability_zone = high_availability.value.standby_availability_zone
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key != null ? [var.customer_managed_key] : []
    content {
      key_vault_key_id                     = customer_managed_key.value.key_vault_key_id
      primary_user_assigned_identity_id    = customer_managed_key.value.primary_user_assigned_identity_id
      geo_backup_key_vault_key_id          = customer_managed_key.value.geo_backup_key_vault_key_id
      geo_backup_user_assigned_identity_id = customer_managed_key.value.geo_backup_user_assigned_identity_id
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      day_of_week  = maintenance_window.value.day_of_week
      start_hour   = maintenance_window.value.start_hour
      start_minute = maintenance_window.value.start_minute
    }
  }

  dynamic "authentication" {
    for_each = var.enable_active_directory_auth ? [1] : []
    content {
      active_directory_auth_enabled = true
      password_auth_enabled         = true
      tenant_id                     = var.ad_admin_tenant_id
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone,
    ]
  }
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  for_each = var.databases

  name      = each.key
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = each.value.charset
  collation = each.value.collation
}

resource "azurerm_postgresql_flexible_server_configuration" "this" {
  for_each = var.server_configurations

  name      = each.key
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = each.value
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "this" {
  for_each = var.firewall_rules

  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "this" {
  count = var.enable_active_directory_auth ? 1 : 0

  server_name         = azurerm_postgresql_flexible_server.this.name
  resource_group_name = var.resource_group_name
  tenant_id           = var.ad_admin_tenant_id
  object_id           = var.ad_admin_object_id
  principal_name      = "AAD Admin - ${var.name}"
  principal_type      = "ServicePrincipal"
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_threat_detection ? 1 : 0

  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_postgresql_flexible_server.this.id
  log_analytics_workspace_id = null

  enabled_log {
    category = "PostgreSQLLogs"
  }

  enabled_log {
    category = "PostgreSQLFlexSessions"
  }

  enabled_log {
    category = "PostgreSQLFlexQueryStoreRuntime"
  }

  enabled_log {
    category = "PostgreSQLFlexQueryStoreWaitStats"
  }

  enabled_log {
    category = "PostgreSQLFlexTableStats"
  }

  enabled_log {
    category = "PostgreSQLFlexDatabaseXacts"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
