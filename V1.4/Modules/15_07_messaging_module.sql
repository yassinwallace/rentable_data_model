-- ==========================================
-- Messaging Module (STEP 15)
-- ==========================================
-- This file contains all database objects related to Messaging:
-- - Tables: conversation, message, message_attachment, system_notification, etc.
-- - ENUMs: message_type
-- - Foreign Keys and Indexes related to Messaging tables
-- 
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- This module depends on:
-- 1. User Management Module (01_01_user_management_module.sql)
-- 2. Item Management Module (04_03_item_management_module.sql)
-- 
-- Deployment order: 15 (fifteenth deployment step)
-- Module number: 07 (Messaging)

-- ==========================================
-- ENUM Types
-- ==========================================
CREATE TYPE message_type AS ENUM('text','system','attachment');

-- ==========================================
-- Tables
-- ==========================================
CREATE TABLE conversation (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id UUID,
    last_message_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE message (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    conversation_id UUID NOT NULL,
    sender_id UUID NOT NULL,
    content TEXT NOT NULL,
    message_type message_type NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE message_attachment (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    message_id UUID NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_size INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE conversation_participant (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    conversation_id UUID NOT NULL,
    user_id UUID NOT NULL,
    last_read_message_id UUID,
    is_archived BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE message_status (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    message_id UUID NOT NULL,
    recipient_id UUID NOT NULL,
    is_delivered BOOLEAN DEFAULT false,
    is_read BOOLEAN DEFAULT false,
    delivered_at TIMESTAMP,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE system_notification (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    notification_type VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    related_entity_type VARCHAR(50),
    related_entity_id UUID,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE message_template (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    template_name VARCHAR(100) NOT NULL,
    template_content TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE auto_responder (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    is_active BOOLEAN DEFAULT false,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE message_analytics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    average_response_time INTERVAL,
    messages_sent INTEGER DEFAULT 0,
    messages_received INTEGER DEFAULT 0,
    last_updated_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

-- ==========================================
-- Indexes
-- ==========================================
CREATE INDEX ON conversation (item_id);
CREATE INDEX ON conversation (last_message_at);
CREATE INDEX ON message (conversation_id);
CREATE INDEX ON message (sender_id);
CREATE INDEX ON message (created_at);
CREATE INDEX ON message_attachment (message_id);
CREATE INDEX ON conversation_participant (conversation_id);
CREATE INDEX ON conversation_participant (user_id);
CREATE INDEX ON conversation_participant (last_read_message_id);
CREATE INDEX ON message_status (message_id);
CREATE INDEX ON message_status (recipient_id);
CREATE INDEX ON system_notification (user_id);
CREATE INDEX ON system_notification (is_read);
CREATE INDEX ON auto_responder (user_id);
CREATE INDEX ON auto_responder (is_active);
CREATE INDEX ON message_analytics (user_id);

-- ==========================================
-- Foreign Keys (Internal to this module)
-- ==========================================
ALTER TABLE message ADD FOREIGN KEY (conversation_id) REFERENCES conversation (id);
ALTER TABLE message_attachment ADD FOREIGN KEY (message_id) REFERENCES message (id);
ALTER TABLE conversation_participant ADD FOREIGN KEY (conversation_id) REFERENCES conversation (id);
ALTER TABLE conversation_participant ADD FOREIGN KEY (last_read_message_id) REFERENCES message (id);
ALTER TABLE message_status ADD FOREIGN KEY (message_id) REFERENCES message (id);

-- Note: Cross-module foreign keys will be defined in a separate file (16_cross_module_fk.sql)