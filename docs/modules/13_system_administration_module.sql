-- ============================================================================
-- Suriyaraja Siddha Health Care ERP (SSHC ERP)
-- Migration : 13_system_administration_module.sql
-- Version   : 1.0.0
-- Database  : PostgreSQL 17 (Supabase)
-- Author    : Dr. Raja Suriyaraja & ChatGPT
--
-- Description:
-- System Administration module for SSHC ERP.
-- Stores role-based access control (RBAC),
-- clinic configuration,
-- numbering sequences,
-- departments,
-- working hours,
-- holidays,
-- backup settings,
-- theme settings,
-- application settings,
-- and other global administrative configurations.
--
-- This module integrates with:
-- • User Profiles
-- • Audit & Security
-- • Patients
-- • Appointments
-- • Consultations
-- • Prescriptions
-- • Pharmacy
-- • Billing
-- • Accounts
-- • Reports
-- • Notifications
-- ============================================================================

BEGIN;

-- ============================================================================
-- ROLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS roles (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    role_code VARCHAR(20) NOT NULL UNIQUE,

    role_name VARCHAR(100) NOT NULL UNIQUE,

    role_description TEXT,

    role_level INTEGER NOT NULL DEFAULT 1,
    -- Higher value = Higher privilege

    role_type VARCHAR(30) NOT NULL DEFAULT 'System',
    -- System / Custom

    is_default BOOLEAN NOT NULL DEFAULT FALSE,

    display_order INTEGER NOT NULL DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_roles_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_roles_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE roles IS
'Stores system and custom user roles used for Role-Based Access Control (RBAC) throughout the SSHC ERP.';

CREATE TRIGGER trg_roles_updated_at
BEFORE UPDATE ON roles
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PERMISSIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS permissions (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    permission_code VARCHAR(50) NOT NULL UNIQUE,

    permission_name VARCHAR(150) NOT NULL,

    permission_description TEXT,

    module_name VARCHAR(50) NOT NULL,
    -- Patients / Consultations / Pharmacy /
    -- Billing / Reports / Settings / etc.

    permission_group VARCHAR(50),
    -- View / Create / Update / Delete /
    -- Print / Export / Approve / Manage

    permission_type VARCHAR(30) NOT NULL DEFAULT 'System',
    -- System / Custom

    display_order INTEGER NOT NULL DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_permissions_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_permissions_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE permissions IS
'Stores all system permissions used for Role-Based Access Control (RBAC) across every module of the SSHC ERP.';

CREATE TRIGGER trg_permissions_updated_at
BEFORE UPDATE ON permissions
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- ROLE PERMISSIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS role_permissions (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    role_id UUID NOT NULL,

    permission_id UUID NOT NULL,

    is_allowed BOOLEAN NOT NULL DEFAULT TRUE,

    granted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    granted_by UUID,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_role_permissions_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_role_permissions_permission
        FOREIGN KEY (permission_id)
        REFERENCES permissions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_role_permissions_granted_by
        FOREIGN KEY (granted_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_role_permissions_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_role_permissions_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT uq_role_permissions
        UNIQUE (role_id, permission_id)

);

COMMENT ON TABLE role_permissions IS
'Maps roles to permissions for implementing Role-Based Access Control (RBAC) within the SSHC ERP.';

CREATE TRIGGER trg_role_permissions_updated_at
BEFORE UPDATE ON role_permissions
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- USER ROLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_roles (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    role_id UUID NOT NULL,

    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    assigned_by UUID,

    valid_from DATE DEFAULT CURRENT_DATE,

    valid_until DATE,

    is_primary_role BOOLEAN NOT NULL DEFAULT FALSE,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_user_roles_user
        FOREIGN KEY (user_id)
        REFERENCES user_profiles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_roles_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_roles_assigned_by
        FOREIGN KEY (assigned_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_user_roles_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_user_roles_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT uq_user_roles
        UNIQUE (user_id, role_id)

);

COMMENT ON TABLE user_roles IS
'Stores role assignments for users. Supports multiple roles per user and identifies the primary role used within the SSHC ERP.';

CREATE TRIGGER trg_user_roles_updated_at
BEFORE UPDATE ON user_roles
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- CLINIC SETTINGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS clinic_settings (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    clinic_code VARCHAR(20) NOT NULL UNIQUE,

    clinic_name VARCHAR(200) NOT NULL,

    clinic_tagline VARCHAR(300),

    registration_number VARCHAR(50),

    license_number VARCHAR(100),

    gst_number VARCHAR(30),

    address_line_1 VARCHAR(250),

    address_line_2 VARCHAR(250),

    city VARCHAR(100),

    district VARCHAR(100),

    state VARCHAR(100),

    country VARCHAR(100) DEFAULT 'India',

    postal_code VARCHAR(20),

    phone_number VARCHAR(20),

    alternate_phone VARCHAR(20),

    whatsapp_number VARCHAR(20),

    email VARCHAR(200),

    website VARCHAR(200),

    logo_url TEXT,

    digital_signature_url TEXT,

    prescription_footer TEXT,

    receipt_footer TEXT,

    invoice_footer TEXT,

    consultation_duration_minutes INTEGER DEFAULT 15,

    currency_code VARCHAR(10) DEFAULT 'INR',

    timezone VARCHAR(100) DEFAULT 'Asia/Kolkata',

    language_code VARCHAR(10) DEFAULT 'en',

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_clinic_settings_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_clinic_settings_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE clinic_settings IS
'Stores global clinic information including registration details, contact information, branding, prescription settings and default application configuration.';

CREATE TRIGGER trg_clinic_settings_updated_at
BEFORE UPDATE ON clinic_settings
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- NUMBERING SEQUENCES
-- ============================================================================

CREATE TABLE IF NOT EXISTS numbering_sequences (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    sequence_code VARCHAR(30) NOT NULL UNIQUE,
    -- PATIENT / OPD / CONSULTATION /
    -- PRESCRIPTION / BILL / PAYMENT /
    -- PURCHASE / STOCK / REPORT

    sequence_name VARCHAR(100) NOT NULL,

    prefix VARCHAR(20) NOT NULL,

    suffix VARCHAR(20),

    separator VARCHAR(5) DEFAULT '',

    current_number BIGINT NOT NULL DEFAULT 0,

    increment_by INTEGER NOT NULL DEFAULT 1,

    minimum_digits INTEGER NOT NULL DEFAULT 6,

    reset_policy VARCHAR(20) NOT NULL DEFAULT 'Never',
    -- Never / Daily / Monthly / Yearly

    last_reset_date DATE,

    next_reset_date DATE,

    starting_number BIGINT NOT NULL DEFAULT 1,

    maximum_number BIGINT,

    is_auto_generate BOOLEAN NOT NULL DEFAULT TRUE,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_numbering_sequences_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_numbering_sequences_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE numbering_sequences IS
'Stores configurable auto-numbering sequences used throughout the SSHC ERP for patients, consultations, prescriptions, billing, pharmacy and other modules.';

CREATE TRIGGER trg_numbering_sequences_updated_at
BEFORE UPDATE ON numbering_sequences
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DEPARTMENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS departments (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    department_code VARCHAR(20) NOT NULL UNIQUE,

    department_name VARCHAR(150) NOT NULL UNIQUE,

    department_type VARCHAR(50) NOT NULL,
    -- Clinical / Administrative / Support

    department_head UUID,

    description TEXT,

    location VARCHAR(150),

    contact_number VARCHAR(20),

    email VARCHAR(200),

    consultation_fee NUMERIC(10,2),

    display_order INTEGER NOT NULL DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_departments_head
        FOREIGN KEY (department_head)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_departments_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_departments_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE departments IS
'Stores clinic departments used for organizing consultations, pharmacy, therapy, billing, administration and staff assignments within the SSHC ERP.';

CREATE TRIGGER trg_departments_updated_at
BEFORE UPDATE ON departments
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- WORKING HOURS
-- ============================================================================

CREATE TABLE IF NOT EXISTS working_hours (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    day_of_week VARCHAR(15) NOT NULL,
    -- Monday / Tuesday / Wednesday /
    -- Thursday / Friday / Saturday / Sunday

    department_id UUID,

    opening_time TIME NOT NULL,

    closing_time TIME NOT NULL,

    lunch_break_start TIME,

    lunch_break_end TIME,

    consultation_start_time TIME,

    consultation_end_time TIME,

    slot_duration_minutes INTEGER NOT NULL DEFAULT 15,

    maximum_patients_per_day INTEGER,

    is_working_day BOOLEAN NOT NULL DEFAULT TRUE,

    is_emergency_service BOOLEAN NOT NULL DEFAULT FALSE,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_working_hours_department
        FOREIGN KEY (department_id)
        REFERENCES departments(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_working_hours_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_working_hours_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT uq_working_hours
        UNIQUE (day_of_week, department_id),

    CONSTRAINT chk_working_hours_time
        CHECK (opening_time < closing_time)

);

COMMENT ON TABLE working_hours IS
'Stores clinic and department working schedules including consultation hours, lunch breaks, appointment slot duration and emergency service availability.';

CREATE TRIGGER trg_working_hours_updated_at
BEFORE UPDATE ON working_hours
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- HOLIDAYS
-- ============================================================================

CREATE TABLE IF NOT EXISTS holidays (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    holiday_code VARCHAR(20) NOT NULL UNIQUE,

    holiday_name VARCHAR(150) NOT NULL,

    holiday_date DATE NOT NULL,

    holiday_type VARCHAR(30) NOT NULL DEFAULT 'Public',
    -- Public / Clinic / National / Festival / Emergency

    department_id UUID,
    -- NULL = Applies to entire clinic

    is_recurring BOOLEAN NOT NULL DEFAULT TRUE,

    recurrence_type VARCHAR(20),
    -- Yearly / Monthly / None

    is_paid_holiday BOOLEAN NOT NULL DEFAULT FALSE,

    description TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT chk_holidays_recurrence
    CHECK (recurrence_type IN ('Yearly','Monthly','None')),
    
    CONSTRAINT fk_holidays_department
        FOREIGN KEY (department_id)
        REFERENCES departments(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_holidays_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_holidays_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE holidays IS
'Stores public holidays, clinic holidays, festival holidays and emergency closures used for appointment scheduling and staff availability.';

CREATE TRIGGER trg_holidays_updated_at
BEFORE UPDATE ON holidays
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- BACKUP SETTINGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS backup_settings (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    backup_code VARCHAR(20) NOT NULL UNIQUE,

    backup_name VARCHAR(150) NOT NULL,

    backup_type VARCHAR(30) NOT NULL,
    -- Full / Incremental / Differential

    backup_frequency VARCHAR(20) NOT NULL,
    -- Hourly / Daily / Weekly / Monthly

    backup_time TIME,

    storage_provider VARCHAR(50),
    -- Local / Supabase / AWS S3 / Google Cloud /
    -- Azure / External Storage

    storage_location TEXT,

    retention_days INTEGER NOT NULL DEFAULT 30,

    maximum_backups INTEGER DEFAULT 30,

    compression_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    encryption_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    encryption_algorithm VARCHAR(50),

    auto_backup_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    backup_status VARCHAR(30) NOT NULL DEFAULT 'Active',
    -- Active / Inactive / Suspended

    last_backup_at TIMESTAMPTZ,

    next_backup_at TIMESTAMPTZ,

    last_backup_status VARCHAR(30),
    -- Success / Failed / Partial

    last_backup_size_mb NUMERIC(12,2),

    last_error_message TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_backup_settings_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_backup_settings_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_backup_frequency
    CHECK (
    backup_frequency IN ('Hourly','Daily','Weekly','Monthly')
)

);

COMMENT ON TABLE backup_settings IS
'Stores database backup schedules, storage configuration, retention policies, encryption settings and backup history configuration for SSHC ERP.';

CREATE TRIGGER trg_backup_settings_updated_at
BEFORE UPDATE ON backup_settings
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- THEME SETTINGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS theme_settings (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    theme_code VARCHAR(20) NOT NULL UNIQUE,

    theme_name VARCHAR(100) NOT NULL,

    theme_mode VARCHAR(20) NOT NULL DEFAULT 'Light',
    -- Light / Dark / Auto

    primary_color VARCHAR(20) NOT NULL DEFAULT '#2E7D32',

    secondary_color VARCHAR(20) DEFAULT '#4CAF50',

    accent_color VARCHAR(20) DEFAULT '#FFC107',

    background_color VARCHAR(20),

    text_color VARCHAR(20),

    sidebar_color VARCHAR(20),

    header_color VARCHAR(20),

    font_family VARCHAR(100) DEFAULT 'Inter',

    font_size VARCHAR(20) DEFAULT 'Medium',
    -- Small / Medium / Large

    border_radius INTEGER DEFAULT 8,

    compact_mode BOOLEAN NOT NULL DEFAULT FALSE,

    animations_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    logo_url TEXT,

    favicon_url TEXT,

    login_background_url TEXT,

    default_theme BOOLEAN NOT NULL DEFAULT FALSE,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT chk_theme_mode
    CHECK (theme_mode IN ('Light','Dark','Auto')),
    
    CONSTRAINT fk_theme_settings_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_theme_settings_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE theme_settings IS
'Stores UI themes, branding, colors, typography and visual customization settings for the SSHC ERP.';

CREATE TRIGGER trg_theme_settings_updated_at
BEFORE UPDATE ON theme_settings
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- APPLICATION SETTINGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS application_settings (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    setting_code VARCHAR(50) NOT NULL UNIQUE,

    setting_name VARCHAR(150) NOT NULL,

    setting_category VARCHAR(50) NOT NULL,
    -- General / Authentication / Billing /
    -- Pharmacy / Notification / Security /
    -- Appointment / Reports / System

    setting_value TEXT,

    default_value TEXT,

    data_type VARCHAR(30) NOT NULL,
    -- String / Integer / Decimal /
    -- Boolean / JSON / Date / Time

    description TEXT,

    validation_rule TEXT,

    is_editable BOOLEAN NOT NULL DEFAULT TRUE,

    requires_restart BOOLEAN NOT NULL DEFAULT FALSE,

    display_order INTEGER NOT NULL DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT chk_application_data_type
CHECK (
    data_type IN (
        'String',
        'Integer',
        'Decimal',
        'Boolean',
        'JSON',
        'Date',
        'Time'
    )
),
    CONSTRAINT fk_application_settings_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_application_settings_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE application_settings IS
'Stores global application configuration including authentication, billing, notifications, pharmacy, appointments, reporting and system-wide settings for the SSHC ERP.';

CREATE TRIGGER trg_application_settings_updated_at
BEFORE UPDATE ON application_settings
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_roles_code
ON roles(role_code);

CREATE INDEX IF NOT EXISTS idx_roles_name
ON roles(role_name);

CREATE INDEX IF NOT EXISTS idx_roles_type
ON roles(role_type);

CREATE INDEX IF NOT EXISTS idx_roles_active
ON roles(is_active);

CREATE INDEX IF NOT EXISTS idx_permissions_code
ON permissions(permission_code);

CREATE INDEX IF NOT EXISTS idx_permissions_module
ON permissions(module_name);

CREATE INDEX IF NOT EXISTS idx_permissions_group
ON permissions(permission_group);

CREATE INDEX IF NOT EXISTS idx_permissions_active
ON permissions(is_active);

CREATE INDEX IF NOT EXISTS idx_role_permissions_role
ON role_permissions(role_id);

CREATE INDEX IF NOT EXISTS idx_role_permissions_permission
ON role_permissions(permission_id);

CREATE INDEX IF NOT EXISTS idx_role_permissions_allowed
ON role_permissions(is_allowed);

CREATE INDEX IF NOT EXISTS idx_user_roles_user
ON user_roles(user_id);

CREATE INDEX IF NOT EXISTS idx_user_roles_role
ON user_roles(role_id);

CREATE INDEX IF NOT EXISTS idx_user_roles_primary
ON user_roles(is_primary_role);

CREATE INDEX IF NOT EXISTS idx_clinic_settings_code
ON clinic_settings(clinic_code);

CREATE INDEX IF NOT EXISTS idx_clinic_settings_name
ON clinic_settings(clinic_name);

CREATE INDEX IF NOT EXISTS idx_numbering_sequences_code
ON numbering_sequences(sequence_code);

CREATE INDEX IF NOT EXISTS idx_numbering_sequences_active
ON numbering_sequences(is_active);

CREATE INDEX IF NOT EXISTS idx_departments_code
ON departments(department_code);

CREATE INDEX IF NOT EXISTS idx_departments_name
ON departments(department_name);

CREATE INDEX IF NOT EXISTS idx_departments_type
ON departments(department_type);

CREATE INDEX IF NOT EXISTS idx_working_hours_day
ON working_hours(day_of_week);

CREATE INDEX IF NOT EXISTS idx_working_hours_department
ON working_hours(department_id);

CREATE INDEX IF NOT EXISTS idx_working_hours_working_day
ON working_hours(is_working_day);

CREATE INDEX IF NOT EXISTS idx_holidays_code
ON holidays(holiday_code);

CREATE INDEX IF NOT EXISTS idx_holidays_date
ON holidays(holiday_date);

CREATE INDEX IF NOT EXISTS idx_holidays_department
ON holidays(department_id);

CREATE INDEX IF NOT EXISTS idx_holidays_type
ON holidays(holiday_type);

CREATE INDEX IF NOT EXISTS idx_backup_settings_code
ON backup_settings(backup_code);

CREATE INDEX IF NOT EXISTS idx_backup_settings_frequency
ON backup_settings(backup_frequency);

CREATE INDEX IF NOT EXISTS idx_backup_settings_status
ON backup_settings(backup_status);

CREATE INDEX IF NOT EXISTS idx_theme_settings_code
ON theme_settings(theme_code);

CREATE INDEX IF NOT EXISTS idx_theme_settings_name
ON theme_settings(theme_name);

CREATE INDEX IF NOT EXISTS idx_theme_settings_default
ON theme_settings(default_theme);

CREATE INDEX IF NOT EXISTS idx_application_settings_code
ON application_settings(setting_code);

CREATE INDEX IF NOT EXISTS idx_application_settings_category
ON application_settings(setting_category);

CREATE INDEX IF NOT EXISTS idx_application_settings_active
ON application_settings(is_active);

COMMIT;
