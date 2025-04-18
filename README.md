# Rentable Database Schema - Modular Deployment Strategy

## Overview

This directory contains the modularized database schema for the Rentable application. The schema has been split into separate modules to enable phased deployment and better organization.

## Module Structure

Each module is contained in its own file and includes:
- Tables related to that module
- ENUM types specific to that module
- Indexes for the module's tables
- Foreign keys where both the referencing and referenced tables are within the same module

## Cross-Module Foreign Keys

Foreign keys that reference tables across different modules are placed in separate files named according to the modules they connect:
- `01_02_cross_module_fk.sql` contains foreign keys between User Management (01) and Business Management (02)
- Additional cross-module FK files will be created as needed

## Deployment Sequence

To ensure proper database creation, the files must be executed in the following order:

### 1. Base Module Files (in numerical order)
1. `01_user_management_module.sql` - User tables, roles, permissions
2. `02_business_management_module.sql` - Business profiles and assignments
3. `03_item_management_module.sql` - Items, categories, attributes
4. (Additional module files as they are created)

### 2. Cross-Module Foreign Key Files
After all base modules have been deployed, execute the cross-module foreign key files:
1. `01_02_cross_module_fk.sql` - Foreign keys between User and Business modules
2. (Additional cross-module FK files as they are created)

### 3. Final Verification
After all files have been executed, verify database integrity and relationships.

## Module Descriptions

### 01 - User Management
Contains all user-related tables including user accounts, profiles, verification, roles, and permissions.

### 02 - Business Management
Contains business profiles and business-related data structures.

### 03 - Item Management
Contains item listings, categories, attributes, and availability.

(Additional module descriptions will be added as they are created)

## Notes
- The original schema is preserved in `mono_tenant_template.sql` for reference
- Each module file contains comments indicating what was moved from the original schema
