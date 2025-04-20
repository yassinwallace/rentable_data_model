-- START OF: 01_user_management_module.sql
-- Enums
CREATE TYPE profile_type AS ENUM ('individual', 'organization');
CREATE TYPE invitation_status AS ENUM ('pending', 'accepted', 'expired');
CREATE TYPE certification_type AS ENUM ('CACES', 'Forklift', 'Crane', 'Other');

-- Tables
CREATE TABLE user_ref (
  user_id UUID PRIMARY KEY
);

CREATE TABLE profile (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  profile_type profile_type NOT NULL,
  first_name VARCHAR,
  last_name VARCHAR,
  date_of_birth DATE,
  organization_name VARCHAR,
  siret_number VARCHAR,
  phone_number VARCHAR,
  avatar_url VARCHAR,
  created_at TIMESTAMP DEFAULT now(),
  CONSTRAINT fk_profile_user FOREIGN KEY (user_id) REFERENCES user_ref(user_id)
);

CREATE INDEX idx_profile_user_id ON profile(user_id);

CREATE TABLE organization_invitation (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_profile_id UUID NOT NULL,
  invited_by_profile_id UUID NOT NULL,
  email VARCHAR NOT NULL,
  role VARCHAR,
  token VARCHAR NOT NULL,
  status invitation_status DEFAULT 'pending',
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT now(),
  CONSTRAINT fk_org_invite_org FOREIGN KEY (organization_profile_id) REFERENCES profile(id),
  CONSTRAINT fk_org_invite_by FOREIGN KEY (invited_by_profile_id) REFERENCES profile(id)
);

CREATE INDEX idx_org_invite_org_id ON organization_invitation(organization_profile_id);
CREATE INDEX idx_org_invite_email ON organization_invitation(email);

CREATE TABLE profile_membership (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL,
  organization_profile_id UUID NOT NULL,
  status VARCHAR DEFAULT 'active',
  joined_at TIMESTAMP DEFAULT now(),
  CONSTRAINT fk_membership_profile FOREIGN KEY (profile_id) REFERENCES profile(id),
  CONSTRAINT fk_membership_org FOREIGN KEY (organization_profile_id) REFERENCES profile(id)
);

CREATE INDEX idx_profile_membership_profile ON profile_membership(profile_id);
CREATE INDEX idx_profile_membership_org ON profile_membership(organization_profile_id);

