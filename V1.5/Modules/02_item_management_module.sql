
-- Enums
CREATE TYPE item_status AS ENUM ('active', 'inactive', 'pending_review');
CREATE TYPE item_condition AS ENUM ('new', 'like_new', 'good', 'fair', 'poor');
CREATE TYPE item_type AS ENUM ('P2P', 'B2B', 'B2C');
CREATE TYPE item_insurance_cost_type AS ENUM ('flat', 'percentage');
CREATE TYPE related_items_relation_type AS ENUM ('accessory', 'similar', 'complementary');
CREATE TYPE bulk_import_status AS ENUM ('pending', 'processing', 'completed', 'failed');
CREATE TYPE item_history_action AS ENUM ('created', 'updated', 'deleted', 'status_changed');

-- Tables
CREATE TABLE item (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_profile_id UUID NOT NULL REFERENCES profile(id),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    item_status item_status NOT NULL,
    item_condition item_condition NOT NULL,
    item_type item_type NOT NULL,
    quantity INT DEFAULT 1,
    minimum_rental_period INT,
    maximum_rental_period INT,
    start_hours VARCHAR(50),
    end_hours VARCHAR(50),
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE item_category (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES item_category(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    level INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE item_category_assignment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES item(id),
    category_id UUID NOT NULL REFERENCES item_category(id),
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE item_attributes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES item(id),
    attribute_name VARCHAR(100) NOT NULL,
    attribute_value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE item_availability (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES item(id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_available BOOLEAN NOT NULL,
    custom_price DECIMAL(10,2),
    inventory_count INT,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE item_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES item(id),
    image_url VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    display_order INT NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE item_pricing_tier (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES item(id),
    min_days INT NOT NULL,
    max_days INT,
    price_per_day DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE item_maintenance_record (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES item(id),
    maintenance_type VARCHAR(100) NOT NULL,
    description TEXT,
    performed_by VARCHAR(255),
    performed_at TIMESTAMP NOT NULL,
    cost DECIMAL(10,2),
    next_maintenance_due TIMESTAMP,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE item_rental_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES item(id),
    rule_type VARCHAR(100) NOT NULL,
    rule_value TEXT NOT NULL,
    is_required BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE item_insurance_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES item(id),
    insurance_name VARCHAR(255) NOT NULL,
    description TEXT,
    cost DECIMAL(10,2) NOT NULL,
    item_insurance_cost_type item_insurance_cost_type NOT NULL,
    coverage_amount DECIMAL(10,2) NOT NULL,
    is_required BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE item_bundle (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    discount_percentage DECIMAL(5,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE items_bundle_assignment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bundle_id UUID NOT NULL REFERENCES item_bundle(id),
    item_id UUID NOT NULL REFERENCES item(id),
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE related_item (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES item(id),
    related_item_id UUID NOT NULL REFERENCES item(id),
    related_items_relation_type related_items_relation_type NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE item_bulk_import (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES profile(id),
    import_source VARCHAR,
    item_count INT,
    status bulk_import_status DEFAULT 'pending',
    error_report TEXT,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE service_level_agreement (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES item(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    terms TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE item_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL REFERENCES item(id),
    profile_id UUID NOT NULL REFERENCES profile(id),
    action item_history_action NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT now()
);


-- item
CREATE INDEX idx_item_owner ON item(owner_profile_id);

-- item_category_assignment
CREATE INDEX idx_item_cat_assign_item ON item_category_assignment(item_id);
CREATE INDEX idx_item_cat_assign_cat ON item_category_assignment(category_id);

-- item_attributes
CREATE INDEX idx_item_attr_item ON item_attributes(item_id);

-- item_availability
CREATE INDEX idx_item_avail_item ON item_availability(item_id);
CREATE INDEX idx_item_avail_range ON item_availability(start_date, end_date);

-- item_images
CREATE INDEX idx_item_images_item ON item_images(item_id);

-- item_pricing_tier
CREATE INDEX idx_item_price_tier_item ON item_pricing_tier(item_id);

-- item_maintenance_record
CREATE INDEX idx_item_maint_item ON item_maintenance_record(item_id);

-- item_rental_rules
CREATE INDEX idx_item_rules_item ON item_rental_rules(item_id);

-- item_insurance_options
CREATE INDEX idx_item_insurance_item ON item_insurance_options(item_id);

-- items_bundle_assignment
CREATE INDEX idx_bundle_assign_bundle ON items_bundle_assignment(bundle_id);
CREATE INDEX idx_bundle_assign_item ON items_bundle_assignment(item_id);

-- related_item
CREATE INDEX idx_related_item_main ON related_item(item_id);
CREATE INDEX idx_related_item_related ON related_item(related_item_id);

-- item_bulk_import
CREATE INDEX idx_bulk_import_profile ON item_bulk_import(profile_id);

-- item_history
CREATE INDEX idx_item_history_item ON item_history(item_id);
CREATE INDEX idx_item_history_profile ON item_history(profile_id);

-- service_level_agreement
CREATE INDEX idx_sla_item ON service_level_agreement(item_id);
