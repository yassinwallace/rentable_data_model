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
