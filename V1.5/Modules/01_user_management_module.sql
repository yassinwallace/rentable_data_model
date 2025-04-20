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
