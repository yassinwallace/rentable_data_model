-- CREATE TYPE profile_type AS ENUM (
--   'individual',
--   'organization'
-- );

-- CREATE TABLE "profile" (
--   "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   "user_id" UUID NOT NULL,
--   "profile_type" profile_type NOT NULL,
--   "first_name" VARCHAR,
--   "last_name" VARCHAR,
--   "date_of_birth" DATE,
--   "organization_name" VARCHAR,
--   "siret_number" VARCHAR,
--   "phone_number" VARCHAR,
--   "avatar_url" VARCHAR,
--   "created_at" TIMESTAMP DEFAULT now()
-- );

-- CREATE TYPE certification_type AS ENUM (
--   'CACES',
--   'Forklift',
--   'Crane',
--   'Other'
-- );

-- CREATE TYPE item_status AS ENUM (
--   'active',
--   'inactive',
--   'pending_review'
-- );

-- CREATE TYPE item_condition AS ENUM (
--   'new',
--   'like_new',
--   'good',
--   'fair',
--   'poor'
-- );

-- CREATE TYPE item_type AS ENUM (
--   'P2P',
--   'B2B',
--   'B2C'
-- );

-- CREATE TYPE item_insurance_cost_type AS ENUM (
--   'flat',
--   'percentage'
-- );

-- CREATE TYPE related_items_relation_type AS ENUM (
--   'accessory',
--   'similar',
--   'complementary'
-- );

-- CREATE TYPE bulk_import_status AS ENUM (
--   'pending',
--   'processing',
--   'completed',
--   'failed'
-- );

-- CREATE TYPE item_history_action AS ENUM (
--   'created',
--   'updated',
--   'deleted',
--   'status_changed'
-- );

-- CREATE TYPE logistics_type AS ENUM (
--   'delivery',
--   'pickup'
-- );

-- CREATE TYPE logistics_mode AS ENUM (
--   'none',
--   'optional',
--   'required'
-- );

-- CREATE TYPE logistics_party_type AS ENUM (
--   'renter',
--   'owner',
--   'transporter'
-- );

-- CREATE TYPE item_block_type AS ENUM (
--   'maintenance',
--   'internal_use',
--   'reserved_for_demo',
--   'unavailable_other'
-- );

-- CREATE TABLE "item" (
--   "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   "owner_profile_id" UUID NOT NULL,
--   "title" VARCHAR(255) NOT NULL,
--   "description" TEXT NOT NULL,
--   "base_price" DECIMAL(10,2) NOT NULL,
--   "currency" CHAR(3) NOT NULL,
--   "item_status" item_status NOT NULL,
--   "item_condition" item_condition NULL,
--   "item_type" item_type NOT NULL,
--   "minimum_rental_period" INT,
--   "maximum_rental_period" INT,
--   "start_hours" VARCHAR(50),
--   "end_hours" VARCHAR(50),
--   "required_certification" certification_type NULL,
--   "logistics_mode" logistics_mode DEFAULT 'none',
--   "created_at" TIMESTAMP DEFAULT now(),
--   "updated_at" TIMESTAMP DEFAULT now()
-- );

-- CREATE TABLE "item_unit" (
--   "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   "item_id" UUID NOT NULL,
--   "serial_number" VARCHAR,
--   "internal_reference" VARCHAR,
--   "item_condition" item_condition,
--   "is_active" BOOLEAN DEFAULT TRUE,
--   "current_location_id" UUID,
--   "created_at" TIMESTAMP DEFAULT now()
-- );


-- CREATE TABLE "item_addon" (
--   "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--   "item_id" UUID NOT NULL,
--   "name" VARCHAR(100) NOT NULL,
--   "description" TEXT,
--   "price" DECIMAL(10,2) NOT NULL,
--   "is_required" BOOLEAN DEFAULT FALSE,
--   "created_at" TIMESTAMP DEFAULT now(),
--   "updated_at" TIMESTAMP DEFAULT now()
-- );



--FROM HERE

 

-- Order Management Module SQL
-- Generated from DBML file

-- Create ENUMs first
CREATE TYPE order_status AS ENUM (
  'pending',
  'confirmed',
  'in_progress',
  'completed',
  'cancelled',
  'disputed'
);

