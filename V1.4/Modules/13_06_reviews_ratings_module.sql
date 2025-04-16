-- ==========================================
-- Reviews & Ratings Module (STEP 13)
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
-- 3. Booking & Transactions Module (10_05_booking_transactions_module.sql)
-- 
-- Deployment order: 13 (thirteenth deployment step)
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

-- Note: Cross-module foreign keys will be defined in a separate file (14_cross_module_fk.sql)