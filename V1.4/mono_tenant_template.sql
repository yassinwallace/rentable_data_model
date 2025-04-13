CREATE TYPE "user_type" AS ENUM('individual','business');
CREATE TYPE "business_verification_status" AS ENUM('pending','verified','rejected');
CREATE TYPE "locationable_type" AS ENUM('user','business','item');
CREATE TYPE "address_type" AS ENUM('home','business','warehouse','item_collection','other');
CREATE TYPE "user_verification_type" AS ENUM('email','phone','government_id');
CREATE TYPE "user_verification_status" AS ENUM('pending','approved','rejected');
CREATE TYPE "item_owner_type" AS ENUM('user','business');
CREATE TYPE "item_status" AS ENUM('active','inactive','pending_review');
CREATE TYPE "item_condition" AS ENUM('new','like_new','good','fair','poor');
CREATE TYPE "item_type" AS ENUM('P2P','B2B','B2C');
CREATE TYPE "item_insurance_cost_type" AS ENUM('flat','percentage');
CREATE TYPE "related_items_relation_type" AS ENUM('accessory','similar','complementary');
CREATE TYPE "bulk_import_status" AS ENUM('pending','processing','completed','failed');
CREATE TYPE "item_history_action" AS ENUM('created','updated','deleted','status_changed');
CREATE TYPE "booking_status" AS ENUM('pending','confirmed','cancelled','completed');
CREATE TYPE "booking_payment_status" AS ENUM('pending','completed','failed','refunded');
CREATE TYPE "booking_insurance_status" AS ENUM('active','cancelled','claimed');
CREATE TYPE "booking_dispute_type" AS ENUM('damage','late_return','no_show','other');
CREATE TYPE "booking_dispute_status" AS ENUM('open','under_review','resolved','closed');
CREATE TYPE "security_deposit_status" AS ENUM('held','partially_refunded','fully_refunded','claimed');
CREATE TYPE "item_handover_type" AS ENUM('checkout','return');
CREATE TYPE "additional_charge_type" AS ENUM('damage','extra_mileage','cleaning_fee','other');
CREATE TYPE "booking_extension_status" AS ENUM('pending','approved','rejected');
CREATE TYPE "booking_message_type" AS ENUM('chat','system_notification','dispute_related');
CREATE TYPE "payment_status" AS ENUM('pending','completed','failed','refunded');
CREATE TYPE "transaction_type" AS ENUM('payment','refund','payout','fee');
CREATE TYPE "transaction_status" AS ENUM('pending','completed','failed');
CREATE TYPE "refund_status" AS ENUM('pending','processed','failed');
CREATE TYPE "payout_status" AS ENUM('pending','processed','failed');
CREATE TYPE "payment_method_type" AS ENUM('credit_card','debit_card','paypal','bank_transfer');
CREATE TYPE "fee_type" AS ENUM('percentage','fixed');
CREATE TYPE "fee_applicable_to" AS ENUM('renter','owner');
CREATE TYPE "invoice_status" AS ENUM('draft','sent','paid','cancelled');
CREATE TYPE "payment_dispute_reason" AS ENUM('unauthorized','duplicate','fraudulent','incorrect_amount','other');
CREATE TYPE "payment_dispute_status" AS ENUM('open','under_review','resolved','closed');
CREATE TYPE "platform_revenue_type" AS ENUM('commission','fee','penalty');
CREATE TYPE "payout_schedule_frequency" AS ENUM('daily','weekly','monthly');
CREATE TYPE "payout_schedule_user_type" AS ENUM('individual','business');
CREATE TYPE "transaction_logs_action" AS ENUM('created','updated','status_changed');
CREATE TYPE "review_status" AS ENUM('pending','approved','rejected');
CREATE TYPE "review_flag_reason" AS ENUM('inappropriate','spam','offensive','inaccurate','other');
CREATE TYPE "review_flag_status" AS ENUM('pending','reviewed','resolved');
CREATE TYPE "review_reminder_type" AS ENUM('initial','follow_up');
CREATE TYPE "review_reminder_status" AS ENUM('pending','sent','cancelled');
CREATE TYPE "review_analytics_entity_type" AS ENUM('user','item');
CREATE TYPE "renter_type" AS ENUM ('user', 'business');
CREATE TYPE "message_type" AS ENUM('text','system','attachment');
CREATE TYPE "admin_user_role" AS ENUM('super_admin','moderator','support_agent','analyst');
CREATE TYPE "admin_user_status" AS ENUM('active','suspended','inactive');
CREATE TYPE "support_ticket_status" AS ENUM('open','in_progress','resolved','closed');
CREATE TYPE "support_ticket_priority" AS ENUM('low','medium','high','urgent');
CREATE TYPE "content_moderation_status" AS ENUM('pending','reviewed','action_taken','dismissed');
CREATE TYPE "data_export_status" AS ENUM('pending','processing','completed','failed');
CREATE TYPE "ab_test_status" AS ENUM('draft','active','completed','cancelled');
CREATE TYPE "security_incident_severity" AS ENUM('low','medium','high','critical');
CREATE TYPE "security_incident_status" AS ENUM('open','investigating','resolved','closed');
CREATE TYPE "compliance_report_status" AS ENUM('draft','submitted','approved','rejected');
CREATE TYPE "data_access_request_type" AS ENUM('access','deletion','correction');
CREATE TYPE "data_access_request_status" AS ENUM('pending','processing','completed','rejected');
CREATE TYPE "vulnerability_scan_status" AS ENUM('in_progress','completed','failed');
CREATE TYPE "security_alert_severity" AS ENUM('low','medium','high','critical');
CREATE TYPE "security_alert_status" AS ENUM('new','investigating','resolved','false_positive');
CREATE TYPE "third_party_vendor_compliance_status" AS ENUM('compliant','non_compliant','pending_review');

