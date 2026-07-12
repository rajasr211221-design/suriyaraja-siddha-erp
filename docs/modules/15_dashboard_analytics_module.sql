-- ============================================================================
-- Suriyaraja Siddha Health Care ERP (SSHC ERP)
-- Migration : 15_dashboard_analytics_module.sql
-- Version   : 1.0.0
-- Database  : PostgreSQL 17 (Supabase)
-- Author    : Dr. Raja Suriyaraja & ChatGPT
--
-- Description:
-- Dashboard & Analytics module for SSHC ERP.
-- Stores dashboard widgets,
-- user dashboard preferences,
-- analytics snapshots,
-- system alerts,
-- inventory alerts,
-- revenue statistics,
-- patient statistics,
-- disease statistics,
-- doctor statistics,
-- and KPI information used throughout the ERP.
--
-- This module integrates with:
-- • User Profiles
-- • Patients
-- • Appointments
-- • Consultations
-- • Prescriptions
-- • Pharmacy
-- • Billing
-- • Accounts
-- • Reports
-- • Notifications
-- • Audit & Security
-- ============================================================================

BEGIN;

-- ============================================================================
-- DASHBOARD WIDGETS
-- ============================================================================

CREATE TABLE IF NOT EXISTS dashboard_widgets (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    widget_code VARCHAR(30) NOT NULL UNIQUE,

    widget_name VARCHAR(150) NOT NULL,

    widget_category VARCHAR(50) NOT NULL,
    -- KPI / Chart / Table / Calendar /
    -- Shortcut / Alert / Summary

    widget_description TEXT,

    widget_icon VARCHAR(100),

    widget_color VARCHAR(30),

    widget_type VARCHAR(30) NOT NULL,
    -- System / Custom

    display_order INTEGER NOT NULL DEFAULT 1,

    default_width SMALLINT NOT NULL DEFAULT 4,

    default_height SMALLINT NOT NULL DEFAULT 3,

    refresh_interval_seconds INTEGER DEFAULT 300,

    data_source VARCHAR(100),
    -- SQL View / Function / Materialized View /
    -- API / Static

    chart_type VARCHAR(30),
    -- Bar / Line / Pie / Doughnut /
    -- Area / Card / Gauge / Table

    is_visible BOOLEAN NOT NULL DEFAULT TRUE,

    is_default BOOLEAN NOT NULL DEFAULT TRUE,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_dashboard_widgets_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_dashboard_widgets_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_dashboard_widget_category
        CHECK (
            widget_category IN (
                'KPI',
                'Chart',
                'Table',
                'Calendar',
                'Shortcut',
                'Alert',
                'Summary'
            )
        ),

    CONSTRAINT chk_dashboard_widget_type
        CHECK (
            widget_type IN (
                'System',
                'Custom'
            )
        ), 
    CONSTRAINT chk_dashboard_chart_type
        CHECK (
              chart_type IS NULL OR
              chart_type IN (
                'Bar',
                'Line',
                'Pie',
                'Doughnut',
                'Area',
                'Card',
                'Gauge',
                'Table'
            )
        ),

    CONSTRAINT chk_dashboard_data_source
        CHECK (
              data_source IS NULL OR
              data_source IN (
                'SQL View',
                'Function',
                'Materialized View',
                'API',
                'Static'
            )
       ),

    CONSTRAINT chk_refresh_interval
        CHECK (refresh_interval_seconds > 0)

);

COMMENT ON TABLE dashboard_widgets IS
'Stores master definitions for all dashboard widgets, KPI cards, charts, tables, alerts and shortcuts available within the SSHC ERP.';

CREATE TRIGGER trg_dashboard_widgets_updated_at
BEFORE UPDATE ON dashboard_widgets
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DASHBOARD PREFERENCES
-- ============================================================================

