-- ============================================================================
-- Suriyaraja Siddha Health Care ERP (SSHC ERP)
-- Migration : 01_foundation.sql
-- Version   : 1.0.0
-- Database  : PostgreSQL 17 (Supabase)
-- Author    : Dr. Raja Suriyaraja & ChatGPT
--
-- Description:
-- Foundation migration for SSHC ERP.
-- Creates extensions, common utility functions,
-- number sequences, roles, profiles,
-- clinic settings, audit logs and shared infrastructure.
-- ============================================================================

BEGIN;

-- ============================================================================
-- REQUIRED EXTENSIONS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================================
-- COMMON UPDATE FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS
$$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

-- ============================================================================
-- NUMBER SEQUENCE SYSTEM
-- ============================================================================

CREATE TABLE IF NOT EXISTS number_sequences (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    sequence_name VARCHAR(30) NOT NULL UNIQUE,

    prefix VARCHAR(20) NOT NULL,

    last_number INTEGER NOT NULL DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

CREATE TRIGGER trg_number_sequences_updated_at
BEFORE UPDATE ON number_sequences
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

INSERT INTO number_sequences
(sequence_name,prefix,last_number)

VALUES

('PAT','PAT',0),

('APT','APT',0),

('OP','OP',0),

('CONS','CONS',0),

('RX','RX',0),

('INV','INV',0)

ON CONFLICT (sequence_name) DO NOTHING;
-- ============================================================================
-- ROLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS roles (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    role_code VARCHAR(20) NOT NULL UNIQUE,

    role_name VARCHAR(100) NOT NULL UNIQUE,

    description TEXT,

    is_system_role BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE roles IS
'Stores all system roles used in SSHC ERP.';

CREATE TRIGGER trg_roles_updated_at
BEFORE UPDATE ON roles
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

INSERT INTO roles
(role_code, role_name, description, is_system_role)

VALUES

('ADMIN','Administrator',
'Full system access',
TRUE),

('DOCTOR','Doctor',
'Clinical consultation and prescriptions',
TRUE),

('RECEPTION','Receptionist',
'Patient registration and appointments',
TRUE),

('PHARMACY','Pharmacist',
'Medicine dispensing and stock',
TRUE),

('ACCOUNTS','Accounts',
'Billing and financial management',
TRUE),

('PATIENT','Patient',
'Patient portal access',
TRUE)

ON CONFLICT (role_code) DO NOTHING;

-- ============================================================================
-- PERMISSIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS permissions (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    permission_code VARCHAR(100) NOT NULL UNIQUE,

    permission_name VARCHAR(150) NOT NULL,

    module_name VARCHAR(50) NOT NULL,

    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE permissions IS
'Stores all application permissions.';

CREATE TRIGGER trg_permissions_updated_at
BEFORE UPDATE ON permissions
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

INSERT INTO permissions
(permission_code, permission_name, module_name)

VALUES

('patient.create','Create Patient','Patients'),
('patient.view','View Patient','Patients'),
('patient.edit','Edit Patient','Patients'),
('patient.delete','Delete Patient','Patients'),

('consultation.create','Create Consultation','Consultation'),
('consultation.view','View Consultation','Consultation'),
('consultation.edit','Edit Consultation','Consultation'),

('prescription.create','Create Prescription','Prescription'),
('prescription.print','Print Prescription','Prescription'),

('billing.create','Create Bill','Billing'),
('billing.view','View Bill','Billing'),

('reports.view','View Reports','Reports'),

('settings.manage','Manage Settings','Administration')

ON CONFLICT (permission_code) DO NOTHING;
-- ============================================================================
-- ROLE PERMISSIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS role_permissions (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    role_id UUID NOT NULL,

    permission_id UUID NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    CONSTRAINT fk_role_permissions_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_role_permissions_permission
    FOREIGN KEY (permission_id)
    REFERENCES permissions(id)
    ON DELETE CASCADE,

    CONSTRAINT uq_role_permission
        UNIQUE(role_id, permission_id)

);
INSERT INTO role_permissions (role_id, permission_id)

SELECT
    r.id,
    p.id
FROM roles r
CROSS JOIN permissions p
WHERE r.role_code = 'ADMIN'

ON CONFLICT DO NOTHING;
-- ============================================================================
-- USER PROFILES
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_profiles (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    auth_user_id UUID UNIQUE REFERENCES auth.users(id),

    full_name VARCHAR(150) NOT NULL,

    registration_number VARCHAR(50),

    email VARCHAR(150),

    mobile_number VARCHAR(20),

    profile_photo_url TEXT, 

    designation VARCHAR(100),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

CREATE TRIGGER trg_user_profiles_updated_at
BEFORE UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- USER ROLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_roles (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_profile_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,

    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    UNIQUE(user_profile_id, role_id)

);

CREATE TRIGGER trg_user_roles_updated_at
BEFORE UPDATE ON user_roles
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
-- ============================================================================
-- CLINIC SETTINGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS clinic_settings (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    clinic_name VARCHAR(200) NOT NULL,

    registration_number VARCHAR(50),

    address TEXT,

    city VARCHAR(100),

    state VARCHAR(100),

    pincode VARCHAR(10),

    country VARCHAR(100) DEFAULT 'India',

    phone VARCHAR(20),

    alternate_phone VARCHAR(20),

    email VARCHAR(150),

    website VARCHAR(255),

    logo_url TEXT,

    consultation_start_time TIME,

    consultation_end_time TIME,

    currency VARCHAR(10) DEFAULT 'INR',

    timezone VARCHAR(100) DEFAULT 'Asia/Kolkata',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

CREATE TRIGGER trg_clinic_settings_updated_at
BEFORE UPDATE ON clinic_settings
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
INSERT INTO clinic_settings (

clinic_name,
registration_number,
phone,
alternate_phone,
email,
city,
state,
country,
currency,
timezone

)

VALUES (

'Suriyaraja Siddha Health Care',

'8283',

'9150031833',

'9842982233',

'suriyarajasiddha@gmail.com',

'Bhavani',

'Tamil Nadu',

'India',

'INR',

'Asia/Kolkata'

)

ON CONFLICT DO NOTHING;

-- ============================================================================
-- SYSTEM SETTINGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS system_settings (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    setting_key VARCHAR(100) NOT NULL UNIQUE,

    setting_value TEXT,

    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE system_settings IS
'Stores configurable system-wide settings for SSHC ERP.';

CREATE TRIGGER trg_system_settings_updated_at
BEFORE UPDATE ON system_settings
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

INSERT INTO system_settings
(setting_key, setting_value, description)

VALUES

('patient_prefix','PAT','Patient Number Prefix'),

('op_prefix','OP','OP Number Prefix'),

('consultation_prefix','CONS','Consultation Prefix'),

('prescription_prefix','RX','Prescription Prefix'),

('invoice_prefix','INV','Invoice Prefix'),

('currency','INR','Default Currency'),

('timezone','Asia/Kolkata','System Time Zone'),

('default_language','English','Default System Language')

ON CONFLICT (setting_key) DO NOTHING;

-- ============================================================================
-- AUDIT LOGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS audit_logs (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    module_name VARCHAR(100) NOT NULL,

    table_name VARCHAR(100) NOT NULL,

    record_id UUID,

    action VARCHAR(30) NOT NULL,

    performed_by UUID,

    remarks TEXT,

    old_data JSONB,

    new_data JSONB,

    ip_address VARCHAR(100),

    user_agent TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()

);

COMMENT ON TABLE audit_logs IS
'Stores audit trail for important actions performed in SSHC ERP.';
-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_permissions_module
ON permissions(module_name);

CREATE INDEX IF NOT EXISTS idx_user_profiles_email
ON user_profiles(email);

CREATE INDEX IF NOT EXISTS idx_user_profiles_mobile
ON user_profiles(mobile_number);

CREATE INDEX IF NOT EXISTS idx_user_roles_role
ON user_roles(role_id);

CREATE INDEX IF NOT EXISTS idx_user_roles_user
ON user_roles(user_profile_id);

CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at
ON audit_logs(created_at);

COMMIT;