CREATE TABLE "users" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"username" varchar UNIQUE NOT NULL,
"email" varchar UNIQUE NOT NULL,
"password_hash" varchar NOT NULL,
"user_type" user_type NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" timestamp
);

CREATE TABLE "user_profiles" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID NOT NULL,
"first_name" VARCHAR(100) NOT NULL,
"last_name" VARCHAR(100) NOT NULL,
"bio" TEXT,
"avatar_url" VARCHAR(255),
"date_of_birth" DATE,
"gender" VARCHAR(50),
"occupation" VARCHAR(100),
"phone_number" VARCHAR(20),
"preferences" JSONB,
"preferred_language" VARCHAR(10),
"additional_languages" TEXT[],  -- Changed from JSON to text[]
"is_verified" BOOLEAN DEFAULT false,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);


CREATE TABLE "businesses" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"business_name" VARCHAR(255) NOT NULL,
"business_type" VARCHAR(100),
"registration_number" varchar UNIQUE,
"tax_id" VARCHAR(100),
"business_verification_status" business_verification_status NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "business_profiles" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"business_id" UUID NOT NULL,
"description" text,
"website" varchar,
"founded_year" int,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" timestamp
);

CREATE TABLE "users_businesses_assignment" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID,
"business_id" UUID,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "locations" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"locationable_id" UUID NOT NULL,
"locationable_type" locationable_type NOT NULL,
"address_type" address_type NOT NULL,
"street_address1" VARCHAR(255) NOT NULL,
"street_address2" VARCHAR(255),
"city" VARCHAR(100) NOT NULL,
"state" VARCHAR(100),
"postal_code" VARCHAR(20) NOT NULL,
"country" VARCHAR(100) NOT NULL,
"is_default" BOOLEAN DEFAULT false,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "user_verifications" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID,
"user_verification_type" user_verification_type NOT NULL,
"user_verification_status" user_verification_status NOT NULL,
"verification_data" JSONB,
"document_type" VARCHAR(50),
"document_number" VARCHAR(100),
"verified_at" TIMESTAMP,
"expires_at" TIMESTAMP,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "roles" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"name" VARCHAR(50) UNIQUE NOT NULL,
"description" TEXT,
"is_active" BOOLEAN DEFAULT true,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "permissions" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"name" VARCHAR(100) UNIQUE NOT NULL,
"description" TEXT,
"category" VARCHAR(50) NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "role_permissions" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"role_id" UUID,
"permission_id" UUID,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "user_sessions" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"session_id" VARCHAR(255),
"token" VARCHAR(255) UNIQUE,
"user_id" UUID,
"roles" TEXT[],  -- PostgreSQL array for storing roles
"ip_address" VARCHAR(45) NOT NULL,
"user_agent" TEXT,
"expires_at" TIMESTAMP NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "password_reset_tokens" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID,
"token" VARCHAR(255) UNIQUE NOT NULL,
"expires_at" TIMESTAMP NOT NULL,
"is_used" BOOLEAN DEFAULT false,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "user_activity_logs" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID,
"activity_type" VARCHAR(50) NOT NULL,
"details" JSONB,
"ip_address" VARCHAR(45),
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "user_business_roles_assignment" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID,
"business_profile_id" UUID,
"role_id" UUID,
"assigned_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"assigned_by" UUID
);

