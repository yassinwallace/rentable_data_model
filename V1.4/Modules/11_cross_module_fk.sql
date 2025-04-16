-- ==========================================
-- Cross-Module Foreign Keys for Booking & Transactions Module (STEP 11)
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
-- 4. Location Management Module (07_04_location_management_module.sql)
-- 5. Booking & Transactions Module (10_05_booking_transactions_module.sql)
-- 
-- Deployment order: 11 (eleventh deployment step)

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