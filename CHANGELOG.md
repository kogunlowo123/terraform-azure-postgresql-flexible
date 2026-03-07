# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-07

### Added

- Initial release of the Azure PostgreSQL Flexible Server Terraform module.
- PostgreSQL Flexible Server resource with configurable SKU, storage, and version.
- Zone-redundant and same-zone high availability support.
- Geo-redundant backup configuration with adjustable retention period.
- Storage auto-grow capability.
- VNet integration via delegated subnet and private DNS zone.
- Database creation with configurable charset and collation.
- Server configuration parameter management (including pgBouncer).
- Firewall rule management.
- Azure Active Directory authentication and administrator setup.
- Customer-managed key (CMK) encryption support.
- Diagnostic settings for threat detection and monitoring.
- Maintenance window configuration.
- Basic, advanced, and complete usage examples.
