# Rentable Data Model V1.5

This version of the Rentable data model includes enhanced pricing features implemented in tiers to support various business scenarios while maintaining a normalized and coherent database structure.

## Deployment Sequence

To ensure proper database creation, the files must be executed in the following order:

### 1. Base Module Files (in numerical order)
1. `01_01_user_management_module.sql` - User tables, roles, permissions
2. `01_02_item_management_module.sql` - Items, categories, attributes
3. `01_03_order_management_module.sql` - Orders, payments, logistics
4. (Additional module files as they are created)

### 2. Cross-Module Foreign Key Files
After all base modules have been deployed, execute the cross-module foreign key files:
1. `03_cross_module_fk.sql` - Foreign keys between modules
2. (Additional cross-module FK files as they are created)

### 3. Final Verification
After all files have been executed, verify database integrity and relationships.

## Pricing Features

The pricing system has been implemented in tiers of increasing complexity:

### Tier 1 Pricing Features (Basic Pricing)

1. **Tenant-Level Currency Settings**:
   - Normalized `currency` table with code, name, symbol, and active status
   - References to currency via `currency_code` in `profile` and `item` tables
   - Pre-populated with common currencies (EUR, USD, GBP)

2. **Rate Unit Support for Items**:
   - `rate_unit` enum with values: `hour`, `day`, `week`, `month`
   - Applied to items to define their default billing period

3. **Tiered Pricing Per Item**:
   - Duration-based pricing tiers with min/max duration
   - Support for different rate units per tier
   - Flexible pricing strategies based on rental duration

4. **Structured Tax Support (ERP Style)**:
   - Tax definitions with rates and active status
   - Item-tax assignments with tax-inclusive pricing options
   - Support for multiple taxes per item

5. **Default Client Discount**:
   - Normalized discount management via `profile_discount` table
   - Support for percentage-based discounts
   - Validation to ensure non-negative discount values

### Tier 2 Pricing Features (Intermediate Pricing)

1. **Add-On Charges Per Item**:
   - Optional add-ons linked to items (e.g., operator, fuel, attachments)
   - Support for required vs. optional add-ons
   - Independent pricing for each add-on

2. **Unit-Specific Add-Ons in Orders**:
   - Add-ons linked to specific order item units
   - Support for quantity and custom pricing overrides
   - Clear association between physical units and their add-ons

3. **Custom Pricing Per Order Unit**:
   - Unit-specific price and rate unit overrides
   - Flexible pricing adjustments for specific rentals
   - Support for negotiated rates on individual units

4. **Unified Promotional and Duration-Based Pricing**:
   - Enhanced pricing tier system with date range support
   - Explicit promotional pricing with guaranteed higher priority
   - Support for seasonal pricing, time-limited promotions, and standard duration tiers
   - Priority system to resolve overlapping pricing rules

## Module Descriptions

### 01 - User Management
Contains all user-related tables including user accounts, profiles, verification, roles, and permissions. Includes tenant-level currency settings and client discount management.

### 02 - Item Management
Contains item listings, categories, attributes, and availability. Includes comprehensive pricing features such as rate units, pricing tiers, add-ons, promotional pricing, and tax handling.

### 03 - Order Management
Contains order processing, payments, and logistics. Includes custom pricing overrides and add-on selections at the order item unit level.

## Future Enhancements

Planned pricing features for future tiers include:
- Volume-based discounts
- Bundle pricing
- Loyalty program pricing
- Dynamic pricing based on demand
- Competitor-based pricing adjustments

## Notes
- All pricing features maintain proper normalization and referential integrity
- The system is designed to be extensible for future pricing strategies
- Pricing calculations should be handled at the application level using the data structures provided