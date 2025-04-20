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
