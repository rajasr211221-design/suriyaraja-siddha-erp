-- ============================================================================
-- Suriyaraja Siddha Health Care ERP (SSHC ERP)
-- Migration : 12_audit_security_module.sql
-- Version   : 1.0.0
-- Database  : PostgreSQL 17 (Supabase)
-- Author    : Dr. Raja Suriyaraja & ChatGPT
--
-- Description:
-- Audit and Security module for SSHC ERP.
-- Stores audit logs, user activities,
-- login history, active sessions,
-- API access logs, security events,
-- password history, access control,
-- data change history and audit archive.
--
-- This module integrates with:
-- • User Profiles
-- • Authentication
-- • Patients
-- • Appointments
-- • Consultations
-- • Pharmacy
-- • Billing
-- • Accounts
-- • Reports
-- • Notifications
-- ============================================================================

BEGIN;

-- ============================================================================
-- AUDIT LOGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS audit_logs (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    audit_number VARCHAR(20) NOT NULL UNIQUE,

    user_id UUID,

    module_name VARCHAR(50) NOT NULL,

    table_name VARCHAR(100),

    record_id UUID,

    action_type VARCHAR(30) NOT NULL,
    -- INSERT / UPDATE / DELETE / LOGIN / LOGOUT / VIEW

    action_status VARCHAR(30) NOT NULL DEFAULT 'Success',
    -- Success / Failed

    description TEXT,

    old_values JSONB,

    new_values JSONB,

    ip_address INET,

    device_information TEXT,

    browser_information TEXT,

    operating_system VARCHAR(150),

    session_id UUID,
  
    action_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    execution_time_ms INTEGER,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_audit_logs_user
        FOREIGN KEY (user_id)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_audit_logs_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_audit_logs_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE audit_logs IS
'Stores complete audit trail of every important action performed within the SSHC ERP.';

CREATE TRIGGER trg_audit_logs_updated_at
BEFORE UPDATE ON audit_logs
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- ACTIVITY LOGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS activity_logs (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    activity_number VARCHAR(20) NOT NULL UNIQUE,

    user_id UUID,

    patient_id UUID,

    module_name VARCHAR(50) NOT NULL,

    activity_type VARCHAR(50) NOT NULL,
    -- Patient Registration / Appointment Created /
    -- Consultation Updated / Prescription Printed /
    -- Bill Generated / Payment Received / Medicine Dispensed /
    -- Report Exported / Login / Logout

    activity_title VARCHAR(200) NOT NULL,

    activity_source VARCHAR(30),
-- Web / Mobile / API / System

    activity_description TEXT,

    reference_table VARCHAR(100),

    reference_id UUID,

    activity_status VARCHAR(30) NOT NULL DEFAULT 'Completed',
    -- Pending / Completed / Failed / Cancelled

    priority VARCHAR(20) NOT NULL DEFAULT 'Normal',
    -- Low / Normal / High / Critical

    ip_address INET,

    device_information TEXT,

    browser_information TEXT,

    activity_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_activity_logs_user
        FOREIGN KEY (user_id)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_logs_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_logs_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_logs_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE activity_logs IS
'Stores user activities performed throughout the SSHC ERP including patient registration, consultations, prescriptions, billing, pharmacy, reports and other operational events.';

CREATE TRIGGER trg_activity_logs_updated_at
BEFORE UPDATE ON activity_logs
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- LOGIN HISTORY
-- ============================================================================

CREATE TABLE IF NOT EXISTS login_history (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    login_number VARCHAR(20) NOT NULL UNIQUE,

    user_id UUID NOT NULL,

    login_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    logout_time TIMESTAMPTZ,

    session_duration_minutes INTEGER,

    login_status VARCHAR(30) NOT NULL DEFAULT 'Success',
    -- Success / Failed / Locked / Expired / Logged Out

    authentication_method VARCHAR(30) DEFAULT 'Password',
    -- Password / OTP / OAuth / Magic Link

    session_id UUID,
   
    refresh_token TEXT,

    ip_address INET,

    device_information TEXT,

    browser_information TEXT,

    operating_system VARCHAR(150),

    device_type VARCHAR(50),
    -- Desktop / Mobile / Tablet

    user_agent TEXT,

    login_location VARCHAR(200),

    latitude NUMERIC(10,6),

    longitude NUMERIC(10,6),

    failure_reason TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_login_history_user
        FOREIGN KEY (user_id)
        REFERENCES user_profiles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_login_history_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_login_history_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE login_history IS
'Stores complete login and logout history including authentication method, device information, IP address, session duration and login status.';

CREATE TRIGGER trg_login_history_updated_at
BEFORE UPDATE ON login_history
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- USER SESSIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_sessions (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    session_number VARCHAR(20) NOT NULL UNIQUE,

    user_id UUID NOT NULL,

    session_token TEXT NOT NULL,

    refresh_token TEXT,

    login_history_id UUID,

    session_status VARCHAR(30) NOT NULL DEFAULT 'Active',
    -- Active / Expired / Logged Out / Revoked

    login_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    last_activity_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    expires_at TIMESTAMPTZ NOT NULL,

    logout_time TIMESTAMPTZ,

    logout_reason VARCHAR(100),
    -- User Logout / Session Expired /
    -- Admin Logout / Password Changed

    ip_address INET,

    device_information TEXT,

    browser_information TEXT,

    operating_system VARCHAR(150),

    device_type VARCHAR(50),
    -- Desktop / Mobile / Tablet

    user_agent TEXT,

    is_current_session BOOLEAN NOT NULL DEFAULT TRUE,

    is_remember_me BOOLEAN NOT NULL DEFAULT FALSE,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_user_sessions_user
        FOREIGN KEY (user_id)
        REFERENCES user_profiles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_sessions_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_user_sessions_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE user_sessions IS
'Stores active and historical user sessions including login, expiry, logout, device information and session lifecycle.';

CREATE TRIGGER trg_user_sessions_updated_at
BEFORE UPDATE ON user_sessions
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- API ACCESS LOGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS api_access_logs (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    api_log_number VARCHAR(20) NOT NULL UNIQUE,

    request_id UUID DEFAULT gen_random_uuid(),

    user_id UUID,

    session_id UUID,

    request_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    request_method VARCHAR(10) NOT NULL,
    -- GET / POST / PUT / PATCH / DELETE

    api_endpoint TEXT NOT NULL,

    module_name VARCHAR(50),

    request_headers JSONB,

    request_payload JSONB,

    response_code INTEGER,

    response_message TEXT,

    response_payload JSONB,

    execution_time_ms INTEGER,

    request_size_bytes BIGINT,

    response_size_bytes BIGINT,

    ip_address INET,

    device_information TEXT,

    browser_information TEXT,

    operating_system VARCHAR(150),

    user_agent TEXT,

    api_version VARCHAR(20),

    request_status VARCHAR(30) NOT NULL DEFAULT 'Success',
    -- Success / Failed / Unauthorized /
    -- Forbidden / Timeout / Error

    error_code VARCHAR(50),

    error_message TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_api_access_logs_user
        FOREIGN KEY (user_id)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_api_access_logs_session
        FOREIGN KEY (session_id)
        REFERENCES user_sessions(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_api_access_logs_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_api_access_logs_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE api_access_logs IS
'Stores complete API request and response logs including endpoint, request method, payload, execution time, response status and client information.';

CREATE TRIGGER trg_api_access_logs_updated_at
BEFORE UPDATE ON api_access_logs
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

  -- ============================================================================
-- SECURITY EVENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS security_events (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    security_event_number VARCHAR(20) NOT NULL UNIQUE,

    user_id UUID,

    session_id UUID,

    event_type VARCHAR(50) NOT NULL,
    -- Failed Login / Account Locked /
    -- Password Changed / Password Reset /
    -- MFA Enabled / MFA Disabled /
    -- Permission Changed / Role Changed /
    -- Suspicious Activity / API Abuse

    severity VARCHAR(20) NOT NULL DEFAULT 'Medium',
    -- Low / Medium / High / Critical

    event_status VARCHAR(30) NOT NULL DEFAULT 'Open',
    -- Open / Investigating / Resolved /
    -- Ignored / Closed

    event_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    detected_by VARCHAR(50) DEFAULT 'System',
    -- System / Admin / User

    description TEXT NOT NULL,

    affected_module VARCHAR(50),

    ip_address INET,

    device_information TEXT,

    browser_information TEXT,

    operating_system VARCHAR(150),

    user_agent TEXT,

    location VARCHAR(200),

    latitude NUMERIC(10,6),

    longitude NUMERIC(10,6),

    risk_score SMALLINT DEFAULT 0
    CHECK (risk_score BETWEEN 0 AND 100),

    action_taken TEXT,

    resolved_by UUID,

    resolved_at TIMESTAMPTZ,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_security_events_user
        FOREIGN KEY (user_id)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

   CONSTRAINT fk_security_events_session
        FOREIGN KEY (session_id)
        REFERENCES user_sessions(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_security_events_resolved_by
        FOREIGN KEY (resolved_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_security_events_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_security_events_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE security_events IS
'Stores security-related events including failed logins, account lockouts, password changes, permission changes, suspicious activities and other security incidents.';

CREATE TRIGGER trg_security_events_updated_at
BEFORE UPDATE ON security_events
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PASSWORD HISTORY
-- ============================================================================

CREATE TABLE IF NOT EXISTS password_history (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    password_history_number VARCHAR(20) NOT NULL UNIQUE,

    user_id UUID NOT NULL,

    password_hash TEXT NOT NULL,

    password_salt TEXT,

    password_changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    password_expiry_date DATE,

    change_reason VARCHAR(50),
    -- User Changed / Admin Reset /
    -- First Login / Password Expired /
    -- Security Reset

    changed_by UUID,

    password_algorithm VARCHAR(50) DEFAULT 'bcrypt',

    password_strength VARCHAR(20),
    -- Weak / Medium / Strong / Very Strong

    is_current_password BOOLEAN NOT NULL DEFAULT FALSE,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_password_history_user
        FOREIGN KEY (user_id)
        REFERENCES user_profiles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_password_history_changed_by
        FOREIGN KEY (changed_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_password_history_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_password_history_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE password_history IS
'Stores historical password hashes for users to enforce password reuse prevention, password expiry policies and security compliance.';

CREATE TRIGGER trg_password_history_updated_at
BEFORE UPDATE ON password_history
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
  
-- ============================================================================
-- ACCESS CONTROL LOGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS access_control_logs (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    access_log_number VARCHAR(20) NOT NULL UNIQUE,

    user_id UUID NOT NULL,

    session_id UUID,

    role_name VARCHAR(100),

    module_name VARCHAR(50) NOT NULL,

    page_name VARCHAR(100),

    permission_name VARCHAR(100),
    -- View / Create / Update / Delete /
    -- Approve / Print / Export

    action_type VARCHAR(30) NOT NULL,
    -- View / Create / Update / Delete /
    -- Print / Export / Login

    access_result VARCHAR(30) NOT NULL DEFAULT 'Allowed',
    -- Allowed / Denied

    access_reason TEXT,

    request_method VARCHAR(10),
    -- GET / POST / PUT / DELETE

    request_path TEXT,

    ip_address INET,

    device_information TEXT,

    browser_information TEXT,

    operating_system VARCHAR(150),

    user_agent TEXT,

    access_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    execution_time_ms INTEGER,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_access_control_logs_user
        FOREIGN KEY (user_id)
        REFERENCES user_profiles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_access_control_logs_session
        FOREIGN KEY (session_id)
        REFERENCES user_sessions(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_access_control_logs_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_access_control_logs_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE access_control_logs IS
'Stores role-based access control (RBAC) activity including module access, permission validation, allowed or denied operations and authorization history.';

CREATE TRIGGER trg_access_control_logs_updated_at
BEFORE UPDATE ON access_control_logs
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DATA CHANGE HISTORY
-- ============================================================================

CREATE TABLE IF NOT EXISTS data_change_history (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    change_number VARCHAR(20) NOT NULL UNIQUE,

    user_id UUID NOT NULL,

    module_name VARCHAR(50) NOT NULL,

    table_name VARCHAR(100) NOT NULL,

    record_id UUID NOT NULL,

    field_name VARCHAR(100) NOT NULL,

    old_value TEXT,

    new_value TEXT,

    change_type VARCHAR(30) NOT NULL,
    -- Insert / Update / Delete / Restore

    change_reason TEXT,

    approved_by UUID,

    approved_at TIMESTAMPTZ,

    change_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    ip_address INET,

    device_information TEXT,

    browser_information TEXT,

    operating_system VARCHAR(150),

    user_agent TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_data_change_history_user
        FOREIGN KEY (user_id)
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_data_change_history_approved_by
        FOREIGN KEY (approved_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_data_change_history_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_data_change_history_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE data_change_history IS
'Stores field-level audit history for every important data modification including old value, new value, user, approval and timestamp.';

CREATE TRIGGER trg_data_change_history_updated_at
BEFORE UPDATE ON data_change_history
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- AUDIT ARCHIVE
-- ============================================================================

CREATE TABLE IF NOT EXISTS audit_archive (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    archive_number VARCHAR(20) NOT NULL UNIQUE,

    source_table VARCHAR(100) NOT NULL,

    source_record_id UUID NOT NULL,

    archived_data JSONB NOT NULL,

    record_version INTEGER DEFAULT 1,

    archive_reason VARCHAR(100),
    -- Data Retention / Manual Archive /
    -- Year End / Compliance / Backup

    archive_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    archived_by UUID,

    retention_until DATE,

    restore_status VARCHAR(30) NOT NULL DEFAULT 'Archived',
    -- Archived / Restored / Permanently Deleted

    restored_by UUID,

    restored_at TIMESTAMPTZ,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_audit_archive_archived_by
        FOREIGN KEY (archived_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_audit_archive_restored_by
        FOREIGN KEY (restored_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_audit_archive_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_audit_archive_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE audit_archive IS
'Stores archived audit and security records for long-term retention, compliance and historical restoration.';

CREATE TRIGGER trg_audit_archive_updated_at
BEFORE UPDATE ON audit_archive
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- RESOLVE CIRCULAR FOREIGN KEYS
-- ============================================================================

ALTER TABLE login_history
ADD CONSTRAINT fk_login_history_session
FOREIGN KEY (session_id)
REFERENCES user_sessions(id)
ON DELETE SET NULL;

ALTER TABLE user_sessions
ADD CONSTRAINT fk_user_sessions_login_history
FOREIGN KEY (login_history_id)
REFERENCES login_history(id)
ON DELETE SET NULL;

ALTER TABLE audit_logs
ADD CONSTRAINT fk_audit_logs_session
FOREIGN KEY (session_id)
REFERENCES user_sessions(id)
ON DELETE SET NULL;

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_audit_logs_number
ON audit_logs(audit_number);

CREATE INDEX IF NOT EXISTS idx_audit_logs_user
ON audit_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_audit_logs_module
ON audit_logs(module_name);

CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp
ON audit_logs(action_timestamp);

CREATE INDEX IF NOT EXISTS idx_activity_logs_number
ON activity_logs(activity_number);

CREATE INDEX IF NOT EXISTS idx_activity_logs_user
ON activity_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_activity_logs_patient
ON activity_logs(patient_id);

CREATE INDEX IF NOT EXISTS idx_activity_logs_module
ON activity_logs(module_name);

CREATE INDEX IF NOT EXISTS idx_activity_logs_timestamp
ON activity_logs(activity_timestamp);

CREATE INDEX IF NOT EXISTS idx_login_history_number
ON login_history(login_number);

CREATE INDEX IF NOT EXISTS idx_login_history_user
ON login_history(user_id);

CREATE INDEX IF NOT EXISTS idx_login_history_login_time
ON login_history(login_time);

CREATE INDEX IF NOT EXISTS idx_login_history_status
ON login_history(login_status);

CREATE INDEX IF NOT EXISTS idx_user_sessions_number
ON user_sessions(session_number);

CREATE INDEX IF NOT EXISTS idx_user_sessions_user
ON user_sessions(user_id);

CREATE INDEX IF NOT EXISTS idx_user_sessions_status
ON user_sessions(session_status);

CREATE INDEX IF NOT EXISTS idx_user_sessions_expiry
ON user_sessions(expires_at);

CREATE INDEX IF NOT EXISTS idx_api_access_logs_number
ON api_access_logs(api_log_number);

CREATE INDEX IF NOT EXISTS idx_api_access_logs_user
ON api_access_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_api_access_logs_endpoint
ON api_access_logs(api_endpoint);

CREATE INDEX IF NOT EXISTS idx_api_access_logs_timestamp
ON api_access_logs(request_timestamp);

CREATE INDEX IF NOT EXISTS idx_security_events_number
ON security_events(security_event_number);

CREATE INDEX IF NOT EXISTS idx_security_events_user
ON security_events(user_id);

CREATE INDEX IF NOT EXISTS idx_security_events_type
ON security_events(event_type);

CREATE INDEX IF NOT EXISTS idx_security_events_severity
ON security_events(severity);

CREATE INDEX IF NOT EXISTS idx_security_events_timestamp
ON security_events(event_timestamp);

CREATE INDEX IF NOT EXISTS idx_password_history_number
ON password_history(password_history_number);

CREATE INDEX IF NOT EXISTS idx_password_history_user
ON password_history(user_id);

CREATE INDEX IF NOT EXISTS idx_access_control_logs_number
ON access_control_logs(access_log_number);

CREATE INDEX IF NOT EXISTS idx_access_control_logs_user
ON access_control_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_access_control_logs_module
ON access_control_logs(module_name);

CREATE INDEX IF NOT EXISTS idx_access_control_logs_timestamp
ON access_control_logs(access_timestamp);

CREATE INDEX IF NOT EXISTS idx_data_change_history_number
ON data_change_history(change_number);

CREATE INDEX IF NOT EXISTS idx_data_change_history_user
ON data_change_history(user_id);

CREATE INDEX IF NOT EXISTS idx_data_change_history_table
ON data_change_history(table_name);

CREATE INDEX IF NOT EXISTS idx_data_change_history_record
ON data_change_history(record_id);

CREATE INDEX IF NOT EXISTS idx_data_change_history_timestamp
ON data_change_history(change_timestamp);

CREATE INDEX IF NOT EXISTS idx_audit_archive_number
ON audit_archive(archive_number);

CREATE INDEX IF NOT EXISTS idx_audit_archive_source_table
ON audit_archive(source_table);

CREATE INDEX IF NOT EXISTS idx_audit_archive_archive_date
ON audit_archive(archive_date);

CREATE INDEX IF NOT EXISTS idx_audit_archive_retention
ON audit_archive(retention_until);

CREATE INDEX IF NOT EXISTS idx_audit_logs_table
ON audit_logs(table_name);

CREATE INDEX IF NOT EXISTS idx_api_access_logs_status
ON api_access_logs(request_status);

CREATE INDEX IF NOT EXISTS idx_security_events_status
ON security_events(event_status);

CREATE INDEX IF NOT EXISTS idx_security_events_module
ON security_events(affected_module);

CREATE INDEX IF NOT EXISTS idx_activity_logs_reference
ON activity_logs(reference_id);

CREATE INDEX IF NOT EXISTS idx_user_sessions_last_activity
ON user_sessions(last_activity_at);

CREATE UNIQUE INDEX IF NOT EXISTS idx_api_access_logs_request_id
ON api_access_logs(request_id);

CREATE INDEX IF NOT EXISTS idx_audit_logs_session
ON audit_logs(session_id);

CREATE INDEX IF NOT EXISTS idx_api_access_logs_session
ON api_access_logs(session_id);

CREATE INDEX IF NOT EXISTS idx_security_events_session
ON security_events(session_id);

CREATE INDEX IF NOT EXISTS idx_access_control_logs_session
ON access_control_logs(session_id);

COMMIT;