CREATE TABLE "items" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"owner_id" UUID NOT NULL,
"item_owner_type" item_owner_type NOT NULL,
"title" VARCHAR(255) NOT NULL,
"description" TEXT NOT NULL,
"base_price" DECIMAL(10,2) NOT NULL,
"currency" CHAR(3) NOT NULL,
"item_status" item_status NOT NULL,
"item_condition" item_condition NOT NULL,
"item_type" item_type NOT NULL,
"quantity" INTEGER DEFAULT 1,
"minimum_rental_period" INTEGER,
"maximum_rental_period" INTEGER,
"start_hours" VARCHAR(50),
"end_hours" VARCHAR(50),
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "item_categories" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"parent_id" UUID,
"name" VARCHAR(100) NOT NULL,
"description" TEXT,
"level" INTEGER NOT NULL,
"is_active" BOOLEAN DEFAULT true,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "items_item_categories_assignment" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"item_id" UUID NOT NULL,
"category_id" UUID NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "item_attributes" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"item_id" UUID NOT NULL,
"attribute_name" VARCHAR(100) NOT NULL,
"attribute_value" TEXT NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "item_availability" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"item_id" UUID NOT NULL,
"start_date" DATE NOT NULL,
"end_date" DATE NOT NULL,
"is_available" BOOLEAN NOT NULL,
"custom_price" DECIMAL(10,2),
"inventory_count" INTEGER,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "item_images" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"item_id" UUID NOT NULL,
"image_url" VARCHAR(255) NOT NULL,
"is_primary" BOOLEAN DEFAULT false,
"display_order" INTEGER NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "items_locations_assignment" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"item_id" UUID NOT NULL,
"location_id" UUID NOT NULL,
"location_type" locationable_type NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "item_pricing_tiers" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"item_id" UUID NOT NULL,
"min_days" INTEGER NOT NULL,
"max_days" INTEGER,
"price_per_day" DECIMAL(10,2) NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "item_maintenance_records" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"item_id" UUID NOT NULL,
"maintenance_type" VARCHAR(100) NOT NULL,
"description" TEXT,
"performed_by" VARCHAR(255),
"performed_at" TIMESTAMP NOT NULL,
"cost" DECIMAL(10,2),
"next_maintenance_due" TIMESTAMP,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "item_rental_rules" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"item_id" UUID NOT NULL,
"rule_type" VARCHAR(100) NOT NULL,
"rule_value" TEXT NOT NULL,
"is_required" BOOLEAN DEFAULT true,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "item_insurance_options" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"item_id" UUID NOT NULL,
"insurance_name" VARCHAR(255) NOT NULL,
"description" TEXT,
"cost" DECIMAL(10,2) NOT NULL,
"item_insurance_cost_type" item_insurance_cost_type NOT NULL,
"coverage_amount" DECIMAL(10,2) NOT NULL,
"is_required" BOOLEAN DEFAULT false,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "item_bundles" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"name" VARCHAR(255) NOT NULL,
"description" TEXT,
"discount_percentage" DECIMAL(5,2),
"is_active" BOOLEAN DEFAULT true,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "items_bundles_assignment" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"bundle_id" UUID NOT NULL,
"item_id" UUID NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "related_items" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"item_id" UUID NOT NULL,
"related_item_id" UUID NOT NULL,
"related_items_relation_type" related_items_relation_type NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "bulk_imports" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID NOT NULL,
"business_id" UUID,
"bulk_import_status" bulk_import_status NOT NULL,
"total_items" INTEGER NOT NULL,
"processed_items" INTEGER DEFAULT 0,
"error_log" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "service_level_agreements" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"item_id" UUID NOT NULL,
"name" VARCHAR(255) NOT NULL,
"description" TEXT,
"terms" TEXT NOT NULL,
"is_active" BOOLEAN DEFAULT true,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "item_history" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"item_id" UUID NOT NULL,
"user_id" UUID NOT NULL,
"item_history_action" item_history_action NOT NULL,
"details" JSONB,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "bookings" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"item_id" UUID NOT NULL,
"renter_id" UUID NOT NULL,
"renter_type" renter_type NOT NULL,
"start_date" TIMESTAMP NOT NULL,
"end_date" TIMESTAMP NOT NULL,
"booking_status" booking_status NOT NULL,
"total_price" DECIMAL(10,2) NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);



