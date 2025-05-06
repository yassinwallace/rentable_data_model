# Item Management Module - AI Context

## [CRITICAL] Module Purpose

The Item Management module (02) is the core of the Rentable equipment rental system. It manages equipment listings, categories, attributes, availability, and pricing. This module implements the foundational concepts of items, item units, and the comprehensive pricing system.

## [IMPORTANT] Key Entities

### 1. Item

**Purpose**: Represents a type or template of equipment that can be rented.

**Entity**: `item`
- Owned by an organization profile via `owner_profile_id`
- Has basic details: title, description, base price
- References currency via `currency_code`
- Has status, condition, and type classifications
- Includes rental period constraints and logistics settings
- Has a default `rate_unit` (hour, day, week, month)

**Business Rules**:
- Items are templates for rentable equipment, not specific physical units
- Items can have multiple physical units (item_unit)
- Items have a base price that can be overridden by pricing tiers
- Items define the common characteristics shared by all units of that type

### 2. Item Unit

**Purpose**: Represents a specific physical instance of an item that is actually rented.

**Entity**: `item_unit`
- Belongs to an item via `item_id`
- Has identifying information: serial number, internal reference
- Tracks condition and location
- Can be marked active/inactive

**Business Rules**:
- Item units are the actual physical equipment that gets rented
- Each unit can have its own availability schedule
- Units can be tracked individually for maintenance and location
- All logistics, usage tracking, and handovers apply to specific units, not to the template item

### 3. Item Pricing Tier

**Purpose**: Implements flexible, multi-dimensional pricing.

**Entity**: `item_pricing_tier`
- Links to an item via `item_id`
- Defines pricing based on rental duration (`min_duration`, `max_duration`)
- Supports different rate units (hour, day, week, month)
- Can be time-limited with `start_date` and `end_date`
- Can be marked as promotional with higher priority
- Supports different tier types (standard, promotional, seasonal)

**Business Rules**:
- Pricing tiers can overlap, with priority determining which applies
- Promotional pricing always takes precedence (enforced by CHECK constraint)
- Pricing can vary based on rental duration, time period, and rate unit
- Pricing tiers only affect price, not availability - they do not reserve or block inventory

### 4. Item Add-on

**Purpose**: Defines optional or required add-ons for items.

**Entity**: `item_addon`
- Links to an item via `item_id`
- Has name, description, and price
- Can be marked as required or optional

**Business Rules**:
- Add-ons can be selected when creating an order
- Required add-ons must be included in all rentals of the item
- Add-ons have their own pricing separate from the base item

### 5. Tax

**Purpose**: Defines tax rates that can be applied to items.

**Entity**: `tax`
- Has name, rate, and active status
- Linked to items via `item_tax_assignment`

**Business Rules**:
- Taxes can be included in the price or added separately
- Multiple taxes can be applied to a single item
- Tax assignments are tracked in orders for historical accuracy

### 6. Item Logistics Option

**Purpose**: Defines delivery and pickup options for items.

**Entity**: `item_logistics_option`
- Links to an item via `item_id`
- Defines who handles delivery and pickup (owner, renter, third party)
- Includes pricing for delivery and pickup services
- Can specify distance limitations and conditions

**Business Rules**:
- Multiple logistics options can be defined for a single item
- Options can be restricted by distance or location
- Logistics pricing can be flat-rate or distance-based

### 7. Item Unit Availability Management

**Purpose**: Manages when item units can be rented and when handovers can occur.

**Entities**:
- `item_unit_block_date`: Periods when a unit is completely unavailable for rental
- `item_unit_blackout_date`: Periods when handovers/returns are restricted, but the rental period can include these dates

**Business Rules**:
- Block dates make a unit completely unavailable for any rental that overlaps with the block period
- Blackout dates only restrict when handovers and returns can occur
- A rental can span blackout dates as long as handover and return are outside those dates
- Different availability types affect how conflicts are handled:
  - `standard`: Normal availability rules apply
  - `promotional`: Special promotional availability that may override standard rules
  - `soft_block`: Tentative block that can be overridden if necessary

## [CONTEXT] Relationships with Other Modules

### User Management Module
- Items are owned by profiles via `owner_profile_id`
- References the currency table for pricing

### Order Management Module
- Orders reference items and item units
- Pricing information flows from this module to orders
- Add-ons can be selected in orders

### Document Management Module
- Items and item units can have associated documents
- Documents may be required for compliance

## [IMPORTANT] Implementation Patterns

### Tiered Pricing System
- The unified pricing tier system handles both duration-based and time-window pricing
- Priority system resolves conflicts when multiple tiers could apply
- Promotional pricing is explicitly flagged and given higher priority

### Enum Usage
- `item_status`, `item_condition`, `item_type` classify items
- `rate_unit` defines the time unit for pricing (hour, day, week, month)

## [CONTEXT] Technical Notes

1. This module contains some of the most complex business logic in the system
2. The pricing tier system was refactored to unify duration-based and promotional pricing
3. The module follows the standard naming convention: `01_02_item_management_module.sql`

## [CRITICAL] Business Context

The item management system supports various equipment rental scenarios:

1. **Equipment Types**:
   - Heavy machinery (excavators, bulldozers)
   - Construction equipment
   - Specialized tools
   - Vehicles and transportation equipment

2. **Rental Models**:
   - B2B: Business renting to other businesses
   - B2C: Business renting to consumers
   - P2P: Peer-to-peer equipment sharing

3. **Pricing Strategies**:
   - Duration-based discounts (longer rentals = lower daily rate)
   - Seasonal pricing (higher rates during peak seasons)
   - Promotional pricing (time-limited special offers)
   - Add-on services (operators, fuel, attachments, delivery)

The flexible pricing system accommodates complex real-world pricing scenarios while maintaining a clear and normalized database structure.
