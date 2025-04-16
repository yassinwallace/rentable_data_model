-- ==========================================
-- Security & Compliance Module (STEP 21)
-- ==========================================
-- This file contains all database objects related to Security & Compliance:
-- - Tables: security_incident, data_encryption_key, compliance_report, etc.
-- - ENUMs: security_incident_severity, security_incident_status, etc.
-- - Foreign Keys and Indexes related to Security & Compliance tables
-- 
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- This module depends on:
-- 1. User Management Module (01_01_user_management_module.sql)
-- 2. Admin & Support Module (15_08_admin_support_module.sql)
-- 
-- Deployment order: 219 (nineteenth deployment step)
-- Module number: 10 (Security & Compliance)

-- ==========================================
-- ENUM Types
-- ==========================================
CREATE TYPE security_incident_severity AS ENUM('low','medium','high','critical');
CREATE TYPE security_incident_status AS ENUM('open','investigating','resolved','closed');
CREATE TYPE compliance_report_status AS ENUM('draft','submitted','approved','rejected');
CREATE TYPE data_access_request_type AS ENUM('access','deletion','correction');
CREATE TYPE data_access_request_status AS ENUM('pending','processing','completed','rejected');
CREATE TYPE vulnerability_scan_status AS ENUM('in_progress','completed','failed');
CREATE TYPE security_alert_severity AS ENUM('low','medium','high','critical');
CREATE TYPE security_alert_status AS ENUM('new','investigating','resolved','false_positive');
CREATE TYPE third_party_vendor_compliance_status AS ENUM('compliant','non_compliant','pending_review');

-- ==========================================
-- Tables
-- ==========================================
CREATE TABLE security_incident (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    incident_type VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    security_incident_severity security_incident_severity NOT NULL,
    security_incident_status security_incident_status NOT NULL,
    reported_by UUID,
    assigned_to UUID,
    resolution_notes TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE data_encryption_key (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    key_type VARCHAR(50) NOT NULL,
    encrypted_key TEXT NOT NULL,
    is_active BOOLEAN NOT NULL,
    activated_at TIMESTAMP NOT NULL,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE compliance_report (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    report_type VARCHAR(100) NOT NULL,
    report_period VARCHAR(50) NOT NULL,
    compliance_report_status compliance_report_status NOT NULL,
    submitted_by UUID,
    submitted_at TIMESTAMP,
    report_url TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE data_access_request (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    data_access_request_type data_access_request_type NOT NULL,
    data_access_request_status data_access_request_status NOT NULL,
    request_details JSONB,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE data_retention_policy (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    data_type VARCHAR(100) NOT NULL,
    retention_period INTERVAL NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE vulnerability_scan (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    scan_type VARCHAR(100) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    vulnerability_scan_status vulnerability_scan_status NOT NULL,
    results JSONB,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE security_alert (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    alert_type VARCHAR(100) NOT NULL,
    security_alert_severity security_alert_severity NOT NULL,
    description TEXT NOT NULL,
    security_alert_status security_alert_status NOT NULL,
    resolved_by UUID,
    resolved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE third_party_vendor (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    service_type VARCHAR(100) NOT NULL,
    contract_start_date DATE NOT NULL,
    contract_end_date DATE,
    data_access_level VARCHAR(50) NOT NULL,
    third_party_vendor_compliance_status third_party_vendor_compliance_status NOT NULL,
    last_audit_date DATE,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

-- ==========================================
-- Indexes
-- ==========================================
CREATE INDEX ON security_incident (security_incident_severity);
CREATE INDEX ON security_incident (security_incident_status);
CREATE INDEX ON security_incident (reported_by);
CREATE INDEX ON security_incident (assigned_to);
CREATE INDEX ON data_encryption_key (key_type);
CREATE INDEX ON data_encryption_key (is_active);
CREATE INDEX ON compliance_report (report_type);
CREATE INDEX ON compliance_report (compliance_report_status);
CREATE INDEX ON compliance_report (submitted_by);
CREATE INDEX ON data_access_request (user_id);
CREATE INDEX ON data_access_request (data_access_request_type);
CREATE INDEX ON data_access_request (data_access_request_status);
CREATE INDEX ON data_retention_policy (data_type);
CREATE INDEX ON data_retention_policy (is_active);
CREATE INDEX ON vulnerability_scan (scan_type);
CREATE INDEX ON vulnerability_scan (vulnerability_scan_status);
CREATE INDEX ON security_alert (alert_type);
CREATE INDEX ON security_alert (security_alert_severity);
CREATE INDEX ON security_alert (security_alert_status);
CREATE INDEX ON security_alert (resolved_by);
CREATE INDEX ON third_party_vendor (service_type);
CREATE INDEX ON third_party_vendor (third_party_vendor_compliance_status);

-- ==========================================
-- Foreign Keys (Internal to this module)
-- ==========================================
-- No internal foreign keys in this module

-- Note: Cross-module foreign keys will be defined in a separate file (22_cross_module_fk.sql)