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
  'OPEN',
  'RESOLVED',
  'ESCALATED'
);

CREATE TYPE deposit_action_type AS ENUM (
  'CLAIM',
  'RELEASE'
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
  "currency" VARCHAR(10),
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

CREATE TABLE "order_dispute" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_id" UUID NOT NULL,
  "raised_by_profile_id" UUID NOT NULL,
  "reason" TEXT,
  "status" dispute_status DEFAULT 'OPEN',
  "resolution" TEXT,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "order_deposit_action" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_deposit_id" UUID NOT NULL,
  "action_type" deposit_action_type NOT NULL,
  "amount" NUMERIC(10, 2) NOT NULL,
  "reason" TEXT,
  "initiated_by_profile_id" UUID,
  "approved_by_profile_id" UUID,
  "created_at" TIMESTAMP DEFAULT now()
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

ALTER TABLE "order_dispute" ADD CONSTRAINT "fk_order_dispute_order" 
  FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "order_dispute" ADD CONSTRAINT "fk_order_dispute_raised_by" 
  FOREIGN KEY ("raised_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order_deposit_action" ADD CONSTRAINT "fk_order_deposit_action_deposit" 
  FOREIGN KEY ("order_deposit_id") REFERENCES "order_deposit" ("id");

ALTER TABLE "order_deposit_action" ADD CONSTRAINT "fk_order_deposit_action_initiated_by" 
  FOREIGN KEY ("initiated_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "order_deposit_action" ADD CONSTRAINT "fk_order_deposit_action_approved_by" 
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

-- Add unique constraints
ALTER TABLE "order_deposit" ADD CONSTRAINT "uq_order_deposit_order_id" 
  UNIQUE ("order_id");

ALTER TABLE "order_deposit" ADD CONSTRAINT "uq_order_deposit_payment_id" 
  UNIQUE ("order_payment_id");

ALTER TABLE "order_dispute" ADD CONSTRAINT "uq_order_dispute_order_id" 
  UNIQUE ("order_id");

-- Track item unit usage at the end of each order
CREATE TABLE "order_unit_usage" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_id" UUID NOT NULL,
  "item_unit_id" UUID NOT NULL,
  "operating_hours" DECIMAL(10,2),
  "distance_traveled" DECIMAL(10,2),
  "fuel_level" DECIMAL(5,2),
  "notes" TEXT,
  "reported_by_profile_id" UUID,
  "reported_at" TIMESTAMP DEFAULT now()
);

-- Add foreign key constraints for order_unit_usage
ALTER TABLE "order_unit_usage" ADD CONSTRAINT "fk_order_unit_usage_order" 
  FOREIGN KEY ("order_id") REFERENCES "order" ("id");

ALTER TABLE "order_unit_usage" ADD CONSTRAINT "fk_order_unit_usage_item_unit" 
  FOREIGN KEY ("item_unit_id") REFERENCES "item_unit" ("id");

ALTER TABLE "order_unit_usage" ADD CONSTRAINT "fk_order_unit_usage_profile" 
  FOREIGN KEY ("reported_by_profile_id") REFERENCES "profile" ("id");

-- Create indexes for order_unit_usage
CREATE INDEX "idx_order_unit_usage_order" ON "order_unit_usage" ("order_id");
CREATE INDEX "idx_order_unit_usage_item_unit" ON "order_unit_usage" ("item_unit_id");
CREATE INDEX "idx_order_unit_usage_reported_by" ON "order_unit_usage" ("reported_by_profile_id");