CREATE TABLE IF NOT EXISTS dashboard_preferences (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    preference_number VARCHAR(20) NOT NULL UNIQUE,

    user_id UUID NOT NULL,

    dashboard_name VARCHAR(100) NOT NULL DEFAULT 'Default Dashboard',

    layout_name VARCHAR(100),
    
    widgets JSONB NOT NULL DEFAULT '{}'::jsonb,
    -- Stores widget positions, sizes and visibility

    theme_mode VARCHAR(20) NOT NULL DEFAULT 'Light',
    -- Light / Dark / Auto

    sidebar_collapsed BOOLEAN NOT NULL DEFAULT FALSE,

    compact_mode BOOLEAN NOT NULL DEFAULT FALSE,

    show_welcome_message BOOLEAN NOT NULL DEFAULT TRUE,

    default_landing_page VARCHAR(100),
    -- Dashboard / Appointments / Patients /
    -- Billing / Pharmacy

    auto_refresh_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    auto_refresh_interval_seconds INTEGER DEFAULT 300,

    last_accessed_at TIMESTAMPTZ,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_dashboard_preferences_user
        FOREIGN KEY (user_id)
        REFERENCES user_profiles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_dashboard_preferences_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_dashboard_preferences_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT uq_dashboard_preferences_user
        UNIQUE(user_id, dashboard_name),

    CONSTRAINT chk_dashboard_theme_mode
        CHECK (
            theme_mode IN (
                'Light',
                'Dark',
                'Auto'
            )
        ),

    CONSTRAINT chk_dashboard_default_landing_page
        CHECK (
            default_landing_page IS NULL OR
            default_landing_page IN (
               'Dashboard',
               'Patients',
               'Appointments',
               'Consultations',
               'Prescription',
               'Billing',
               'Pharmacy',
               'Reports'
             )
        ),
    
   CONSTRAINT chk_widgets_json
        CHECK (
            jsonb_typeof(widgets) = 'object'
        )
);

COMMENT ON TABLE dashboard_preferences IS
'Stores personalized dashboard layout, widget arrangement, display preferences and auto-refresh settings for each SSHC ERP user.';

