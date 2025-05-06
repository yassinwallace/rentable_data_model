# Organization Management Module - AI Context

## [CRITICAL] Module Purpose

The Organization Management module (00) provides the foundation for organization-specific functionality in the Rentable system. It manages how organizations define and track custom usage metrics for equipment rental.

## [IMPORTANT] Key Entities

### 1. Organization Usage Metrics

**Purpose**: Allows organizations to define their own metrics for tracking equipment usage during rentals.

**Entity**: `organization_usage_metric`
- Belongs to a specific organization (via `organization_profile_id`)
- Has a name (e.g., "Engine Hours") and unit (e.g., "hours")
- Classified by metric type:
  - `stock`: Cumulative counter requiring start and end values (e.g., odometer)
  - `flow`: Per-rental consumption with a single reported value (e.g., fuel used)
- Can be marked active/inactive

**Business Rules**:
- Each organization can define multiple custom metrics
- Metrics are used to track usage of rented equipment
- Metrics can be organization-specific or standardized across the platform
- Organizations control which metrics apply to which equipment types

### 2. Organization-Level Rules and Defaults

**Purpose**: Provides organization-wide settings for rental operations.

**Business Rules**:
- Organizations can define blackout calendars (dates when handovers/returns are restricted)
- Default logistics options can be set at the organization level
- Organizations can set default working hours and availability
- These organization-level settings can be overridden at the item or item unit level

### 3. Organization Tax Configuration

**Purpose**: [UPCOMING] Allows organizations to define default tax settings.

**Business Rules**:
- Organizations will be able to define default tax rates and rules
- Tax configurations can be applied automatically to new items
- Tax settings include whether taxes are included in prices by default
- This feature is planned for future implementation

## [CONTEXT] Relationships with Other Modules

### User Management Module
- References the `profile` table for organization profiles
- Foreign key constraint: `organization_usage_metric.organization_profile_id` → `profile.id`

### Order Management Module
- Provides metrics that are tracked in the `order_unit_metric_reading` table
- Readings are recorded during equipment handover and return

## [IMPORTANT] Implementation Patterns

### Enum Usage
- `metric_type` enum defines the behavior of each metric (stock vs. flow)
- This affects how readings are recorded in the order management module

### Extensibility
- The module is designed to be extended with additional organization-specific settings
- Future enhancements might include organization preferences, policies, and templates

## [CONTEXT] Technical Notes

1. This module must be deployed before other modules since it's referenced by them
2. Foreign key constraints to this module are defined in the respective modules
3. The module follows the standard naming convention: `00_organization_management_module.sql`

## [CRITICAL] Business Context

Organizations in Rentable need to track various usage metrics for equipment to:
1. Calculate usage-based charges
2. Monitor equipment condition and maintenance needs
3. Verify proper usage according to rental agreements
4. Support compliance and reporting requirements

The flexible metric system allows each organization to define metrics relevant to their specific equipment types and business model.
