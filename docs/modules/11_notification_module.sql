-- ============================================================================
-- Suriyaraja Siddha Health Care ERP (SSHC ERP)
-- Migration : 11_notification_module.sql
-- Version   : 1.0.0
-- Database  : PostgreSQL 17 (Supabase)
-- Author    : Dr. Raja Suriyaraja & ChatGPT
--
-- Description:
-- Notification and Reminder module for SSHC ERP.
-- Stores notification templates,
-- notifications, recipients,
-- reminder schedules,
-- delivery logs,
-- notification preferences,
-- provider configurations,
-- notification attachments
-- and audit history.
--
-- This module integrates with:
-- • Patients
-- • Appointments
-- • Consultations
-- • Prescriptions
-- • Billing
-- • Reports
-- • Follow-ups
-- • User Profiles
-- ============================================================================

BEGIN;

-- ============================================================================
-- NOTIFICATION TEMPLATES
-- ============================================================================

CREATE TABLE IF NOT EXISTS notification_templates (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    template_code VARCHAR(20) NOT NULL UNIQUE,

    template_name VARCHAR(200) NOT NULL,

    notification_type VARCHAR(30) NOT NULL,
    -- SMS / WhatsApp / Email / Push / In-App

    category VARCHAR(50) NOT NULL,
    -- Appointment / Follow-up / Billing /
    -- Reminder / Marketing / General

    subject VARCHAR(250),

    message_body TEXT NOT NULL,

    variables JSONB,

    language_code VARCHAR(10) DEFAULT 'en',

    template_version INTEGER DEFAULT 1,

    is_system BOOLEAN NOT NULL DEFAULT FALSE,

    is_default BOOLEAN NOT NULL DEFAULT FALSE,

    display_order INTEGER DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_notification_templates_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notification_templates_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE notification_templates IS
'Stores reusable notification templates for SMS, WhatsApp, Email, Push and In-App notifications.';

CREATE TRIGGER trg_notification_templates_updated_at
BEFORE UPDATE ON notification_templates
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- NOTIFICATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS notifications (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    notification_number VARCHAR(20) NOT NULL UNIQUE,

    template_id UUID,

    patient_id UUID,

    appointment_id UUID,

    consultation_id UUID,

    prescription_id UUID,

    bill_id UUID,

    report_id UUID,

    notification_type VARCHAR(30) NOT NULL,
    -- SMS / WhatsApp / Email / Push / In-App

    delivery_channel VARCHAR(30) NOT NULL,

    notification_category VARCHAR(50) NOT NULL,
    -- Appointment Reminder / Follow-up /
    -- Billing / Prescription / Marketing

    priority VARCHAR(20) NOT NULL DEFAULT 'Normal',
    -- Low / Normal / High / Urgent / Emergency

    title VARCHAR(250),

    subject VARCHAR(250),

    message_body TEXT NOT NULL,

    scheduled_at TIMESTAMPTZ,

    sent_at TIMESTAMPTZ,

    read_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    notification_status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    -- Pending / Queued / Sending /
    -- Sent / Delivered / Read /
    -- Failed / Cancelled / Expired

    retry_count INTEGER NOT NULL DEFAULT 0,

    last_retry_at TIMESTAMPTZ,

    max_retry_count INTEGER NOT NULL DEFAULT 3,

    provider_response TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_notifications_template
        FOREIGN KEY (template_id)
        REFERENCES notification_templates(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notifications_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_notifications_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notifications_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notifications_prescription
        FOREIGN KEY (prescription_id)
        REFERENCES prescriptions(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notifications_bill
        FOREIGN KEY (bill_id)
        REFERENCES bills(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notifications_report
        FOREIGN KEY (report_id)
        REFERENCES generated_reports(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notifications_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notifications_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE notifications IS
'Stores all notifications generated by the system including appointment reminders, follow-ups, billing alerts, prescription notifications and report sharing.';

CREATE TRIGGER trg_notifications_updated_at
BEFORE UPDATE ON notifications
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- NOTIFICATION RECIPIENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS notification_recipients (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    notification_id UUID NOT NULL,

    recipient_type VARCHAR(30) NOT NULL,
    -- Patient / Doctor / Staff / Supplier / Other

    patient_id UUID,

    user_id UUID,

    recipient_name VARCHAR(200),

    recipient_mobile VARCHAR(20),

    recipient_email VARCHAR(200),

    notification_channel VARCHAR(30) NOT NULL,
    -- SMS / WhatsApp / Email / Push / In-App

    delivery_status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    -- Pending / Sent / Delivered / Read / Failed

    delivered_at TIMESTAMPTZ,

    read_at TIMESTAMPTZ,

    provider_message_id VARCHAR(200),

    failure_reason TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_notification_recipients_notification
        FOREIGN KEY (notification_id)
        REFERENCES notifications(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_notification_recipients_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notification_recipients_user
        FOREIGN KEY (user_id)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notification_recipients_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notification_recipients_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE notification_recipients IS
'Stores recipient-wise delivery details for every notification.';

CREATE TRIGGER trg_notification_recipients_updated_at
BEFORE UPDATE ON notification_recipients
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- NOTIFICATION QUEUE
-- ============================================================================

CREATE TABLE IF NOT EXISTS notification_queue (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    queue_number VARCHAR(20) NOT NULL UNIQUE,

    notification_id UUID NOT NULL,

    priority VARCHAR(20) NOT NULL DEFAULT 'Normal',
    -- Low / Normal / High / Urgent

    queue_status VARCHAR(30) NOT NULL DEFAULT 'Waiting',
    -- Waiting / Processing / Completed / Failed

    scheduled_time TIMESTAMPTZ,

    available_after TIMESTAMPTZ,

    processing_started_at TIMESTAMPTZ,

    completed_at TIMESTAMPTZ,

    retry_attempts INTEGER NOT NULL DEFAULT 0,

    max_retry_attempts INTEGER NOT NULL DEFAULT 3,

    worker_name VARCHAR(100),

    error_message TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_notification_queue_notification
        FOREIGN KEY (notification_id)
        REFERENCES notifications(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_notification_queue_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notification_queue_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE notification_queue IS
'Stores queued notifications waiting for processing and delivery.';

CREATE TRIGGER trg_notification_queue_updated_at
BEFORE UPDATE ON notification_queue
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- NOTIFICATION PREFERENCES
-- ============================================================================

CREATE TABLE IF NOT EXISTS notification_preferences (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID,

    patient_id UUID,

    notification_type VARCHAR(50) NOT NULL,
    -- Appointment / Follow-up / Billing /
    -- Prescription / Therapy / Marketing / System

    sms_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    whatsapp_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    email_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    push_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    in_app_enabled BOOLEAN NOT NULL DEFAULT TRUE,

    quiet_hours_enabled BOOLEAN NOT NULL DEFAULT FALSE,

    quiet_hours_start TIME,

    quiet_hours_end TIME,

    language_code VARCHAR(10) DEFAULT 'en',

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_notification_preferences_user
        FOREIGN KEY (user_id)
        REFERENCES user_profiles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_notification_preferences_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_notification_preferences_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notification_preferences_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT uq_notification_preferences
    UNIQUE (
    user_id,
    patient_id,
    notification_type
)

);

COMMENT ON TABLE notification_preferences IS
'Stores notification delivery preferences for users and patients.';

CREATE TRIGGER trg_notification_preferences_updated_at
BEFORE UPDATE ON notification_preferences
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- NOTIFICATION PROVIDER SETTINGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS notification_provider_settings (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    provider_code VARCHAR(20) NOT NULL UNIQUE,

    provider_name VARCHAR(150) NOT NULL,

    provider_type VARCHAR(30) NOT NULL,
    -- SMS / WhatsApp / Email / Push

    api_url TEXT,

    api_key TEXT,

    api_secret TEXT,

    sender_id VARCHAR(100),

    authentication_type VARCHAR(30),
    -- API Key / OAuth / Basic Auth

    daily_limit INTEGER,

    monthly_limit INTEGER,

    priority INTEGER DEFAULT 1,

    supports_unicode BOOLEAN DEFAULT TRUE,

    supports_attachments BOOLEAN DEFAULT FALSE,

    is_default BOOLEAN NOT NULL DEFAULT FALSE,

    provider_status VARCHAR(30) NOT NULL DEFAULT 'Active',
    -- Active / Inactive / Testing

    last_success_at TIMESTAMPTZ,

    last_failure_at TIMESTAMPTZ,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_notification_provider_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notification_provider_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE notification_provider_settings IS
'Stores SMS, WhatsApp, Email and Push notification provider configuration.';

CREATE TRIGGER trg_notification_provider_settings_updated_at
BEFORE UPDATE ON notification_provider_settings
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- NOTIFICATION LOGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS notification_logs (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    log_number VARCHAR(20) NOT NULL UNIQUE,

    notification_id UUID,

    recipient_id UUID,

    provider_id UUID,

    notification_channel VARCHAR(30) NOT NULL,
    -- SMS / WhatsApp / Email / Push / In-App

    event_type VARCHAR(30) NOT NULL,
    -- Queued / Sent / Delivered / Read / Failed / Retried

    event_status VARCHAR(30) NOT NULL DEFAULT 'Success',
    -- Success / Failed

    provider_message_id VARCHAR(200),

    provider_transaction_id VARCHAR(200),

    provider_response TEXT,

    error_code VARCHAR(50),

    error_message TEXT,

    event_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    processing_time_ms INTEGER,

    retry_number INTEGER DEFAULT 0,

    ip_address INET,

    device_information TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_notification_logs_notification
        FOREIGN KEY (notification_id)
        REFERENCES notifications(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notification_logs_recipient
        FOREIGN KEY (recipient_id)
        REFERENCES notification_recipients(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notification_logs_provider
        FOREIGN KEY (provider_id)
        REFERENCES notification_provider_settings(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notification_logs_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_notification_logs_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE notification_logs IS
'Stores complete notification delivery audit trail including provider responses, failures and retries.';

CREATE TRIGGER trg_notification_logs_updated_at
BEFORE UPDATE ON notification_logs
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_notifications_number
ON notifications(notification_number);

CREATE INDEX IF NOT EXISTS idx_notifications_type
ON notifications(notification_type);

CREATE INDEX IF NOT EXISTS idx_notifications_status
ON notifications(notification_status);

CREATE INDEX IF NOT EXISTS idx_notifications_priority
ON notifications(priority);

CREATE INDEX IF NOT EXISTS idx_notifications_scheduled
ON notifications(scheduled_at);

CREATE INDEX IF NOT EXISTS idx_notification_recipients_notification
ON notification_recipients(notification_id);

CREATE INDEX IF NOT EXISTS idx_notification_recipients_patient
ON notification_recipients(patient_id);

CREATE INDEX IF NOT EXISTS idx_notification_recipients_user
ON notification_recipients(user_id);

CREATE INDEX IF NOT EXISTS idx_notification_recipients_status
ON notification_recipients(delivery_status);

CREATE INDEX IF NOT EXISTS idx_notification_queue_number
ON notification_queue(queue_number);

CREATE INDEX IF NOT EXISTS idx_notification_queue_status
ON notification_queue(queue_status);

CREATE INDEX IF NOT EXISTS idx_notification_queue_priority
ON notification_queue(priority);

CREATE INDEX IF NOT EXISTS idx_notification_queue_schedule
ON notification_queue(scheduled_time);

CREATE INDEX IF NOT EXISTS idx_notification_preferences_user
ON notification_preferences(user_id);

CREATE INDEX IF NOT EXISTS idx_notification_preferences_patient
ON notification_preferences(patient_id);

CREATE INDEX IF NOT EXISTS idx_notification_preferences_type
ON notification_preferences(notification_type);

CREATE INDEX IF NOT EXISTS idx_notification_provider_code
ON notification_provider_settings(provider_code);

CREATE INDEX IF NOT EXISTS idx_notification_provider_type
ON notification_provider_settings(provider_type);

CREATE INDEX IF NOT EXISTS idx_notification_provider_status
ON notification_provider_settings(provider_status);

CREATE INDEX IF NOT EXISTS idx_notification_logs_number
ON notification_logs(log_number);

CREATE INDEX IF NOT EXISTS idx_notification_logs_notification
ON notification_logs(notification_id);

CREATE INDEX IF NOT EXISTS idx_notification_logs_recipient
ON notification_logs(recipient_id);

CREATE INDEX IF NOT EXISTS idx_notification_logs_provider
ON notification_logs(provider_id);

CREATE INDEX IF NOT EXISTS idx_notification_logs_event
ON notification_logs(event_type);

CREATE INDEX IF NOT EXISTS idx_notification_logs_status
ON notification_logs(event_status);

CREATE INDEX IF NOT EXISTS idx_notification_logs_time
ON notification_logs(event_time);

CREATE INDEX IF NOT EXISTS idx_notifications_patient
ON notifications(patient_id);

CREATE INDEX IF NOT EXISTS idx_notifications_bill
ON notifications(bill_id);

CREATE INDEX IF NOT EXISTS idx_notifications_consultation
ON notifications(consultation_id);

CREATE INDEX IF NOT EXISTS idx_notifications_template
ON notifications(template_id);

CREATE INDEX IF NOT EXISTS idx_notifications_created_at
ON notifications(created_at);

CREATE INDEX IF NOT EXISTS idx_notification_logs_created_at
ON notification_logs(created_at);

CREATE INDEX IF NOT EXISTS idx_notification_templates_type
ON notification_templates(notification_type);

CREATE INDEX IF NOT EXISTS idx_notification_templates_category
ON notification_templates(category);

COMMIT;
