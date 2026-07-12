-- ============================================================================
-- Suriyaraja Siddha Health Care ERP (SSHC ERP)
-- Migration : 14_patient_portal_module.sql
-- Version   : 1.0.0
-- Database  : PostgreSQL 17 (Supabase)
-- Author    : Dr. Raja Suriyaraja & ChatGPT
--
-- Description:
-- Patient Portal module for SSHC ERP.
-- Stores patient portal accounts,
-- registered devices,
-- online appointment requests,
-- patient documents,
-- notifications,
-- feedback,
-- secure messaging,
-- and other self-service portal features.
--
-- This module integrates with:
-- • Patients
-- • User Profiles
-- • Appointments
-- • Consultations
-- • Prescriptions
-- • Billing
-- • Reports
-- • Notifications
-- • Audit & Security
-- ============================================================================

BEGIN;

-- ============================================================================
-- PATIENT PORTAL ACCOUNTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_portal_accounts (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    portal_account_number VARCHAR(20) NOT NULL UNIQUE,

    patient_id UUID NOT NULL,

    username VARCHAR(100) NOT NULL UNIQUE,

    email VARCHAR(200),

    mobile_number VARCHAR(20),

    password_hash TEXT NOT NULL,

    account_status VARCHAR(30) NOT NULL DEFAULT 'Active',
    -- Active / Inactive / Locked / Suspended

    email_verified BOOLEAN NOT NULL DEFAULT FALSE,

    mobile_verified BOOLEAN NOT NULL DEFAULT FALSE,

    last_login_at TIMESTAMPTZ,

    failed_login_attempts INTEGER NOT NULL DEFAULT 0,

    account_locked_until TIMESTAMPTZ,

    password_changed_at TIMESTAMPTZ,

    profile_photo_url TEXT,

    preferred_language VARCHAR(20) DEFAULT 'en',

    timezone VARCHAR(100) DEFAULT 'Asia/Kolkata',

    notification_email BOOLEAN NOT NULL DEFAULT TRUE,

    notification_sms BOOLEAN NOT NULL DEFAULT TRUE,

    notification_whatsapp BOOLEAN NOT NULL DEFAULT TRUE,

    notification_push BOOLEAN NOT NULL DEFAULT TRUE,

    two_factor_enabled BOOLEAN NOT NULL DEFAULT FALSE,

    last_password_reset_at TIMESTAMPTZ,

    last_failed_login_at TIMESTAMPTZ,

    login_ip_address INET,

    login_device_information TEXT,

    login_browser_information TEXT,

    login_operating_system VARCHAR(150),

    refresh_token TEXT,

    refresh_token_expires_at TIMESTAMPTZ,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_portal_accounts_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_patient_portal_accounts_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_portal_accounts_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT uq_patient_portal_email
        UNIQUE (email),

    CONSTRAINT uq_patient_portal_mobile
        UNIQUE (mobile_number),

    CONSTRAINT chk_portal_account_status
        CHECK (
            account_status IN (
                'Active',
                'Inactive',
                'Locked',
                'Suspended'
            )
        ),

    CONSTRAINT chk_failed_login_attempts
        CHECK (failed_login_attempts >= 0)

);

COMMENT ON TABLE patient_portal_accounts IS
'Stores patient portal accounts, authentication details, notification preferences, login security and self-service access for SSHC ERP.';

