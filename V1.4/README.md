# Rentable Database Schema - Modular Deployment Strategy (V1.4)

## Overview

This directory contains the modularized database schema for the Rentable application. The schema has been split into separate modules to enable phased deployment and better organization.

## Module Structure

Each module is contained in its own file and includes:
- Tables related to that module
- ENUM types specific to that module
- Indexes for the module's tables
- Foreign keys where both the referencing and referenced tables are within the same module
- Prerequisites section indicating which modules must be deployed first

## File Naming Convention

Files are named according to their deployment sequence and module number:

### Base Module Files
Format: `XX_YY_module_name.sql`
- XX: Deployment step number (01, 02, 04, etc.)
- YY: Module number from Module grouping.md (01 for User Management, 02 for Business Management, etc.)

Examples:
- `01_01_user_management_module.sql` - First deployment step, User Management module
- `02_02_business_management_module.sql` - Second deployment step, Business Management module
- `04_03_item_management_module.sql` - Fourth deployment step, Item Management module

### Cross-Module Foreign Key Files
Format: `XX_cross_module_fk.sql`
- XX: Deployment step number (03, 05, etc.)

Examples:
- `03_cross_module_fk.sql` - Third deployment step, cross-module FKs between modules 01 and 02
- `05_cross_module_fk.sql` - Fifth deployment step, cross-module FKs for module 03

## Deployment Sequence

To ensure proper database creation, the files must be executed in the following order:

1. `01_01_user_management_module.sql` - User tables, roles, permissions
2. `02_02_business_management_module.sql` - Business profiles and assignments
3. `03_cross_module_fk.sql` - Foreign keys between User and Business modules
4. `04_03_item_management_module.sql` - Items, categories, attributes
5. `05_cross_module_fk.sql` - Foreign keys for Item Management module
6. `06_04_location_management_module.sql` - Addresses, locations, and related data
7. `07_cross_module_fk.sql` - Foreign keys for Location Management module
8. `08_location_polymorphic_validations.sql` - Validation triggers for polymorphic relationships
9. `09_05_booking_transactions_module.sql` - Bookings, payments, transactions
10. `10_cross_module_fk.sql` - Foreign keys for Booking & Transactions module
11. `11_06_reviews_ratings_module.sql` - Reviews, ratings, user reputation
12. `12_cross_module_fk.sql` - Foreign keys for Reviews & Ratings module
13. `13_07_messaging_module.sql` - Conversations, messages, notifications
14. `14_cross_module_fk.sql` - Foreign keys for Messaging module
15. `15_08_admin_support_module.sql` - Admin users, support tickets, FAQs
16. `16_cross_module_fk.sql` - Foreign keys for Admin & Support module
17. `17_09_analytics_reporting_module.sql` - Analytics, metrics, dashboards
18. `18_cross_module_fk.sql` - Foreign keys for Analytics & Reporting module
19. `19_10_security_compliance_module.sql` - Security, compliance, data protection
20. `20_cross_module_fk.sql` - Foreign keys for Security & Compliance module

## Module Descriptions

### 01 - User Management
Contains all user-related tables including user accounts, profiles, verification, roles, and permissions.

### 02 - Business Management
Contains business profiles and business-related data structures.

### 03 - Item Management
Contains item listings, categories, attributes, and availability.

### 04 - Location Management
Contains addresses, locations, and related data.

### 05 - Booking & Transactions
Contains bookings, payments, transactions, and related data.

### 06 - Reviews & Ratings
Contains reviews, ratings, user reputation, and related data.

### 07 - Messaging
Contains conversations, messages, notifications, and related data.

### 08 - Admin & Support
Contains admin users, support tickets, FAQs, and related data.

### 09 - Analytics & Reporting
Contains analytics, metrics, dashboards, and related data.

### 10 - Security & Compliance
Contains security, compliance, data protection, and related data.

## Remaining Tables to be Modularized

The following modules still need to be created from the remaining tables in mono_tenant_template.sql:

(No remaining modules)

## Notes
- The original schema is preserved in `mono_tenant_template.sql` for reference
- Each module file contains comments indicating what was moved from the original schema
- Cross-module dependencies are clearly documented in each file's prerequisites section