CREATE TRIGGER trg_dashboard_preferences_updated_at
BEFORE UPDATE ON dashboard_preferences
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- ANALYTICS SNAPSHOTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS analytics_snapshots (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    snapshot_number VARCHAR(20) NOT NULL UNIQUE,

    snapshot_name VARCHAR(150) NOT NULL,

    snapshot_type VARCHAR(30) NOT NULL,
    -- Daily / Weekly / Monthly / Quarterly / Yearly / Custom

    snapshot_date DATE NOT NULL,

    snapshot_period_start DATE NOT NULL,

    snapshot_period_end DATE NOT NULL,

    total_patients INTEGER NOT NULL DEFAULT 0,

    new_patients INTEGER NOT NULL DEFAULT 0,

    returning_patients INTEGER NOT NULL DEFAULT 0,

    total_consultations INTEGER NOT NULL DEFAULT 0,

    total_appointments INTEGER NOT NULL DEFAULT 0,

    completed_appointments INTEGER NOT NULL DEFAULT 0,

    cancelled_appointments INTEGER NOT NULL DEFAULT 0,

    total_prescriptions INTEGER NOT NULL DEFAULT 0,

    total_bills INTEGER NOT NULL DEFAULT 0,

    total_revenue NUMERIC(15,2) NOT NULL DEFAULT 0,

    total_expenses NUMERIC(15,2) NOT NULL DEFAULT 0,

    net_profit NUMERIC(15,2) NOT NULL DEFAULT 0,

    pharmacy_sales NUMERIC(15,2) NOT NULL DEFAULT 0,

    pending_payments NUMERIC(15,2) NOT NULL DEFAULT 0,

    dashboard_metrics JSONB NOT NULL DEFAULT '{}'::jsonb,
    -- Additional KPIs and aggregated values

    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    generated_by UUID,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_analytics_snapshots_generated_by
        FOREIGN KEY (generated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_analytics_snapshots_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_analytics_snapshots_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT uq_analytics_snapshot_period
        UNIQUE (
            snapshot_type,
            snapshot_period_start,
            snapshot_period_end
        ),

   CONSTRAINT chk_dashboard_metrics_json
        CHECK (
            jsonb_typeof(dashboard_metrics) = 'object'
        ),
    
    CONSTRAINT chk_snapshot_type
        CHECK (
            snapshot_type IN (
                'Daily',
                'Weekly',
                'Monthly',
                'Quarterly',
                'Yearly',
                'Custom'
            )
        ),

    CONSTRAINT chk_snapshot_dates
        CHECK (snapshot_period_start <= snapshot_period_end),

    CONSTRAINT chk_snapshot_date
        CHECK (
            snapshot_date >= snapshot_period_start
            AND snapshot_date <= snapshot_period_end
        ),

   CONSTRAINT chk_snapshot_values
    CHECK (
        total_patients >= 0
        AND new_patients >= 0
        AND returning_patients >= 0
        AND total_consultations >= 0
        AND total_appointments >= 0
        AND completed_appointments >= 0
        AND cancelled_appointments >= 0
        AND total_prescriptions >= 0
        AND total_bills >= 0
        AND total_revenue >= 0
        AND total_expenses >= 0
        AND pharmacy_sales >= 0
        AND pending_payments >= 0
    )
);

COMMENT ON TABLE analytics_snapshots IS
'Stores periodic dashboard snapshots and KPI summaries for historical analytics, trend analysis and reporting within the SSHC ERP.';

CREATE TRIGGER trg_analytics_snapshots_updated_at
BEFORE UPDATE ON analytics_snapshots
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- SYSTEM ALERTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS system_alerts (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    alert_number VARCHAR(20) NOT NULL UNIQUE,

    alert_title VARCHAR(200) NOT NULL,

    alert_type VARCHAR(50) NOT NULL,
    -- System / Security / Backup /
    -- Database / Performance / License /
    -- Notification / Integration

    alert_category VARCHAR(50),
    -- Information / Warning / Error / Critical

    severity VARCHAR(20) NOT NULL DEFAULT 'Medium',
    -- Low / Medium / High / Critical

    alert_message TEXT NOT NULL,

    source_module VARCHAR(100),
    -- Dashboard / Pharmacy / Billing /
    -- Patients / Reports / etc.

    source_record_id UUID,

    detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    acknowledged_at TIMESTAMPTZ,

    acknowledged_by UUID,

    resolved_at TIMESTAMPTZ,

    resolved_by UUID,

    resolution_notes TEXT,

    alert_status VARCHAR(30) NOT NULL DEFAULT 'Open',
    -- Open / Acknowledged /
    -- Resolved / Closed

    notification_sent BOOLEAN NOT NULL DEFAULT FALSE,

    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,

    recurrence_interval_minutes INTEGER,

    expires_at TIMESTAMPTZ,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_system_alerts_acknowledged_by
        FOREIGN KEY (acknowledged_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_system_alerts_resolved_by
        FOREIGN KEY (resolved_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_system_alerts_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_system_alerts_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_system_alert_severity
        CHECK (
            severity IN (
                'Low',
                'Medium',
                'High',
                'Critical'
            )
        ),

    CONSTRAINT chk_system_alert_status
        CHECK (
            alert_status IN (
                'Open',
                'Acknowledged',
                'Resolved',
                'Closed'
            )
        ),
    CONSTRAINT chk_system_alert_category
        CHECK (
            alert_category IS NULL OR
            alert_category IN (
                'Information',
                'Warning',
                'Error',
                'Critical'
             )
        )

);

COMMENT ON TABLE system_alerts IS
'Stores system-generated alerts including security events, database issues, backup failures, integration problems, performance warnings and operational notifications within the SSHC ERP.';

CREATE TRIGGER trg_system_alerts_updated_at
BEFORE UPDATE ON system_alerts
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- LOW STOCK ALERTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS low_stock_alerts (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    alert_number VARCHAR(20) NOT NULL UNIQUE,

    medicine_id UUID NOT NULL,

    batch_id UUID,

    current_stock NUMERIC(12,3) NOT NULL,

    minimum_stock_level NUMERIC(12,3) NOT NULL,

    reorder_level NUMERIC(12,3),

    shortage_quantity NUMERIC(12,3),

    alert_status VARCHAR(30) NOT NULL DEFAULT 'Open',
    -- Open / Acknowledged / Ordered / Resolved

    priority VARCHAR(20) NOT NULL DEFAULT 'High',
    -- Low / Medium / High / Critical

    supplier_id UUID,

    purchase_order_id UUID,

    detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    acknowledged_at TIMESTAMPTZ,

    acknowledged_by UUID,

    resolved_at TIMESTAMPTZ,

    resolved_by UUID,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_low_stock_alerts_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES medicines(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_low_stock_alerts_batch
        FOREIGN KEY (batch_id)
        REFERENCES medicine_batches(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_low_stock_alerts_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES suppliers(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_low_stock_alerts_purchase_order
        FOREIGN KEY (purchase_order_id)
        REFERENCES purchases(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_low_stock_alerts_acknowledged_by
        FOREIGN KEY (acknowledged_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_low_stock_alerts_resolved_by
        FOREIGN KEY (resolved_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_low_stock_alerts_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_low_stock_alerts_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_low_stock_alert_status
        CHECK (
            alert_status IN (
                'Open',
                'Acknowledged',
                'Ordered',
                'Resolved'
            )
        ),

    CONSTRAINT chk_low_stock_priority
        CHECK (
            priority IN (
                'Low',
                'Medium',
                'High',
                'Critical'
            )
        ),
    CONSTRAINT chk_low_stock_values
         CHECK (
               current_stock >= 0
           AND minimum_stock_level >= 0
           AND (reorder_level IS NULL OR reorder_level >= 0)
           AND (shortage_quantity IS NULL OR shortage_quantity >= 0)
           )
    
);

COMMENT ON TABLE low_stock_alerts IS
'Stores automatic low stock alerts for medicines, helping the clinic maintain inventory, reorder medicines on time and prevent stock shortages.';

CREATE TRIGGER trg_low_stock_alerts_updated_at
BEFORE UPDATE ON low_stock_alerts
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- EXPIRY ALERTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS expiry_alerts (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    alert_number VARCHAR(20) NOT NULL UNIQUE,

    medicine_id UUID NOT NULL,

    batch_id UUID NOT NULL,

    supplier_id UUID,

    expiry_date DATE NOT NULL,

    days_remaining INTEGER NOT NULL,

    current_stock NUMERIC(12,3) NOT NULL,

    estimated_stock_value NUMERIC(15,2),

    expiry_status VARCHAR(30) NOT NULL DEFAULT 'Upcoming',
    -- Upcoming / Near Expiry / Expired / Disposed

    priority VARCHAR(20) NOT NULL DEFAULT 'Medium',
    -- Low / Medium / High / Critical

    alert_generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    acknowledged_at TIMESTAMPTZ,

    acknowledged_by UUID,

    action_taken VARCHAR(50),
    -- Discounted / Returned / Destroyed /
    -- Dispensed / Ignored

    action_taken_at TIMESTAMPTZ,

    resolved_at TIMESTAMPTZ,

    resolved_by UUID,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_expiry_alerts_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES medicines(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_expiry_alerts_batch
        FOREIGN KEY (batch_id)
        REFERENCES medicine_batches(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_expiry_alerts_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES suppliers(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_expiry_alerts_acknowledged_by
        FOREIGN KEY (acknowledged_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_expiry_alerts_resolved_by
        FOREIGN KEY (resolved_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_expiry_alerts_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_expiry_alerts_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_expiry_status
        CHECK (
            expiry_status IN (
                'Upcoming',
                'Near Expiry',
                'Expired',
                'Disposed'
            )
        ),

    CONSTRAINT chk_expiry_priority
        CHECK (
            priority IN (
                'Low',
                'Medium',
                'High',
                'Critical'
            )
        ),

    CONSTRAINT chk_expiry_values
        CHECK (
            days_remaining >= 0
            AND current_stock >= 0
            AND (
                estimated_stock_value IS NULL
                OR estimated_stock_value >= 0
            )
        )

);

COMMENT ON TABLE expiry_alerts IS
'Stores medicine expiry alerts for batches nearing expiry or already expired, enabling timely dispensing, returns, disposal and inventory management within the SSHC ERP.';

CREATE TRIGGER trg_expiry_alerts_updated_at
BEFORE UPDATE ON expiry_alerts
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- REVENUE STATISTICS
-- ============================================================================

CREATE TABLE IF NOT EXISTS revenue_statistics (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    statistic_number VARCHAR(20) NOT NULL UNIQUE,

    statistic_date DATE NOT NULL,

    period_type VARCHAR(20) NOT NULL,
    -- Daily / Weekly / Monthly / Quarterly / Yearly

    department_id UUID,

    doctor_id UUID,

    total_consultation_income NUMERIC(15,2) NOT NULL DEFAULT 0,

    total_pharmacy_income NUMERIC(15,2) NOT NULL DEFAULT 0,

    total_therapy_income NUMERIC(15,2) NOT NULL DEFAULT 0,

    total_lab_income NUMERIC(15,2) NOT NULL DEFAULT 0,

    other_income NUMERIC(15,2) NOT NULL DEFAULT 0,

    gross_revenue NUMERIC(15,2) NOT NULL DEFAULT 0,

    total_expenses NUMERIC(15,2) NOT NULL DEFAULT 0,

    net_profit NUMERIC(15,2) NOT NULL DEFAULT 0,

    patient_count INTEGER NOT NULL DEFAULT 0,

    average_bill_amount NUMERIC(15,2),

    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_revenue_statistics_department
        FOREIGN KEY (department_id)
        REFERENCES departments(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_revenue_statistics_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_revenue_statistics_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_revenue_statistics_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT uq_revenue_statistics
        UNIQUE (
            department_id,
            doctor_id,
            statistic_date,
            period_type
        ),

    CONSTRAINT chk_revenue_period
        CHECK (
            period_type IN (
                'Daily',
                'Weekly',
                'Monthly',
                'Quarterly',
                'Yearly'
            )
        ),

    CONSTRAINT chk_revenue_values
        CHECK (
                gross_revenue >= 0
            AND total_expenses >= 0
            AND total_consultation_income >= 0
            AND total_pharmacy_income >= 0
            AND total_therapy_income >= 0
            AND total_lab_income >= 0
            AND other_income >= 0
            AND net_profit >= 0
            AND patient_count >= 0
        )
);

COMMENT ON TABLE revenue_statistics IS
'Stores summarized revenue, expenses and profit statistics for dashboard analytics and business performance reporting in SSHC ERP.';

CREATE TRIGGER trg_revenue_statistics_updated_at
BEFORE UPDATE ON revenue_statistics
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PATIENT STATISTICS
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_statistics (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    statistic_number VARCHAR(20) NOT NULL UNIQUE,

    statistic_date DATE NOT NULL,

    period_type VARCHAR(20) NOT NULL,
    -- Daily / Weekly / Monthly / Quarterly / Yearly

    department_id UUID,

    doctor_id UUID,

    total_registered_patients INTEGER NOT NULL DEFAULT 0,

    new_patients INTEGER NOT NULL DEFAULT 0,

    returning_patients INTEGER NOT NULL DEFAULT 0,

    total_consultations INTEGER NOT NULL DEFAULT 0,

    followup_patients INTEGER NOT NULL DEFAULT 0,

    online_appointments INTEGER NOT NULL DEFAULT 0,

    cancelled_appointments INTEGER NOT NULL DEFAULT 0,

    no_show_patients INTEGER NOT NULL DEFAULT 0,

    average_waiting_time_minutes NUMERIC(6,2),

    average_consultation_time_minutes NUMERIC(6,2),

    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_statistics_department
        FOREIGN KEY (department_id)
        REFERENCES departments(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_statistics_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_statistics_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_statistics_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT uq_patient_statistics
        UNIQUE (
            department_id,
            doctor_id,
            statistic_date,
            period_type
        ),

    CONSTRAINT chk_patient_statistics_period
        CHECK (
            period_type IN (
                'Daily',
                'Weekly',
                'Monthly',
                'Quarterly',
                'Yearly'
            )
        ),

    CONSTRAINT chk_patient_statistics_values
        CHECK (
            total_registered_patients >= 0
            AND new_patients >= 0
            AND returning_patients >= 0
            AND total_consultations >= 0
            AND followup_patients >= 0
            AND online_appointments >= 0
            AND cancelled_appointments >= 0
            AND no_show_patients >= 0
            AND (
                average_waiting_time_minutes IS NULL
                OR average_waiting_time_minutes >= 0
            )
            AND (
                average_consultation_time_minutes IS NULL
                OR average_consultation_time_minutes >= 0
            )
        )

);

COMMENT ON TABLE patient_statistics IS
'Stores summarized patient statistics including registrations, consultations, follow-ups, appointments and waiting time for dashboard analytics.';

CREATE TRIGGER trg_patient_statistics_updated_at
BEFORE UPDATE ON patient_statistics
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DOCTOR STATISTICS
-- ============================================================================

CREATE TABLE IF NOT EXISTS doctor_statistics (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    statistic_number VARCHAR(20) NOT NULL UNIQUE,

    statistic_date DATE NOT NULL,

    period_type VARCHAR(20) NOT NULL,
    -- Daily / Weekly / Monthly / Quarterly / Yearly

    doctor_id UUID NOT NULL,

    department_id UUID,

    total_patients INTEGER NOT NULL DEFAULT 0,

    new_patients INTEGER NOT NULL DEFAULT 0,

    followup_patients INTEGER NOT NULL DEFAULT 0,

    consultations_completed INTEGER NOT NULL DEFAULT 0,

    appointments_completed INTEGER NOT NULL DEFAULT 0,

    appointments_cancelled INTEGER NOT NULL DEFAULT 0,

    therapies_performed INTEGER NOT NULL DEFAULT 0,

    prescriptions_issued INTEGER NOT NULL DEFAULT 0,

    revenue_generated NUMERIC(12,2) NOT NULL DEFAULT 0,

    average_consultation_time_minutes NUMERIC(6,2),

    patient_satisfaction_score NUMERIC(4,2),

    generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_doctor_statistics_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES user_profiles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_doctor_statistics_department
        FOREIGN KEY (department_id)
        REFERENCES departments(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_doctor_statistics_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_doctor_statistics_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT uq_doctor_statistics
        UNIQUE (
            doctor_id,
            statistic_date,
            period_type
        ),

    CONSTRAINT chk_doctor_statistics_period
        CHECK (
            period_type IN (
                'Daily',
                'Weekly',
                'Monthly',
                'Quarterly',
                'Yearly'
            )
        ),

    CONSTRAINT chk_patient_satisfaction_score
        CHECK (
              patient_satisfaction_score IS NULL
           OR (
              patient_satisfaction_score >= 0
          AND patient_satisfaction_score <= 5
           )
       ),

    CONSTRAINT chk_doctor_statistics_values
        CHECK (
            total_patients >= 0
            AND new_patients >= 0
            AND followup_patients >= 0
            AND consultations_completed >= 0
            AND appointments_completed >= 0
            AND appointments_cancelled >= 0
            AND therapies_performed >= 0
            AND prescriptions_issued >= 0
            AND revenue_generated >= 0
        )

);

COMMENT ON TABLE doctor_statistics IS
'Stores performance statistics for each doctor including consultations, appointments, prescriptions, therapies, revenue and patient satisfaction for dashboard analytics.';

CREATE TRIGGER trg_doctor_statistics_updated_at
BEFORE UPDATE ON doctor_statistics
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_dashboard_widgets_code
ON dashboard_widgets(widget_code);

CREATE INDEX IF NOT EXISTS idx_dashboard_widgets_category
ON dashboard_widgets(widget_category);

CREATE INDEX IF NOT EXISTS idx_dashboard_widgets_active
ON dashboard_widgets(is_active);

CREATE INDEX IF NOT EXISTS idx_dashboard_preferences_user
ON dashboard_preferences(user_id);

CREATE INDEX IF NOT EXISTS idx_dashboard_preferences_active
ON dashboard_preferences(is_active);

CREATE INDEX IF NOT EXISTS idx_analytics_snapshots_date
ON analytics_snapshots(snapshot_date);

CREATE INDEX IF NOT EXISTS idx_analytics_snapshots_type
ON analytics_snapshots(snapshot_type);

CREATE INDEX IF NOT EXISTS idx_analytics_snapshots_period
ON analytics_snapshots(
    snapshot_type,
    snapshot_period_start,
    snapshot_period_end
);

CREATE INDEX IF NOT EXISTS idx_system_alerts_type
ON system_alerts(alert_type);

CREATE INDEX IF NOT EXISTS idx_system_alerts_priority
ON system_alerts(priority);

CREATE INDEX IF NOT EXISTS idx_system_alerts_status
ON system_alerts(alert_status);

CREATE INDEX IF NOT EXISTS idx_system_alerts_status_priority
ON system_alerts(
    alert_status,
    priority
);

CREATE INDEX IF NOT EXISTS idx_system_alerts_detected_at
ON system_alerts(detected_at);

CREATE INDEX IF NOT EXISTS idx_system_alerts_module
ON system_alerts(source_module);

CREATE INDEX IF NOT EXISTS idx_low_stock_alerts_medicine
ON low_stock_alerts(medicine_id);

CREATE INDEX IF NOT EXISTS idx_low_stock_alerts_status
ON low_stock_alerts(alert_status);

CREATE INDEX IF NOT EXISTS idx_low_stock_alerts_priority
ON low_stock_alerts(priority);

CREATE INDEX IF NOT EXISTS idx_low_stock_alerts_detected
ON low_stock_alerts(detected_at);

CREATE INDEX IF NOT EXISTS idx_low_stock_alerts_status_priority
ON low_stock_alerts(
    alert_status,
    priority
);

CREATE INDEX IF NOT EXISTS idx_expiry_alerts_batch
ON expiry_alerts(batch_id);

CREATE INDEX IF NOT EXISTS idx_expiry_alerts_expiry_date
ON expiry_alerts(expiry_date);

CREATE INDEX IF NOT EXISTS idx_expiry_alerts_status
ON expiry_alerts(expiry_status);

CREATE INDEX IF NOT EXISTS idx_expiry_alerts_priority
ON expiry_alerts(priority);

CREATE INDEX IF NOT EXISTS idx_expiry_alerts_status_expiry
ON expiry_alerts(
    expiry_status,
    expiry_date
);

CREATE INDEX IF NOT EXISTS idx_revenue_statistics_date
ON revenue_statistics(statistic_date);

CREATE INDEX IF NOT EXISTS idx_revenue_statistics_period
ON revenue_statistics(period_type);

CREATE INDEX IF NOT EXISTS idx_revenue_statistics_doctor
ON revenue_statistics(doctor_id);

CREATE INDEX IF NOT EXISTS idx_revenue_statistics_department
ON revenue_statistics(department_id);

CREATE INDEX IF NOT EXISTS idx_revenue_statistics_period_date
ON revenue_statistics(
    period_type,
    statistic_date
);

CREATE INDEX IF NOT EXISTS idx_patient_statistics_date
ON patient_statistics(statistic_date);

CREATE INDEX IF NOT EXISTS idx_patient_statistics_period
ON patient_statistics(period_type);

CREATE INDEX IF NOT EXISTS idx_patient_statistics_doctor
ON patient_statistics(doctor_id);

CREATE INDEX IF NOT EXISTS idx_patient_statistics_department
ON patient_statistics(department_id);

CREATE INDEX IF NOT EXISTS idx_patient_statistics_period_date
ON patient_statistics(
    period_type,
    statistic_date
);

CREATE INDEX IF NOT EXISTS idx_doctor_statistics_date
ON doctor_statistics(statistic_date);

CREATE INDEX IF NOT EXISTS idx_doctor_statistics_doctor
ON doctor_statistics(doctor_id);

CREATE INDEX IF NOT EXISTS idx_doctor_statistics_period
ON doctor_statistics(period_type);

CREATE INDEX IF NOT EXISTS idx_doctor_statistics_department
ON doctor_statistics(department_id);

CREATE INDEX IF NOT EXISTS idx_doctor_statistics_period_date
ON doctor_statistics(
    period_type,
    statistic_date
);

COMMIT;