CREATE TABLE "booking_payments" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"booking_id" UUID NOT NULL,
"amount" DECIMAL(10,2) NOT NULL,
"payment_method" VARCHAR(50) NOT NULL,
"transaction_id" VARCHAR(255),
"booking_payment_status" booking_payment_status NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "booking_insurance" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"booking_id" UUID NOT NULL,
"insurance_option_id" UUID NOT NULL,
"cost" DECIMAL(10,2) NOT NULL,
"booking_insurance_status" booking_insurance_status NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "booking_status_history" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"booking_id" UUID NOT NULL,
"booking_status" booking_status NOT NULL,
"changed_by" UUID NOT NULL,
"reason" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "booking_disputes" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"booking_id" UUID NOT NULL,
"reported_by" UUID NOT NULL,
"booking_dispute_type" booking_dispute_type NOT NULL,
"description" TEXT NOT NULL,
"booking_dispute_status" booking_dispute_status NOT NULL,
"resolution" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "booking_reviews" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"booking_id" UUID NOT NULL,
"reviewer_id" UUID NOT NULL,
"reviewee_id" UUID NOT NULL,
"rating" INTEGER NOT NULL,
"review" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "booking_cancellations" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"booking_id" UUID NOT NULL,
"cancelled_by" UUID NOT NULL,
"reason" TEXT NOT NULL,
"cancellation_fee" DECIMAL(10,2),
"refund_amount" DECIMAL(10,2),
"policy_applied" VARCHAR(255) NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "security_deposits" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"booking_id" UUID NOT NULL,
"amount" DECIMAL(10,2) NOT NULL,
"security_deposit_status" security_deposit_status NOT NULL,
"hold_transaction_id" VARCHAR(255),
"release_transaction_id" VARCHAR(255),
"claimed_amount" DECIMAL(10,2),
"claim_reason" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "item_handovers" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"booking_id" UUID NOT NULL,
"item_handover_type" item_handover_type NOT NULL,
"scheduled_time" TIMESTAMP NOT NULL,
"actual_time" TIMESTAMP,
"location" TEXT,
"handover_by" UUID NOT NULL,
"handover_to" UUID NOT NULL,
"item_condition" TEXT,
"notes" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "late_returns" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"booking_id" UUID NOT NULL,
"actual_return_time" TIMESTAMP NOT NULL,
"late_duration" INTERVAL NOT NULL,
"additional_charge" DECIMAL(10,2) NOT NULL,
"reason" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "additional_charges" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"booking_id" UUID NOT NULL,
"additional_charge_type" additional_charge_type NOT NULL,
"amount" DECIMAL(10,2) NOT NULL,
"description" TEXT NOT NULL,
"charged_at" TIMESTAMP NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "booking_extensions" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"booking_id" UUID NOT NULL,
"requested_by" UUID NOT NULL,
"original_end_date" TIMESTAMP NOT NULL,
"requested_end_date" TIMESTAMP NOT NULL,
"booking_extension_status" booking_extension_status NOT NULL,
"additional_cost" DECIMAL(10,2),
"approved_by" UUID,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "booking_communication_logs" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"booking_id" UUID NOT NULL,
"sender_id" UUID NOT NULL,
"recipient_id" UUID NOT NULL,
"booking_message_type" booking_message_type NOT NULL,
"message_content" TEXT NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "payments" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"booking_id" UUID NOT NULL,
"user_id" UUID NOT NULL,
"amount" DECIMAL(10,2) NOT NULL,
"currency" CHAR(3) NOT NULL,
"payment_method" VARCHAR(50) NOT NULL,
"payment_status" payment_status NOT NULL,
"transaction_id" VARCHAR(255),
"payment_date" TIMESTAMP NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "transactions" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID NOT NULL,
"item_id" UUID,
"booking_id" UUID,
"transaction_type" transaction_type NOT NULL,
"amount" DECIMAL(10,2) NOT NULL,
"currency" CHAR(3) NOT NULL,
"transaction_status" transaction_status NOT NULL,
"description" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "refunds" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"payment_id" UUID NOT NULL,
"amount" DECIMAL(10,2) NOT NULL,
"currency" CHAR(3) NOT NULL,
"reason" TEXT NOT NULL,
"refund_status" refund_status NOT NULL,
"refunded_by" UUID NOT NULL,
"refund_date" TIMESTAMP,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "payouts" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID NOT NULL,
"amount" DECIMAL(10,2) NOT NULL,
"currency" CHAR(3) NOT NULL,
"payout_status" payout_status NOT NULL,
"payout_method" VARCHAR(50) NOT NULL,
"payout_reference" VARCHAR(255),
"scheduled_date" TIMESTAMP NOT NULL,
"processed_date" TIMESTAMP,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "payment_methods" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID NOT NULL,
"payment_method_type" payment_method_type NOT NULL,
"provider_token" VARCHAR(255) NOT NULL,
"last4" CHAR(4),
"expiry_month" SMALLINT,
"expiry_year" SMALLINT,
"is_default" BOOLEAN DEFAULT false,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "fees" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"name" VARCHAR(100) NOT NULL,
"description" TEXT,
"fee_type" fee_type NOT NULL,
"value" DECIMAL(5,2) NOT NULL,
"fee_applicable_to" fee_applicable_to NOT NULL,
"is_active" BOOLEAN DEFAULT true,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "invoices" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID NOT NULL,
"booking_id" UUID NOT NULL,
"invoice_number" VARCHAR(50) UNIQUE NOT NULL,
"total_amount" DECIMAL(10,2) NOT NULL,
"tax_amount" DECIMAL(10,2) NOT NULL,
"invoice_status" invoice_status NOT NULL,
"due_date" TIMESTAMP NOT NULL,
"paid_date" TIMESTAMP,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "tax_rates" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"name" VARCHAR(100) NOT NULL,
"rate" DECIMAL(5,2) NOT NULL,
"country" VARCHAR(100) NOT NULL,
"region" VARCHAR(100),
"item_category_id" UUID,
"start_date" DATE NOT NULL,
"end_date" DATE,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "currency_exchange_rates" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"from_currency" CHAR(3) NOT NULL,
"to_currency" CHAR(3) NOT NULL,
"exchange_rate" DECIMAL(10,6) NOT NULL,
"effective_date" DATE NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "promotional_credits" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID NOT NULL,
"credit_code" VARCHAR(50) UNIQUE,
"amount" DECIMAL(10,2) NOT NULL,
"currency" CHAR(3) NOT NULL,
"expiration_date" TIMESTAMP,
"is_used" BOOLEAN DEFAULT false,
"used_at" TIMESTAMP,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "payment_disputes" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"payment_id" UUID NOT NULL,
"disputed_by" UUID NOT NULL,
"payment_dispute_reason" payment_dispute_reason NOT NULL,
"description" TEXT NOT NULL,
"payment_dispute_status" payment_dispute_status NOT NULL,
"resolution" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "platform_revenue" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"date" DATE NOT NULL,
"platform_revenue_type" platform_revenue_type NOT NULL,
"amount" DECIMAL(10,2) NOT NULL,
"currency" CHAR(3) NOT NULL,
"description" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "payout_schedules" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"name" VARCHAR(100) NOT NULL,
"payout_schedule_frequency" payout_schedule_frequency NOT NULL,
"day_of_week" SMALLINT,
"day_of_month" SMALLINT,
"min_amount" DECIMAL(10,2),
"payout_schedule_user_type" payout_schedule_user_type NOT NULL,
"is_default" BOOLEAN DEFAULT false,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "transaction_logs" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"transaction_id" UUID NOT NULL,
"transaction_logs_action" transaction_logs_action NOT NULL,
"description" TEXT NOT NULL,
"performed_by" UUID,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "payment_gateways" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"name" VARCHAR(100) NOT NULL,
"api_key" VARCHAR(255) NOT NULL,
"secret_key" VARCHAR(255) NOT NULL,
"is_active" BOOLEAN DEFAULT true,
"supported_currencies" JSONB,
"config_settings" JSONB,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "review_types" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"name" VARCHAR(50) UNIQUE NOT NULL,
"description" TEXT,
"is_active" BOOLEAN DEFAULT true,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "review_categories" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"review_type_id" UUID NOT NULL,
"name" VARCHAR(100) NOT NULL,
"description" TEXT,
"is_active" BOOLEAN DEFAULT true,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "reviews" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"review_type_id" UUID NOT NULL,
"booking_id" UUID NOT NULL,
"reviewer_id" UUID NOT NULL,
"reviewee_id" UUID NOT NULL,
"item_id" UUID NOT NULL,
"rating" DECIMAL(2,1) NOT NULL,
"review_content" TEXT,
"is_public" BOOLEAN DEFAULT true,
"review_status" review_status NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "category_ratings" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"review_id" UUID NOT NULL,
"category_id" UUID NOT NULL,
"rating" DECIMAL(2,1) NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "review_photos" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"review_id" UUID NOT NULL,
"photo_url" VARCHAR(255) NOT NULL,
"caption" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "review_helpfulness" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"review_id" UUID NOT NULL,
"user_id" UUID NOT NULL,
"is_helpful" BOOLEAN NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "review_responses" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"review_id" UUID NOT NULL,
"responder_id" UUID NOT NULL,
"content" TEXT NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "review_flags" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"review_id" UUID NOT NULL,
"flagged_by" UUID NOT NULL,
"review_flag_reason" review_flag_reason NOT NULL,
"description" TEXT,
"review_flag_status" review_flag_status NOT NULL,
"resolution_note" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "user_reputation_scores" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID NOT NULL,
"overall_score" DECIMAL(3,2) NOT NULL,
"renter_score" DECIMAL(3,2),
"owner_score" DECIMAL(3,2),
"total_reviews" INTEGER DEFAULT 0,
"total_transactions" INTEGER DEFAULT 0,
"last_calculated_at" TIMESTAMP NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "review_reminders" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"booking_id" UUID NOT NULL,
"user_id" UUID NOT NULL,
"review_reminder_type" review_reminder_type NOT NULL,
"scheduled_at" TIMESTAMP NOT NULL,
"sent_at" TIMESTAMP,
"review_reminder_status" review_reminder_status NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "review_analytics" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"review_analytics_entity_type" review_analytics_entity_type NOT NULL,
"entity_id" UUID NOT NULL,
"average_rating" DECIMAL(3,2) NOT NULL,
"total_reviews" INTEGER NOT NULL,
"rating_distribution" JSONB NOT NULL,
"most_common_keywords" JSONB,
"last_review_date" TIMESTAMP,
"last_calculated_at" TIMESTAMP NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "conversations" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"item_id" UUID,
"last_message_at" TIMESTAMP NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "messages" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"conversation_id" UUID NOT NULL,
"sender_id" UUID NOT NULL,
"content" TEXT NOT NULL,
"message_type" message_type NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "message_attachments" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"message_id" UUID NOT NULL,
"file_url" VARCHAR(255) NOT NULL,
"file_type" VARCHAR(50) NOT NULL,
"file_name" VARCHAR(255) NOT NULL,
"file_size" INTEGER NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "conversation_participants" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"conversation_id" UUID NOT NULL,
"user_id" UUID NOT NULL,
"last_read_message_id" UUID,
"is_archived" BOOLEAN DEFAULT false,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "message_statuses" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"message_id" UUID NOT NULL,
"recipient_id" UUID NOT NULL,
"is_delivered" BOOLEAN DEFAULT false,
"is_read" BOOLEAN DEFAULT false,
"delivered_at" TIMESTAMP,
"read_at" TIMESTAMP,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "system_notifications" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID NOT NULL,
"notification_type" VARCHAR(100) NOT NULL,
"content" TEXT NOT NULL,
"is_read" BOOLEAN DEFAULT false,
"related_entity_type" VARCHAR(50),
"related_entity_id" UUID,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "blocked_users" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"blocked_by" UUID NOT NULL,
"blocked_user" UUID NOT NULL,
"reason" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "message_templates" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"template_name" VARCHAR(100) NOT NULL,
"template_content" TEXT NOT NULL,
"is_active" BOOLEAN DEFAULT true,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "auto_responders" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID NOT NULL,
"is_active" BOOLEAN DEFAULT false,
"start_date" TIMESTAMP,
"end_date" TIMESTAMP,
"message" TEXT NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "message_analytics" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID NOT NULL,
"average_response_time" INTERVAL,
"messages_sent" INTEGER DEFAULT 0,
"messages_received" INTEGER DEFAULT 0,
"last_updated_at" TIMESTAMP NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "admin_users" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID,
"admin_user_role" admin_user_role NOT NULL,
"admin_user_status" admin_user_status NOT NULL,
"last_login_at" TIMESTAMP,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "support_tickets" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID,
"subject" VARCHAR(255) NOT NULL,
"description" TEXT NOT NULL,
"support_ticket_status" support_ticket_status NOT NULL,
"support_ticket_priority" support_ticket_priority NOT NULL,
"category" VARCHAR(100) NOT NULL,
"assigned_to" UUID,
"resolution" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "admin_logs" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"admin_id" UUID,
"action" VARCHAR(100) NOT NULL,
"entity_type" VARCHAR(50) NOT NULL,
"entity_id" UUID NOT NULL,
"details" JSONB NOT NULL,
"ip_address" VARCHAR(45) NOT NULL,
"user_agent" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "system_settings" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"key" VARCHAR(100) UNIQUE NOT NULL,
"value" TEXT NOT NULL,
"data_type" VARCHAR(50) NOT NULL,
"description" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "content_moderation" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"content_type" VARCHAR(50) NOT NULL,
"content_id" UUID NOT NULL,
"reported_by" UUID,
"reason" TEXT NOT NULL,
"content_moderation_status" content_moderation_status NOT NULL,
"moderated_by" UUID,
"action_taken" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "support_ticket_comments" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"ticket_id" UUID,
"user_id" UUID,
"comment" TEXT NOT NULL,
"is_internal" BOOLEAN DEFAULT false,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "faq_categories" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"name" VARCHAR(100) NOT NULL,
"description" TEXT,
"is_active" BOOLEAN DEFAULT true,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "faqs" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"category_id" UUID,
"question" TEXT NOT NULL,
"answer" TEXT NOT NULL,
"is_active" BOOLEAN DEFAULT true,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "admin_notifications" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"admin_id" UUID,
"message" TEXT NOT NULL,
"is_read" BOOLEAN DEFAULT false,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "audit_trails" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID,
"action" VARCHAR(100) NOT NULL,
"table_name" VARCHAR(100) NOT NULL,
"record_id" UUID NOT NULL,
"old_values" JSONB,
"new_values" JSONB,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "analytics_events" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID,
"event_type" VARCHAR(100) NOT NULL,
"event_data" JSONB NOT NULL,
"device_type" VARCHAR(50),
"browser_info" VARCHAR(255),
"ip_address" VARCHAR(45),
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "metrics" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"metric_name" VARCHAR(100) NOT NULL,
"metric_value" DECIMAL(15,2) NOT NULL,
"metric_unit" VARCHAR(50),
"time_period" VARCHAR(50) NOT NULL,
"date" DATE NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "reports" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"name" VARCHAR(255) NOT NULL,
"description" TEXT,
"report_type" VARCHAR(100) NOT NULL,
"configuration" JSONB NOT NULL,
"schedule" VARCHAR(100),
"last_run_at" TIMESTAMP,
"created_by" UUID,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "data_warehouse" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"dimension_type" VARCHAR(100) NOT NULL,
"dimension_id" UUID NOT NULL,
"metric_name" VARCHAR(100) NOT NULL,
"metric_value" DECIMAL(15,2) NOT NULL,
"date" DATE NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "user_segments" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"name" VARCHAR(255) NOT NULL,
"description" TEXT,
"criteria" JSONB NOT NULL,
"created_by" UUID,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "dashboards" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"name" VARCHAR(255) NOT NULL,
"description" TEXT,
"layout" JSONB,
"is_public" BOOLEAN DEFAULT false,
"created_by" UUID,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "dashboard_widgets" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"dashboard_id" UUID,
"widget_type" VARCHAR(100) NOT NULL,
"name" VARCHAR(255) NOT NULL,
"configuration" JSONB NOT NULL,
"position" JSONB,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "data_exports" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID,
"export_type" VARCHAR(100) NOT NULL,
"data_export_status" data_export_status NOT NULL,
"file_url" VARCHAR(255),
"expires_at" TIMESTAMP,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "ab_tests" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"name" VARCHAR(255) NOT NULL,
"description" TEXT,
"start_date" TIMESTAMP NOT NULL,
"end_date" TIMESTAMP,
"ab_test_status" ab_test_status NOT NULL,
"variants" JSONB NOT NULL,
"created_by" UUID,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "ab_test_results" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"test_id" UUID,
"variant" VARCHAR(100) NOT NULL,
"metric_name" VARCHAR(100) NOT NULL,
"metric_value" DECIMAL(15,2) NOT NULL,
"sample_size" INTEGER NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "audit_logs" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID,
"event_type" VARCHAR(100) NOT NULL,
"event_details" JSONB NOT NULL,
"ip_address" VARCHAR(45) NOT NULL,
"user_agent" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "user_consent" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID,
"consent_type" VARCHAR(100) NOT NULL,
"version" VARCHAR(50) NOT NULL,
"ip_address" VARCHAR(45) NOT NULL,
"consented_at" TIMESTAMP NOT NULL,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "security_incidents" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"incident_type" VARCHAR(100) NOT NULL,
"description" TEXT NOT NULL,
"security_incident_severity" security_incident_severity NOT NULL,
"security_incident_status" security_incident_status NOT NULL,
"reported_by" UUID,
"assigned_to" UUID,
"resolution_notes" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "data_encryption_keys" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"key_type" VARCHAR(50) NOT NULL,
"encrypted_key" TEXT NOT NULL,
"is_active" BOOLEAN NOT NULL,
"activated_at" TIMESTAMP NOT NULL,
"expires_at" TIMESTAMP,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "compliance_reports" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"report_type" VARCHAR(100) NOT NULL,
"report_period" VARCHAR(50) NOT NULL,
"compliance_report_status" compliance_report_status NOT NULL,
"submitted_by" UUID,
"submitted_at" TIMESTAMP,
"report_url" TEXT,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "data_access_requests" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"user_id" UUID,
"data_access_request_type" data_access_request_type NOT NULL,
"data_access_request_status" data_access_request_status NOT NULL,
"request_details" JSONB,
"completed_at" TIMESTAMP,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "data_retention_policies" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"data_type" VARCHAR(100) NOT NULL,
"retention_period" INTERVAL NOT NULL,
"description" TEXT,
"is_active" BOOLEAN DEFAULT true,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "vulnerability_scans" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"scan_type" VARCHAR(100) NOT NULL,
"start_time" TIMESTAMP NOT NULL,
"end_time" TIMESTAMP,
"vulnerability_scan_status" vulnerability_scan_status NOT NULL,
"results" JSONB,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "security_alerts" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"alert_type" VARCHAR(100) NOT NULL,
"security_alert_severity" security_alert_severity NOT NULL,
"description" TEXT NOT NULL,
"security_alert_status" security_alert_status NOT NULL,
"resolved_by" UUID,
"resolved_at" TIMESTAMP,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE TABLE "third_party_vendors" (
"id" UUID DEFAULT gen_random_uuid() PRIMARY KEY,
"name" VARCHAR(255) NOT NULL,
"service_type" VARCHAR(100) NOT NULL,
"contract_start_date" DATE NOT NULL,
"contract_end_date" DATE,
"data_access_level" VARCHAR(50) NOT NULL,
"third_party_vendor_compliance_status" third_party_vendor_compliance_status NOT NULL,
"last_audit_date" DATE,
"created_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP),
"updated_at" TIMESTAMP DEFAULT (CURRENT_TIMESTAMP)
);

