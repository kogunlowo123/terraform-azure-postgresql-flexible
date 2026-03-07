locals {
  # Determine if private network integration is configured
  is_private = var.delegated_subnet_id != null && var.private_dns_zone_id != null

  # Default tags merged with user-provided tags
  default_tags = {
    ManagedBy = "Terraform"
    Module    = "terraform-azure-postgresql-flexible"
  }

  tags = merge(local.default_tags, var.tags)

  # AD admin display name derived from object ID
  ad_admin_display_name = var.enable_active_directory_auth ? "AAD Admin - ${var.name}" : null
}
