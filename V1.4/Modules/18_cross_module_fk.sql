-- ==========================================
-- Cross-Module Foreign Keys for Admin & Support Module (STEP 18)
-- ==========================================
-- This file contains all foreign key relationships between the Admin & Support module
-- and other modules (User Management)
-- 
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- This file depends on:
-- 1. User Management Module (01_01_user_management_module.sql)
-- 2. Admin & Support Module (17_08_admin_support_module.sql)
-- 
-- Deployment order: 18 (eighteenth deployment step)

-- ==========================================
-- Foreign Keys from Admin & Support to User Management
-- ==========================================
ALTER TABLE admin_user ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE support_ticket ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE content_moderation ADD FOREIGN KEY (reported_by) REFERENCES "user" (id);
ALTER TABLE support_ticket_comment ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE audit_trail ADD FOREIGN KEY (user_id) REFERENCES "user" (id);