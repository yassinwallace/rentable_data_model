-- START OF: 01_user_management_module.sql
-- User Management Module SQL
-- Generated from DBML file

-- Create ENUMs first
CREATE TYPE profile_type AS ENUM (
  'individual',
  'organization'
);

CREATE TYPE invitation_status AS ENUM (
  'pending',
  'accepted',
  'expired'
);

CREATE TYPE certification_type AS ENUM (
  'CACES',
  'Forklift',
  'Crane',
  'Other'
);

-- Create Tables
CREATE TABLE "user_ref" (
  "user_id" UUID PRIMARY KEY
);

CREATE TABLE "profile" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" UUID NOT NULL,
  "profile_type" profile_type NOT NULL,
  "first_name" VARCHAR,
  "last_name" VARCHAR,
  "date_of_birth" DATE,
  "organization_name" VARCHAR,
  "siret_number" VARCHAR,
  "phone_number" VARCHAR,
  "avatar_url" VARCHAR,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_profile_user_id" ON "profile" ("user_id");

CREATE TABLE "organization_invitation" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "organization_profile_id" UUID NOT NULL,
  "invited_by_profile_id" UUID NOT NULL,
  "email" VARCHAR NOT NULL,
  "role" VARCHAR,
  "token" VARCHAR NOT NULL,
  "status" invitation_status DEFAULT 'pending',
  "expires_at" TIMESTAMP NOT NULL,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_org_invite_org_id" ON "organization_invitation" ("organization_profile_id");
CREATE INDEX "idx_org_invite_email" ON "organization_invitation" ("email");

CREATE TABLE "profile_membership" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "profile_id" UUID NOT NULL,
  "organization_profile_id" UUID NOT NULL,
  "status" VARCHAR DEFAULT 'active',
  "joined_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_profile_membership_profile" ON "profile_membership" ("profile_id");
CREATE INDEX "idx_profile_membership_org" ON "profile_membership" ("organization_profile_id");

CREATE TABLE "role" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "name" VARCHAR NOT NULL,
  "description" TEXT,
  "is_active" BOOLEAN DEFAULT TRUE,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "permission" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "name" VARCHAR NOT NULL UNIQUE,
  "description" TEXT,
  "category" VARCHAR NOT NULL,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "role_permission" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "role_id" UUID,
  "permission_id" UUID,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_role_permission_role_id" ON "role_permission" ("role_id");
CREATE INDEX "idx_role_permission_permission_id" ON "role_permission" ("permission_id");

CREATE TABLE "profile_role" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "profile_id" UUID NOT NULL,
  "organization_profile_id" UUID,
  "role_id" UUID NOT NULL,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE UNIQUE INDEX ON "profile_role" ("profile_id", "organization_profile_id", "role_id");
CREATE INDEX "idx_profile_role_profile" ON "profile_role" ("profile_id");
CREATE INDEX "idx_profile_role_org" ON "profile_role" ("organization_profile_id");
CREATE INDEX "idx_profile_role_role" ON "profile_role" ("role_id");

CREATE TABLE "profile_certification" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "profile_id" UUID NOT NULL,
  "certification_type" certification_type NOT NULL,
  "certification_number" VARCHAR,
  "issued_by" VARCHAR,
  "valid_from" DATE,
  "valid_until" DATE,
  "document_url" TEXT,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "organization_logistics_rule" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "organization_profile_id" UUID NOT NULL,
  "min_lead_time_hours" INT DEFAULT 24,
  "allowed_days" VARCHAR[],
  "allowed_hours" JSONB,
  "buffer_between_orders_minutes" INT DEFAULT 60,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "organization_blackout_date" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "organization_profile_id" UUID NOT NULL,
  "start_date" DATE NOT NULL,
  "end_date" DATE NOT NULL,
  "reason" TEXT,
  "is_recurring" BOOLEAN DEFAULT FALSE,
  "recurrence_pattern" VARCHAR,
  "created_at" TIMESTAMP DEFAULT now()
);

-- Add Foreign Key Constraints
ALTER TABLE "profile" ADD CONSTRAINT "fk_profile_user_ref" 
  FOREIGN KEY ("user_id") REFERENCES "user_ref" ("user_id");

