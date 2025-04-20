CREATE TYPE item_status AS ENUM ('active', 'inactive', 'pending_review');
CREATE TYPE item_condition AS ENUM ('new', 'like_new', 'good', 'fair', 'poor');
CREATE TYPE item_type AS ENUM ('P2P', 'B2B', 'B2C');
CREATE TYPE item_insurance_cost_type AS ENUM ('flat', 'percentage');
CREATE TYPE related_items_relation_type AS ENUM ('accessory', 'similar', 'complementary');
CREATE TYPE bulk_import_status AS ENUM ('pending', 'processing', 'completed', 'failed');
CREATE TYPE item_history_action AS ENUM ('created', 'updated', 'deleted', 'status_changed');
CREATE TYPE logistics_type AS ENUM ('delivery', 'pickup');
CREATE TYPE logistics_mode AS ENUM ('none', 'optional', 'required');
CREATE TYPE logistics_party_type AS ENUM ('renter', 'owner', 'transporter');

-- item table
CREATE TABLE item (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_profile_id UUID NOT NULL,
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
    required_certification certification_type,
    logistics_mode logistics_mode DEFAULT 'none',
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),
    CONSTRAINT idx_item_owner FOREIGN KEY (owner_profile_id) REFERENCES profile(id)
);

CREATE INDEX idx_item_owner ON item(owner_profile_id);

-- item_category
CREATE TABLE item_category (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    level INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_item_category_parent FOREIGN KEY (parent_id) REFERENCES item_category(id)
);

-- item_category_assignment
CREATE TABLE item_category_assignment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL,
    category_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_item_cat_assign_item FOREIGN KEY (item_id) REFERENCES item(id),
    CONSTRAINT fk_item_cat_assign_cat FOREIGN KEY (category_id) REFERENCES item_category(id)
);

CREATE INDEX idx_item_cat_assign_item ON item_category_assignment(item_id);
CREATE INDEX idx_item_cat_assign_cat ON item_category_assignment(category_id);

-- item_attributes
CREATE TABLE item_attributes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL,
    attribute_name VARCHAR(100) NOT NULL,
    attribute_value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_item_attr_item FOREIGN KEY (item_id) REFERENCES item(id)
);

CREATE INDEX idx_item_attr_item ON item_attributes(item_id);

-- item_availability
CREATE TABLE item_availability (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_available BOOLEAN NOT NULL,
    custom_price DECIMAL(10,2),
    inventory_count INT,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_item_avail_item FOREIGN KEY (item_id) REFERENCES item(id)
);

CREATE INDEX idx_item_avail_item ON item_availability(item_id);
CREATE INDEX idx_item_avail_range ON item_availability(start_date, end_date);

-- item_images
CREATE TABLE item_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    display_order INT NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_item_images_item FOREIGN KEY (item_id) REFERENCES item(id)
);

CREATE INDEX idx_item_images_item ON item_images(item_id);

-- item_pricing_tier
CREATE TABLE item_pricing_tier (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL,
    min_days INT NOT NULL,
    max_days INT,
    price_per_day DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_item_price_tier_item FOREIGN KEY (item_id) REFERENCES item(id)
);

CREATE INDEX idx_item_price_tier_item ON item_pricing_tier(item_id);

-- item_maintenance_record
CREATE TABLE item_maintenance_record (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL,
    maintenance_type VARCHAR(100) NOT NULL,
    description TEXT,
    performed_by VARCHAR(255),
    performed_at TIMESTAMP NOT NULL,
    cost DECIMAL(10,2),
    next_maintenance_due TIMESTAMP,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_item_maint_item FOREIGN KEY (item_id) REFERENCES item(id)
);

CREATE INDEX idx_item_maint_item ON item_maintenance_record(item_id);

-- item_rental_rules
CREATE TABLE item_rental_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL,
    rule_type VARCHAR(100) NOT NULL,
    rule_value TEXT NOT NULL,
    is_required BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_item_rules_item FOREIGN KEY (item_id) REFERENCES item(id)
);

CREATE INDEX idx_item_rules_item ON item_rental_rules(item_id);

-- item_insurance_options
CREATE TABLE item_insurance_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL,
    insurance_name VARCHAR(255) NOT NULL,
    description TEXT,
    cost DECIMAL(10,2) NOT NULL,
    item_insurance_cost_type item_insurance_cost_type NOT NULL,
    coverage_amount DECIMAL(10,2) NOT NULL,
    is_required BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_item_insurance_item FOREIGN KEY (item_id) REFERENCES item(id)
);

CREATE INDEX idx_item_insurance_item ON item_insurance_options(item_id);

-- item_bundle
CREATE TABLE item_bundle (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    discount_percentage DECIMAL(5,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

-- items_bundle_assignment
CREATE TABLE items_bundle_assignment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bundle_id UUID NOT NULL,
    item_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_bundle_assign_bundle FOREIGN KEY (bundle_id) REFERENCES item_bundle(id),
    CONSTRAINT fk_bundle_assign_item FOREIGN KEY (item_id) REFERENCES item(id)
);

CREATE INDEX idx_bundle_assign_bundle ON items_bundle_assignment(bundle_id);
CREATE INDEX idx_bundle_assign_item ON items_bundle_assignment(item_id);

-- related_item
CREATE TABLE related_item (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL,
    related_item_id UUID NOT NULL,
    related_items_relation_type related_items_relation_type NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_related_item_main FOREIGN KEY (item_id) REFERENCES item(id),
    CONSTRAINT fk_related_item_related FOREIGN KEY (related_item_id) REFERENCES item(id)
);

CREATE INDEX idx_related_item_main ON related_item(item_id);
CREATE INDEX idx_related_item_related ON related_item(related_item_id);

-- item_bulk_import
CREATE TABLE item_bulk_import (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL,
    import_source VARCHAR,
    item_count INT,
    status bulk_import_status DEFAULT 'pending',
    error_report TEXT,
    created_at TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_bulk_import_profile FOREIGN KEY (profile_id) REFERENCES profile(id)
);

CREATE INDEX idx_bulk_import_profile ON item_bulk_import(profile_id);

-- service_level_agreement
CREATE TABLE service_level_agreement (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    terms TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_sla_item FOREIGN KEY (item_id) REFERENCES item(id)
);

CREATE INDEX idx_sla_item ON service_level_agreement(item_id);

-- item_history
CREATE TABLE item_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL,
    profile_id UUID NOT NULL,
    action item_history_action NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT now(),
    CONSTRAINT fk_item_history_item FOREIGN KEY (item_id) REFERENCES item(id),
    CONSTRAINT fk_item_history_profile FOREIGN KEY (profile_id) REFERENCES profile(id)
);

CREATE INDEX idx_item_history_item ON item_history(item_id);
CREATE INDEX idx_item_history_profile ON item_history(profile_id);

-- item_operator_requirement
CREATE TABLE item_operator_requirement (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL,
    certification_type certification_type NOT NULL,
    is_mandatory BOOLEAN DEFAULT TRUE,
    note TEXT,
    CONSTRAINT fk_item_operator_req_item FOREIGN KEY (item_id) REFERENCES item(id)
);

-- item_logistics_option
CREATE TABLE item_logistics_option (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL,
    logistics_type logistics_type NOT NULL,
    party_type logistics_party_type NOT NULL,
    transporter_organization_profile_id UUID,
    CONSTRAINT fk_logistics_opt_item FOREIGN KEY (item_id) REFERENCES item(id),
    CONSTRAINT fk_logistics_opt_transporter FOREIGN KEY (transporter_organization_profile_id) REFERENCES profile(id)
);
