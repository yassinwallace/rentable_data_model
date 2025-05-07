# Order Management Module - AI Context

## [CRITICAL] Module Purpose

The Order Management module (03) handles all aspects of rental transactions in the Rentable system. It manages orders, payments, logistics, item handovers, returns, and usage tracking. This module implements the core business processes that connect renters with equipment owners.

## [IMPORTANT] Key Entities

### 1. Order

**Purpose**: Represents a rental agreement between a renter and an equipment owner.

**Entity**: `order`
- Links to the renter via `ordered_by_profile_id`
- Links to the owner via `owner_profile_id`
- References the item via `item_id`
- Tracks rental period with `start_time` and `end_time`
- Has status tracking via `order_status` enum
- Includes pricing information: `total_price`, `total_tax_amount`, `currency_code`
- Specifies payment method via `payment_method` enum (authoritative)
- Optionally stores preferred payment method via `preferred_payment_method` (intent)

**Business Rules**:
- Orders represent the contractual agreement for equipment rental
- Order status progresses through a defined lifecycle (pending → confirmed → in_progress → completed)
- Orders can also be cancelled or disputed
- Tax information is copied from item_tax_assignment to the order for historical consistency
- Payment method affects invoicing and payout behavior, especially for cash payments
- Preferred payment method tracks the renter's intent during checkout (useful for UX)
- Actual payment method is the authoritative record of how payment was processed

### 2. Order Item Unit

**Purpose**: Links specific physical units to an order.

**Entity**: `order_item_unit`
- Links to an order via `order_id`
- Links to a specific item unit via `item_unit_id`
- Can override pricing with `custom_price` and `rate_unit`
- Includes tax information: `tax_id`, `tax_rate`, `tax_amount`, `tax_included_in_price`

**Business Rules**:
- Multiple units can be assigned to a single order
- Each unit can have custom pricing that overrides the default
- Tax information is preserved for historical accuracy

### 3. Order Item Unit Add-on

**Purpose**: Tracks add-ons selected for specific item units in an order.

**Entity**: `order_item_unit_addon`
- Links to an order item unit via `order_item_unit_id`
- References an add-on via `addon_id`
- Includes quantity and optional custom pricing

**Business Rules**:
- Add-ons are associated with specific item units, not the entire order
- Custom pricing can override the default add-on price
- Quantities allow for multiple instances of the same add-on

### 4. Order Unit Metric Reading

**Purpose**: Tracks usage metrics for item units during a rental.

**Entity**: `order_unit_metric_reading`
- Links to an order via `order_id`
- Links to an item unit via `item_unit_id`
- References a metric via `metric_id`
- Records readings with `reading_type` (start, end, value), `value`, and reporting details

**Business Rules**:
- Metric types determine how readings are recorded:
  - **Stock metrics** (cumulative counters): Require both start and end readings
    - Start value is captured at handover
    - End value is captured at return
    - The difference represents usage during the rental
  - **Flow metrics** (consumption): Require a single value reading
    - A single value represents the total consumption during the rental
- Readings are reported by the owner at handover and return
- Historical data is preserved (no overwriting)
- Readings can be used for usage-based billing calculations

### 5. Order Payment

**Purpose**: Tracks payments associated with an order.

**Entity**: `order_payment`
- Links to an order via `order_id`
- Links to the paying profile via `profile_id`
- Includes amount, payment type, and status
- Tracks payment timing and external references

**Business Rules**:
- Orders can have multiple payments (rent, deposit, extras)
- Payment status progresses through a defined lifecycle
- Deposits are tracked separately with their own status

### 6. Order Logistics Action

**Purpose**: Tracks delivery and pickup activities for an order.

**Entity**: `order_logistics_action`
- Links to an order via `order_id`
- Defines action type (delivery, pickup)
- Tracks who is responsible (owner, renter, third party)
- Includes scheduling information and status
- Records actual execution time and details

**Business Rules**:
- Logistics actions are created based on the selected logistics options
- Status progresses through a defined lifecycle (scheduled → in_progress → completed)
- Logistics actions can be rescheduled if needed
- Actual execution details are recorded for historical reference

### 7. Incident Tracking and Dispute Resolution

**Purpose**: Provides a structured system for tracking incidents, managing disputes, and processing financial claims.

