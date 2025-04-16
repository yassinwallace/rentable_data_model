-- ==========================================
-- Cross-Module Foreign Keys (Step 08)
-- ==========================================
-- This file contains foreign key relationships between:
-- - Location Management module (07_04_location_management_module.sql)
-- - User Management module (01_01_user_management_module.sql)
-- - Business Management module (02_02_business_management_module.sql)
-- - Item Management module (04_03_item_management_module.sql)
--
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- Requires prior deployment of:
-- - 01_01_user_management_module.sql
-- - 02_02_business_management_module.sql
-- - 04_03_item_management_module.sql
-- - 07_04_location_management_module.sql
--
-- Deployment order: 08 (eighth deployment step)

-- ==========================================
-- Foreign Keys
-- ==========================================
-- Foreign keys from Location Management tables to User Management tables
-- (when owner_type = 'user')
-- These are dynamic foreign keys based on the owner_type value

-- Foreign keys from Location Management tables to Business Management tables
-- (when owner_type = 'business')
-- These are dynamic foreign keys based on the owner_type value

-- Foreign keys from Location Management tables to Item Management tables
-- (when linked_entity_type = 'item')
-- These are dynamic foreign keys based on the linked_entity_type value

-- Note: The Location Management module uses polymorphic associations through
-- owner_type/owner_id and linked_entity_type/linked_entity_id fields.
-- These relationships are typically enforced at the application level rather than
-- through database foreign keys, as PostgreSQL doesn't directly support polymorphic
-- associations with foreign key constraints.
