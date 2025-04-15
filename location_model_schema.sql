
-- ENUMS
CREATE TYPE location_type AS ENUM ('fixed', 'mobile', 'virtual', 'store');
CREATE TYPE location_role AS ENUM ('pickup', 'storage', 'workplace', 'maintenance');
CREATE TYPE owner_type AS ENUM ('user', 'business');
CREATE TYPE linked_entity_type AS ENUM ('user', 'item', 'business');

-- Table: address
CREATE TABLE address (
    id UUID PRIMARY KEY,
    line1 TEXT,
    line2 TEXT,
    postal_code TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Table: location
CREATE TABLE location (
    id UUID PRIMARY KEY,
    name TEXT,
    description TEXT,
    address_id UUID REFERENCES address(id),
    location_type location_type,
    owner_type owner_type,
    owner_id UUID,
    is_public BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true
);

-- Table: location_link
CREATE TABLE location_link (
    id UUID PRIMARY KEY,
    location_id UUID REFERENCES location(id),
    linked_entity_type linked_entity_type,
    linked_entity_id UUID,
    location_role location_role,
    is_primary BOOLEAN DEFAULT false,
    verified BOOLEAN DEFAULT false
);

-- Table: location_hour
CREATE TABLE location_hour (
    id UUID PRIMARY KEY,
    location_id UUID REFERENCES location(id),
    day_of_week INTEGER, -- 0=Sunday ... 6=Saturday
    opens_at TIME,
    closes_at TIME,
    is_closed BOOLEAN DEFAULT false
);

-- Table: location_special_period
CREATE TABLE location_special_period (
    id UUID PRIMARY KEY,
    location_id UUID REFERENCES location(id),
    name TEXT,
    start_date DATE,
    end_date DATE,
    is_closed BOOLEAN DEFAULT false
);

-- Table: location_special_hour
CREATE TABLE location_special_hour (
    id UUID PRIMARY KEY,
    special_period_id UUID REFERENCES location_special_period(id),
    day_of_week INTEGER,
    opens_at TIME,
    closes_at TIME,
    is_closed BOOLEAN DEFAULT false
);

-- Table: location_holiday_exception
CREATE TABLE location_holiday_exception (
    id UUID PRIMARY KEY,
    location_id UUID REFERENCES location(id),
    date DATE,
    opens_at TIME,
    closes_at TIME,
    is_closed BOOLEAN DEFAULT false,
    label TEXT
);