CREATE TRIGGER trg_patient_portal_accounts_updated_at
BEFORE UPDATE ON patient_portal_accounts
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PATIENT DEVICES
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_devices (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    device_number VARCHAR(20) NOT NULL UNIQUE,

    portal_account_id UUID NOT NULL,

    device_name VARCHAR(100),

    device_type VARCHAR(30) NOT NULL,
    -- Mobile / Tablet / Desktop / Laptop

    device_brand VARCHAR(100),

    device_model VARCHAR(100),

    operating_system VARCHAR(100),

    os_version VARCHAR(50),

    browser_name VARCHAR(100),

    browser_version VARCHAR(50),

    device_identifier TEXT NOT NULL UNIQUE,

    push_notification_token TEXT,

    app_version VARCHAR(30),

    ip_address INET,

    last_login_at TIMESTAMPTZ,

    last_active_at TIMESTAMPTZ,

    registration_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    is_trusted_device BOOLEAN NOT NULL DEFAULT FALSE,

    is_current_device BOOLEAN NOT NULL DEFAULT FALSE,

    device_status VARCHAR(30) NOT NULL DEFAULT 'Active',
    -- Active / Inactive / Blocked / Revoked

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_devices_portal_account
        FOREIGN KEY (portal_account_id)
        REFERENCES patient_portal_accounts(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_patient_devices_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_devices_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_patient_device_status
        CHECK (
            device_status IN (
                'Active',
                'Inactive',
                'Blocked',
                'Revoked'
            )
        )

);

COMMENT ON TABLE patient_devices IS
'Stores all devices registered by patient portal users for secure login, trusted device management, push notifications and session tracking.';

CREATE TRIGGER trg_patient_devices_updated_at
BEFORE UPDATE ON patient_devices
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- ONLINE APPOINTMENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS online_appointments (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    online_appointment_number VARCHAR(20) NOT NULL UNIQUE,

    portal_account_id UUID NOT NULL,

    patient_id UUID NOT NULL,

    appointment_id UUID,

    preferred_doctor_id UUID,

    appointment_date DATE NOT NULL,

    preferred_time TIME,

    appointment_type VARCHAR(30) NOT NULL DEFAULT 'Consultation',
    -- Consultation / Follow-up / Therapy / Review

    consultation_mode VARCHAR(30) NOT NULL DEFAULT 'In Person',
    -- In Person / Video / Phone

    chief_complaint TEXT NOT NULL,

    symptoms TEXT,

    priority VARCHAR(20) NOT NULL DEFAULT 'Normal',
    -- Low / Normal / High / Emergency

    booking_status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    -- Pending / Confirmed / Cancelled / Completed / Rejected

    booking_source VARCHAR(30) NOT NULL DEFAULT 'Patient Portal',
    -- Patient Portal / Mobile App / Website

    estimated_consultation_fee NUMERIC(10,2),

    requested_on TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    confirmed_on TIMESTAMPTZ,

    cancellation_reason TEXT,

    cancelled_at TIMESTAMPTZ,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_online_appointments_portal_account
        FOREIGN KEY (portal_account_id)
        REFERENCES patient_portal_accounts(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_online_appointments_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_online_appointments_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_online_appointments_doctor
        FOREIGN KEY (preferred_doctor_id)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_online_appointments_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_online_appointments_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_online_booking_status
        CHECK (
            booking_status IN (
                'Pending',
                'Confirmed',
                'Cancelled',
                'Completed',
                'Rejected'
            )
        ),

    CONSTRAINT chk_online_consultation_mode
        CHECK (
            consultation_mode IN (
                'In Person',
                'Video',
                'Phone'
            )
        )

);

COMMENT ON TABLE online_appointments IS
'Stores appointment requests submitted through the patient portal, including preferred doctor, consultation mode, booking status and scheduling details.';

CREATE TRIGGER trg_online_appointments_updated_at
BEFORE UPDATE ON online_appointments
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PATIENT DOCUMENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_documents (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    document_number VARCHAR(20) NOT NULL UNIQUE,

    patient_id UUID NOT NULL,

    portal_account_id UUID,

    consultation_id UUID,

    document_type VARCHAR(50) NOT NULL,
    -- Prescription / Lab Report / Scan /
    -- X-Ray / Medical Certificate /
    -- Invoice / Consent Form / Other

    document_title VARCHAR(200) NOT NULL,

    document_description TEXT,

    file_name VARCHAR(255) NOT NULL,

    original_file_name VARCHAR(255),

    file_path TEXT NOT NULL,

    file_url TEXT,

    storage_bucket VARCHAR(100),
    storage_object_path TEXT,

    file_extension VARCHAR(20),

    mime_type VARCHAR(100),

    file_size_bytes BIGINT,

    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    uploaded_by UUID,

    document_status VARCHAR(30) NOT NULL DEFAULT 'Active',
    -- Active / Archived / Deleted

    access_level VARCHAR(30) NOT NULL DEFAULT 'Patient',
    -- Patient / Doctor / Staff / Admin

    is_downloadable BOOLEAN NOT NULL DEFAULT TRUE,

    is_shareable BOOLEAN NOT NULL DEFAULT FALSE,

    expiry_date DATE,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_documents_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_patient_documents_portal_account
        FOREIGN KEY (portal_account_id)
        REFERENCES patient_portal_accounts(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_documents_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_documents_uploaded_by
        FOREIGN KEY (uploaded_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_documents_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_documents_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_patient_document_status
        CHECK (
            document_status IN (
                'Active',
                'Archived',
                'Deleted'
            )
        ),

    CONSTRAINT chk_patient_document_access
        CHECK (
            access_level IN (
                'Patient',
                'Doctor',
                'Staff',
                'Admin'
            )
        )

);

COMMENT ON TABLE patient_documents IS
'Stores patient-related documents uploaded or generated within the SSHC ERP, including prescriptions, laboratory reports, invoices, certificates and other medical records accessible through the patient portal.';

CREATE TRIGGER trg_patient_documents_updated_at
BEFORE UPDATE ON patient_documents
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PATIENT NOTIFICATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_notifications (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    notification_number VARCHAR(20) NOT NULL UNIQUE,

    portal_account_id UUID NOT NULL,

    patient_id UUID NOT NULL,

    notification_type VARCHAR(30) NOT NULL,
    -- Appointment / Prescription / Billing /
    -- Report / Reminder / Promotion / System

    notification_channel VARCHAR(30) NOT NULL,
    -- In-App / SMS / Email / WhatsApp / Push

    title VARCHAR(200) NOT NULL,

    message TEXT NOT NULL,

    reference_table VARCHAR(100),

    reference_type VARCHAR(50),
    -- Appointment / Bill / Prescription / Report / Consultation

    reference_id UUID,

    priority VARCHAR(20) NOT NULL DEFAULT 'Normal',
    -- Low / Normal / High / Critical

    notification_status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    -- Pending / Sent / Delivered / Read / Failed

    scheduled_at TIMESTAMPTZ,

    sent_at TIMESTAMPTZ,

    delivered_at TIMESTAMPTZ,

    read_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    failure_reason TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_notifications_portal_account
        FOREIGN KEY (portal_account_id)
        REFERENCES patient_portal_accounts(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_patient_notifications_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_patient_notifications_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_notifications_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_patient_notification_channel
        CHECK (
            notification_channel IN (
                'In-App',
                'SMS',
                'Email',
                'WhatsApp',
                'Push'
            )
        ),

    CONSTRAINT chk_patient_notification_status
        CHECK (
            notification_status IN (
                'Pending',
                'Sent',
                'Delivered',
                'Read',
                'Failed'
            )
        )

);

COMMENT ON TABLE patient_notifications IS
'Stores notifications sent to patients through the patient portal, including appointment reminders, prescriptions, reports, billing alerts and system messages.';

CREATE TRIGGER trg_patient_notifications_updated_at
BEFORE UPDATE ON patient_notifications
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PATIENT FEEDBACK
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_feedback (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    feedback_number VARCHAR(20) NOT NULL UNIQUE,

    portal_account_id UUID,

    patient_id UUID NOT NULL,

    visit_id UUID,

    appointment_id UUID,

    consultation_id UUID,

    doctor_id UUID,

    feedback_type VARCHAR(30) NOT NULL DEFAULT 'Consultation',
    -- Consultation / Therapy / Pharmacy /
    -- Billing / Staff / General

    overall_rating SMALLINT NOT NULL
        CHECK (overall_rating BETWEEN 1 AND 5),

    doctor_rating SMALLINT
        CHECK (doctor_rating BETWEEN 1 AND 5),

    staff_rating SMALLINT
        CHECK (staff_rating BETWEEN 1 AND 5),

    clinic_rating SMALLINT
        CHECK (clinic_rating BETWEEN 1 AND 5),

    waiting_time_rating SMALLINT
        CHECK (waiting_time_rating BETWEEN 1 AND 5),

    cleanliness_rating SMALLINT
        CHECK (cleanliness_rating BETWEEN 1 AND 5),

    title VARCHAR(200),

    feedback_comments TEXT,

    suggestions TEXT,

    would_recommend BOOLEAN,

    is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,

    feedback_status VARCHAR(30) NOT NULL DEFAULT 'Submitted',
    -- Submitted / Reviewed / Resolved / Closed

    reviewed_by UUID,

    reviewed_at TIMESTAMPTZ,

    response_comments TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_feedback_visit
        FOREIGN KEY (visit_id)
        REFERENCES consultations(id)
        ON DELETE SET NULL,
    
    CONSTRAINT fk_patient_feedback_portal_account
        FOREIGN KEY (portal_account_id)
        REFERENCES patient_portal_accounts(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_feedback_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_patient_feedback_appointment
        FOREIGN KEY (appointment_id)
        REFERENCES appointments(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_feedback_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_feedback_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_feedback_reviewed_by
        FOREIGN KEY (reviewed_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_feedback_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_feedback_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_patient_feedback_status
        CHECK (
            feedback_status IN (
                'Submitted',
                'Reviewed',
                'Resolved',
                'Closed'
            )
        )

);

COMMENT ON TABLE patient_feedback IS
'Stores patient feedback and satisfaction ratings for consultations, therapies, pharmacy services, billing, staff behaviour and overall clinic experience.';

CREATE TRIGGER trg_patient_feedback_updated_at
BEFORE UPDATE ON patient_feedback
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PATIENT MESSAGES
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_messages (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    message_number VARCHAR(20) NOT NULL UNIQUE,

    portal_account_id UUID NOT NULL,

    patient_id UUID NOT NULL,

    sender_type VARCHAR(30) NOT NULL,
    -- Patient / Doctor / Staff / System

    receiver_type VARCHAR(30) NOT NULL,
    -- Patient / Doctor / Staff / System

    doctor_id UUID,

    staff_id UUID,

    subject VARCHAR(200),

    message_body TEXT NOT NULL,

    message_type VARCHAR(30) NOT NULL DEFAULT 'General',
    -- General / Consultation / Prescription /
    -- Billing / Appointment / Follow-up

    priority VARCHAR(20) NOT NULL DEFAULT 'Normal',
    -- Low / Normal / High / Urgent

    attachment_url TEXT,

    attachment_name VARCHAR(255),

    sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    delivered_at TIMESTAMPTZ,

    read_at TIMESTAMPTZ,

    replied_at TIMESTAMPTZ,

    message_status VARCHAR(30) NOT NULL DEFAULT 'Sent',
    -- Draft / Sent / Delivered / Read / Replied / Archived

    is_patient_deleted BOOLEAN NOT NULL DEFAULT FALSE,

    is_staff_deleted BOOLEAN NOT NULL DEFAULT FALSE,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_messages_staff
        FOREIGN KEY (staff_id)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,
    
    CONSTRAINT fk_patient_messages_portal_account
        FOREIGN KEY (portal_account_id)
        REFERENCES patient_portal_accounts(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_patient_messages_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_patient_messages_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_messages_created_by
        FOREIGN KEY (created_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_messages_updated_by
        FOREIGN KEY (updated_by)
        REFERENCES user_profiles(id)
        ON DELETE SET NULL,

    CONSTRAINT chk_patient_messages_sender
        CHECK (
            sender_type IN (
                'Patient',
                'Doctor',
                'Staff',
                'System'
            )
        ),

    CONSTRAINT chk_patient_messages_receiver
        CHECK (
            receiver_type IN (
                'Patient',
                'Doctor',
                'Staff',
                'System'
            )
        ),

    CONSTRAINT chk_patient_messages_status
        CHECK (
            message_status IN (
                'Draft',
                'Sent',
                'Delivered',
                'Read',
                'Replied',
                'Archived'
            )
        )

);

COMMENT ON TABLE patient_messages IS
'Stores secure two-way communication between patients and clinic staff, including appointment queries, consultation follow-ups, prescriptions, billing and general support through the patient portal.';

CREATE TRIGGER trg_patient_messages_updated_at
BEFORE UPDATE ON patient_messages
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_patient_portal_accounts_number
ON patient_portal_accounts(portal_account_number);

CREATE INDEX IF NOT EXISTS idx_patient_portal_accounts_patient
ON patient_portal_accounts(patient_id);

CREATE INDEX IF NOT EXISTS idx_patient_portal_accounts_username
ON patient_portal_accounts(username);

CREATE INDEX IF NOT EXISTS idx_patient_portal_accounts_email
ON patient_portal_accounts(email);

CREATE INDEX IF NOT EXISTS idx_patient_portal_accounts_mobile
ON patient_portal_accounts(mobile_number);

CREATE INDEX IF NOT EXISTS idx_patient_portal_accounts_status
ON patient_portal_accounts(account_status);

CREATE INDEX IF NOT EXISTS idx_patient_devices_number
ON patient_devices(device_number);

CREATE INDEX IF NOT EXISTS idx_patient_devices_portal_account
ON patient_devices(portal_account_id);

CREATE INDEX IF NOT EXISTS idx_patient_devices_identifier
ON patient_devices(device_identifier);

CREATE INDEX IF NOT EXISTS idx_patient_devices_status
ON patient_devices(device_status);

CREATE INDEX IF NOT EXISTS idx_online_appointments_number
ON online_appointments(online_appointment_number);

CREATE INDEX IF NOT EXISTS idx_online_appointments_patient
ON online_appointments(patient_id);

CREATE INDEX IF NOT EXISTS idx_online_appointments_portal_account
ON online_appointments(portal_account_id);

CREATE INDEX IF NOT EXISTS idx_online_appointments_date
ON online_appointments(appointment_date);

CREATE INDEX IF NOT EXISTS idx_online_appointments_status
ON online_appointments(booking_status);

CREATE INDEX IF NOT EXISTS idx_patient_documents_number
ON patient_documents(document_number);

CREATE INDEX IF NOT EXISTS idx_patient_documents_patient
ON patient_documents(patient_id);

CREATE INDEX IF NOT EXISTS idx_patient_documents_portal_account
ON patient_documents(portal_account_id);

CREATE INDEX IF NOT EXISTS idx_patient_documents_type
ON patient_documents(document_type);

CREATE INDEX IF NOT EXISTS idx_patient_documents_status
ON patient_documents(document_status);

CREATE INDEX IF NOT EXISTS idx_patient_notifications_number
ON patient_notifications(notification_number);

CREATE INDEX IF NOT EXISTS idx_patient_notifications_patient
ON patient_notifications(patient_id);

CREATE INDEX IF NOT EXISTS idx_patient_notifications_portal_account
ON patient_notifications(portal_account_id);

CREATE INDEX IF NOT EXISTS idx_patient_notifications_status
ON patient_notifications(notification_status);

CREATE INDEX IF NOT EXISTS idx_patient_notifications_type
ON patient_notifications(notification_type);

CREATE INDEX IF NOT EXISTS idx_patient_feedback_number
ON patient_feedback(feedback_number);

CREATE INDEX IF NOT EXISTS idx_patient_feedback_patient
ON patient_feedback(patient_id);

CREATE INDEX IF NOT EXISTS idx_patient_feedback_doctor
ON patient_feedback(doctor_id);

CREATE INDEX IF NOT EXISTS idx_patient_feedback_status
ON patient_feedback(feedback_status);

CREATE INDEX IF NOT EXISTS idx_patient_messages_number
ON patient_messages(message_number);

CREATE INDEX IF NOT EXISTS idx_patient_messages_patient
ON patient_messages(patient_id);

CREATE INDEX IF NOT EXISTS idx_patient_messages_portal_account
ON patient_messages(portal_account_id);

CREATE INDEX IF NOT EXISTS idx_patient_messages_doctor
ON patient_messages(doctor_id);

CREATE INDEX IF NOT EXISTS idx_patient_messages_status
ON patient_messages(message_status);

CREATE INDEX IF NOT EXISTS idx_patient_documents_consultation
ON patient_documents(consultation_id);

CREATE INDEX IF NOT EXISTS idx_patient_feedback_consultation
ON patient_feedback(consultation_id);

CREATE INDEX IF NOT EXISTS idx_patient_notifications_reference
ON patient_notifications(reference_id);

CREATE INDEX IF NOT EXISTS idx_patient_messages_sent_at
ON patient_messages(sent_at);

CREATE INDEX IF NOT EXISTS idx_patient_devices_last_active
ON patient_devices(last_active_at);

COMMIT;