CREATE TABLE role (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE permission (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR UNIQUE NOT NULL,
  description TEXT,
  category VARCHAR NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE role_permission (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_id UUID,
  permission_id UUID,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_role_permission_role FOREIGN KEY (role_id) REFERENCES role(id),
  CONSTRAINT fk_role_permission_perm FOREIGN KEY (permission_id) REFERENCES permission(id)
);

CREATE INDEX idx_role_permission_role_id ON role_permission(role_id);
CREATE INDEX idx_role_permission_permission_id ON role_permission(permission_id);

CREATE TABLE profile_role (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL,
  organization_profile_id UUID,
  role_id UUID NOT NULL,
  created_at TIMESTAMP DEFAULT now(),
  CONSTRAINT fk_profile_role_profile FOREIGN KEY (profile_id) REFERENCES profile(id),
  CONSTRAINT fk_profile_role_org FOREIGN KEY (organization_profile_id) REFERENCES profile(id),
  CONSTRAINT fk_profile_role_role FOREIGN KEY (role_id) REFERENCES role(id),
  CONSTRAINT uq_profile_role UNIQUE (profile_id, organization_profile_id, role_id)
);

CREATE INDEX idx_profile_role_profile ON profile_role(profile_id);
CREATE INDEX idx_profile_role_org ON profile_role(organization_profile_id);
CREATE INDEX idx_profile_role_role ON profile_role(role_id);

CREATE TABLE profile_certification (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES profile(id),
  certification_type certification_type NOT NULL,
  certification_number VARCHAR,
  issued_by VARCHAR,
  valid_from DATE,
  valid_until DATE,
  document_url TEXT,
  created_at TIMESTAMP DEFAULT now()
);

-- END OF: 01_user_management_module.sql

-- START OF: 02_item_management_module.sql
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

-- END OF: 02_item_management_module.sql

-- START OF: 03_location_management_module.sql
-- ENUMS
CREATE TYPE address_usage_type AS ENUM ('general', 'billing', 'shipping', 'pickup', 'return', 'stock');

-- ADDRESS REPOSITORY
CREATE TABLE address (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    postal_code VARCHAR(20),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) NOT NULL,
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE location (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255),
    description TEXT,
    address_id UUID NOT NULL REFERENCES address(id),
    created_by_profile_id UUID NOT NULL REFERENCES profile(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE location_assignment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_id UUID NOT NULL REFERENCES location(id),
    profile_id UUID REFERENCES profile(id),
    item_id UUID REFERENCES item(id),
    address_usage_type address_usage_type DEFAULT 'general',
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT now(),
    CHECK (num_nonnulls(profile_id, item_id) = 1)
);

-- OPENING HOURS
CREATE TABLE location_hour (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_id UUID NOT NULL REFERENCES location(id),
    weekday INT NOT NULL,  -- 0 = Sunday ... 6 = Saturday
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

-- SEASONAL SCHEDULES
CREATE TABLE location_special_period (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_id UUID NOT NULL REFERENCES location(id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    label VARCHAR(255),
    is_closed BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE location_special_hour (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    special_period_id UUID NOT NULL REFERENCES location_special_period(id),
    weekday INT NOT NULL,
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

-- HOLIDAY EXCEPTIONS
CREATE TABLE location_holiday_exception (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_id UUID NOT NULL REFERENCES location(id),
    holiday_date DATE NOT NULL,
    is_closed BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

-- UNIQUE CONSTRAINTS (optional)
CREATE UNIQUE INDEX unique_profile_address_type
ON location_assignment(profile_id, address_usage_type)
WHERE profile_id IS NOT NULL;

CREATE UNIQUE INDEX unique_item_address_type
ON location_assignment(item_id, address_usage_type)
WHERE item_id IS NOT NULL;

-- END OF: 03_location_management_module.sql

-- START OF: 04_order_management_module.sql
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled', 'disputed');
CREATE TYPE order_event_type AS ENUM ('cancellation_requested', 'cancellation_approved', 'cancellation_rejected', 'extension_requested', 'extension_approved', 'extension_rejected', 'dispute_raised', 'dispute_resolved', 'status_changed', 'message_sent', 'custom_note');
CREATE TYPE approval_status AS ENUM ('pending', 'approved', 'rejected', 'auto_approved');
CREATE TYPE handover_type AS ENUM ('OUTGOING', 'RETURN');
CREATE TYPE payment_type AS ENUM ('RENT', 'DEPOSIT', 'EXTRA');
CREATE TYPE payment_status AS ENUM ('PENDING', 'PAID', 'FAILED', 'REFUNDED');
CREATE TYPE deposit_status AS ENUM ('HELD', 'RELEASED', 'CLAIMED');
CREATE TYPE dispute_status AS ENUM ('OPEN', 'RESOLVED', 'ESCALATED');
CREATE TYPE deposit_action_type AS ENUM ('CLAIM', 'RELEASE');
CREATE TYPE logistics_time_window AS ENUM ('morning', 'afternoon', 'full_day');
CREATE TYPE logistics_status AS ENUM ('pending', 'confirmed', 'in_transit', 'completed', 'failed');
CREATE TYPE confirmation_method AS ENUM ('qr_code', 'signature', 'manual');

CREATE TABLE "order" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ordered_by_profile_id UUID NOT NULL REFERENCES profile(id),
    owner_profile_id UUID NOT NULL REFERENCES profile(id),
    item_id UUID NOT NULL REFERENCES item(id),
    status order_status DEFAULT 'pending',
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    total_price NUMERIC(10,2),
    currency VARCHAR(10),
    note TEXT,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE order_event (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES "order"(id),
    event_type order_event_type NOT NULL,
    initiated_by_profile_id UUID NOT NULL REFERENCES profile(id),
    approved_by_profile_id UUID REFERENCES profile(id),
    approval_status approval_status DEFAULT 'pending',
    payload JSONB,
    created_at TIMESTAMP DEFAULT now(),
    effective_at TIMESTAMP
);

CREATE TABLE item_handover (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES "order"(id),
    handover_time TIMESTAMP,
    type handover_type,
    expected_return_time TIMESTAMP,
    actual_return_time TIMESTAMP,
    received_by_profile_id UUID REFERENCES profile(id),
    handed_over_by_profile_id UUID NOT NULL REFERENCES profile(id),
    checked_by_profile_id UUID REFERENCES profile(id),
    condition_report TEXT,
    photos_urls TEXT[],
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE item_return (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES "order"(id),
    actual_return_time TIMESTAMP NOT NULL,
    returned_by_profile_id UUID NOT NULL REFERENCES profile(id),
    confirmed_by_profile_id UUID REFERENCES profile(id),
    condition_report TEXT,
    is_late BOOLEAN DEFAULT FALSE,
    late_by_minutes INTEGER,
    grace_period_exceeded BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT now()
);


CREATE TABLE order_payment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES "order"(id),
    profile_id UUID NOT NULL REFERENCES profile(id),
    amount NUMERIC(10,2) NOT NULL,
    payment_type payment_type NOT NULL,
    status payment_status DEFAULT 'PENDING',
    paid_at TIMESTAMP,
    external_ref TEXT,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE order_deposit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL UNIQUE REFERENCES "order"(id),
    order_payment_id UUID NOT NULL UNIQUE REFERENCES order_payment(id),
    amount NUMERIC(10,2) NOT NULL,
    status deposit_status DEFAULT 'HELD',
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE order_dispute (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL UNIQUE REFERENCES "order"(id),
    raised_by_profile_id UUID NOT NULL REFERENCES profile(id),
    reason TEXT,
    status dispute_status DEFAULT 'OPEN',
    resolution TEXT,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE order_deposit_action (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_deposit_id UUID NOT NULL REFERENCES order_deposit(id),
    action_type deposit_action_type NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    reason TEXT,
    initiated_by_profile_id UUID REFERENCES profile(id),
    approved_by_profile_id UUID REFERENCES profile(id),
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE order_operator_assignment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES "order"(id),
    profile_id UUID REFERENCES profile(id),
    full_name VARCHAR,
    phone_number VARCHAR,
    certification_type certification_type,
    certification_number VARCHAR,
    certification_valid_until DATE,
    certification_document_url TEXT,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE order_logistics_action (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES "order"(id),
    logistics_type logistics_type NOT NULL,
    requested_date DATE NOT NULL,
    requested_time_window logistics_time_window NOT NULL,
    confirmed_datetime TIMESTAMP,
    status logistics_status DEFAULT 'pending',
    handled_by_profile_id UUID REFERENCES profile(id),
    transporter_profile_id UUID REFERENCES profile(id),
    confirmation_method confirmation_method,
    confirmation_time TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT now()
);

-- END OF: 04_order_management_module.sql

