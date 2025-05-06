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

-- Create currency table for normalized currency handling
CREATE TABLE "currency" (
  "code" CHAR(3) PRIMARY KEY, -- ISO 4217, e.g., 'EUR'
  "name" VARCHAR(50) NOT NULL,
  "symbol" VARCHAR(10),
  "is_active" BOOLEAN DEFAULT TRUE
);

-- Insert common currencies
INSERT INTO "currency" ("code", "name", "symbol") VALUES
('EUR', 'Euro', '€'),
('USD', 'US Dollar', '$'),
('GBP', 'British Pound', '£');

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
  "currency_code" CHAR(3) REFERENCES "currency"("code") DEFAULT 'EUR',
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "profile_discount" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "profile_id" UUID NOT NULL,
  "discount_percentage" DECIMAL(5,2) NOT NULL CHECK (discount_percentage >= 0),
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

ALTER TABLE "profile_discount" ADD CONSTRAINT "fk_profile_discount_profile" 
  FOREIGN KEY ("profile_id") REFERENCES "profile" ("id");

-- Customizable Usage Metrics per Organization moved to 00_organization_management_module.sql

-- Foreign key constraints for tables in other modules that reference tables in this module
ALTER TABLE "organization_usage_metric" ADD CONSTRAINT "fk_organization_usage_metric_profile" 
  FOREIGN KEY ("organization_profile_id") REFERENCES "profile" ("id");

-- Document management foreign key constraints
ALTER TABLE "document" ADD CONSTRAINT "fk_document_uploaded_by_profile" 
  FOREIGN KEY ("uploaded_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "document" ADD CONSTRAINT "fk_document_verified_by_profile" 
  FOREIGN KEY ("verified_by_profile_id") REFERENCES "profile" ("id");

ALTER TABLE "profile_document" ADD CONSTRAINT "fk_profile_document_profile" 
  FOREIGN KEY ("profile_id") REFERENCES "profile" ("id");
