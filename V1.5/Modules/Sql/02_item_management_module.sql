
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

-- Create a new enum for unit availability classification
CREATE TYPE availability_context AS ENUM (
  'standard',
  'promo',
  'override',
  'soft_block'
);

-- Create rate_unit enum for pricing
CREATE TYPE rate_unit AS ENUM (
  'hour', 
  'day', 
  'week', 
  'month'
);

-- Create Tables
CREATE TABLE "item" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "owner_profile_id" UUID NOT NULL,
  "title" VARCHAR(255) NOT NULL,
  "description" TEXT NOT NULL,
  "base_price" DECIMAL(10,2) NOT NULL,
  "currency_code" CHAR(3) NOT NULL REFERENCES "currency"("code"),
  "item_status" item_status NOT NULL,
  "item_condition" item_condition NULL,
  "item_type" item_type NOT NULL,
  "minimum_rental_period" INT,
  "maximum_rental_period" INT,
  "start_hours" VARCHAR(50),
  "end_hours" VARCHAR(50),
  "required_certification" certification_type NULL,
  "logistics_mode" logistics_mode DEFAULT 'none',
  "rate_unit" rate_unit NOT NULL DEFAULT 'day',
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

DROP TABLE IF EXISTS "item_pricing_tier";

CREATE TABLE "item_pricing_tier" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "min_duration" INT NOT NULL,
  "max_duration" INT,
  "price" DECIMAL(10,2) NOT NULL,
  "rate_unit" rate_unit NOT NULL DEFAULT 'day',
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
  "recurrence_rule" TEXT,
  "availability_type" availability_type DEFAULT 'standard',
  "availability_context" availability_context DEFAULT 'standard',
  "created_at" TIMESTAMP DEFAULT now()
);

-- Add structured tax support (ERP style)
CREATE TABLE "tax" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "name" VARCHAR(100) NOT NULL,
  "rate" DECIMAL(5,2) NOT NULL, -- e.g., 20.00 for 20%
  "is_active" BOOLEAN DEFAULT TRUE,
  "description" TEXT,
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "item_tax_assignment" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "tax_id" UUID NOT NULL,
  "is_included_in_price" BOOLEAN DEFAULT FALSE,
  "created_at" TIMESTAMP DEFAULT now()
);

-- Add foreign key constraints for tax tables
ALTER TABLE "item_tax_assignment" ADD CONSTRAINT "fk_item_tax_assignment_item" 
  FOREIGN KEY ("item_id") REFERENCES "item" ("id");

ALTER TABLE "item_tax_assignment" ADD CONSTRAINT "fk_item_tax_assignment_tax" 
  FOREIGN KEY ("tax_id") REFERENCES "tax" ("id");

-- Create indexes for tax tables
CREATE INDEX "idx_item_tax_assignment_item" ON "item_tax_assignment" ("item_id");
CREATE INDEX "idx_item_tax_assignment_tax" ON "item_tax_assignment" ("tax_id");

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
