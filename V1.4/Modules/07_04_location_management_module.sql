-- ==========================================
-- Location Management Module (STEP 07)
-- ==========================================
-- This file contains all database objects related to Location Management:
-- - Tables: address, location, location_link, location_hour, etc.
-- - ENUMs: location_type, location_role, owner_type, linked_entity_type
-- - Foreign Keys and Indexes related to Location Management tables
-- 
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- Requires prior deployment of:
-- - 01_01_user_management_module.sql
-- - 02_02_business_management_module.sql
-- - 03_cross_module_fk.sql
-- - 04_03_item_management_module.sql
-- - 05_cross_module_fk.sql
--
-- Deployment order: 07 (seventh deployment step)
-- Module number: 04 (Location Management)

-- ==========================================
-- ENUM Types
-- ==========================================
CREATE TYPE location_type AS ENUM ('fixed', 'mobile', 'virtual', 'store');
CREATE TYPE location_role AS ENUM ('pickup', 'storage', 'workplace', 'maintenance');
CREATE TYPE owner_type AS ENUM ('user', 'business');
CREATE TYPE linked_entity_type AS ENUM ('user', 'item', 'business');

-- ==========================================
-- Tables
-- ==========================================
CREATE TABLE address (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    line1 TEXT,
    line2 TEXT,
    postal_code TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE location (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT,
    description TEXT,
    address_id UUID,
    location_type location_type,
    owner_type owner_type,
    owner_id UUID,
    is_public BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE location_link (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    location_id UUID,
    linked_entity_type linked_entity_type,
    linked_entity_id UUID,
    location_role location_role,
    is_primary BOOLEAN DEFAULT false,
    verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE location_hour (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    location_id UUID,
    day_of_week INTEGER, -- 0=Sunday ... 6=Saturday
    opens_at TIME,
    closes_at TIME,
    is_closed BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE location_special_period (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    location_id UUID,
    name TEXT,
    start_date DATE,
    end_date DATE,
    is_closed BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE location_special_hour (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    special_period_id UUID,
    day_of_week INTEGER,
    opens_at TIME,
    closes_at TIME,
    is_closed BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE location_holiday_exception (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    location_id UUID,
    date DATE,
    opens_at TIME,
    closes_at TIME,
    is_closed BOOLEAN DEFAULT false,
    label TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

-- ==========================================
-- Indexes
-- ==========================================
CREATE INDEX ON address (postal_code, country);
CREATE INDEX ON address (city, state, country);
CREATE INDEX ON location (name);
CREATE INDEX ON location (owner_type, owner_id);
CREATE INDEX ON location (is_public, is_active);
CREATE INDEX ON location_link (location_id);
CREATE INDEX ON location_link (linked_entity_type, linked_entity_id);
CREATE INDEX ON location_hour (location_id, day_of_week);
CREATE INDEX ON location_special_period (location_id, start_date, end_date);
CREATE INDEX ON location_holiday_exception (location_id, date);

-- ==========================================
-- Foreign Keys (Internal to Location Management)
-- ==========================================
-- Only including foreign keys where both tables are in the Location Management module
ALTER TABLE location ADD FOREIGN KEY (address_id) REFERENCES address (id);
ALTER TABLE location_link ADD FOREIGN KEY (location_id) REFERENCES location (id);
ALTER TABLE location_hour ADD FOREIGN KEY (location_id) REFERENCES location (id);
ALTER TABLE location_special_period ADD FOREIGN KEY (location_id) REFERENCES location (id);
ALTER TABLE location_special_hour ADD FOREIGN KEY (special_period_id) REFERENCES location_special_period (id);
ALTER TABLE location_holiday_exception ADD FOREIGN KEY (location_id) REFERENCES location (id);

-- Note: Foreign keys that reference tables in other modules (or are referenced by other modules)
-- remain in cross-module foreign key files