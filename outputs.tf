output "server_id" {
  description = "The ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "server_name" {
  description = "The name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.name
}

output "server_fqdn" {
  description = "The FQDN of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "server_location" {
  description = "The Azure region of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.location
}

output "server_version" {
  description = "The version of PostgreSQL running on the Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.version
}

output "server_sku_name" {
  description = "The SKU name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.sku_name
}

output "administrator_login" {
  description = "The administrator login for the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.administrator_login
}

output "database_ids" {
  description = "Map of database names to their IDs."
  value       = { for k, v in azurerm_postgresql_flexible_server_database.this : k => v.id }
}

output "firewall_rule_ids" {
  description = "Map of firewall rule names to their IDs."
  value       = { for k, v in azurerm_postgresql_flexible_server_firewall_rule.this : k => v.id }
}

output "configuration_ids" {
  description = "Map of configuration names to their IDs."
  value       = { for k, v in azurerm_postgresql_flexible_server_configuration.this : k => v.id }
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled for the server."
  value       = azurerm_postgresql_flexible_server.this.public_network_access_enabled
}