CREATE TYPE order_event_type AS ENUM (
  'cancellation_requested',
  'cancellation_approved',
  'cancellation_rejected',
  'extension_requested',
  'extension_approved',
  'extension_rejected',
  'dispute_raised',
  'dispute_resolved',
  'status_changed',
  'message_sent',
  'custom_note'
);

CREATE TYPE approval_status AS ENUM (
  'pending',
  'approved',
  'rejected',
  'auto_approved'
);

CREATE TYPE handover_type AS ENUM (
  'OUTGOING',
  'RETURN'
);

CREATE TYPE payment_type AS ENUM (
  'RENT',
  'DEPOSIT',
  'EXTRA'
);

CREATE TYPE payment_status AS ENUM (
  'PENDING',
  'PAID',
  'FAILED',
  'REFUNDED'
);

CREATE TYPE deposit_status AS ENUM (
  'HELD',
  'RELEASED',
  'CLAIMED'
);

CREATE TYPE dispute_status AS ENUM (
  'open',
  'under_review',
  'resolved',
  'rejected'
);

CREATE TYPE deposit_action_type AS ENUM (
  'hold',
  'release',
  'partial_claim',
  'full_claim'
);

CREATE TYPE logistics_time_window AS ENUM (
  'morning',
  'afternoon',
  'full_day'
);

CREATE TYPE logistics_status AS ENUM (
  'pending',
  'confirmed',
  'in_transit',
  'completed',
  'failed'
);

CREATE TYPE confirmation_method AS ENUM (
  'qr_code',
  'signature',
  'manual'
);

-- Create new ENUMs for the incident tracking and dispute resolution system
CREATE TYPE incident_type AS ENUM (
  'damage',
  'malfunction',
  'loss',
  'injury',
  'delay',
  'other'
);

CREATE TYPE incident_reported_during AS ENUM (
  'handover',
  'in_use',
  'return',
  'other'
);

CREATE TYPE incident_status AS ENUM (
  'open',
  'resolved',
  'archived'
);

-- Create ENUMs for invoice system
CREATE TYPE invoice_status AS ENUM (
  'draft',
  'issued',
  'paid',
  'partially_paid',
  'cancelled',
  'overdue'
);

CREATE TYPE invoice_type AS ENUM (
  'rental',      -- Invoice to renter for the rental (visible to renter)
  'platform_fee', -- Invoice to owner for platform fees (internal)
  'service_fee'  -- Invoice to renter for platform service fee only (for cash payments)
);

CREATE TYPE fee_calculation_type AS ENUM (
  'percentage',  -- Fee calculated as percentage of order value
  'flat',        -- Flat fee regardless of order value
  'tiered'       -- Fee based on tiered structure
);

CREATE TYPE payment_method AS ENUM (
  'card',             -- Default (Stripe card payment)
  'wallet',           -- Stripe Wallets (Apple Pay, Google Pay)
  'bank_transfer',    -- Stripe-supported bank payments
  'cash_on_delivery'  -- Offline cash payment (special logic)
);

CREATE TYPE payout_status AS ENUM (
  'pending',     -- Payout created but not yet processed
  'processing',  -- Payout is being processed by financial provider
  'paid',        -- Payout successfully completed
  'failed'       -- Payout failed to process
);

CREATE TYPE payout_method AS ENUM (
  'stripe_transfer',  -- Transfer via Stripe Connect
  'manual',           -- Manually processed by admin
  'bank_transfer',    -- Direct bank transfer
  'wallet_transfer'   -- Transfer to digital wallet
);

CREATE TYPE account_type AS ENUM (
  'iban',             -- International Bank Account Number
  'wallet',           -- Digital wallet
  'stripe_account',   -- Stripe Connected Account
  'local_bank',       -- Local bank account
  'other'             -- Other account type
);

-- Create Tables
CREATE TABLE "order" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "ordered_by_profile_id" UUID NOT NULL,
  "owner_profile_id" UUID NOT NULL,
  "item_id" UUID NOT NULL,
  "status" order_status DEFAULT 'pending',
  "start_time" TIMESTAMP NOT NULL,
  "end_time" TIMESTAMP NOT NULL,
  "total_price" NUMERIC(10, 2),
  "total_tax_amount" NUMERIC(10, 2),
  "currency_code" CHAR(3) REFERENCES "currency"("code"),
  "payment_method" payment_method DEFAULT 'card',
  "preferred_payment_method" payment_method,
  "note" TEXT,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "order_event" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_id" UUID NOT NULL,
  "event_type" order_event_type NOT NULL,
  "initiated_by_profile_id" UUID NOT NULL,
  "approved_by_profile_id" UUID,
  "approval_status" approval_status DEFAULT 'pending',
  "payload" JSONB,
  "created_at" TIMESTAMP DEFAULT now(),
  "effective_at" TIMESTAMP
);

