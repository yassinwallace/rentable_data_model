
-- ORGANIZATION POLICY MODULE

CREATE TABLE organization_policy (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_profile_id UUID NOT NULL REFERENCES profile(id),
  grace_period_minutes INT,
  cancellation_policy TEXT,
  max_late_tolerance_minutes INT,
  created_at TIMESTAMP DEFAULT now()
);
