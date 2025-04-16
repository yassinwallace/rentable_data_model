-- ==========================================
-- Admin & Support Module (STEP 17)
-- ==========================================
-- This file contains all database objects related to Admin & Support:
-- - Tables: admin_user, support_ticket, system_setting, content_moderation, etc.
-- - ENUMs: admin_user_role, admin_user_status, support_ticket_status, etc.
-- - Foreign Keys and Indexes related to Admin & Support tables
-- 
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- This module depends on:
-- 1. User Management Module (01_01_user_management_module.sql)
-- 
-- Deployment order: 17 (seventeenth deployment step)
-- Module number: 08 (Admin & Support)

-- ==========================================
-- ENUM Types
-- ==========================================
CREATE TYPE admin_user_role AS ENUM('super_admin','moderator','support_agent','analyst');
CREATE TYPE admin_user_status AS ENUM('active','suspended','inactive');
CREATE TYPE support_ticket_status AS ENUM('open','in_progress','resolved','closed');
CREATE TYPE support_ticket_priority AS ENUM('low','medium','high','urgent');
CREATE TYPE content_moderation_status AS ENUM('pending','reviewed','action_taken','dismissed');

-- ==========================================
-- Tables
-- ==========================================
CREATE TABLE admin_user (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    admin_user_role admin_user_role NOT NULL,
    admin_user_status admin_user_status NOT NULL,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE support_ticket (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    support_ticket_status support_ticket_status NOT NULL,
    support_ticket_priority support_ticket_priority NOT NULL,
    category VARCHAR(100) NOT NULL,
    assigned_to UUID,
    resolution TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE admin_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    admin_id UUID,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    details JSONB NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE system_setting (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT NOT NULL,
    data_type VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE content_moderation (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    content_type VARCHAR(50) NOT NULL,
    content_id UUID NOT NULL,
    reported_by UUID,
    reason TEXT NOT NULL,
    content_moderation_status content_moderation_status NOT NULL,
    moderated_by UUID,
    action_taken TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE support_ticket_comment (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    ticket_id UUID,
    user_id UUID,
    comment TEXT NOT NULL,
    is_internal BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE faq_category (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE faq (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    category_id UUID,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE admin_notification (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    admin_id UUID,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE audit_trail (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    old_values JSONB,
    new_values JSONB,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

-- ==========================================
-- Indexes
-- ==========================================
CREATE INDEX ON admin_user (user_id);
CREATE INDEX ON admin_user (admin_user_role);
CREATE INDEX ON admin_user (admin_user_status);
CREATE INDEX ON support_ticket (user_id);
CREATE INDEX ON support_ticket (support_ticket_status);
CREATE INDEX ON support_ticket (support_ticket_priority);
CREATE INDEX ON support_ticket (assigned_to);
CREATE INDEX ON admin_log (admin_id);
CREATE INDEX ON admin_log (entity_type, entity_id);
CREATE UNIQUE INDEX ON system_setting (key);
CREATE INDEX ON content_moderation (content_type, content_id);
CREATE INDEX ON content_moderation (reported_by);
CREATE INDEX ON content_moderation (moderated_by);
CREATE INDEX ON content_moderation (content_moderation_status);
CREATE INDEX ON support_ticket_comment (ticket_id);
CREATE INDEX ON support_ticket_comment (user_id);
CREATE INDEX ON faq (category_id);
CREATE INDEX ON faq (is_active);
CREATE INDEX ON admin_notification (admin_id);
CREATE INDEX ON admin_notification (is_read);
CREATE INDEX ON audit_trail (user_id);
CREATE INDEX ON audit_trail (table_name, record_id);

-- ==========================================
-- Foreign Keys (Internal to this module)
-- ==========================================
ALTER TABLE support_ticket ADD FOREIGN KEY (assigned_to) REFERENCES admin_user (id);
ALTER TABLE admin_log ADD FOREIGN KEY (admin_id) REFERENCES admin_user (id);
ALTER TABLE content_moderation ADD FOREIGN KEY (moderated_by) REFERENCES admin_user (id);
ALTER TABLE support_ticket_comment ADD FOREIGN KEY (ticket_id) REFERENCES support_ticket (id);
ALTER TABLE faq ADD FOREIGN KEY (category_id) REFERENCES faq_category (id);
ALTER TABLE admin_notification ADD FOREIGN KEY (admin_id) REFERENCES admin_user (id);

-- Note: Cross-module foreign keys will be defined in a separate file (18_cross_module_fk.sql)