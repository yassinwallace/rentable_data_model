-- ==========================================
-- User Management Module (01)
-- ==========================================
-- This file contains all database objects related to User Management:
-- - Tables: user, user_profile, user_verification, role, permission, etc.
-- - ENUMs: user_type, user_verification_type, user_verification_status
-- - Foreign Keys and Indexes related to User Management tables
-- 
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- This is a base module with no prerequisites.
-- Deployment order: 01 (first deployment step)
-- Module number: 01 (User Management)

-- ==========================================
-- ENUM Types
-- ==========================================
CREATE TYPE user_type AS ENUM('individual','business');
CREATE TYPE user_verification_type AS ENUM('email','phone','government_id');
CREATE TYPE user_verification_status AS ENUM('pending','approved','rejected');

-- ==========================================
-- Tables
-- ==========================================
CREATE TABLE "user" (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    username varchar UNIQUE NOT NULL,
    email varchar UNIQUE NOT NULL,
    password_hash varchar NOT NULL,
    user_type user_type NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at timestamp
);

CREATE TABLE user_profile (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    bio TEXT,
    avatar_url VARCHAR(255),
    date_of_birth DATE,
    gender VARCHAR(50),
    occupation VARCHAR(100),
    phone_number VARCHAR(20),
    preferences JSONB,
    preferred_language VARCHAR(10),
    additional_languages TEXT[],  -- Changed from JSON to text[]
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE user_verification (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    user_verification_type user_verification_type NOT NULL,
    user_verification_status user_verification_status NOT NULL,
    verification_data JSONB,
    document_type VARCHAR(50),
    document_number VARCHAR(100),
    verified_at TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE role (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE permission (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE role_permission (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    role_id UUID,
    permission_id UUID,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE user_session (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    session_id VARCHAR(255),
    token VARCHAR(255) UNIQUE,
    user_id UUID,
    roles TEXT[],  -- PostgreSQL array for storing roles
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE password_reset_token (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE user_activity_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    activity_type VARCHAR(50) NOT NULL,
    details JSONB,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE user_business_roles_assignment (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    business_profile_id UUID,
    role_id UUID,
    assigned_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    assigned_by UUID
);

CREATE TABLE user_consent (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    consent_type VARCHAR(100) NOT NULL,
    version VARCHAR(50) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    consented_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE user_reputation_score (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    overall_score DECIMAL(3,2) NOT NULL,
    renter_score DECIMAL(3,2),
    owner_score DECIMAL(3,2),
    total_reviews INTEGER DEFAULT 0,
    total_transactions INTEGER DEFAULT 0,
    last_calculated_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE blocked_user (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    blocked_by UUID NOT NULL,
    blocked_user UUID NOT NULL,
    reason TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

-- ==========================================
-- Indexes
-- ==========================================
CREATE UNIQUE INDEX ON "user" (email, username);
CREATE INDEX user_created_at_index ON "user" (created_at);
CREATE UNIQUE INDEX ON user_profile (user_id, phone_number);
CREATE INDEX ON user_profile (first_name, last_name);
CREATE INDEX ON blocked_user (blocked_by);
CREATE INDEX ON blocked_user (blocked_user);

-- ==========================================
-- Foreign Keys (Internal to User Management)
-- ==========================================
-- Only including foreign keys where both tables are in the User Management module
ALTER TABLE user_profile ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE user_verification ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE role_permission ADD FOREIGN KEY (role_id) REFERENCES role (id);
ALTER TABLE role_permission ADD FOREIGN KEY (permission_id) REFERENCES permission (id);
ALTER TABLE user_session ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE password_reset_token ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE user_activity_log ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE user_business_roles_assignment ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE user_business_roles_assignment ADD FOREIGN KEY (role_id) REFERENCES role (id);
ALTER TABLE user_business_roles_assignment ADD FOREIGN KEY (assigned_by) REFERENCES "user" (id);
ALTER TABLE user_consent ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE user_reputation_score ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE blocked_user ADD FOREIGN KEY (blocked_by) REFERENCES "user" (id);
ALTER TABLE blocked_user ADD FOREIGN KEY (blocked_user) REFERENCES "user" (id);

-- Note: Foreign keys that reference tables in other modules (or are referenced by other modules)
-- remain in cross-module foreign key files
-- ==========================================
-- Business Management Module (02)
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
-- ==========================================
-- Cross-Module Foreign Keys (Step 03)
-- ==========================================
-- This file contains foreign key relationships between:
-- - User Management module (01_01_user_management_module.sql)
-- - Business Management module (02_02_business_management_module.sql)
--
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- Requires prior deployment of:
-- - 01_01_user_management_module.sql
-- - 02_02_business_management_module.sql
--
-- Deployment order: 03 (third deployment step)

-- ==========================================
-- Foreign Keys
-- ==========================================
-- Foreign keys from User Management tables to Business Management tables
ALTER TABLE user_business_roles_assignment ADD FOREIGN KEY (business_profile_id) REFERENCES business_profile (id);

-- Note: Foreign keys from Business Management tables to User Management tables
-- are already defined in the Business Management module (02_02_business_management_module.sql)
-- because they reference tables that are created earlier in the deployment sequence.
-- ==========================================
-- Item Management Module (03)
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
-- ==========================================
-- Cross-Module Foreign Keys (Step 05)
-- ==========================================
-- This file contains foreign key relationships between:
-- - User Management module (01_01_user_management_module.sql)
-- - Business Management module (02_02_business_management_module.sql)
-- - Item Management module (04_03_item_management_module.sql)
--
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- Requires prior deployment of:
-- - 01_01_user_management_module.sql
-- - 02_02_business_management_module.sql
-- - 04_03_item_management_module.sql
--
-- Deployment order: 05 (fifth deployment step)

-- ==========================================
-- Foreign Keys
-- ==========================================
-- Foreign keys from Item Management tables to User Management tables
ALTER TABLE item_history ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE bulk_import ADD FOREIGN KEY (user_id) REFERENCES "user" (id);

-- Foreign keys from Item Management tables to Business Management tables
ALTER TABLE bulk_import ADD FOREIGN KEY (business_id) REFERENCES business (id);
-- ==========================================
-- Location Management Module (04)
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
-- Deployment order: 06 (sixth deployment step)
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
-- ==========================================
-- Location Polymorphic Validations (Step 08)
-- ==========================================
-- Validation and cascade logic for polymorphic relationships in the location module
-- This file should be executed after the location module tables are created
--
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- Requires prior deployment of:
-- - 01_01_user_management_module.sql
-- - 02_02_business_management_module.sql
-- - 04_03_item_management_module.sql
-- - 06_04_location_management_module.sql
-- - 07_cross_module_fk.sql
--
-- Deployment order: 08 (eighth deployment step)

-- ==========================================
-- VALIDATION FUNCTION
-- ==========================================

CREATE OR REPLACE FUNCTION validate_location_link_entity()
RETURNS TRIGGER AS $$
DECLARE
    entity_exists BOOLEAN;
BEGIN
    IF NEW.linked_entity_type = 'user' THEN
        SELECT EXISTS(SELECT 1 FROM "user" WHERE id = NEW.linked_entity_id) INTO entity_exists;
    ELSIF NEW.linked_entity_type = 'item' THEN
        SELECT EXISTS(SELECT 1 FROM item WHERE id = NEW.linked_entity_id) INTO entity_exists;
    ELSIF NEW.linked_entity_type = 'business' THEN
        SELECT EXISTS(SELECT 1 FROM business WHERE id = NEW.linked_entity_id) INTO entity_exists;
    ELSE
        RAISE EXCEPTION 'Invalid linked_entity_type: %', NEW.linked_entity_type;
    END IF;
    IF NOT entity_exists THEN
        RAISE EXCEPTION 'Referenced entity (type %, id %) does not exist', NEW.linked_entity_type, NEW.linked_entity_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- TRIGGER FOR VALIDATION
-- ==========================================

CREATE TRIGGER validate_location_link_entity_trigger
BEFORE INSERT OR UPDATE OF linked_entity_type, linked_entity_id ON location_link
FOR EACH ROW
EXECUTE FUNCTION validate_location_link_entity();

-- ==========================================
-- CASCADE DELETE FUNCTIONS
-- ==========================================

-- When a user is deleted, delete their location links
CREATE OR REPLACE FUNCTION handle_user_delete_location_link()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM location_link WHERE linked_entity_type = 'user' AND linked_entity_id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER handle_user_delete_location_link_trigger
BEFORE DELETE ON "user"
FOR EACH ROW
EXECUTE FUNCTION handle_user_delete_location_link();

-- When an item is deleted, delete its location links
CREATE OR REPLACE FUNCTION handle_item_delete_location_link()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM location_link WHERE linked_entity_type = 'item' AND linked_entity_id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER handle_item_delete_location_link_trigger
BEFORE DELETE ON item
FOR EACH ROW
EXECUTE FUNCTION handle_item_delete_location_link();

-- When a business is deleted, delete its location links
CREATE OR REPLACE FUNCTION handle_business_delete_location_link()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM location_link WHERE linked_entity_type = 'business' AND linked_entity_id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER handle_business_delete_location_link_trigger
BEFORE DELETE ON business
FOR EACH ROW
EXECUTE FUNCTION handle_business_delete_location_link();

-- ==========================================
-- DOCUMENTATION
-- ==========================================
/*
This file implements validation and cascading delete logic for the polymorphic relationship in the location_link table.

- On INSERT/UPDATE, it checks that the referenced entity exists in the corresponding table based on linked_entity_type.
- On DELETE of a user, item, or business, it deletes associated location_link rows.

This replaces traditional FKs, which are not possible for polymorphic relationships in PostgreSQL.
*/
-- ==========================================
-- Booking & Transactions Module (STEP 09)
-- ==========================================
-- This file contains all database objects related to Booking & Transactions:
-- - Tables: booking, booking_payment, transaction, payment, refund, etc.
-- - ENUMs: booking_status, payment_status, transaction_type, etc.
-- - Foreign Keys and Indexes related to Booking & Transactions tables
-- 
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- This module depends on:
-- 1. User Management Module (01_01_user_management_module.sql)
-- 2. Business Management Module (02_02_business_management_module.sql)
-- 3. Item Management Module (04_03_item_management_module.sql)
-- 
-- Deployment order: 09 (ninth deployment step)
-- Module number: 05 (Booking & Transactions)

-- ==========================================
-- ENUM Types
-- ==========================================
CREATE TYPE booking_status AS ENUM('pending','confirmed','cancelled','completed');
CREATE TYPE booking_payment_status AS ENUM('pending','completed','failed','refunded');
CREATE TYPE booking_insurance_status AS ENUM('active','cancelled','claimed');
CREATE TYPE booking_dispute_type AS ENUM('damage','late_return','no_show','other');
CREATE TYPE booking_dispute_status AS ENUM('open','under_review','resolved','closed');
CREATE TYPE security_deposit_status AS ENUM('held','partially_refunded','fully_refunded','claimed');
CREATE TYPE item_handover_type AS ENUM('checkout','return');
CREATE TYPE additional_charge_type AS ENUM('damage','extra_mileage','cleaning_fee','other');
CREATE TYPE booking_extension_status AS ENUM('pending','approved','rejected');
CREATE TYPE booking_message_type AS ENUM('chat','system_notification','dispute_related');
CREATE TYPE payment_status AS ENUM('pending','completed','failed','refunded');
CREATE TYPE transaction_type AS ENUM('payment','refund','payout','fee');
CREATE TYPE transaction_status AS ENUM('pending','completed','failed');
CREATE TYPE refund_status AS ENUM('pending','processed','failed');
CREATE TYPE payout_status AS ENUM('pending','processed','failed');
CREATE TYPE payment_method_type AS ENUM('credit_card','debit_card','paypal','bank_transfer');
CREATE TYPE fee_type AS ENUM('percentage','fixed');
CREATE TYPE fee_applicable_to AS ENUM('renter','owner');
CREATE TYPE invoice_status AS ENUM('draft','sent','paid','cancelled');
CREATE TYPE payment_dispute_reason AS ENUM('unauthorized','duplicate','fraudulent','incorrect_amount','other');
CREATE TYPE payment_dispute_status AS ENUM('open','under_review','resolved','closed');
CREATE TYPE platform_revenue_type AS ENUM('commission','fee','penalty');
CREATE TYPE payout_schedule_frequency AS ENUM('daily','weekly','monthly');
CREATE TYPE payout_schedule_user_type AS ENUM('individual','business');
CREATE TYPE transaction_logs_action AS ENUM('created','updated','status_changed');
CREATE TYPE renter_type AS ENUM ('user', 'business');

-- ==========================================
-- Tables
-- ==========================================
CREATE TABLE booking (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id UUID NOT NULL,
    renter_id UUID NOT NULL,
    renter_type renter_type NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    booking_status booking_status NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE booking_payment (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    transaction_id VARCHAR(255),
    booking_payment_status booking_payment_status NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE booking_insurance (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID NOT NULL,
    insurance_option_id UUID NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    booking_insurance_status booking_insurance_status NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE booking_status_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID NOT NULL,
    booking_status booking_status NOT NULL,
    changed_by UUID NOT NULL,
    reason TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE booking_dispute (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID NOT NULL,
    reported_by UUID NOT NULL,
    booking_dispute_type booking_dispute_type NOT NULL,
    description TEXT NOT NULL,
    booking_dispute_status booking_dispute_status NOT NULL,
    resolution TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE booking_cancellation (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID NOT NULL,
    cancelled_by UUID NOT NULL,
    reason TEXT NOT NULL,
    cancellation_fee DECIMAL(10,2),
    refund_amount DECIMAL(10,2),
    policy_applied VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE security_deposit (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    security_deposit_status security_deposit_status NOT NULL,
    hold_transaction_id VARCHAR(255),
    release_transaction_id VARCHAR(255),
    claimed_amount DECIMAL(10,2),
    claim_reason TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE item_handover (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID NOT NULL,
    item_handover_type item_handover_type NOT NULL,
    scheduled_time TIMESTAMP NOT NULL,
    actual_time TIMESTAMP,
    location TEXT,
    handover_by UUID NOT NULL,
    handover_to UUID NOT NULL,
    item_condition TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE late_return (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID NOT NULL,
    actual_return_time TIMESTAMP NOT NULL,
    late_duration INTERVAL NOT NULL,
    additional_charge DECIMAL(10,2) NOT NULL,
    reason TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE additional_charge (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID NOT NULL,
    additional_charge_type additional_charge_type NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    description TEXT NOT NULL,
    charged_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE booking_extension (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID NOT NULL,
    requested_by UUID NOT NULL,
    original_end_date TIMESTAMP NOT NULL,
    requested_end_date TIMESTAMP NOT NULL,
    booking_extension_status booking_extension_status NOT NULL,
    additional_cost DECIMAL(10,2),
    approved_by UUID,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE booking_communication_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID NOT NULL,
    sender_id UUID NOT NULL,
    recipient_id UUID NOT NULL,
    booking_message_type booking_message_type NOT NULL,
    message_content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE payment (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID NOT NULL,
    user_id UUID NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status payment_status NOT NULL,
    transaction_id VARCHAR(255),
    payment_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE transaction (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    item_id UUID,
    booking_id UUID,
    transaction_type transaction_type NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    transaction_status transaction_status NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE refund (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    payment_id UUID NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    reason TEXT NOT NULL,
    refund_status refund_status NOT NULL,
    refunded_by UUID NOT NULL,
    refund_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE payout (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    payout_status payout_status NOT NULL,
    payout_method VARCHAR(50) NOT NULL,
    payout_reference VARCHAR(255),
    scheduled_date TIMESTAMP NOT NULL,
    processed_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE payment_method (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    payment_method_type payment_method_type NOT NULL,
    provider_token VARCHAR(255) NOT NULL,
    last4 CHAR(4),
    expiry_month SMALLINT,
    expiry_year SMALLINT,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE fee (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    fee_type fee_type NOT NULL,
    value DECIMAL(5,2) NOT NULL,
    fee_applicable_to fee_applicable_to NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE invoice (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    booking_id UUID NOT NULL,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) NOT NULL,
    invoice_status invoice_status NOT NULL,
    due_date TIMESTAMP NOT NULL,
    paid_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE tax_rate (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    rate DECIMAL(5,2) NOT NULL,
    country VARCHAR(100) NOT NULL,
    region VARCHAR(100),
    item_category_id UUID,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE currency_exchange_rate (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    from_currency CHAR(3) NOT NULL,
    to_currency CHAR(3) NOT NULL,
    exchange_rate DECIMAL(10,6) NOT NULL,
    effective_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE promotional_credit (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    credit_code VARCHAR(50) UNIQUE,
    amount DECIMAL(10,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    expiration_date TIMESTAMP,
    is_used BOOLEAN DEFAULT false,
    used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE payment_dispute (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    payment_id UUID NOT NULL,
    disputed_by UUID NOT NULL,
    payment_dispute_reason payment_dispute_reason NOT NULL,
    description TEXT NOT NULL,
    payment_dispute_status payment_dispute_status NOT NULL,
    resolution TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE platform_revenue (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    date DATE NOT NULL,
    platform_revenue_type platform_revenue_type NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE payout_schedule (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    payout_schedule_frequency payout_schedule_frequency NOT NULL,
    day_of_week SMALLINT,
    day_of_month SMALLINT,
    min_amount DECIMAL(10,2),
    payout_schedule_user_type payout_schedule_user_type NOT NULL,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE transaction_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    transaction_id UUID NOT NULL,
    transaction_logs_action transaction_logs_action NOT NULL,
    description TEXT NOT NULL,
    performed_by UUID,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE payment_gateway (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    api_key VARCHAR(255) NOT NULL,
    secret_key VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    supported_currencies JSONB,
    config_settings JSONB,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

-- ==========================================
-- Indexes
-- ==========================================
CREATE INDEX ON booking (item_id);
CREATE INDEX ON booking (renter_id);
CREATE INDEX ON booking (booking_status);
CREATE INDEX ON booking (start_date, end_date);
CREATE INDEX ON booking (total_price);
CREATE INDEX ON booking_payment (booking_id);
CREATE INDEX ON booking_insurance (booking_id);
CREATE INDEX ON booking_insurance (insurance_option_id);
CREATE INDEX ON booking_status_history (booking_id);
CREATE INDEX ON booking_dispute (booking_id);
CREATE INDEX ON booking_dispute (reported_by);
CREATE INDEX ON booking_cancellation (booking_id);
CREATE INDEX ON security_deposit (booking_id);
CREATE INDEX ON item_handover (booking_id);
CREATE INDEX ON late_return (booking_id);
CREATE INDEX ON additional_charge (booking_id);
CREATE INDEX ON booking_extension (booking_id);
CREATE INDEX ON booking_communication_log (booking_id);
CREATE INDEX ON payment (booking_id);
CREATE INDEX ON payment (user_id);
CREATE INDEX ON transaction (user_id);
CREATE INDEX ON transaction (booking_id);
CREATE INDEX ON refund (payment_id);
CREATE INDEX ON payout (user_id);
CREATE INDEX ON payment_method (user_id);
CREATE INDEX ON invoice (user_id);
CREATE INDEX ON invoice (booking_id);
CREATE INDEX ON tax_rate (item_category_id);
CREATE INDEX ON promotional_credit (user_id);
CREATE INDEX ON payment_dispute (payment_id);
CREATE INDEX ON transaction_log (transaction_id);

-- ==========================================
-- Foreign Keys (Internal to this module)
-- ==========================================
ALTER TABLE booking_payment ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
ALTER TABLE booking_insurance ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
ALTER TABLE booking_status_history ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
ALTER TABLE booking_dispute ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
ALTER TABLE booking_cancellation ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
ALTER TABLE security_deposit ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
ALTER TABLE item_handover ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
ALTER TABLE late_return ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
ALTER TABLE additional_charge ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
ALTER TABLE booking_extension ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
ALTER TABLE booking_communication_log ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
ALTER TABLE payment ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
ALTER TABLE transaction ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
ALTER TABLE invoice ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
ALTER TABLE refund ADD FOREIGN KEY (payment_id) REFERENCES payment (id);
ALTER TABLE payment_dispute ADD FOREIGN KEY (payment_id) REFERENCES payment (id);
ALTER TABLE transaction_log ADD FOREIGN KEY (transaction_id) REFERENCES transaction (id);

-- Note: Cross-module foreign keys will be defined in a separate file (10_cross_module_fk.sql)
-- ==========================================
-- Cross-Module Foreign Keys for Booking & Transactions Module
-- ==========================================
-- This file contains all foreign key relationships between the Booking & Transactions module
-- and other modules (User Management, Business Management, Item Management, Location Management)
-- 
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- This file depends on:
-- 1. User Management Module (01_01_user_management_module.sql)
-- 2. Business Management Module (02_02_business_management_module.sql)
-- 3. Item Management Module (04_03_item_management_module.sql)
-- 4. Location Management Module (06_04_location_management_module.sql)
-- 5. Booking & Transactions Module (09_05_booking_transactions_module.sql)
-- 
-- Deployment order: 10 (tenth deployment step)

-- ==========================================
-- Foreign Keys from Booking & Transactions to User Management
-- ==========================================
ALTER TABLE booking ADD CONSTRAINT fk_booking_renter_user 
    FOREIGN KEY (renter_id) REFERENCES "user" (id);
ALTER TABLE booking ADD CONSTRAINT check_booking_renter_type_user 
    CHECK (renter_type = 'user');

ALTER TABLE booking_status_history ADD FOREIGN KEY (changed_by) REFERENCES "user" (id);
ALTER TABLE booking_dispute ADD FOREIGN KEY (reported_by) REFERENCES "user" (id);
ALTER TABLE booking_cancellation ADD FOREIGN KEY (cancelled_by) REFERENCES "user" (id);
ALTER TABLE item_handover ADD FOREIGN KEY (handover_by) REFERENCES "user" (id);
ALTER TABLE item_handover ADD FOREIGN KEY (handover_to) REFERENCES "user" (id);
ALTER TABLE booking_extension ADD FOREIGN KEY (requested_by) REFERENCES "user" (id);
ALTER TABLE booking_extension ADD FOREIGN KEY (approved_by) REFERENCES "user" (id);
ALTER TABLE booking_communication_log ADD FOREIGN KEY (sender_id) REFERENCES "user" (id);
ALTER TABLE booking_communication_log ADD FOREIGN KEY (recipient_id) REFERENCES "user" (id);
ALTER TABLE payment ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE transaction ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE refund ADD FOREIGN KEY (refunded_by) REFERENCES "user" (id);
ALTER TABLE payout ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE payment_method ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE invoice ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE promotional_credit ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE payment_dispute ADD FOREIGN KEY (disputed_by) REFERENCES "user" (id);
ALTER TABLE transaction_log ADD FOREIGN KEY (performed_by) REFERENCES "user" (id);

-- ==========================================
-- Foreign Keys from Booking & Transactions to Business Management
-- ==========================================
ALTER TABLE booking ADD CONSTRAINT fk_booking_renter_business 
    FOREIGN KEY (renter_id) REFERENCES business (id);
ALTER TABLE booking ADD CONSTRAINT check_booking_renter_type_business 
    CHECK (renter_type = 'business');

-- ==========================================
-- Foreign Keys from Booking & Transactions to Item Management
-- ==========================================
ALTER TABLE booking ADD FOREIGN KEY (item_id) REFERENCES item (id);
ALTER TABLE booking_insurance ADD FOREIGN KEY (insurance_option_id) REFERENCES item_insurance_options (id);
ALTER TABLE transaction ADD FOREIGN KEY (item_id) REFERENCES item (id);
ALTER TABLE tax_rate ADD FOREIGN KEY (item_category_id) REFERENCES item_category (id);
-- ==========================================
-- Reviews & Ratings Module (06)
-- ==========================================
-- This file contains all database objects related to Reviews & Ratings:
-- - Tables: review, review_category, review_type, category_rating, etc.
-- - ENUMs: review_status, review_flag_reason, review_flag_status, etc.
-- - Foreign Keys and Indexes related to Reviews & Ratings tables
-- 
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- This module depends on:
-- 1. User Management Module (01_01_user_management_module.sql)
-- 2. Item Management Module (04_03_item_management_module.sql)
-- 3. Booking & Transactions Module (09_05_booking_transactions_module.sql)
-- 
-- Deployment order: 11 (eleventh deployment step)
-- Module number: 06 (Reviews & Ratings)

-- ==========================================
-- ENUM Types
-- ==========================================
CREATE TYPE review_status AS ENUM('pending','approved','rejected');
CREATE TYPE review_flag_reason AS ENUM('inappropriate','spam','offensive','inaccurate','other');
CREATE TYPE review_flag_status AS ENUM('pending','reviewed','resolved');
CREATE TYPE review_reminder_type AS ENUM('initial','follow_up');
CREATE TYPE review_reminder_status AS ENUM('pending','sent','cancelled');
CREATE TYPE review_analytics_entity_type AS ENUM('user','item');

-- ==========================================
-- Tables
-- ==========================================
CREATE TABLE review_type (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE review_category (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    review_type_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE review (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    review_type_id UUID NOT NULL,
    booking_id UUID NOT NULL,
    reviewer_id UUID NOT NULL,
    reviewee_id UUID NOT NULL,
    item_id UUID NOT NULL,
    rating DECIMAL(2,1) NOT NULL,
    review_content TEXT,
    is_public BOOLEAN DEFAULT true,
    review_status review_status NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE category_rating (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    review_id UUID NOT NULL,
    category_id UUID NOT NULL,
    rating DECIMAL(2,1) NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE review_photo (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    review_id UUID NOT NULL,
    photo_url VARCHAR(255) NOT NULL,
    caption TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE review_helpfulness (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    review_id UUID NOT NULL,
    user_id UUID NOT NULL,
    is_helpful BOOLEAN NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE review_response (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    review_id UUID NOT NULL,
    responder_id UUID NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE review_flag (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    review_id UUID NOT NULL,
    flagged_by UUID NOT NULL,
    review_flag_reason review_flag_reason NOT NULL,
    description TEXT,
    review_flag_status review_flag_status NOT NULL,
    resolution_note TEXT,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE review_reminder (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    booking_id UUID NOT NULL,
    user_id UUID NOT NULL,
    review_reminder_type review_reminder_type NOT NULL,
    scheduled_at TIMESTAMP NOT NULL,
    sent_at TIMESTAMP,
    review_reminder_status review_reminder_status NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE review_analytics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    review_analytics_entity_type review_analytics_entity_type NOT NULL,
    entity_id UUID NOT NULL,
    average_rating DECIMAL(3,2) NOT NULL,
    total_reviews INTEGER NOT NULL,
    rating_distribution JSONB NOT NULL,
    most_common_keywords JSONB,
    last_review_date TIMESTAMP,
    last_calculated_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
    updated_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

-- ==========================================
-- Indexes
-- ==========================================
CREATE INDEX ON review (review_type_id);
CREATE INDEX ON review (booking_id);
CREATE INDEX ON review (reviewer_id);
CREATE INDEX ON review (reviewee_id);
CREATE INDEX ON review (item_id);
CREATE INDEX ON review (review_status);
CREATE INDEX ON review (rating);
CREATE INDEX ON review_category (review_type_id);
CREATE INDEX ON category_rating (review_id);
CREATE INDEX ON category_rating (category_id);
CREATE INDEX ON review_photo (review_id);
CREATE INDEX ON review_helpfulness (review_id);
CREATE INDEX ON review_helpfulness (user_id);
CREATE INDEX ON review_response (review_id);
CREATE INDEX ON review_response (responder_id);
CREATE INDEX ON review_flag (review_id);
CREATE INDEX ON review_flag (flagged_by);
CREATE INDEX ON user_reputation_score (user_id);
CREATE INDEX ON review_reminder (booking_id);
CREATE INDEX ON review_reminder (user_id);
CREATE INDEX ON review_analytics (entity_id);
CREATE INDEX ON review_analytics (review_analytics_entity_type);

-- ==========================================
-- Foreign Keys (Internal to this module)
-- ==========================================
ALTER TABLE review_category ADD FOREIGN KEY (review_type_id) REFERENCES review_type (id);
ALTER TABLE review ADD FOREIGN KEY (review_type_id) REFERENCES review_type (id);
ALTER TABLE category_rating ADD FOREIGN KEY (review_id) REFERENCES review (id);
ALTER TABLE category_rating ADD FOREIGN KEY (category_id) REFERENCES review_category (id);
ALTER TABLE review_photo ADD FOREIGN KEY (review_id) REFERENCES review (id);
ALTER TABLE review_helpfulness ADD FOREIGN KEY (review_id) REFERENCES review (id);
ALTER TABLE review_response ADD FOREIGN KEY (review_id) REFERENCES review (id);
ALTER TABLE review_flag ADD FOREIGN KEY (review_id) REFERENCES review (id);

-- Note: Cross-module foreign keys will be defined in a separate file (12_cross_module_fk.sql)
-- ==========================================
-- Cross-Module Foreign Keys for Reviews & Ratings Module
-- ==========================================
-- This file contains all foreign key relationships between the Reviews & Ratings module
-- and other modules (User Management, Item Management, Booking & Transactions)
-- 
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- This file depends on:
-- 1. User Management Module (01_01_user_management_module.sql)
-- 2. Item Management Module (04_03_item_management_module.sql)
-- 3. Booking & Transactions Module (09_05_booking_transactions_module.sql)
-- 4. Reviews & Ratings Module (11_06_reviews_ratings_module.sql)
-- 
-- Deployment order: 12 (twelfth deployment step)

-- ==========================================
-- Foreign Keys from Reviews & Ratings to User Management
-- ==========================================
ALTER TABLE review ADD FOREIGN KEY (reviewer_id) REFERENCES "user" (id);
ALTER TABLE review ADD FOREIGN KEY (reviewee_id) REFERENCES "user" (id);
ALTER TABLE review_helpfulness ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE review_response ADD FOREIGN KEY (responder_id) REFERENCES "user" (id);
ALTER TABLE review_flag ADD FOREIGN KEY (flagged_by) REFERENCES "user" (id);
ALTER TABLE user_reputation_score ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE review_reminder ADD FOREIGN KEY (user_id) REFERENCES "user" (id);

-- ==========================================
-- Foreign Keys from Reviews & Ratings to Item Management
-- ==========================================
ALTER TABLE review ADD FOREIGN KEY (item_id) REFERENCES item (id);

ALTER TABLE review_analytics ADD CONSTRAINT fk_review_analytics_entity_item
    FOREIGN KEY (entity_id) REFERENCES item (id);
ALTER TABLE review_analytics ADD CONSTRAINT check_review_analytics_entity_type_item
    CHECK (review_analytics_entity_type = 'item');

-- ALTER TABLE review_analytics ADD FOREIGN KEY (entity_id) REFERENCES "user" (id) WHEN (review_analytics_entity_type = 'user');
-- ALTER TABLE review_analytics ADD CONSTRAINT check_review_analytics_entity_type_user
--     CHECK (review_analytics_entity_type = 'user');

-- ==========================================
-- Foreign Keys from Reviews & Ratings to Booking & Transactions
-- ==========================================
ALTER TABLE review ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
ALTER TABLE review_reminder ADD FOREIGN KEY (booking_id) REFERENCES booking (id);
-- ==========================================
-- Messaging Module (07)
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
-- Deployment order: 13 (thirteenth deployment step)
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

-- Note: Cross-module foreign keys will be defined in a separate file (14_cross_module_fk.sql)
-- ==========================================
-- Cross-Module Foreign Keys for Messaging Module
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
-- 3. Messaging Module (13_07_messaging_module.sql)
-- 
-- Deployment order: 14 (fourteenth deployment step)

-- ==========================================
-- Foreign Keys from Messaging to User Management
-- ==========================================
ALTER TABLE message ADD FOREIGN KEY (sender_id) REFERENCES "user" (id);
ALTER TABLE conversation_participant ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE message_status ADD FOREIGN KEY (recipient_id) REFERENCES "user" (id);
ALTER TABLE system_notification ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE blocked_user ADD FOREIGN KEY (blocked_by) REFERENCES "user" (id);
ALTER TABLE blocked_user ADD FOREIGN KEY (blocked_user) REFERENCES "user" (id);
ALTER TABLE auto_responder ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE message_analytics ADD FOREIGN KEY (user_id) REFERENCES "user" (id);

-- ==========================================
-- Foreign Keys from Messaging to Item Management
-- ==========================================
ALTER TABLE conversation ADD FOREIGN KEY (item_id) REFERENCES item (id);
-- ==========================================
-- Admin & Support Module (08)
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
-- Deployment order: 15 (fifteenth deployment step)
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

-- Note: Cross-module foreign keys will be defined in a separate file (16_cross_module_fk.sql)
-- ==========================================
-- Cross-Module Foreign Keys for Admin & Support Module
-- ==========================================
-- This file contains all foreign key relationships between the Admin & Support module
-- and other modules (User Management)
-- 
-- Created: 2025-04-16
-- ==========================================

-- ==========================================
-- Prerequisites
-- ==========================================
-- This file depends on:
-- 1. User Management Module (01_01_user_management_module.sql)
-- 2. Admin & Support Module (15_08_admin_support_module.sql)
-- 
-- Deployment order: 16 (sixteenth deployment step)

-- ==========================================
-- Foreign Keys from Admin & Support to User Management
-- ==========================================
ALTER TABLE admin_user ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE support_ticket ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE content_moderation ADD FOREIGN KEY (reported_by) REFERENCES "user" (id);
ALTER TABLE support_ticket_comment ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE audit_trail ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
-- ==========================================
-- Analytics & Reporting Module (09)
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
-- 2. Admin & Support Module (15_08_admin_support_module.sql)
-- 
-- Deployment order: 17 (seventeenth deployment step)
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

-- Note: Cross-module foreign keys will be defined in a separate file (18_cross_module_fk.sql)
-- ==========================================
-- Cross-Module Foreign Keys for Analytics & Reporting Module
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
-- 2. Admin & Support Module (15_08_admin_support_module.sql)
-- 3. Analytics & Reporting Module (17_09_analytics_reporting_module.sql)
-- 
-- Deployment order: 18 (eighteenth deployment step)

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
-- ==========================================
-- Security & Compliance Module (10)
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
-- Deployment order: 19 (nineteenth deployment step)
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

-- Note: Cross-module foreign keys will be defined in a separate file (20_cross_module_fk.sql)
-- ==========================================
-- Cross-Module Foreign Keys for Security & Compliance Module
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
-- 2. Admin & Support Module (15_08_admin_support_module.sql)
-- 3. Security & Compliance Module (19_10_security_compliance_module.sql)
-- 
-- Deployment order: 20 (twentieth deployment step)

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