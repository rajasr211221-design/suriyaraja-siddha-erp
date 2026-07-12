-- ============================================================================
-- Suriyaraja Siddha Health Care ERP (SSHC ERP)
-- Migration : 10_reports_module.sql
-- Version   : 1.0.0
-- Database  : PostgreSQL 17 (Supabase)
-- Author    : Dr. Raja Suriyaraja & ChatGPT
--
-- Description:
-- Reports and Analytics module for SSHC ERP.
-- Stores reusable report templates,
-- generated reports, report exports,
-- scheduled reports, dashboard snapshots,
-- analytics cache, report sharing
-- and report audit history.
--
-- This module integrates with:
-- • Patients
-- • OP Registration
-- • Consultations
-- • Prescriptions
-- • Pharmacy
-- • Billing
-- • Accounts
-- • User Profiles
-- ============================================================================

BEGIN;

-- ============================================================================
-- REPORT TEMPLATES
-- ============================================================================

CREATE TABLE IF NOT EXISTS report_templates (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    report_code VARCHAR(20) NOT NULL UNIQUE,

    report_name VARCHAR(200) NOT NULL,

    report_category VARCHAR(50) NOT NULL,

    report_description TEXT,

    report_type VARCHAR(30) NOT NULL DEFAULT 'Standard',

    module_name VARCHAR(50) NOT NULL,

    report_definition JSONB,

    default_filters JSONB,

    output_formats VARCHAR(200),

    is_system BOOLEAN NOT NULL DEFAULT FALSE,

    is_favorite BOOLEAN NOT NULL DEFAULT FALSE,

    display_order INTEGER DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_report_templates_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_report_templates_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE report_templates IS
'Stores reusable report templates for operational, clinical, pharmacy, billing and financial reports.';

CREATE TRIGGER trg_report_templates_updated_at
BEFORE UPDATE ON report_templates
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- GENERATED REPORTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS generated_reports (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    report_number VARCHAR(20) NOT NULL UNIQUE,

    report_template_id UUID NOT NULL,

    report_name VARCHAR(200) NOT NULL,

    report_category VARCHAR(50),

    report_type VARCHAR(30),

    module_name VARCHAR(50),

    generated_by UUID NOT NULL,

    report_status VARCHAR(30) NOT NULL DEFAULT 'Completed',

    report_format VARCHAR(20) NOT NULL DEFAULT 'PDF',

    report_parameters JSONB,

    filters_applied JSONB,

    date_from DATE,

    date_to DATE,

    total_records INTEGER DEFAULT 0,

    generation_time_ms INTEGER,

    file_name VARCHAR(255),

    file_path TEXT,

    file_size_kb NUMERIC(12,2),

    file_size_bytes BIGINT,

    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    completed_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_generated_reports_template
        FOREIGN KEY (report_template_id)
        REFERENCES report_templates(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_generated_reports_generated_by
        FOREIGN KEY (generated_by)
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_generated_reports_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_generated_reports_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE generated_reports IS
'Stores all reports generated from report templates including filters, output files and generation history.';

CREATE TRIGGER trg_generated_reports_updated_at
BEFORE UPDATE ON generated_reports
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- REPORT EXPORTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS report_exports (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    export_number VARCHAR(20) NOT NULL UNIQUE,

    generated_report_id UUID NOT NULL,

    export_format VARCHAR(20) NOT NULL,
    -- PDF / Excel / CSV / JSON / Print

    exported_by UUID NOT NULL,

    file_name VARCHAR(255),

    file_path TEXT,

    file_size_kb NUMERIC(12,2),

    download_count INTEGER NOT NULL DEFAULT 0,

    last_downloaded_at TIMESTAMPTZ,

    export_status VARCHAR(30) NOT NULL DEFAULT 'Completed',
    -- Pending / Completed / Failed

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_report_exports_generated_report
        FOREIGN KEY (generated_report_id)
        REFERENCES generated_reports(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_report_exports_exported_by
        FOREIGN KEY (exported_by)
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_report_exports_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_report_exports_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE report_exports IS
'Stores exported report files including PDF, Excel, CSV, JSON and print history.';

CREATE TRIGGER trg_report_exports_updated_at
BEFORE UPDATE ON report_exports
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- SCHEDULED REPORTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS scheduled_reports (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    schedule_number VARCHAR(20) NOT NULL UNIQUE,

    report_template_id UUID NOT NULL,

    schedule_name VARCHAR(200) NOT NULL,

    report_format VARCHAR(20) NOT NULL DEFAULT 'PDF',

    frequency VARCHAR(30) NOT NULL,
    -- Daily / Weekly / Monthly / Quarterly / Yearly

    run_time TIME,

    start_date DATE,

    end_date DATE,

    last_run_at TIMESTAMPTZ,

    next_run_at TIMESTAMPTZ,

    last_run_status VARCHAR(30),

    last_generated_report_id UUID,

    email_recipients TEXT,

    is_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    schedule_status VARCHAR(30) NOT NULL DEFAULT 'Active',
    -- Active / Paused / Completed

    created_by UUID,

    updated_by UUID,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_scheduled_reports_template
        FOREIGN KEY (report_template_id)
        REFERENCES report_templates(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_scheduled_reports_generated_report
        FOREIGN KEY (last_generated_report_id)
        REFERENCES generated_reports(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_scheduled_reports_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_scheduled_reports_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE scheduled_reports IS
'Stores scheduled automatic report generation settings including frequency, timing and delivery details.';

CREATE TRIGGER trg_scheduled_reports_updated_at
BEFORE UPDATE ON scheduled_reports
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DASHBOARD SNAPSHOTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS dashboard_snapshots (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    snapshot_number VARCHAR(20) NOT NULL UNIQUE,

    snapshot_date DATE NOT NULL DEFAULT CURRENT_DATE,

    snapshot_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    total_patients INTEGER NOT NULL DEFAULT 0,

    new_patients INTEGER NOT NULL DEFAULT 0,

    active_patients INTEGER NOT NULL DEFAULT 0,

    consultations INTEGER NOT NULL DEFAULT 0,

    prescriptions INTEGER NOT NULL DEFAULT 0,

    appointments INTEGER NOT NULL DEFAULT 0,

    completed_appointments INTEGER NOT NULL DEFAULT 0,

    cancelled_appointments INTEGER NOT NULL DEFAULT 0,

    pharmacy_sales NUMERIC(12,2) NOT NULL DEFAULT 0,

    consultation_income NUMERIC(12,2) NOT NULL DEFAULT 0,

    therapy_income NUMERIC(12,2) NOT NULL DEFAULT 0,

    total_income NUMERIC(12,2) NOT NULL DEFAULT 0,

    total_expenses NUMERIC(12,2) NOT NULL DEFAULT 0,

    net_profit NUMERIC(12,2) NOT NULL DEFAULT 0,

    pending_followups INTEGER NOT NULL DEFAULT 0,

    low_stock_items INTEGER NOT NULL DEFAULT 0,

    expiring_medicines INTEGER NOT NULL DEFAULT 0,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_dashboard_snapshots_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_dashboard_snapshots_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE dashboard_snapshots IS
'Stores historical dashboard statistics for trend analysis and business reporting.';

CREATE TRIGGER trg_dashboard_snapshots_updated_at
BEFORE UPDATE ON dashboard_snapshots
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- ANALYTICS CACHE
-- ============================================================================

CREATE TABLE IF NOT EXISTS analytics_cache (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    cache_key VARCHAR(150) NOT NULL UNIQUE,

    analytics_category VARCHAR(50) NOT NULL,

    analytics_name VARCHAR(150) NOT NULL,

    module_name VARCHAR(50),

    cache_data JSONB NOT NULL,

    date_from DATE,

    date_to DATE,

    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    expires_at TIMESTAMPTZ,

    refresh_interval_minutes INTEGER DEFAULT 60,

    cache_version INTEGER DEFAULT 1,

    cache_status VARCHAR(30) NOT NULL DEFAULT 'Active',

    generated_by UUID,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_analytics_cache_generated_by
        FOREIGN KEY (generated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_analytics_cache_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_analytics_cache_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE analytics_cache IS
'Stores precomputed analytics and dashboard data to improve reporting and dashboard performance.';

CREATE TRIGGER trg_analytics_cache_updated_at
BEFORE UPDATE ON analytics_cache
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- REPORT SHARES
-- ============================================================================

CREATE TABLE IF NOT EXISTS report_shares (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    share_number VARCHAR(20) NOT NULL UNIQUE,

    generated_report_id UUID NOT NULL,

    shared_by UUID NOT NULL,

    shared_with UUID,

    recipient_name VARCHAR(200),

    recipient_email VARCHAR(200),

    recipient_mobile VARCHAR(20),

    share_method VARCHAR(30) NOT NULL,
    -- Email / WhatsApp / SMS / Download Link / Print

    access_token VARCHAR(255),

    access_password VARCHAR(255),

    shared_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    expires_at TIMESTAMPTZ,

    access_count INTEGER NOT NULL DEFAULT 0,

    last_accessed_at TIMESTAMPTZ,

    share_status VARCHAR(30) NOT NULL DEFAULT 'Active',
    -- Active / Expired / Revoked

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_report_shares_generated_report
        FOREIGN KEY (generated_report_id)
        REFERENCES generated_reports(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_report_shares_shared_by
        FOREIGN KEY (shared_by)
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_report_shares_shared_with
        FOREIGN KEY (shared_with)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_report_shares_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_report_shares_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE report_shares IS
'Stores report sharing history including email, WhatsApp, SMS, download links and recipient access details.';

CREATE TRIGGER trg_report_shares_updated_at
BEFORE UPDATE ON report_shares
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- REPORT AUDIT LOGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS report_audit_logs (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    audit_number VARCHAR(20) NOT NULL UNIQUE,

    report_template_id UUID,

    generated_report_id UUID,

    user_id UUID NOT NULL,

    action_type VARCHAR(50) NOT NULL,
    -- Generate / Export / View / Print / Share / Delete / Download

    action_status VARCHAR(30) NOT NULL DEFAULT 'Success',
    -- Success / Failed

    ip_address INET,

    device_information TEXT,

    browser_information TEXT,

    operating_system VARCHAR(150),

    action_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    execution_time_ms INTEGER,

    response_code INTEGER,
    
    additional_data JSONB,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_report_audit_template
        FOREIGN KEY (report_template_id)
        REFERENCES report_templates(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_report_audit_generated_report
        FOREIGN KEY (generated_report_id)
        REFERENCES generated_reports(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_report_audit_user
        FOREIGN KEY (user_id)
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_report_audit_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_report_audit_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE report_audit_logs IS
'Stores complete audit trail for report generation, viewing, exporting, downloading, printing and sharing activities.';

CREATE TRIGGER trg_report_audit_logs_updated_at
BEFORE UPDATE ON report_audit_logs
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_report_templates_code
ON report_templates(report_code);

CREATE INDEX IF NOT EXISTS idx_report_templates_name
ON report_templates(report_name);

CREATE INDEX IF NOT EXISTS idx_report_templates_category
ON report_templates(report_category);

CREATE INDEX IF NOT EXISTS idx_report_templates_module
ON report_templates(module_name);

CREATE INDEX IF NOT EXISTS idx_report_templates_system
ON report_templates(is_system);

CREATE INDEX IF NOT EXISTS idx_generated_reports_number
ON generated_reports(report_number);

CREATE INDEX IF NOT EXISTS idx_generated_reports_template
ON generated_reports(report_template_id);

CREATE INDEX IF NOT EXISTS idx_generated_reports_generated_by
ON generated_reports(generated_by);

CREATE INDEX IF NOT EXISTS idx_generated_reports_category
ON generated_reports(report_category);

CREATE INDEX IF NOT EXISTS idx_generated_reports_module
ON generated_reports(module_name);

CREATE INDEX IF NOT EXISTS idx_generated_reports_status
ON generated_reports(report_status);

CREATE INDEX IF NOT EXISTS idx_generated_reports_format
ON generated_reports(report_format);

CREATE INDEX IF NOT EXISTS idx_generated_reports_generated_at
ON generated_reports(generated_at);

CREATE INDEX IF NOT EXISTS idx_report_exports_number
ON report_exports(export_number);

CREATE INDEX IF NOT EXISTS idx_report_exports_report
ON report_exports(generated_report_id);

CREATE INDEX IF NOT EXISTS idx_report_exports_format
ON report_exports(export_format);

CREATE INDEX IF NOT EXISTS idx_report_exports_exported_by
ON report_exports(exported_by);

CREATE INDEX IF NOT EXISTS idx_report_exports_status
ON report_exports(export_status);

CREATE INDEX IF NOT EXISTS idx_scheduled_reports_number
ON scheduled_reports(schedule_number);

CREATE INDEX IF NOT EXISTS idx_scheduled_reports_template
ON scheduled_reports(report_template_id);

CREATE INDEX IF NOT EXISTS idx_scheduled_reports_status
ON scheduled_reports(schedule_status);

CREATE INDEX IF NOT EXISTS idx_scheduled_reports_enabled
ON scheduled_reports(is_enabled);

CREATE INDEX IF NOT EXISTS idx_scheduled_reports_next_run
ON scheduled_reports(next_run_at);

CREATE INDEX IF NOT EXISTS idx_dashboard_snapshots_number
ON dashboard_snapshots(snapshot_number);

CREATE INDEX IF NOT EXISTS idx_dashboard_snapshots_date
ON dashboard_snapshots(snapshot_date);

CREATE INDEX IF NOT EXISTS idx_dashboard_snapshots_created_at
ON dashboard_snapshots(created_at);

CREATE INDEX IF NOT EXISTS idx_analytics_cache_key
ON analytics_cache(cache_key);

CREATE INDEX IF NOT EXISTS idx_analytics_cache_category
ON analytics_cache(analytics_category);

CREATE INDEX IF NOT EXISTS idx_analytics_cache_module
ON analytics_cache(module_name);

CREATE INDEX IF NOT EXISTS idx_analytics_cache_status
ON analytics_cache(cache_status);

CREATE INDEX IF NOT EXISTS idx_analytics_cache_expires
ON analytics_cache(expires_at);

CREATE INDEX IF NOT EXISTS idx_report_shares_number
ON report_shares(share_number);

CREATE INDEX IF NOT EXISTS idx_report_shares_report
ON report_shares(generated_report_id);

CREATE INDEX IF NOT EXISTS idx_report_shares_shared_by
ON report_shares(shared_by);

CREATE INDEX IF NOT EXISTS idx_report_shares_shared_with
ON report_shares(shared_with);

CREATE INDEX IF NOT EXISTS idx_report_shares_status
ON report_shares(share_status);

CREATE INDEX IF NOT EXISTS idx_report_shares_shared_at
ON report_shares(shared_at);

CREATE INDEX IF NOT EXISTS idx_report_audit_number
ON report_audit_logs(audit_number);

CREATE INDEX IF NOT EXISTS idx_report_audit_template
ON report_audit_logs(report_template_id);

CREATE INDEX IF NOT EXISTS idx_report_audit_generated_report
ON report_audit_logs(generated_report_id);

CREATE INDEX IF NOT EXISTS idx_report_audit_user
ON report_audit_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_report_audit_action
ON report_audit_logs(action_type);

CREATE INDEX IF NOT EXISTS idx_report_audit_status
ON report_audit_logs(action_status);

CREATE INDEX IF NOT EXISTS idx_report_audit_timestamp
ON report_audit_logs(action_timestamp);

CREATE INDEX IF NOT EXISTS idx_generated_reports_date_range
ON generated_reports(date_from, date_to);

CREATE INDEX IF NOT EXISTS idx_dashboard_snapshots_profit
ON dashboard_snapshots(net_profit);

CREATE INDEX IF NOT EXISTS idx_report_shares_expiry
ON report_shares(expires_at);

COMMIT;