#### Order Incident

**Entity**: `order_incident`
- Links to an order via `order_id`
- Records who reported the incident via `reported_by_profile_id`
- Categorizes incidents by `incident_type` (damage, malfunction, loss, injury, delay, other)
- Tracks when the incident occurred via `reported_during` (handover, in_use, return, other)
- Includes detailed description and supporting evidence (photos, documents)
- Has status tracking via `incident_status` enum (open, resolved, archived)

**Business Rules**:
- Incidents capture any issue reported during a rental, whether or not a dispute is raised
- Incidents can be resolved directly without escalation to a dispute
- Supporting evidence can be attached to document the incident
- Each incident has a clear lifecycle from reporting to resolution

#### Order Dispute

**Entity**: `order_dispute`
- Links to an incident via `order_incident_id`
- Records who raised the dispute via `raised_by_profile_id`
- Includes the reason for disputing the incident outcome
- Has status tracking via `dispute_status` enum (open, under_review, resolved, rejected)
- Tracks resolution details and who reviewed the dispute

**Business Rules**:
- Disputes are formal challenges to incident outcomes or responsibility
- Each incident can have at most one dispute (0..1 relationship)
- Disputes follow a defined review process with clear status transitions
- Resolution details are recorded for audit and compliance purposes

#### Deposit Claim

**Entity**: `deposit_claim`
- Optionally links to a dispute via `order_dispute_id`
- Links to a deposit via `order_deposit_id`
- Records the claim amount, reason, and category
- Has status tracking via `approval_status` enum
- Tracks who approved the claim and when

**Business Rules**:
- Claims represent financial actions against deposits
- Multiple claims can be associated with a single dispute (e.g., repair costs, late fees)
- Claims must have a positive amount (enforced by constraint)
- Claims can be categorized for reporting and analytics
- Each claim follows an approval workflow

**Relationship Structure**:
- Order → Incidents: One-to-many (an order can have multiple incidents)
- Incident → Dispute: One-to-zero-or-one (an incident may escalate to a dispute)
- Dispute → Claims: One-to-many (a dispute can result in multiple financial claims)

This structured approach enables clean workflows, transparent history, and clear financial/operational accountability throughout the incident management process.

### 8. Rental Billing and Platform Fee Tracking

**Purpose**: Provides a comprehensive invoicing system for rental transactions and platform fee management.

#### Invoice

**Entity**: `invoice`
- Links to an order via `order_id`
- Classified by `invoice_type` (rental, platform_fee, service_fee)
- Records issuer and recipient profiles
- Includes financial details: total amount, tax amount, currency
- Specifies the actual payment method used via `payment_method` enum
- Has status tracking via `invoice_status` enum
- Tracks important dates: issue date, due date, paid date

**Business Rules**:
- Different invoice types are generated based on the invoice's payment method:
  - **For Online Payments (card, wallet, bank_transfer)**:
    - **Rental Invoice**: Issued by the platform on behalf of the owner to the renter
    - **Platform Fee Invoice**: Issued by the platform to the owner
  - **For Cash Payments (cash_on_delivery)**:
    - **Platform Fee Invoice**: Issued by the platform to the renter for platform fees only
    - No rental invoice is generated as payment is handled offline by the owner
- The payment method on the invoice is the authoritative record of how payment was processed
- Rental invoices include the total rental price (with platform fee bundled)
- Platform fee invoices show only the commission charged by the platform
- Each invoice has a unique invoice number for legal and accounting purposes
- Invoices progress through a defined lifecycle (draft → issued → paid)

#### Invoice Line Item

**Entity**: `invoice_line_item`
- Links to an invoice via `invoice_id`
- Contains detailed information about each charge
- Includes quantity, unit price, and total price
- Can include tax rate and amount
- References the specific item being charged (e.g., rental, add-on)

**Business Rules**:
- Line items provide itemized breakdown of charges
- Each line item can reference the specific entity it represents
- Tax information is preserved for accounting and compliance
- Quantities and prices must be positive (enforced by constraints)

#### Platform Fee Configuration

**Entity**: `platform_fee_config`
- Links to an organization profile via `organization_profile_id`
- Defines how platform fees are calculated for that organization
- Supports multiple calculation methods:
  - Percentage-based fees (percentage of order value)
  - Flat fees (fixed amount per order)
  - Tiered fees (based on order value ranges)
