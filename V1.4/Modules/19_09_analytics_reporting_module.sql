-- ==========================================
-- Analytics & Reporting Module (STEP 19)
-- ==========================================
-- This file contains all database objects related to Analytics & Reporting:
-- - Tables: analytics_event, metric, report, dashboard, data_export, etc.
-- - ENUMs: data_export_status, ab_test_status
-- - Foreign Keys and Indexes related to Analytics & Reporting tables
-- 
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- This module depends on:
-- 1. User Management Module (01_01_user_management_module.sql)
-- 2. Admin & Support Module (17_08_admin_support_module.sql)
-- 
-- Deployment order: 19 (nineteenth deployment step)
-- Module number: 09 (Analytics & Reporting)

-- ==========================================
-- ENUM Types
-- ==========================================
CREATE TYPE data_export_status AS ENUM('pending','processing','completed','failed');
CREATE TYPE ab_test_status AS ENUM('draft','active','completed','cancelled');

-- ==========================================
-- Tables
-- ==========================================
CREATE TABLE analytics_event (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB NOT NULL,
    device_type VARCHAR(50),
    browser_info VARCHAR(255),
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE metric (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15,2) NOT NULL,
    metric_unit VARCHAR(50),
    time_period VARCHAR(50) NOT NULL,
    date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE report (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    report_type VARCHAR(100) NOT NULL,
    configuration JSONB NOT NULL,
    schedule VARCHAR(100),
    last_run_at TIMESTAMP,
    created_by UUID,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE data_warehouse (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    dimension_type VARCHAR(100) NOT NULL,
    dimension_id UUID NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15,2) NOT NULL,
    date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE user_segment (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    criteria JSONB NOT NULL,
    created_by UUID,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE dashboard (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    layout JSONB,
    is_public BOOLEAN DEFAULT false,
    created_by UUID,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE dashboard_widget (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    dashboard_id UUID,
    widget_type VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    configuration JSONB NOT NULL,
    position JSONB,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE data_export (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    export_type VARCHAR(100) NOT NULL,
    data_export_status data_export_status NOT NULL,
    file_url VARCHAR(255),
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE ab_test (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    ab_test_status ab_test_status NOT NULL,
    variants JSONB NOT NULL,
    created_by UUID,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE ab_test_result (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    test_id UUID,
    variant VARCHAR(100) NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15,2) NOT NULL,
    sample_size INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

-- ==========================================
-- Indexes
-- ==========================================
CREATE INDEX ON analytics_event (user_id);
CREATE INDEX ON analytics_event (event_type);
CREATE INDEX ON analytics_event (created_at);
CREATE INDEX ON metric (metric_name);
CREATE INDEX ON metric (date);
CREATE INDEX ON report (report_type);
CREATE INDEX ON report (created_by);
CREATE INDEX ON data_warehouse (dimension_type, dimension_id);
CREATE INDEX ON data_warehouse (metric_name);
CREATE INDEX ON data_warehouse (date);
CREATE INDEX ON user_segment (created_by);
CREATE INDEX ON dashboard (created_by);
CREATE INDEX ON dashboard (is_public);
CREATE INDEX ON dashboard_widget (dashboard_id);
CREATE INDEX ON dashboard_widget (widget_type);
CREATE INDEX ON data_export (user_id);
CREATE INDEX ON data_export (data_export_status);
CREATE INDEX ON ab_test (ab_test_status);
CREATE INDEX ON ab_test (created_by);
CREATE INDEX ON ab_test_result (test_id);

-- ==========================================
-- Foreign Keys (Internal to this module)
-- ==========================================
ALTER TABLE dashboard_widget ADD FOREIGN KEY (dashboard_id) REFERENCES dashboard (id);
ALTER TABLE ab_test_result ADD FOREIGN KEY (test_id) REFERENCES ab_test (id);

-- Note: Cross-module foreign keys will be defined in a separate file (20_cross_module_fk.sql)