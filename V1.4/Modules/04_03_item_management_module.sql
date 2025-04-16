-- ==========================================
-- Item Management Module (STEP 04)
-- ==========================================
-- This file contains all database objects related to Item Management:
-- - Tables: item, item_category, item_attributes, item_availability, etc.
-- - ENUMs: item_owner_type, item_status, item_condition, etc.
-- - Foreign Keys and Indexes related to Item Management tables
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
--
-- Deployment order: 04 (fourth deployment step)
-- Module number: 03 (Item Management)

-- ==========================================
-- ENUM Types
-- ==========================================
CREATE TYPE item_owner_type AS ENUM('user','business');
CREATE TYPE item_status AS ENUM('active','inactive','pending_review');
CREATE TYPE item_condition AS ENUM('new','like_new','good','fair','poor');
CREATE TYPE item_type AS ENUM('P2P','B2B','B2C');
CREATE TYPE item_insurance_cost_type AS ENUM('flat','percentage');
CREATE TYPE related_items_relation_type AS ENUM('accessory','similar','complementary');
CREATE TYPE bulk_import_status AS ENUM('pending','processing','completed','failed');
CREATE TYPE item_history_action AS ENUM('created','updated','deleted','status_changed');

-- ==========================================
-- Tables
-- ==========================================
CREATE TABLE item (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    owner_id UUID NOT NULL,
    item_owner_type item_owner_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    item_status item_status NOT NULL,
    item_condition item_condition NOT NULL,
    item_type item_type NOT NULL,
    quantity INTEGER DEFAULT 1,
    minimum_rental_period INTEGER,
    maximum_rental_period INTEGER,
    start_hours VARCHAR(50),
    end_hours VARCHAR(50),
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE item_category (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    parent_id UUID,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    level INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE item_category_assignment (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id UUID NOT NULL,
    category_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE item_attributes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id UUID NOT NULL,
    attribute_name VARCHAR(100) NOT NULL,
    attribute_value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE item_availability (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_available BOOLEAN NOT NULL,
    custom_price DECIMAL(10,2),
    inventory_count INTEGER,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE item_images (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id UUID NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    display_order INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE item_pricing_tier (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id UUID NOT NULL,
    min_days INTEGER NOT NULL,
    max_days INTEGER,
    price_per_day DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE item_maintenance_record (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id UUID NOT NULL,
    maintenance_type VARCHAR(100) NOT NULL,
    description TEXT,
    performed_by VARCHAR(255),
    performed_at TIMESTAMP NOT NULL,
    cost DECIMAL(10,2),
    next_maintenance_due TIMESTAMP,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE item_rental_rules (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id UUID NOT NULL,
    rule_type VARCHAR(100) NOT NULL,
    rule_value TEXT NOT NULL,
    is_required BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE item_insurance_options (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id UUID NOT NULL,
    insurance_name VARCHAR(255) NOT NULL,
    description TEXT,
    cost DECIMAL(10,2) NOT NULL,
    item_insurance_cost_type item_insurance_cost_type NOT NULL,
    coverage_amount DECIMAL(10,2) NOT NULL,
    is_required BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE item_bundle (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    discount_percentage DECIMAL(5,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE items_bundle_assignment (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    bundle_id UUID NOT NULL,
    item_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE related_item (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id UUID NOT NULL,
    related_item_id UUID NOT NULL,
    related_items_relation_type related_items_relation_type NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE bulk_import (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    business_id UUID,
    bulk_import_status bulk_import_status NOT NULL,
    total_items INTEGER NOT NULL,
    processed_items INTEGER DEFAULT 0,
    error_log TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE service_level_agreement (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    terms TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE item_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id UUID NOT NULL,
    user_id UUID NOT NULL,
    item_history_action item_history_action NOT NULL,
    details JSONB,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

-- ==========================================
-- Indexes
-- ==========================================
CREATE INDEX ON item (title);
CREATE INDEX ON item (description);
CREATE INDEX ON item (base_price);
CREATE INDEX ON item (currency);
CREATE INDEX ON item (item_status);
CREATE INDEX ON item (item_condition);
CREATE INDEX ON item (item_type);
CREATE INDEX ON item (quantity);
CREATE INDEX ON item (minimum_rental_period);
CREATE INDEX ON item (maximum_rental_period);
CREATE INDEX ON item (start_hours);
CREATE INDEX ON item (end_hours);

-- ==========================================
-- Foreign Keys (Internal to Item Management)
-- ==========================================
-- Only including foreign keys where both tables are in the Item Management module
ALTER TABLE item_category ADD FOREIGN KEY (parent_id) REFERENCES item_category (id);
ALTER TABLE item_category_assignment ADD FOREIGN KEY (item_id) REFERENCES item (id);
ALTER TABLE item_category_assignment ADD FOREIGN KEY (category_id) REFERENCES item_category (id);
ALTER TABLE item_attributes ADD FOREIGN KEY (item_id) REFERENCES item (id);
ALTER TABLE item_availability ADD FOREIGN KEY (item_id) REFERENCES item (id);
ALTER TABLE item_images ADD FOREIGN KEY (item_id) REFERENCES item (id);
ALTER TABLE item_pricing_tier ADD FOREIGN KEY (item_id) REFERENCES item (id);
ALTER TABLE item_maintenance_record ADD FOREIGN KEY (item_id) REFERENCES item (id);
ALTER TABLE item_rental_rules ADD FOREIGN KEY (item_id) REFERENCES item (id);
ALTER TABLE item_insurance_options ADD FOREIGN KEY (item_id) REFERENCES item (id);
ALTER TABLE items_bundle_assignment ADD FOREIGN KEY (bundle_id) REFERENCES item_bundle (id);
ALTER TABLE items_bundle_assignment ADD FOREIGN KEY (item_id) REFERENCES item (id);
ALTER TABLE related_item ADD FOREIGN KEY (item_id) REFERENCES item (id);
ALTER TABLE related_item ADD FOREIGN KEY (related_item_id) REFERENCES item (id);
ALTER TABLE service_level_agreement ADD FOREIGN KEY (item_id) REFERENCES item (id);
ALTER TABLE item_history ADD FOREIGN KEY (item_id) REFERENCES item (id);

-- Note: Foreign keys that reference tables in other modules (or are referenced by other modules)
-- remain in cross-module foreign key files