CREATE TABLE "item_handover" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_id" UUID NOT NULL,
  "handover_time" TIMESTAMP,
  "type" handover_type,
  "expected_return_time" TIMESTAMP,
  "actual_return_time" TIMESTAMP,
  "received_by_profile_id" UUID,
  "handed_over_by_profile_id" UUID NOT NULL,
  "checked_by_profile_id" UUID,
  "condition_report" TEXT,
  "photos_urls" TEXT[],
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "item_return" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_id" UUID NOT NULL,
  "actual_return_time" TIMESTAMP NOT NULL,
  "returned_by_profile_id" UUID NOT NULL,
  "confirmed_by_profile_id" UUID,
  "condition_report" TEXT,
  "is_late" BOOLEAN DEFAULT FALSE,
  "late_by_minutes" INTEGER,
  "grace_period_exceeded" BOOLEAN DEFAULT FALSE,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "order_payment" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_id" UUID NOT NULL,
  "profile_id" UUID NOT NULL,
  "amount" NUMERIC(10, 2) NOT NULL,
  "payment_type" payment_type NOT NULL,
  "status" payment_status DEFAULT 'PENDING',
  "paid_at" TIMESTAMP,
  "external_ref" TEXT,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "order_deposit" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_id" UUID NOT NULL,
  "order_payment_id" UUID NOT NULL,
  "amount" NUMERIC(10, 2) NOT NULL,
  "status" deposit_status DEFAULT 'HELD',
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "order_incident" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_id" UUID NOT NULL,
  "reported_by_profile_id" UUID NOT NULL,
  "incident_type" incident_type NOT NULL,
  "reported_during" incident_reported_during NOT NULL,
  "description" TEXT NOT NULL,
  "photo_urls" TEXT[],
  "document_ids" UUID[],
  "status" incident_status DEFAULT 'open',
  "resolution_notes" TEXT,
  "resolved_by_profile_id" UUID,
  "resolved_at" TIMESTAMP,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "order_dispute" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_incident_id" UUID NOT NULL,
  "raised_by_profile_id" UUID NOT NULL,
  "dispute_reason" TEXT NOT NULL,
  "status" dispute_status DEFAULT 'open',
  "resolution_summary" TEXT,
  "reviewed_by_profile_id" UUID,
  "raised_at" TIMESTAMP DEFAULT now(),
  "closed_at" TIMESTAMP,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "deposit_claim" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_dispute_id" UUID,
  "order_deposit_id" UUID NOT NULL,
  "amount" NUMERIC(10, 2) NOT NULL,
  "claim_reason" TEXT NOT NULL,
  "claim_category" VARCHAR(50) NOT NULL,
  "status" approval_status DEFAULT 'pending',
  "approved_by_profile_id" UUID,
  "approved_at" TIMESTAMP,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now(),
  CONSTRAINT "deposit_claim_amount_positive" CHECK (amount > 0)
);

CREATE TABLE "order_operator_assignment" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_id" UUID NOT NULL,
  "profile_id" UUID,
  "full_name" VARCHAR,
  "phone_number" VARCHAR,
  "certification_type" certification_type,
  "certification_number" VARCHAR,
  "certification_valid_until" DATE,
  "certification_document_url" TEXT,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "order_logistics_action" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_id" UUID NOT NULL,
  "logistics_type" logistics_type NOT NULL,
  "requested_date" DATE NOT NULL,
  "requested_time_window" logistics_time_window NOT NULL,
  "confirmed_datetime" TIMESTAMP,
  "status" logistics_status DEFAULT 'pending',
  "handled_by_profile_id" UUID,
  "transporter_profile_id" UUID,
  "confirmation_method" confirmation_method,
  "confirmation_time" TIMESTAMP,
  "notes" TEXT,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE UNIQUE INDEX "uq_order_logistics_type" ON "order_logistics_action" ("order_id", "logistics_type");

