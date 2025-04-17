-- START OF: 01_01_user_management_module.sql
-- ==========================================
-- User Management Module (STEP 01)
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
-- END OF: 01_01_user_management_module.sql

-- START OF: 02_02_business_management_module.sql
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
-- END OF: 02_02_business_management_module.sql

-- START OF: 03_cross_module_fk.sql
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
-- END OF: 03_cross_module_fk.sql

