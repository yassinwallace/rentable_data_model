-- ==========================================
-- Cross-Module Foreign Keys (Step 03)
-- ==========================================
-- This file contains foreign key relationships between:
-- - User Management module (01_01_user_management_module.sql)
-- - Business Management module (02_02_business_management_module.sql)
--
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- Requires prior deployment of:
-- - 01_01_user_management_module.sql
-- - 02_02_business_management_module.sql
--
-- Deployment order: 03 (third deployment step)

-- ==========================================
-- Foreign Keys
-- ==========================================
-- Foreign keys from User Management tables to Business Management tables
ALTER TABLE user_business_roles_assignment ADD FOREIGN KEY (business_profile_id) REFERENCES business_profile (id);

-- Note: Foreign keys from Business Management tables to User Management tables
-- are already defined in the Business Management module (02_02_business_management_module.sql)
-- because they reference tables that are created earlier in the deployment sequence.