CREATE TABLE "logistics_action_history" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "logistics_action_id" UUID NOT NULL,
  "changed_by_profile_id" UUID NOT NULL,
  "logistics_type" logistics_type NOT NULL,
  "previous_status" logistics_status,
  "new_status" logistics_status,
  "previous_requested_date" DATE,
  "new_requested_date" DATE,
  "previous_time_window" logistics_time_window,
  "new_time_window" logistics_time_window,
  "previous_confirmed_datetime" TIMESTAMP,
  "new_confirmed_datetime" TIMESTAMP,
  "previous_handled_by_profile_id" UUID,
  "new_handled_by_profile_id" UUID,
  "previous_transporter_profile_id" UUID,
  "new_transporter_profile_id" UUID,
  "note" TEXT,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "order_item_unit" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_id" UUID NOT NULL,
  "item_unit_id" UUID NOT NULL,
  "custom_price" DECIMAL(10,2), 
  "rate_unit" rate_unit, 
  "tax_id" UUID, 
  "tax_rate" DECIMAL(5,2), 
  "tax_amount" DECIMAL(10,2),
  "tax_included_in_price" BOOLEAN DEFAULT FALSE, 
  "assigned_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "order_item_unit_addon" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_item_unit_id" UUID NOT NULL,
  "addon_id" UUID NOT NULL,
  "quantity" INT NOT NULL DEFAULT 1,
  "custom_price" DECIMAL(10,2), 
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "invoice" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "invoice_number" VARCHAR(50) NOT NULL,
  "order_id" UUID NOT NULL,
  "invoice_type" invoice_type NOT NULL,
  "issuer_profile_id" UUID NOT NULL, -- Platform profile
  "recipient_profile_id" UUID NOT NULL, -- Renter or owner profile
  "total_amount" NUMERIC(10, 2) NOT NULL,
  "tax_amount" NUMERIC(10, 2) DEFAULT 0,
  "currency_code" CHAR(3) NOT NULL,
  "payment_method" payment_method NOT NULL,
  "status" invoice_status DEFAULT 'draft',
  "issue_date" DATE,
  "due_date" DATE,
  "paid_date" DATE,
  "notes" TEXT,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now(),
  CONSTRAINT "invoice_total_amount_positive" CHECK (total_amount >= 0)
);

CREATE TABLE "invoice_line_item" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "invoice_id" UUID NOT NULL,
  "description" VARCHAR(255) NOT NULL,
  "quantity" NUMERIC(10, 2) NOT NULL DEFAULT 1,
  "unit_price" NUMERIC(10, 2) NOT NULL,
  "total_price" NUMERIC(10, 2) NOT NULL,
  "tax_rate" NUMERIC(5, 2),
  "tax_amount" NUMERIC(10, 2),
  "discount_amount" NUMERIC(10, 2) DEFAULT 0,
  "item_type" VARCHAR(50), -- e.g., 'rental', 'addon', 'fee', 'tax'
  "reference_id" UUID, -- Can reference order_item_unit, order_item_unit_addon, etc.
  "created_at" TIMESTAMP DEFAULT now(),
  CONSTRAINT "invoice_line_item_quantity_positive" CHECK (quantity > 0),
  CONSTRAINT "invoice_line_item_unit_price_non_negative" CHECK (unit_price >= 0),
  CONSTRAINT "invoice_line_item_total_price_non_negative" CHECK (total_price >= 0)
);

CREATE TABLE "platform_fee_config" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "organization_profile_id" UUID NOT NULL, -- Owner organization
  "calculation_type" fee_calculation_type NOT NULL,
  "fee_percentage" NUMERIC(5, 2), -- Used when calculation_type is 'percentage'
  "flat_fee_amount" NUMERIC(10, 2), -- Used when calculation_type is 'flat'
  "min_fee_amount" NUMERIC(10, 2), -- Minimum fee regardless of calculation
  "max_fee_amount" NUMERIC(10, 2), -- Maximum fee cap
  "is_active" BOOLEAN DEFAULT TRUE,
  "effective_from" DATE NOT NULL,
  "effective_to" DATE,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now(),
  CONSTRAINT "platform_fee_percentage_range" CHECK (fee_percentage IS NULL OR (fee_percentage >= 0 AND fee_percentage <= 100)),
  CONSTRAINT "platform_fee_flat_amount_non_negative" CHECK (flat_fee_amount IS NULL OR flat_fee_amount >= 0),
  CONSTRAINT "platform_fee_min_amount_non_negative" CHECK (min_fee_amount IS NULL OR min_fee_amount >= 0),
  CONSTRAINT "platform_fee_max_amount_valid" CHECK (max_fee_amount IS NULL OR (max_fee_amount >= 0 AND (min_fee_amount IS NULL OR max_fee_amount >= min_fee_amount)))
);

