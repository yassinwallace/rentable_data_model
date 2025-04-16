-- ==========================================
-- Cross-Module Foreign Keys for Analytics & Reporting Module (STEP 20)
-- ==========================================
-- This file contains all foreign key relationships between the Analytics & Reporting module
-- and other modules (User Management, Admin & Support)
-- 
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- This file depends on:
-- 1. User Management Module (01_01_user_management_module.sql)
-- 2. Admin & Support Module (17_08_admin_support_module.sql)
-- 3. Analytics & Reporting Module (19_09_analytics_reporting_module.sql)
-- 
-- Deployment order: 20 (twentieth deployment step)

-- ==========================================
-- Foreign Keys from Analytics & Reporting to User Management
-- ==========================================
ALTER TABLE analytics_event ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE data_export ADD FOREIGN KEY (user_id) REFERENCES "user" (id);

-- ==========================================
-- Foreign Keys from Analytics & Reporting to Admin & Support
-- ==========================================
ALTER TABLE report ADD FOREIGN KEY (created_by) REFERENCES admin_user (id);
ALTER TABLE user_segment ADD FOREIGN KEY (created_by) REFERENCES admin_user (id);
ALTER TABLE dashboard ADD FOREIGN KEY (created_by) REFERENCES admin_user (id);
ALTER TABLE ab_test ADD FOREIGN KEY (created_by) REFERENCES admin_user (id);