variable "name" {
  description = "The name of the PostgreSQL Flexible Server."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the PostgreSQL Flexible Server."
  type        = string
}

variable "location" {
  description = "The Azure region where the PostgreSQL Flexible Server should be created."
  type        = string
}

variable "sku_name" {
  description = "The SKU name for the PostgreSQL Flexible Server (e.g., GP_Standard_D2s_v3, MO_Standard_E4s_v3)."
  type        = string
}

variable "storage_mb" {
  description = "The max storage allowed for the PostgreSQL Flexible Server in megabytes."
  type        = number
}

variable "storage_tier" {
  description = "The storage tier for the PostgreSQL Flexible Server (e.g., P30, P40, P50)."
  type        = string
  default     = null
}

variable "postgresql_version" {
  description = "The version of PostgreSQL to use."
  type        = string
  default     = "16"
}

variable "administrator_login" {
  description = "The administrator login for the PostgreSQL Flexible Server."
  type        = string
  default     = null
}

variable "administrator_password" {
  description = "The administrator password for the PostgreSQL Flexible Server."
  type        = string
  sensitive   = true
  default     = null
}

variable "delegated_subnet_id" {
  description = "The ID of the subnet to which the PostgreSQL Flexible Server is delegated."
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "The ID of the private DNS zone for the PostgreSQL Flexible Server."
  type        = string
  default     = null
}

variable "zone" {
  description = "The availability zone for the PostgreSQL Flexible Server."
  type        = string
  default     = null
}

variable "high_availability" {
  description = "High availability configuration for the PostgreSQL Flexible Server."
  type = object({
    mode                      = string
    standby_availability_zone = optional(string)
  })
  default = null
}

variable "backup_retention_days" {
  description = "The number of days to retain backups. Must be between 7 and 35."
  type        = number
  default     = 35
}

variable "geo_redundant_backup_enabled" {
  description = "Whether geo-redundant backups are enabled for the PostgreSQL Flexible Server."
  type        = bool
  default     = true
}

variable "auto_grow_enabled" {
  description = "Whether storage auto-grow is enabled for the PostgreSQL Flexible Server."
  type        = bool
  default     = true
}

variable "databases" {
  description = "Map of databases to create on the PostgreSQL Flexible Server."
  type = map(object({
    charset   = string
    collation = string
  }))
  default = {}
}

variable "server_configurations" {
  description = "Map of server configuration parameters to set on the PostgreSQL Flexible Server."
  type        = map(string)
  default     = {}
}

variable "firewall_rules" {
  description = "Map of firewall rules to create on the PostgreSQL Flexible Server."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "enable_active_directory_auth" {
  description = "Whether to enable Active Directory authentication for the PostgreSQL Flexible Server."
  type        = bool
  default     = false
}

variable "ad_admin_object_id" {
  description = "The object ID of the Azure AD administrator for the PostgreSQL Flexible Server."
  type        = string
  default     = null
}

variable "ad_admin_tenant_id" {
  description = "The tenant ID of the Azure AD administrator for the PostgreSQL Flexible Server."
  type        = string
  default     = null
}

variable "customer_managed_key" {
  description = "Customer-managed key configuration for the PostgreSQL Flexible Server."
  type = object({
    key_vault_key_id                  = string
    primary_user_assigned_identity_id = optional(string)
    geo_backup_key_vault_key_id       = optional(string)
    geo_backup_user_assigned_identity_id = optional(string)
  })
  default = null
}

variable "enable_threat_detection" {
  description = "Whether to enable threat detection (Microsoft Defender) for the PostgreSQL Flexible Server."
  type        = bool
  default     = true
}

variable "maintenance_window" {
  description = "Maintenance window configuration for the PostgreSQL Flexible Server."
  type = object({
    day_of_week  = optional(number, 0)
    start_hour   = optional(number, 0)
    start_minute = optional(number, 0)
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