CREATE TABLE "order_payout" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_id" UUID NOT NULL,
  "owner_profile_id" UUID NOT NULL,
  "rental_invoice_id" UUID NOT NULL,
  "platform_fee_invoice_id" UUID NOT NULL,
  "gross_amount" NUMERIC(10, 2) NOT NULL, -- Total amount paid by renter
  "fee_amount" NUMERIC(10, 2) NOT NULL, -- Platform fee deducted
  "net_amount" NUMERIC(10, 2) NOT NULL, -- Amount paid to owner
  "status" payout_status DEFAULT 'pending',
  "payout_method" payout_method NOT NULL,
  "financial_provider_name" VARCHAR(50), -- e.g., "Stripe", "Wise"
  "destination_account_type" account_type NOT NULL,
  "destination_account_id" VARCHAR(100) NOT NULL, -- Masked or hashed account identifier
  "currency_code" CHAR(3) NOT NULL,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now(),
  "processing_started_at" TIMESTAMP,
  "paid_at" TIMESTAMP,
  "payment_reference" VARCHAR(100), -- Reference ID from payment provider
  "failure_reason" TEXT, -- Reason for failure if status = 'failed'
  "notes" TEXT, -- Optional internal notes
  CONSTRAINT "order_payout_amounts_valid" CHECK (
    gross_amount >= 0 AND 
    fee_amount >= 0 AND 
    net_amount >= 0 AND 
    gross_amount = net_amount + fee_amount
  )
);