CREATE UNIQUE INDEX ON "users" ("email", "username");
CREATE INDEX "user_created_at_index" ON "users" ("created_at");
CREATE UNIQUE INDEX ON "user_profiles" ("user_id", "phone_number");
CREATE INDEX ON "user_profiles" ("first_name", "last_name");
CREATE INDEX ON "businesses" ("business_name");
CREATE UNIQUE INDEX ON "businesses" ("registration_number", "tax_id");
CREATE UNIQUE INDEX ON "business_profiles" ("business_id");
CREATE INDEX ON "business_profiles" ("founded_year");
ALTER TABLE user_profiles ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE business_profiles ADD FOREIGN KEY (business_id) REFERENCES businesses (id);
ALTER TABLE users_businesses_assignment ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE users_businesses_assignment ADD FOREIGN KEY (business_id) REFERENCES businesses (id);
ALTER TABLE user_verifications ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE role_permissions ADD FOREIGN KEY (role_id) REFERENCES roles (id);
ALTER TABLE role_permissions ADD FOREIGN KEY (permission_id) REFERENCES permissions (id);
ALTER TABLE user_sessions ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE password_reset_tokens ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE user_activity_logs ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE user_business_roles_assignment  ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE user_business_roles_assignment  ADD FOREIGN KEY (business_profile_id) REFERENCES businesses (id);
ALTER TABLE user_business_roles_assignment  ADD FOREIGN KEY (role_id) REFERENCES roles (id);
ALTER TABLE user_business_roles_assignment  ADD FOREIGN KEY (assigned_by) REFERENCES users (id);
ALTER TABLE items ADD FOREIGN KEY (owner_id) REFERENCES users (id);
ALTER TABLE items ADD FOREIGN KEY (owner_id) REFERENCES businesses (id);
ALTER TABLE locations ADD FOREIGN KEY (locationable_id) REFERENCES users (id);
ALTER TABLE locations ADD FOREIGN KEY (locationable_id) REFERENCES businesses (id);
ALTER TABLE item_categories  ADD FOREIGN KEY (parent_id) REFERENCES item_categories (id);
ALTER TABLE items_item_categories_assignment  ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE items_item_categories_assignment  ADD FOREIGN KEY (category_id) REFERENCES item_categories (id);
ALTER TABLE item_attributes ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE item_availability ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE item_images ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE items_locations_assignment  ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE item_pricing_tiers ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE item_maintenance_records ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE item_rental_rules ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE item_insurance_options ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE items_bundles_assignment ADD FOREIGN KEY (bundle_id) REFERENCES item_bundles (id);
ALTER TABLE items_bundles_assignment ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE related_items ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE related_items ADD FOREIGN KEY (related_item_id) REFERENCES items (id);
ALTER TABLE bulk_imports ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE bulk_imports ADD FOREIGN KEY (business_id) REFERENCES businesses (id);
ALTER TABLE service_level_agreements ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE item_history ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE item_history ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE bookings ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE bookings ADD FOREIGN KEY (renter_id) REFERENCES users (id);
ALTER TABLE bookings ADD FOREIGN KEY (renter_id) REFERENCES businesses (id);
ALTER TABLE booking_payments ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE booking_insurance ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE booking_insurance ADD FOREIGN KEY (insurance_option_id) REFERENCES item_insurance_options (id);
ALTER TABLE booking_status_history ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE booking_status_history ADD FOREIGN KEY (changed_by) REFERENCES users (id);
ALTER TABLE booking_disputes ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE booking_disputes ADD FOREIGN KEY (reported_by) REFERENCES users (id);
ALTER TABLE booking_reviews ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE booking_reviews ADD FOREIGN KEY (reviewer_id) REFERENCES users (id);
ALTER TABLE booking_reviews ADD FOREIGN KEY (reviewee_id) REFERENCES users (id);
ALTER TABLE booking_cancellations ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE booking_cancellations ADD FOREIGN KEY (cancelled_by) REFERENCES users (id);
ALTER TABLE security_deposits ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE item_handovers ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE item_handovers ADD FOREIGN KEY (handover_by) REFERENCES users (id);
ALTER TABLE item_handovers ADD FOREIGN KEY (handover_to) REFERENCES users (id);
ALTER TABLE late_returns ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE additional_charges ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE booking_extensions ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE booking_extensions ADD FOREIGN KEY (requested_by) REFERENCES users (id);
ALTER TABLE booking_extensions ADD FOREIGN KEY (approved_by) REFERENCES users (id);
ALTER TABLE booking_communication_logs ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE booking_communication_logs ADD FOREIGN KEY (sender_id) REFERENCES users (id);
ALTER TABLE booking_communication_logs ADD FOREIGN KEY (recipient_id) REFERENCES users (id);
ALTER TABLE payments ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE payments ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE transactions ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE transactions ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE transactions ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE refunds ADD FOREIGN KEY (payment_id) REFERENCES payments (id);
ALTER TABLE refunds ADD FOREIGN KEY (refunded_by) REFERENCES users (id);
ALTER TABLE payouts ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE payment_methods ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE invoices ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE invoices ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE tax_rates ADD FOREIGN KEY (item_category_id) REFERENCES item_categories (id);
ALTER TABLE promotional_credits ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE payment_disputes ADD FOREIGN KEY (payment_id) REFERENCES payments (id);
ALTER TABLE payment_disputes ADD FOREIGN KEY (disputed_by) REFERENCES users (id);
ALTER TABLE transaction_logs ADD FOREIGN KEY (transaction_id) REFERENCES transactions (id);
ALTER TABLE transaction_logs ADD FOREIGN KEY (performed_by) REFERENCES users (id);
ALTER TABLE reviews ADD FOREIGN KEY (review_type_id) REFERENCES review_types (id);
ALTER TABLE reviews ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE reviews ADD FOREIGN KEY (reviewer_id) REFERENCES users (id);
ALTER TABLE reviews ADD FOREIGN KEY (reviewee_id) REFERENCES users (id);
ALTER TABLE reviews ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE category_ratings ADD FOREIGN KEY (review_id) REFERENCES reviews (id);
ALTER TABLE category_ratings ADD FOREIGN KEY (category_id) REFERENCES review_categories (id);
ALTER TABLE review_photos ADD FOREIGN KEY (review_id) REFERENCES reviews (id);
ALTER TABLE review_helpfulness ADD FOREIGN KEY (review_id) REFERENCES reviews (id);
ALTER TABLE review_helpfulness ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE review_responses ADD FOREIGN KEY (review_id) REFERENCES reviews (id);
ALTER TABLE review_responses ADD FOREIGN KEY (responder_id) REFERENCES users (id);
ALTER TABLE review_flags ADD FOREIGN KEY (review_id) REFERENCES reviews (id);
ALTER TABLE review_flags ADD FOREIGN KEY (flagged_by) REFERENCES users (id);
ALTER TABLE user_reputation_scores ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE review_reminders ADD FOREIGN KEY (booking_id) REFERENCES bookings (id);
ALTER TABLE review_reminders ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE review_categories ADD FOREIGN KEY (review_type_id) REFERENCES review_types (id);
ALTER TABLE review_analytics ADD FOREIGN KEY (entity_id) REFERENCES users (id);
ALTER TABLE review_analytics ADD FOREIGN KEY (entity_id) REFERENCES items (id);
ALTER TABLE conversations ADD FOREIGN KEY (item_id) REFERENCES items (id);
ALTER TABLE messages ADD FOREIGN KEY (conversation_id) REFERENCES conversations (id);
ALTER TABLE messages ADD FOREIGN KEY (sender_id) REFERENCES users (id);
ALTER TABLE message_attachments ADD FOREIGN KEY (message_id) REFERENCES messages (id);
ALTER TABLE conversation_participants ADD FOREIGN KEY (conversation_id) REFERENCES conversations (id);
ALTER TABLE conversation_participants ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE conversation_participants ADD FOREIGN KEY (last_read_message_id) REFERENCES messages (id);
ALTER TABLE message_statuses ADD FOREIGN KEY (message_id) REFERENCES messages (id);
ALTER TABLE message_statuses ADD FOREIGN KEY (recipient_id) REFERENCES users (id);
ALTER TABLE system_notifications ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE blocked_users ADD FOREIGN KEY (blocked_by) REFERENCES users (id);
ALTER TABLE blocked_users ADD FOREIGN KEY (blocked_user) REFERENCES users (id);
ALTER TABLE auto_responders ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE message_analytics ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE admin_users ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE support_tickets ADD FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE support_tickets ADD FOREIGN KEY (assigned_to) REFERENCES admin_users (id);
ALTER TABLE admin_logs ADD FOREIGN KEY (admin_id) REFERENCES admin_users (id);
ALTER TABLE content_moderation ADD FOREIGN KEY (reported_by) REFERENCES users (id);
ALTER TABLE content_moderation ADD FOREIGN KEY (moderated_by) REFERENCES admin_users (id);
ALTER TABLE "support_ticket_comments" ADD FOREIGN KEY ("ticket_id") REFERENCES "support_tickets" ("id");
ALTER TABLE "support_ticket_comments" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "faqs" ADD FOREIGN KEY ("category_id") REFERENCES "faq_categories" ("id");
ALTER TABLE "admin_notifications" ADD FOREIGN KEY ("admin_id") REFERENCES "admin_users" ("id");
ALTER TABLE "audit_trails" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "analytics_events" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "reports" ADD FOREIGN KEY ("created_by") REFERENCES "admin_users" ("id");
ALTER TABLE "user_segments" ADD FOREIGN KEY ("created_by") REFERENCES "admin_users" ("id");
ALTER TABLE "dashboards" ADD FOREIGN KEY ("created_by") REFERENCES "admin_users" ("id");
ALTER TABLE "dashboard_widgets" ADD FOREIGN KEY ("dashboard_id") REFERENCES "dashboards" ("id");
ALTER TABLE "data_exports" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "ab_tests" ADD FOREIGN KEY ("created_by") REFERENCES "admin_users" ("id");
ALTER TABLE "ab_test_results" ADD FOREIGN KEY ("test_id") REFERENCES "ab_tests" ("id");
ALTER TABLE "audit_logs" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "user_consent" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "security_incidents" ADD FOREIGN KEY ("reported_by") REFERENCES "users" ("id");
ALTER TABLE "security_incidents" ADD FOREIGN KEY ("assigned_to") REFERENCES "admin_users" ("id");
ALTER TABLE "compliance_reports" ADD FOREIGN KEY ("submitted_by") REFERENCES "admin_users" ("id");
ALTER TABLE "data_access_requests" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "security_alerts" ADD FOREIGN KEY ("resolved_by") REFERENCES "admin_users" ("id");