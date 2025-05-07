# Rentable Data Model - AI Context Overview

## [CRITICAL] Project Purpose and Structure

Rentable is a comprehensive equipment rental platform designed to facilitate the rental of various equipment types between businesses (B2B), businesses to consumers (B2C), and peer-to-peer (P2P). The data model follows a modular structure with clear separation of concerns.

### Core Modules

1. **Organization Management (00)** - Organization-specific functionality including usage metrics
2. **User Management (01)** - User accounts, profiles, verification, roles, and permissions
3. **Item Management (02)** - Equipment listings, categories, attributes, and availability
4. **Order Management (03)** - Rental orders, payments, logistics, and usage tracking
5. **Document Management (04)** - Compliance documents and certificates

### Deployment Sequence

The modules must be deployed in a specific sequence following the naming convention:
- Base module files: `XX_YY_module_name.sql` where XX is deployment step, YY is module number
- Foreign key constraints are defined within the modules where the referenced tables exist

## [IMPORTANT] Key Business Concepts

### Multi-Tenant System
- Organizations can be both renters and owners of equipment
- Each organization has its own profile, settings, and preferences

### Equipment Rental Model
- **Items**: Generic equipment types/templates (e.g., "Excavator Model X")
- **Item Units**: Specific physical instances of items that are actually rented (e.g., "Excavator #12345")
- **Availability**: Time windows when specific units can be rented
- **Orders**: Rental agreements between parties

All logistics, usage tracking, handovers, and availability apply specifically to item_units, not to the template items.

### Pricing System (Tiered Implementation)
- **Tier 1**: Basic pricing with tenant-level currency, rate units, tiered pricing, taxes, discounts
- **Tier 2**: Intermediate pricing with add-ons, custom pricing, promotional pricing

### Add-on Support
- Equipment can have optional or required add-ons (e.g., fuel, attachments, operators)
- Add-ons have their own pricing structure separate from the base item
- Required add-ons must be included in all rentals of the item
- Optional add-ons can be selected by the renter during order creation

### Usage Tracking
- Organizations define custom usage metrics (e.g., engine hours, mileage)
- Metrics are tracked per item unit for each order
- Supports both cumulative counters and per-rental consumption

### Document Management
- Compliance documents are categorized by entity type (equipment, unit, operator, order)
- Documents have verification workflows and access control
- Mandatory documents can be required before equipment handover

### Billing and Financial Management
- Dual-invoice system separates customer billing from platform fee tracking
- Multiple payment methods supported (card, wallet, bank_transfer, cash_on_delivery)
- Payment method tracking at both order and invoice level:
  - Order tracks both actual and preferred payment methods
  - Invoice records the authoritative payment method used
- Different invoice flows based on payment method:
  - Online payments: Platform processes full payment and pays out to owner
  - Cash payments: Platform only processes platform fee, rental payment handled offline
- Rental invoices show the full amount to renters (with platform fee bundled)
- Platform fee invoices show either:
  - Commission charged to owners (for online payments)
  - Reservation fee charged to renters (for cash payments)
- Flexible fee structures support percentage-based, flat, and tiered calculations
- Complete payout reconciliation for online payments (none for cash payments)
- Line items provide detailed breakdown of all charges

### Availability Management
- **Block Dates**: Periods when an item/unit is completely unavailable for rental
- **Blackout Dates**: Periods when handovers/returns are restricted, but the rental period can include these dates
- Different availability types (standard, promotional, soft block) affect how the system handles conflicts

## [CONTEXT] Implementation Patterns

### Common Patterns
1. All tables use UUIDs as primary keys with `gen_random_uuid()` as default
2. All tables include `created_at` timestamps, many include `updated_at` as well
3. Enums are used extensively for type classification and status tracking
4. Junction tables are used for many-to-many relationships
5. Foreign key constraints maintain referential integrity

### Standardized Fields
- `id`: UUID primary key
- `created_at`: Creation timestamp
- `updated_at`: Last modification timestamp
- `is_active`: Boolean flag for soft deletion/deactivation

## [IMPORTANT] Business Rules

1. Equipment can only be rented if available during the requested time period
2. Orders require specific documents based on equipment type and rental context
3. Usage metrics must be recorded at handover and return for proper billing
4. Tax handling supports both tax-inclusive and tax-exclusive pricing
5. Pricing can vary based on rental duration, season, and promotional periods

## [CONTEXT] Technical Implementation Notes

1. PostgreSQL-specific features are used (UUIDs, JSONB, arrays)
2. Indexes are created for all foreign keys and frequently queried fields
3. Check constraints enforce business rules at the database level
4. The schema is designed to be extensible for future enhancements

This overview provides the essential context for understanding the Rentable data model structure, business concepts, and implementation patterns. Refer to the module-specific documentation for detailed information about each component.
