-- ==========================================
-- Cross-Module Foreign Keys for Messaging Module (STEP 16)
-- ==========================================
-- This file contains all foreign key relationships between the Messaging module
-- and other modules (User Management, Item Management)
-- 
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- This file depends on:
-- 1. User Management Module (01_01_user_management_module.sql)
-- 2. Item Management Module (04_03_item_management_module.sql)
-- 3. Messaging Module (15_07_messaging_module.sql)
-- 
-- Deployment order: 16 (sixteenth deployment step)

-- ==========================================
-- Foreign Keys from Messaging to User Management
-- ==========================================
ALTER TABLE message ADD FOREIGN KEY (sender_id) REFERENCES "user" (id);
ALTER TABLE conversation_participant ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE message_status ADD FOREIGN KEY (recipient_id) REFERENCES "user" (id);
ALTER TABLE system_notification ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE auto_responder ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE message_analytics ADD FOREIGN KEY (user_id) REFERENCES "user" (id);

-- ==========================================
-- Foreign Keys from Messaging to Item Management
-- ==========================================
ALTER TABLE conversation ADD FOREIGN KEY (item_id) REFERENCES item (id);