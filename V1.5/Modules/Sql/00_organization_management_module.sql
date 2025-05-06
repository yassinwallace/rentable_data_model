-- Organization Management Module SQL
-- Generated for Rentable Data Model V1.5

-- Create ENUMs first
CREATE TYPE metric_type AS ENUM (
  'stock', -- cumulative counter (requires start and end values)
  'flow'   -- per-rental consumption (single reported value)
);

-- Create Tables
CREATE TABLE "organization_usage_metric" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "organization_profile_id" UUID NOT NULL,
  "name" VARCHAR(100) NOT NULL,
  "unit" VARCHAR(50) NOT NULL,
  "metric_type" metric_type NOT NULL,
  "is_active" BOOLEAN DEFAULT TRUE,
  "description" TEXT,
  "created_at" TIMESTAMP DEFAULT now(),
  "updated_at" TIMESTAMP DEFAULT now()
);

-- Create Indexes
CREATE INDEX "idx_organization_usage_metric_profile" ON "organization_usage_metric" ("organization_profile_id");

-- Note: Foreign key constraints will be added in the respective module files
-- ALTER TABLE "organization_usage_metric" ADD CONSTRAINT "fk_organization_usage_metric_profile" 
--   FOREIGN KEY ("organization_profile_id") REFERENCES "profile" ("id");
