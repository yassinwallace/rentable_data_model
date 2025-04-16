-- ==========================================
-- Cross-Module Foreign Keys for Security & Compliance Module (STEP 22)
-- ==========================================
-- This file contains all foreign key relationships between the Security & Compliance module
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
-- 3. Security & Compliance Module (21_10_security_compliance_module.sql)
-- 
-- Deployment order: 22 (twentieth deployment step)

-- ==========================================
-- Foreign Keys from Security & Compliance to User Management
-- ==========================================
ALTER TABLE security_incident ADD FOREIGN KEY (reported_by) REFERENCES "user" (id);
ALTER TABLE compliance_report ADD FOREIGN KEY (submitted_by) REFERENCES "user" (id);
ALTER TABLE data_access_request ADD FOREIGN KEY (user_id) REFERENCES "user" (id);

-- ==========================================
-- Foreign Keys from Security & Compliance to Admin & Support
-- ==========================================
ALTER TABLE security_incident ADD FOREIGN KEY (assigned_to) REFERENCES admin_user (id);
ALTER TABLE security_alert ADD FOREIGN KEY (resolved_by) REFERENCES admin_user (id);