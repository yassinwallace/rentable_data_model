-- ==========================================
-- Booking & Transactions Module (STEP 10)
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
-- Deployment order: 10 (tenth deployment step)
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

-- Note: Cross-module foreign keys will be defined in a separate file (11_cross_module_fk.sql)