-- Add Foreign Key Constraints
ALTER TABLE "order" ADD CONSTRAINT "fk_order_ordered_by_profile" 
  FOREIGN KEY ("ordered_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order" ADD CONSTRAINT "fk_order_owner_profile" 
  FOREIGN KEY ("owner_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order" ADD CONSTRAINT "fk_order_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "order_event" ADD CONSTRAINT "fk_order_event_order" 
  FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "order_event" ADD CONSTRAINT "fk_order_event_initiated_by" 
  FOREIGN KEY ("initiated_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order_event" ADD CONSTRAINT "fk_order_event_approved_by" 
  FOREIGN KEY ("approved_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "item_handover" ADD CONSTRAINT "fk_item_handover_order" 
  FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "item_handover" ADD CONSTRAINT "fk_item_handover_handed_over_by" 
  FOREIGN KEY ("handed_over_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "item_handover" ADD CONSTRAINT "fk_item_handover_received_by" 
  FOREIGN KEY ("received_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "item_handover" ADD CONSTRAINT "fk_item_handover_checked_by" 
  FOREIGN KEY ("checked_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "item_return" ADD CONSTRAINT "fk_item_return_order" 
  FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "item_return" ADD CONSTRAINT "fk_item_return_returned_by" 
  FOREIGN KEY ("returned_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "item_return" ADD CONSTRAINT "fk_item_return_confirmed_by" 
  FOREIGN KEY ("confirmed_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order_payment" ADD CONSTRAINT "fk_order_payment_order" 
  FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "order_payment" ADD CONSTRAINT "fk_order_payment_profile" 
  FOREIGN KEY ("profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order_deposit" ADD CONSTRAINT "fk_order_deposit_order" 
  FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "order_deposit" ADD CONSTRAINT "fk_order_deposit_payment" 
  FOREIGN KEY ("order_payment_id") REFERENCES "order_payment" ("id");

ALTER TABLE "order_incident" ADD CONSTRAINT "fk_order_incident_order" 
  FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "order_incident" ADD CONSTRAINT "fk_order_incident_reported_by" 
  FOREIGN KEY ("reported_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order_incident" ADD CONSTRAINT "fk_order_incident_resolved_by" 
  FOREIGN KEY ("resolved_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order_dispute" ADD CONSTRAINT "fk_order_dispute_incident" 
  FOREIGN KEY ("order_incident_id") REFERENCES "order_incident" ("id");

ALTER TABLE "order_dispute" ADD CONSTRAINT "fk_order_dispute_raised_by" 
  FOREIGN KEY ("raised_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order_dispute" ADD CONSTRAINT "fk_order_dispute_reviewed_by" 
  FOREIGN KEY ("reviewed_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "deposit_claim" ADD CONSTRAINT "fk_deposit_claim_dispute" 
  FOREIGN KEY ("order_dispute_id") REFERENCES "order_dispute" ("id");

ALTER TABLE "deposit_claim" ADD CONSTRAINT "fk_deposit_claim_deposit" 
  FOREIGN KEY ("order_deposit_id") REFERENCES "order_deposit" ("id");

ALTER TABLE "deposit_claim" ADD CONSTRAINT "fk_deposit_claim_approved_by" 
  FOREIGN KEY ("approved_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order_operator_assignment" ADD CONSTRAINT "fk_order_operator_assignment_order" 
  FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "order_operator_assignment" ADD CONSTRAINT "fk_order_operator_assignment_profile" 
  FOREIGN KEY ("profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order_logistics_action" ADD CONSTRAINT "fk_order_logistics_action_order" 
  FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "order_logistics_action" ADD CONSTRAINT "fk_order_logistics_action_handled_by" 
  FOREIGN KEY ("handled_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order_logistics_action" ADD CONSTRAINT "fk_order_logistics_action_transporter" 
  FOREIGN KEY ("transporter_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "logistics_action_history" ADD CONSTRAINT "fk_logistics_action_history_action" 
  FOREIGN KEY ("logistics_action_id") REFERENCES "order_logistics_action" ("id");

ALTER TABLE "logistics_action_history" ADD CONSTRAINT "fk_logistics_action_history_changed_by" 
  FOREIGN KEY ("changed_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "logistics_action_history" ADD CONSTRAINT "fk_logistics_action_history_prev_handled_by" 
  FOREIGN KEY ("previous_handled_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "logistics_action_history" ADD CONSTRAINT "fk_logistics_action_history_new_handled_by" 
  FOREIGN KEY ("new_handled_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "logistics_action_history" ADD CONSTRAINT "fk_logistics_action_history_prev_transporter" 
  FOREIGN KEY ("previous_transporter_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "logistics_action_history" ADD CONSTRAINT "fk_logistics_action_history_new_transporter" 
  FOREIGN KEY ("new_transporter_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order_item_unit" ADD CONSTRAINT "fk_order_item_unit_order" 
  FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "order_item_unit" ADD CONSTRAINT "fk_order_item_unit_item_unit" 
  FOREIGN KEY ("item_unit_id") REFERENCES "item_unit" ("id");

ALTER TABLE "order_item_unit" ADD CONSTRAINT "fk_order_item_unit_tax" 
  FOREIGN KEY ("tax_id") REFERENCES "tax" ("id");

ALTER TABLE "order_item_unit_addon" ADD CONSTRAINT "fk_order_item_unit_addon_order_item_unit" 
  FOREIGN KEY ("order_item_unit_id") REFERENCES "order_item_unit" ("id");

ALTER TABLE "order_item_unit_addon" ADD CONSTRAINT "fk_order_item_unit_addon_addon" 
  FOREIGN KEY ("addon_id") REFERENCES "item_addon" ("id");

CREATE INDEX "idx_order_item_unit_addon_order_item_unit" ON "order_item_unit_addon" ("order_item_unit_id");
CREATE INDEX "idx_order_item_unit_addon_addon" ON "order_item_unit_addon" ("addon_id");

-- Add foreign key constraints for invoice system
ALTER TABLE "invoice" ADD CONSTRAINT "fk_invoice_order" 
  FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "invoice" ADD CONSTRAINT "fk_invoice_issuer" 
  FOREIGN KEY ("issuer_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "invoice" ADD CONSTRAINT "fk_invoice_recipient" 
  FOREIGN KEY ("recipient_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "invoice_line_item" ADD CONSTRAINT "fk_invoice_line_item_invoice" 
  FOREIGN KEY ("invoice_id") REFERENCES "invoice" ("id");

ALTER TABLE "platform_fee_config" ADD CONSTRAINT "fk_platform_fee_config_organization" 
  FOREIGN KEY ("organization_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order_payout" ADD CONSTRAINT "fk_order_payout_order" 
  FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "order_payout" ADD CONSTRAINT "fk_order_payout_owner" 
  FOREIGN KEY ("owner_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order_payout" ADD CONSTRAINT "fk_order_payout_rental_invoice" 
  FOREIGN KEY ("rental_invoice_id") REFERENCES "invoice" ("id");

ALTER TABLE "order_payout" ADD CONSTRAINT "fk_order_payout_platform_fee_invoice" 
  FOREIGN KEY ("platform_fee_invoice_id") REFERENCES "invoice" ("id");

-- Add unique constraints
ALTER TABLE "order_deposit" ADD CONSTRAINT "uq_order_deposit_order_id" 
  UNIQUE ("order_id");

ALTER TABLE "order_deposit" ADD CONSTRAINT "uq_order_deposit_payment_id" 
  UNIQUE ("order_payment_id");

ALTER TABLE "invoice" ADD CONSTRAINT "uq_invoice_number" 
  UNIQUE ("invoice_number");

ALTER TABLE "order_payout" ADD CONSTRAINT "uq_order_payout_order_id" 
  UNIQUE ("order_id");

-- Payout trigger function to ensure payouts are only created under specified conditions
CREATE OR REPLACE FUNCTION check_payout_eligibility()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if order is completed
  IF (SELECT status FROM "order" WHERE id = NEW.order_id) != 'completed' THEN
    RAISE EXCEPTION 'Cannot create payout for order that is not completed';
  END IF;
  
  -- Check if rental invoice is paid
  IF (SELECT status FROM "invoice" WHERE id = NEW.rental_invoice_id) != 'paid' THEN
    RAISE EXCEPTION 'Cannot create payout for order with unpaid rental invoice';
  END IF;
  
  -- Check if payment method is not cash_on_delivery
  IF (SELECT payment_method FROM "order" WHERE id = NEW.order_id) = 'cash_on_delivery' THEN
    RAISE EXCEPTION 'Cannot create payout for cash_on_delivery orders';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to enforce payout eligibility rules
CREATE TRIGGER check_payout_eligibility_trigger
BEFORE INSERT ON "order_payout"
FOR EACH ROW
EXECUTE FUNCTION check_payout_eligibility();

-- Track item unit usage metrics at handover and return
CREATE TABLE "order_unit_metric_reading" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_id" UUID NOT NULL,
  "item_unit_id" UUID NOT NULL,
  "metric_id" UUID NOT NULL, -- Reference to organization_usage_metric (constraint in cross-module FK file)
  "reading_type" VARCHAR(10) NOT NULL, -- 'start' or 'end' for stock metrics, 'value' for flow metrics
  "value" DECIMAL(15,3) NOT NULL,
  "reported_by_profile_id" UUID,
  "reported_at" TIMESTAMP DEFAULT now(),
  "notes" TEXT
);

-- Add foreign key constraints for order_unit_metric_reading
ALTER TABLE "order_unit_metric_reading" ADD CONSTRAINT "fk_order_unit_metric_reading_order" 
  FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "order_unit_metric_reading" ADD CONSTRAINT "fk_order_unit_metric_reading_item_unit" 
  FOREIGN KEY ("item_unit_id") REFERENCES "item_unit" ("id");

ALTER TABLE "order_unit_metric_reading" ADD CONSTRAINT "fk_order_unit_metric_reading_metric" 
  FOREIGN KEY ("metric_id") REFERENCES "organization_usage_metric" ("id");

ALTER TABLE "order_unit_metric_reading" ADD CONSTRAINT "fk_order_unit_metric_reading_profile" 
  FOREIGN KEY ("reported_by_profile_id") REFERENCES "profile" ("id");

-- Create indexes for order_unit_metric_reading
CREATE INDEX "idx_order_unit_metric_reading_order" ON "order_unit_metric_reading" ("order_id");
CREATE INDEX "idx_order_unit_metric_reading_item_unit" ON "order_unit_metric_reading" ("item_unit_id");
CREATE INDEX "idx_order_unit_metric_reading_metric" ON "order_unit_metric_reading" ("metric_id");
CREATE INDEX "idx_order_unit_metric_reading_reported_by" ON "order_unit_metric_reading" ("reported_by_profile_id");
CREATE INDEX "idx_order_unit_metric_reading_type" ON "order_unit_metric_reading" ("reading_type");

-- Document management foreign key constraints
ALTER TABLE "order_document" ADD CONSTRAINT "fk_order_document_order" 
  FOREIGN KEY ("order_id") REFERENCES "order" ("id");