- Includes minimum and maximum fee amounts
- Has effective date range for fee changes over time

**Business Rules**:
- Each organization can have its own fee structure
- Fee configurations can change over time with effective dates
- Minimum fees ensure platform revenue even for small orders
- Maximum fees cap the platform's take on large orders
- Constraints ensure fee values are within valid ranges

#### Order Payout

**Entity**: `order_payout`
- Links to an order via `order_id`
- Links to the owner profile via `owner_profile_id`
- References both rental and platform fee invoices
- Tracks gross amount, fee amount, and net amount
- Includes comprehensive status tracking and financial metadata:
  - Status via `payout_status` enum (pending, processing, paid, failed)
  - Payout method via `payout_method` enum (stripe_transfer, manual, bank_transfer, etc.)
  - Financial provider details (name, account type, masked account ID)
  - Timestamps for creation, processing, and payment
  - Payment references and failure reasons

**Business Rules**:
- Payouts represent the financial settlement between platform and owner
- Payouts are only created when specific conditions are met (enforced by database trigger):
  - The related order must be marked as completed
  - The rental invoice must be marked as paid
  - The payment method cannot be cash_on_delivery
- Gross amount equals the sum of net amount and fee amount (enforced by constraint)
- Each eligible order has exactly one payout record (per-order payout model)
- For cash payment orders (`payment_method` = 'cash_on_delivery'):
  - No payout record is created since the platform holds no rental funds
  - The rental payment is handled offline directly between renter and owner
  - Only the platform fee is processed through the platform
- Payout status progresses through a defined lifecycle (pending → processing → paid)
- Detailed financial tracking supports audit requirements and reconciliation

**Relationship Structure**:
- Order → Invoices: One-to-many (an order has multiple invoices of different types)
- Invoice → Line Items: One-to-many (an invoice contains multiple line items)
- Organization → Fee Config: One-to-many (an organization can have multiple fee configurations over time)
- Order → Payout: One-to-one for online payments, none for cash payments

This structured approach enables comprehensive financial tracking, clear fee transparency, and proper accounting for both the platform and equipment owners, while supporting both online and offline payment scenarios.

## [CONTEXT] Relationships with Other Modules

### User Management Module
- Orders link to profiles for both renters and owners
- Payment information is associated with profiles

### Item Management Module
- Orders reference items and specific item units
- Pricing information flows from items to orders
- Add-ons from items can be selected in orders

### Organization Management Module
- Usage metrics defined by organizations are tracked in orders
- Metric readings are recorded during the rental lifecycle

### Document Management Module
- Orders can have associated documents (agreements, waivers, inspection forms)
- Documents may be required at different stages of the order lifecycle

## [IMPORTANT] Implementation Patterns

### Status Tracking
- Various enum types track the status of orders, payments, and other entities
- Status transitions follow defined business processes

### Custom Pricing
- The system allows overriding default pricing at multiple levels
- Tax information is preserved for historical accuracy

### Usage Tracking
- The flexible metric system supports different types of usage measurements
- Readings are recorded at specific points in the rental lifecycle

## [CONTEXT] Technical Notes

1. This module contains the most complex business processes in the system
2. Many entities have status fields that follow defined state machines
3. The module follows the standard naming convention: `01_03_order_management_module.sql`

## [CRITICAL] Business Context

The order management system supports the complete rental lifecycle:

1. **Order Creation**:
   - Renter selects item, time period, and add-ons
   - System checks availability and calculates pricing
   - Order is created with pending status

2. **Confirmation Process**:
   - Owner reviews and confirms the order
   - Required documents are verified
   - Payment processing begins

3. **Handover Process**:
   - Physical equipment is handed over to the renter
   - Initial usage metrics are recorded
   - Condition is documented

4. **Rental Period**:
   - Equipment is in use by the renter
   - Extensions or modifications can be requested

5. **Return Process**:
   - Equipment is returned to the owner
   - Final usage metrics are recorded
   - Condition is assessed for damage

6. **Completion**:
   - Final payments are processed
   - Deposits are returned or claimed
   - Order is marked as completed

The system also handles exceptions like cancellations, disputes, and damage claims throughout this lifecycle.
