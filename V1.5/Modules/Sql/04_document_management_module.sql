-- Document Management Module SQL
-- Generated for Rentable Data Model V1.5

-- Create ENUMs first
CREATE TYPE document_category AS ENUM (
  'equipment',    -- Equipment-level documents (manuals, certificates, etc.)
  'unit',         -- Unit-level documents (inspection reports, service records, etc.)
  'operator',     -- Operator/Profile documents (licenses, certifications, etc.)
  'order'         -- Order-level documents (agreements, waivers, etc.)
);

CREATE TYPE document_verification_status AS ENUM (
  'pending',      -- Document uploaded but not yet verified
  'approved',     -- Document verified and approved
  'rejected',     -- Document rejected due to issues
  'expired'       -- Document expired but was previously approved
);

CREATE TYPE document_access_level AS ENUM (
  'private',      -- Only visible to the owner and administrators
  'internal',     -- Visible to all members of the organization
  'restricted',   -- Visible to specific roles or in specific contexts
  'public'        -- Visible to anyone with access to the entity
);

-- Create Tables
CREATE TABLE "document_type" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "name" VARCHAR(100) NOT NULL,
  "category" document_category NOT NULL,
  "description" TEXT,
  "is_mandatory" BOOLEAN DEFAULT FALSE,
  "requires_verification" BOOLEAN DEFAULT FALSE,
  "requires_expiration_date" BOOLEAN DEFAULT FALSE,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

-- Pre-populate document types
INSERT INTO "document_type" ("name", "category", "description", "is_mandatory", "requires_verification", "requires_expiration_date") VALUES
-- Equipment-Level Documents
('User Manual', 'equipment', 'Official user manual for the equipment', FALSE, FALSE, FALSE),
('Safety Instructions', 'equipment', 'Safety guidelines and instructions', TRUE, TRUE, FALSE),
('Emission Certificate', 'equipment', 'Certificate confirming emission compliance', TRUE, TRUE, TRUE),
('CE / OSHA Compliance Certificate', 'equipment', 'Regulatory compliance certification', TRUE, TRUE, TRUE),
('Insurance Certificate', 'equipment', 'Equipment insurance documentation', TRUE, TRUE, TRUE),
('Maintenance Log', 'equipment', 'Record of maintenance activities', FALSE, FALSE, FALSE),
('Calibration Certificate', 'equipment', 'Certificate of calibration', FALSE, TRUE, TRUE),
('Warranty Certificate', 'equipment', 'Manufacturer warranty documentation', FALSE, TRUE, TRUE),

-- Unit-Level Documents
('Inspection Report', 'unit', 'Report from equipment inspection', TRUE, TRUE, TRUE),
('Service Record', 'unit', 'Record of service history', FALSE, FALSE, FALSE),
('Calibration Log', 'unit', 'Log of calibration activities', FALSE, FALSE, TRUE),
('Damage Report', 'unit', 'Documentation of existing damage', FALSE, TRUE, FALSE),

-- Operator/Profile Documents
('Driver''s License', 'operator', 'Valid driver''s license', TRUE, TRUE, TRUE),
('Operating Certification', 'operator', 'Certification to operate specific equipment', TRUE, TRUE, TRUE),
('Worksite Access Permit', 'operator', 'Permission to access specific worksites', FALSE, TRUE, TRUE),

-- Order-Level Documents
('Rental Agreement', 'order', 'Signed rental agreement', TRUE, TRUE, FALSE),
('Signed Waivers', 'order', 'Liability and other waivers', TRUE, TRUE, FALSE),
('Pre-rental Checklist', 'order', 'Checklist completed before rental', TRUE, FALSE, FALSE),
('Return Inspection Form', 'order', 'Inspection form completed upon return', TRUE, FALSE, FALSE),
('Damage Claim File', 'order', 'Documentation for damage claims', FALSE, TRUE, FALSE);

CREATE TABLE "document" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "document_type_id" UUID NOT NULL,
  "title" VARCHAR(255) NOT NULL,
  "description" TEXT,
  "file_path" VARCHAR(255) NOT NULL,
  "file_size" BIGINT,
  "file_type" VARCHAR(50),
  "uploaded_by_profile_id" UUID NOT NULL,
  "verification_status" document_verification_status DEFAULT 'pending',
  "verified_by_profile_id" UUID,
  "verified_at" TIMESTAMP,
  "expiration_date" DATE,
  "version" INT DEFAULT 1,
  "metadata" JSONB,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

-- Entity document associations
CREATE TABLE "item_document" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_id" UUID NOT NULL,
  "document_id" UUID NOT NULL,
  "access_level" document_access_level DEFAULT 'private',
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "item_unit_document" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "item_unit_id" UUID NOT NULL,
  "document_id" UUID NOT NULL,
  "access_level" document_access_level DEFAULT 'private',
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "profile_document" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "profile_id" UUID NOT NULL,
  "document_id" UUID NOT NULL,
  "access_level" document_access_level DEFAULT 'private',
  "created_at" TIMESTAMP DEFAULT now()
);

CREATE TABLE "order_document" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "order_id" UUID NOT NULL,
  "document_id" UUID NOT NULL,
  "access_level" document_access_level DEFAULT 'private',
  "created_at" TIMESTAMP DEFAULT now()
);

-- Create Indexes
CREATE INDEX "idx_document_type" ON "document" ("document_type_id");
CREATE INDEX "idx_document_verification_status" ON "document" ("verification_status");
CREATE INDEX "idx_document_expiration_date" ON "document" ("expiration_date");
CREATE INDEX "idx_document_uploaded_by" ON "document" ("uploaded_by_profile_id");

CREATE INDEX "idx_item_document_item" ON "item_document" ("item_id");
CREATE INDEX "idx_item_document_document" ON "item_document" ("document_id");
CREATE INDEX "idx_item_document_access_level" ON "item_document" ("access_level");

CREATE INDEX "idx_item_unit_document_unit" ON "item_unit_document" ("item_unit_id");
CREATE INDEX "idx_item_unit_document_document" ON "item_unit_document" ("document_id");
CREATE INDEX "idx_item_unit_document_access_level" ON "item_unit_document" ("access_level");

CREATE INDEX "idx_profile_document_profile" ON "profile_document" ("profile_id");
CREATE INDEX "idx_profile_document_document" ON "profile_document" ("document_id");
CREATE INDEX "idx_profile_document_access_level" ON "profile_document" ("access_level");

CREATE INDEX "idx_order_document_order" ON "order_document" ("order_id");
CREATE INDEX "idx_order_document_document" ON "order_document" ("document_id");
CREATE INDEX "idx_order_document_access_level" ON "order_document" ("access_level");

-- Internal foreign key constraints
ALTER TABLE "document" ADD CONSTRAINT "fk_document_document_type" 
  FOREIGN KEY ("document_type_id") REFERENCES "document_type" ("id");

ALTER TABLE "item_document" ADD CONSTRAINT "fk_item_document_document" 
  FOREIGN KEY ("document_id") REFERENCES "document" ("id");

ALTER TABLE "item_unit_document" ADD CONSTRAINT "fk_item_unit_document_document" 
  FOREIGN KEY ("document_id") REFERENCES "document" ("id");

ALTER TABLE "profile_document" ADD CONSTRAINT "fk_profile_document_document" 
  FOREIGN KEY ("document_id") REFERENCES "document" ("id");

ALTER TABLE "order_document" ADD CONSTRAINT "fk_order_document_document" 
  FOREIGN KEY ("document_id") REFERENCES "document" ("id");
