
-- ITEM MANAGEMENT MODULE

CREATE TABLE item_rental_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id UUID NOT NULL REFERENCES item(id),
  grace_period_minutes INT,
  max_duration_hours INT,
  min_duration_hours INT,
  requires_verification BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT now()
);
