-- ==========================================
-- Cross-Module Foreign Keys (Step 05)
-- ==========================================
-- This file contains foreign key relationships between:
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
--
-- Deployment order: 05 (fifth deployment step)

-- ==========================================
-- Foreign Keys
-- ==========================================
-- Foreign keys from Item Management tables to User Management tables
ALTER TABLE item_history ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE bulk_import ADD FOREIGN KEY (user_id) REFERENCES "user" (id);

-- Foreign keys from Item Management tables to Business Management tables
ALTER TABLE bulk_import ADD FOREIGN KEY (business_id) REFERENCES business (id);