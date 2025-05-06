# Module Relationships and Architecture - AI Context

## [CRITICAL] System Architecture Overview

The Rentable data model follows a modular architecture with clear separation of concerns. Understanding the relationships between modules is essential for comprehending the system as a whole.

## [IMPORTANT] Module Dependencies

### Deployment Sequence
The modules must be deployed in a specific sequence due to their dependencies:

1. **Organization Management (00)** - Foundation for organization-specific functionality
2. **User Management (01)** - User accounts, profiles, and core identity
3. **Item Management (02)** - Equipment listings and pricing
4. **Order Management (03)** - Rental transactions and processes
5. **Document Management (04)** - Compliance documentation

### Foreign Key Relationships
Foreign key constraints are defined in the module where the referenced table exists, following these patterns:

- Tables in other modules that reference `profile` have their FK constraints in the User Management module
- Tables in other modules that reference `item` or `item_unit` have their FK constraints in the Item Management module
- Tables in other modules that reference `order` have their FK constraints in the Order Management module

## [CONTEXT] Key Cross-Module Relationships

### Organization Management → User Management
- `organization_usage_metric.organization_profile_id` → `profile.id`
- Organizations are represented as profiles with type 'organization'

### User Management → Item Management
- `item.owner_profile_id` → `profile.id`
- Equipment is owned by organization profiles

### Item Management → Order Management
- `order.item_id` → `item.id`
- `order_item_unit.item_unit_id` → `item_unit.id`
- Orders reference both the item type and specific physical units

### Order Management → Organization Management
- `order_unit_metric_reading.metric_id` → `organization_usage_metric.id`
- Usage metrics defined by organizations are tracked in orders

### Order Management Incident Tracking Flow
- `order_incident.order_id` → `order.id`
- `order_dispute.order_incident_id` → `order_incident.id`
- `deposit_claim.order_dispute_id` → `order_dispute.id`
- `deposit_claim.order_deposit_id` → `order_deposit.id`
- This creates a structured flow from incidents to disputes to financial claims

### Order Management Billing Flow
- `invoice.order_id` → `order.id`
- `invoice_line_item.invoice_id` → `invoice.id`
- `order_payout.rental_invoice_id` → `invoice.id`
- `order_payout.platform_fee_invoice_id` → `invoice.id`
- `platform_fee_config.organization_profile_id` → `profile.id`
- This creates a comprehensive financial tracking system for rentals and platform fees

### Document Management → All Other Modules
- `item_document.item_id` → `item.id`
- `item_unit_document.item_unit_id` → `item_unit.id`
- `profile_document.profile_id` → `profile.id`
- `order_document.order_id` → `order.id`
- Documents can be associated with entities from any module
- The document system uses a polymorphic attachment approach, allowing the same document to be linked to different entity types

## [IMPORTANT] Core Business Flows

### Equipment Listing Flow
1. Organization profile is created (User Management)
2. Organization defines custom usage metrics (Organization Management)
3. Organization creates item listings (Item Management)
4. Organization adds physical units to items (Item Management)
5. Organization uploads required documents (Document Management)

### Rental Transaction Flow
1. Renter profile browses and selects equipment (Item Management)
2. Renter creates an order (Order Management)
3. Owner confirms the order (Order Management)
4. Required documents are verified (Document Management)
5. Equipment is handed over with initial metric readings (Order Management)
6. Equipment is returned with final metric readings (Order Management)
7. Payment is processed and order is completed (Order Management)

### Incident Management Flow
1. An issue is reported during a rental (Order Management)
2. The incident is documented with evidence (Order Management)
3. If unresolved, the incident may escalate to a dispute (Order Management)
4. Deposit claims may be processed based on dispute outcomes (Order Management)
5. Supporting documents are attached throughout the process (Document Management)

### Billing and Payout Flow
1. An order is confirmed (Order Management)
2. A rental invoice is generated for the renter (Order Management)
3. When the order is completed, a platform fee invoice is generated for the owner (Order Management)
4. Payout is calculated by deducting platform fees from the rental amount (Order Management)
5. Financial records are maintained for accounting and reconciliation purposes

## [CONTEXT] File Naming Convention

The project follows a specific SQL file naming convention:

1. Regular module files: `XX_YY_module_name.sql` where:
   - XX is the deployment step number (01, 02, etc.)
   - YY is the module number (01 for User Management, 02 for Item Management, etc.)

This creates a clear deployment sequence while preserving the module numbering.

## [CRITICAL] Architectural Principles

1. **Separation of Concerns**: Each module focuses on a specific domain
2. **Referential Integrity**: Foreign key constraints maintain data consistency
3. **Normalized Design**: Tables are properly normalized to minimize redundancy
4. **Extensibility**: The schema is designed to be extended with new features
5. **Business Rule Enforcement**: Constraints and checks enforce business rules at the database level

## [IMPORTANT] Override Hierarchy

The system implements a consistent override hierarchy for various settings:

1. **Organization Level**: Base settings defined at the organization level
2. **Item Level**: Can override organization-level settings
3. **Item Unit Level**: Can override item-level settings
4. **Order Level**: Can override all previous levels for a specific rental

This hierarchy applies to:
- Pricing (base price → pricing tiers → custom price)
- Logistics options (organization defaults → item options → order-specific)
- Tax settings (organization defaults → item-specific → order-specific)
- Availability (organization calendar → item availability → unit-specific blocks)

The override system ensures flexibility while maintaining sensible defaults, allowing for customization at each level of the rental process.

Understanding these architectural principles and module relationships is essential for working with the Rentable data model effectively.
