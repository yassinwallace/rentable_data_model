
-- Enums
CREATE TYPE profile_type AS ENUM ('individual', 'organization');
CREATE TYPE invitation_status AS ENUM ('pending', 'accepted', 'expired');

-- Tables
CREATE TABLE profile (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_ref(user_id),
    profile_type profile_type NOT NULL,
    first_name VARCHAR,
    last_name VARCHAR,
    date_of_birth DATE,
    organization_name VARCHAR,
    siret_number VARCHAR,
    phone_number VARCHAR,
    avatar_url VARCHAR,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE user_ref (
    user_id UUID PRIMARY KEY
    
);

CREATE TABLE organization_invitation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_profile_id UUID NOT NULL REFERENCES profile(id),
    invited_by_profile_id UUID NOT NULL REFERENCES profile(id),
    email VARCHAR NOT NULL,
    role VARCHAR,
    token VARCHAR NOT NULL,
    status invitation_status DEFAULT 'pending',
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE profile_membership (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES profile(id),
    organization_profile_id UUID NOT NULL REFERENCES profile(id),
    status VARCHAR DEFAULT 'active',
    joined_at TIMESTAMP DEFAULT now()
);

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
    role_id UUID REFERENCES role(id),
    permission_id UUID REFERENCES permission(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE profile_role (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES profile(id),
    organization_profile_id UUID REFERENCES profile(id),
    role_id UUID NOT NULL REFERENCES role(id),
    created_at TIMESTAMP DEFAULT now(),
    UNIQUE (profile_id, organization_profile_id, role_id)
);


-- profile
CREATE INDEX idx_profile_user_id ON profile(user_id);

-- organization_invitation
CREATE INDEX idx_org_invite_org_id ON organization_invitation(organization_profile_id);
CREATE INDEX idx_org_invite_email ON organization_invitation(email);

-- profile_membership
CREATE INDEX idx_profile_membership_profile ON profile_membership(profile_id);
CREATE INDEX idx_profile_membership_org ON profile_membership(organization_profile_id);

-- profile_role
CREATE INDEX idx_profile_role_profile ON profile_role(profile_id);
CREATE INDEX idx_profile_role_org ON profile_role(organization_profile_id);
CREATE INDEX idx_profile_role_role ON profile_role(role_id);

-- role_permission
CREATE INDEX idx_role_permission_role_id ON role_permission(role_id);
CREATE INDEX idx_role_permission_permission_id ON role_permission(permission_id);