ALTER TABLE "organization_invitation" ADD CONSTRAINT "fk_org_invitation_org_profile" 
  FOREIGN KEY ("organization_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "organization_invitation" ADD CONSTRAINT "fk_org_invitation_invited_by" 
  FOREIGN KEY ("invited_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "profile_membership" ADD CONSTRAINT "fk_profile_membership_profile" 
  FOREIGN KEY ("profile_id") REFERENCES "profile" ("id");

ALTER TABLE "profile_membership" ADD CONSTRAINT "fk_profile_membership_org" 
  FOREIGN KEY ("organization_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "role_permission" ADD CONSTRAINT "fk_role_permission_role" 
  FOREIGN KEY ("role_id") REFERENCES "role" ("id");

ALTER TABLE "role_permission" ADD CONSTRAINT "fk_role_permission_permission" 
  FOREIGN KEY ("permission_id") REFERENCES "permission" ("id");

ALTER TABLE "profile_role" ADD CONSTRAINT "fk_profile_role_profile" 
  FOREIGN KEY ("profile_id") REFERENCES "profile" ("id");

ALTER TABLE "profile_role" ADD CONSTRAINT "fk_profile_role_org" 
  FOREIGN KEY ("organization_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "profile_role" ADD CONSTRAINT "fk_profile_role_role" 
  FOREIGN KEY ("role_id") REFERENCES "role" ("id");

ALTER TABLE "profile_certification" ADD CONSTRAINT "fk_profile_certification_profile" 
  FOREIGN KEY ("profile_id") REFERENCES "profile" ("id");

ALTER TABLE "organization_logistics_rule" ADD CONSTRAINT "fk_org_logistics_rule_profile" 
  FOREIGN KEY ("organization_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "organization_blackout_date" ADD CONSTRAINT "fk_org_blackout_date_profile" 
  FOREIGN KEY ("organization_profile_id") REFERENCES "profile" ("id");

-- END OF: 01_user_management_module.sql

-- START OF: 02_item_management_module.sql

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

-- FROM HERE


-- Item Management Module SQL
-- Generated from DBML file

-- Create ENUMs first


CREATE TYPE item_status AS ENUM (
  'active',
  'inactive',
  'pending_review'
);

CREATE TYPE item_condition AS ENUM (
  'new',
  'like_new',
  'good',
  'fair',
  'poor'
);

CREATE TYPE item_type AS ENUM (
  'P2P',
  'B2B',
  'B2C'
);

CREATE TYPE item_insurance_cost_type AS ENUM (
  'flat',
  'percentage'
);

CREATE TYPE related_items_relation_type AS ENUM (
  'accessory',
  'similar',
  'complementary'
);

CREATE TYPE bulk_import_status AS ENUM (
  'pending',
  'processing',
  'completed',
  'failed'
);

CREATE TYPE item_history_action AS ENUM (
  'created',
  'updated',
  'deleted',
  'status_changed'
);

CREATE TYPE logistics_type AS ENUM (
  'delivery',
  'pickup'
);

CREATE TYPE logistics_mode AS ENUM (
  'none',
  'optional',
  'required'
);

CREATE TYPE logistics_party_type AS ENUM (
  'renter',
  'owner',
  'transporter'
);

CREATE TYPE item_block_type AS ENUM (
  'maintenance',
  'internal_use',
  'reserved_for_demo',
  'unavailable_other'
);

-- availability_type is referenced but not defined in the DBML
-- Creating it with common availability values
CREATE TYPE availability_type AS ENUM (
  'available',
  'unavailable',
  'pending',
  'reserved'
);

-- Create Tables
CREATE TABLE "item" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "owner_profile_id" UUID NOT NULL,
  "title" VARCHAR(255) NOT NULL,
  "description" TEXT NOT NULL,
  "base_price" DECIMAL(10,2) NOT NULL,
  "currency" CHAR(3) NOT NULL,
  "item_status" item_status NOT NULL,
  "item_condition" item_condition NULL,
  "item_type" item_type NOT NULL,
  "minimum_rental_period" INT,
  "maximum_rental_period" INT,
  "start_hours" VARCHAR(50),
  "end_hours" VARCHAR(50),
  "required_certification" certification_type NULL,
  "logistics_mode" logistics_mode DEFAULT 'none',
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_item_owner" ON "item" ("owner_profile_id");

CREATE TABLE "item_category" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "parent_id" UUID,
  "name" VARCHAR(100) NOT NULL,
  "description" TEXT,
  "level" INT NOT NULL,
  "is_active" BOOLEAN DEFAULT TRUE,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "item_category_assignment" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "category_id" UUID NOT NULL,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_item_cat_assign_item" ON "item_category_assignment" ("item_id");
CREATE INDEX "idx_item_cat_assign_cat" ON "item_category_assignment" ("category_id");

CREATE TABLE "item_attributes" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "attribute_name" VARCHAR(100) NOT NULL,
  "attribute_value" TEXT NOT NULL,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_item_attr_item" ON "item_attributes" ("item_id");

CREATE TABLE "item_availability" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "start_datetime" TIMESTAMP NOT NULL,
  "end_datetime" TIMESTAMP NOT NULL,
  "availability_type" availability_type DEFAULT 'available',
  "custom_price" DECIMAL(10,2),
  "note" TEXT,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "item_images" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "image_url" VARCHAR(255) NOT NULL,
  "is_primary" BOOLEAN DEFAULT FALSE,
  "display_order" INT NOT NULL,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_item_images_item" ON "item_images" ("item_id");

CREATE TABLE "item_pricing_tier" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "min_days" INT NOT NULL,
  "max_days" INT,
  "price_per_day" DECIMAL(10,2) NOT NULL,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_item_price_tier_item" ON "item_pricing_tier" ("item_id");

CREATE TABLE "item_maintenance_record" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "maintenance_type" VARCHAR(100) NOT NULL,
  "description" TEXT,
  "performed_by" VARCHAR(255),
  "performed_at" TIMESTAMP NOT NULL,
  "cost" DECIMAL(10,2),
  "next_maintenance_due" TIMESTAMP,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_item_maint_item" ON "item_maintenance_record" ("item_id");

CREATE TABLE "item_rental_rules" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "rule_type" VARCHAR(100) NOT NULL,
  "rule_value" TEXT NOT NULL,
  "is_required" BOOLEAN DEFAULT TRUE,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_item_rules_item" ON "item_rental_rules" ("item_id");

CREATE TABLE "item_insurance_options" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "insurance_name" VARCHAR(255) NOT NULL,
  "description" TEXT,
  "cost" DECIMAL(10,2) NOT NULL,
  "item_insurance_cost_type" item_insurance_cost_type NOT NULL,
  "coverage_amount" DECIMAL(10,2) NOT NULL,
  "is_required" BOOLEAN DEFAULT FALSE,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_item_insurance_item" ON "item_insurance_options" ("item_id");

CREATE TABLE "item_bundle" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "name" VARCHAR(255) NOT NULL,
  "description" TEXT,
  "discount_percentage" DECIMAL(5,2),
  "is_active" BOOLEAN DEFAULT TRUE,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "items_bundle_assignment" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "bundle_id" UUID NOT NULL,
  "item_id" UUID NOT NULL,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_bundle_assign_bundle" ON "items_bundle_assignment" ("bundle_id");
CREATE INDEX "idx_bundle_assign_item" ON "items_bundle_assignment" ("item_id");

CREATE TABLE "related_item" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "related_item_id" UUID NOT NULL,
  "related_items_relation_type" related_items_relation_type NOT NULL,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_related_item_main" ON "related_item" ("item_id");
CREATE INDEX "idx_related_item_related" ON "related_item" ("related_item_id");

CREATE TABLE "item_bulk_import" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "profile_id" UUID NOT NULL,
  "import_source" VARCHAR,
  "item_count" INT,
  "status" bulk_import_status DEFAULT 'pending',
  "error_report" TEXT,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_bulk_import_profile" ON "item_bulk_import" ("profile_id");

CREATE TABLE "service_level_agreement" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "name" VARCHAR(255) NOT NULL,
  "description" TEXT,
  "terms" TEXT NOT NULL,
  "is_active" BOOLEAN DEFAULT TRUE,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_sla_item" ON "service_level_agreement" ("item_id");

CREATE TABLE "item_history" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "profile_id" UUID NOT NULL,
  "action" item_history_action NOT NULL,
  "metadata" JSONB,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE INDEX "idx_item_history_item" ON "item_history" ("item_id");
CREATE INDEX "idx_item_history_profile" ON "item_history" ("profile_id");

CREATE TABLE "item_operator_requirement" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "certification_type" certification_type NOT NULL,
  "is_mandatory" BOOLEAN DEFAULT TRUE,
  "note" TEXT
);

CREATE TABLE "item_logistics_option" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "logistics_type" logistics_type NOT NULL,
  "party_type" logistics_party_type NOT NULL,
  "transporter_organization_profile_id" UUID,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "item_logistics_rule" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "min_lead_time_hours" INT,
  "allowed_days" VARCHAR[],
  "allowed_hours" JSONB,
  "buffer_between_orders_minutes" INT,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "item_blackout_date" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "start_date" DATE NOT NULL,
  "end_date" DATE NOT NULL,
  "reason" TEXT,
  "is_recurring" BOOLEAN DEFAULT FALSE,
  "recurrence_pattern" VARCHAR,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "item_unit_block_date" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_unit_id" UUID NOT NULL,
  "block_type" item_block_type NOT NULL,
  "start_datetime" TIMESTAMP NOT NULL,
  "end_datetime" TIMESTAMP NOT NULL,
  "reason" TEXT,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "item_unit" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "serial_number" VARCHAR,
  "internal_reference" VARCHAR,
  "item_condition" item_condition,
  "is_active" BOOLEAN DEFAULT TRUE,
  "current_location_id" UUID,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "item_unit_availability" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_unit_id" UUID NOT NULL,
  "start_datetime" TIMESTAMP NOT NULL,
  "end_datetime" TIMESTAMP NOT NULL,
  "is_available" BOOLEAN NOT NULL,
  "note" TEXT,
  "created_at" TIMESTAMP DEFAULT now()
);

-- Add Foreign Key Constraints
ALTER TABLE "item" ADD CONSTRAINT "fk_item_owner_profile" 
  FOREIGN KEY ("owner_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "item_category" ADD CONSTRAINT "fk_item_category_parent" 
  FOREIGN KEY ("parent_id") REFERENCES "item_category" ("id");

ALTER TABLE "item_category_assignment" ADD CONSTRAINT "fk_item_category_assignment_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "item_category_assignment" ADD CONSTRAINT "fk_item_category_assignment_category" 
  FOREIGN KEY ("category_id") REFERENCES "item_category" ("id");

ALTER TABLE "item_attributes" ADD CONSTRAINT "fk_item_attributes_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "item_availability" ADD CONSTRAINT "fk_item_availability_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "item_images" ADD CONSTRAINT "fk_item_images_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "item_pricing_tier" ADD CONSTRAINT "fk_item_pricing_tier_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "item_maintenance_record" ADD CONSTRAINT "fk_item_maintenance_record_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "item_rental_rules" ADD CONSTRAINT "fk_item_rental_rules_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "item_insurance_options" ADD CONSTRAINT "fk_item_insurance_options_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "items_bundle_assignment" ADD CONSTRAINT "fk_items_bundle_assignment_bundle" 
  FOREIGN KEY ("bundle_id") REFERENCES "item_bundle" ("id");

ALTER TABLE "items_bundle_assignment" ADD CONSTRAINT "fk_items_bundle_assignment_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "related_item" ADD CONSTRAINT "fk_related_item_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "related_item" ADD CONSTRAINT "fk_related_item_related" 
  FOREIGN KEY ("related_item_id") REFERENCES "item" ("id");

ALTER TABLE "item_bulk_import" ADD CONSTRAINT "fk_item_bulk_import_profile" 
  FOREIGN KEY ("profile_id") REFERENCES "profile" ("id");

ALTER TABLE "service_level_agreement" ADD CONSTRAINT "fk_service_level_agreement_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "item_history" ADD CONSTRAINT "fk_item_history_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "item_history" ADD CONSTRAINT "fk_item_history_profile" 
  FOREIGN KEY ("profile_id") REFERENCES "profile" ("id");

ALTER TABLE "item_operator_requirement" ADD CONSTRAINT "fk_item_operator_requirement_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "item_logistics_option" ADD CONSTRAINT "fk_item_logistics_option_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "item_logistics_option" ADD CONSTRAINT "fk_item_logistics_option_transporter" 
  FOREIGN KEY ("transporter_organization_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "item_logistics_rule" ADD CONSTRAINT "fk_item_logistics_rule_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "item_blackout_date" ADD CONSTRAINT "fk_item_blackout_date_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "item_unit" ADD CONSTRAINT "fk_item_unit_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "item_unit_block_date" ADD CONSTRAINT "fk_item_unit_block_date_unit" 
  FOREIGN KEY ("item_unit_id") REFERENCES "item_unit" ("id");

ALTER TABLE "item_unit_availability" ADD CONSTRAINT "fk_item_unit_availability_unit" 
  FOREIGN KEY ("item_unit_id") REFERENCES "item_unit" ("id");

-- END OF: 02_item_management_module.sql

-- START OF: 03_order_management_module.sql
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
  "assigned_at" TIMESTAMP DEFAULT now()
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

-- Add unique constraints
ALTER TABLE "order_deposit" ADD CONSTRAINT "uq_order_deposit_order_id" 
  UNIQUE ("order_id");

ALTER TABLE "order_deposit" ADD CONSTRAINT "uq_order_deposit_payment_id" 
  UNIQUE ("order_payment_id");

ALTER TABLE "order_dispute" ADD CONSTRAINT "uq_order_dispute_order_id" 
  UNIQUE ("order_id");

-- END OF: 03_order_management_module.sql

