-- ==========================================
-- Business Management Module (STEP 02)
-- ==========================================
-- This file contains all database objects related to Business Management:
-- - Tables: business, business_profile, user_business_assignment
-- - ENUMs: business_verification_status
-- - Foreign Keys and Indexes related to Business Management tables
-- 
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- Requires prior deployment of:
-- - 01_01_user_management_module.sql
--
-- Deployment order: 02 (second deployment step)
-- Module number: 02 (Business Management)

-- ==========================================
-- ENUM Types
-- ==========================================
CREATE TYPE business_verification_status AS ENUM('pending','verified','rejected');

-- ==========================================
-- Tables
-- ==========================================
CREATE TABLE business (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    business_name VARCHAR(255) NOT NULL,
    business_type VARCHAR(100),
    registration_number varchar UNIQUE,
    tax_id VARCHAR(100),
    business_verification_status business_verification_status NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE business_profile (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    business_id UUID NOT NULL,
    description text,
    website varchar,
    founded_year int,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at timestamp
);

CREATE TABLE user_business_assignment (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    business_id UUID,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

-- ==========================================
-- Indexes
-- ==========================================
CREATE INDEX ON business (business_name);
CREATE UNIQUE INDEX ON business (registration_number, tax_id);
CREATE UNIQUE INDEX ON business_profile (business_id);
CREATE INDEX ON business_profile (founded_year);

-- ==========================================
-- Foreign Keys
-- ==========================================
-- Internal foreign keys within Business Management module
ALTER TABLE business_profile ADD FOREIGN KEY (business_id) REFERENCES business (id);

-- Foreign keys referencing tables from previously defined modules (01_01_user_management_module.sql)
ALTER TABLE user_business_assignment ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE user_business_assignment ADD FOREIGN KEY (business_id) REFERENCES business (id);

-- Note: Foreign keys from other modules that reference Business Management tables
-- remain in cross-module foreign key files