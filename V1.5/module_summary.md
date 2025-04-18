
# 📦 Modular Architecture Overview – Rentable™ / Boilerplate

This document summarizes all implemented and planned modules as of now. Each module is decoupled and reusable, forming a clean SaaS-ready boilerplate that powers Rentable™ and can be adapted for other platforms.

---

## ✅ 1. Core User & Profile Management

Handles identity, roles, and tenant-scoped permissions.

- `profile`: Unified model for individuals and organizations
- `user_ref`: Links tenant profile to global public user
- `profile_membership`: Tracks profile-to-organization membership
- `profile_role`: Assigns roles to profiles (optionally scoped to organization)
- `organization_invitation`: Email-based invitation to join organizations
- `role`: Defines tenant-specific roles
- `permission`: Fine-grained access rights
- `role_permission`: Many-to-many link between roles and permissions

---

## ✅ 2. Item Management

Manages everything about rentable or ownable items.

- `item`: Core table describing the item
- `item_attributes`: Key-value pairs for custom attributes
- `item_availability`: Date-based availability rules
- `item_pricing_tier`: Time-based or dynamic pricing tiers
- `item_maintenance_record`: Maintenance history tracking
- `item_rental_rules`: Custom rules per item
- `item_insurance_options`: Available insurance plans
- `item_bundle`: Item packages
- `item_history`: Logs changes over time

---

## ✅ 3. Location & Address Management

Generic, reusable address module linked to multiple entities.

- `address`: Canonical addresses
- `location`: Represents a geolocated place
- `location_link`: Many-to-many assignments to profiles or items
- `location_hours`: Weekly operating hours
- `location_special_period`: Season-based availability
- `location_holiday_exception`: Exceptions to availability

---

## ✅ 4. Order Module (formerly booking)

Captures the full lifecycle of an order/reservation with full auditability.

- `order`: Main order table
- `order_event`: Event log for all transitions (status, cancellations, disputes, etc.)
- `item_handover`: Tracks physical exchange of the item

---

## ✅ 5. Billing & Payment

Separates money in (payments) from money out (payouts), with invoice logic.

- `invoice`: High-level billing document
- `payment`: Payments from users toward invoices
- `refund`: Refunds tied to payments
- `payout`: Scheduled payments to providers
- `payment_method`: Saved payment details for users

---

## 🔜 Optional / In Progress

Pending integration or optional based on business needs.

- `late_return`, `additional_charge`, `security_deposit`: Auxiliary order-related logic
- `fee`, `tax_rate`, `invoice_line`, `invoice_snapshot`: Advanced billing logic
- `payment_gateway`, `transaction_log`: Payment integrations & audit
- `platform_revenue`: Internal reporting-only table
- `promotional_credit`, `wallet`: Optional incentives and credit system
- `service_level_agreement`: Future compliance/legal feature

---

This modular breakdown ensures Rentable™ is scalable, maintainable, and repurposable across different business domains.
