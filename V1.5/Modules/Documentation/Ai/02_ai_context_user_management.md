# User Management Module - AI Context

## [CRITICAL] Module Purpose

The User Management module (01) handles all user-related functionality in the Rentable™ system, including user accounts, profiles, verification, roles, and permissions. It serves as the foundation for user identity and organization management.

## [IMPORTANT] Key Entities

### 1. User Reference

**Purpose**: Provides a reference point for user identity.

**Entity**: `user_ref`
- Contains the `user_id` as the primary key
- Serves as a lightweight reference to external authentication systems

### 2. Profile

**Purpose**: Stores detailed information about users and organizations.

**Entity**: `profile`
- Linked to a user via `user_id`
- Classified by `profile_type` (individual or organization)
- Contains personal details for individuals (name, date of birth)
- Contains organization details for businesses (organization name, SIRET number)
- References currency settings via `currency_code`

**Business Rules**:
- A user can have multiple profiles (e.g., personal and business)
- Profiles serve as the core identity for both renters and owners
- Organization profiles can define custom settings and preferences

### 3. Profile Discount

**Purpose**: Manages discount settings for profiles.

**Entity**: `profile_discount`
- Links to a profile via `profile_id`
- Stores percentage-based discount information
- Includes validation to ensure non-negative discount values

**Business Rules**:
- Default client discounts can be assigned to profiles
- Discounts are applied automatically during order creation
- Discounts can be overridden at the order level

### 4. Profile Role

**Purpose**: Manages user roles within organizations.

**Entity**: `profile_role`
- Links a user profile to an organization profile
- Assigns specific roles via `role_id`
- Includes active status and time period

**Business Rules**:
- Users can have multiple roles within the same organization
- Roles determine permissions and access levels
- Role assignments can be time-limited

### 5. Operator Profile

**Purpose**: Manages equipment operators who may not have platform accounts.

**Entity**: `operator_profile`
- Contains basic information about equipment operators
- Can be linked to orders without requiring a full platform account
- Tracks certifications and qualifications

**Business Rules**:
- Operators can be assigned to orders for equipment requiring specialized operation
- Operator profiles can be created by organizations for their staff
- Certification documents can be linked to operator profiles

## [CONTEXT] Relationships with Other Modules

### Organization Management Module
- Provides the profile reference for organization-specific settings
- Referenced by `organization_usage_metric.organization_profile_id`

### Item Management Module
- Profiles own items via `item.owner_profile_id`
- Profiles can be assigned to various item-related entities

### Order Management Module
- Profiles participate in orders as both renters and owners
- Referenced in various order-related tables

### Document Management Module
- Profiles can have associated documents (licenses, certifications)
- Documents can be uploaded and verified for profiles

## [IMPORTANT] Implementation Patterns

### Profile Types
- The `profile_type` enum distinguishes between individual and organization profiles
- This affects how profiles are used throughout the system

### Currency Handling
- Currency is normalized through the `currency` table
- Profiles reference currencies via `currency_code`

## [CONTEXT] Technical Notes

1. This module must be deployed early in the sequence (01)
2. Many foreign key constraints from other modules reference the `profile` table
3. The module follows the standard naming convention: `01_01_user_management_module.sql`

## [CRITICAL] Business Context

In the Rentable™ system, profiles represent both sides of rental transactions:

1. **Renters** (individuals or organizations) who:
   - Search for and rent equipment
   - Make payments and provide required documentation
   - Report usage and return equipment

2. **Owners** (typically organizations) who:
   - List equipment for rent
   - Define pricing and availability
   - Verify documentation and manage handovers

The profile system is designed to support both B2B, B2C, and P2P rental scenarios with appropriate verification and documentation requirements for each context.
