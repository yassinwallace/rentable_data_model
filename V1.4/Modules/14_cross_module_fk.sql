-- ==========================================
-- Cross-Module Foreign Keys for Reviews & Ratings Module (STEP 14)
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
-- 3. Booking & Transactions Module (10_05_booking_transactions_module.sql)
-- 4. Reviews & Ratings Module (14_06_reviews_ratings_module.sql)
-- 
-- Deployment order: 14 (fourteenth deployment step)

-- ==========================================
-- Foreign Keys from Reviews & Ratings to User Management
-- ==========================================
ALTER TABLE review ADD FOREIGN KEY (reviewer_id) REFERENCES "user" (id);
ALTER TABLE review ADD FOREIGN KEY (reviewee_id) REFERENCES "user" (id);
ALTER TABLE review_helpfulness ADD FOREIGN KEY (user_id) REFERENCES "user" (id);
ALTER TABLE review_response ADD FOREIGN KEY (responder_id) REFERENCES "user" (id);
ALTER TABLE review_flag ADD FOREIGN KEY (flagged_by) REFERENCES "user" (id);
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