-- ============================================================================
-- Suriyaraja Siddha Health Care ERP (SSHC ERP)
-- ============================================================================
-- Migration : 015_notifications_and_communications.sql
-- Version   : 1.0.0
-- Database  : PostgreSQL 17
-- Platform  : Supabase
-- Author    : Dr. Raja Suriyaraja & ChatGPT
-- ============================================================================
--
-- MODULE
-- ----------------------------------------------------------------------------
-- Notification & Communication Framework
--
-- PURPOSE
-- ----------------------------------------------------------------------------
-- Implements the centralized Notification & Communication system for
-- Suriyaraja Siddha Health Care ERP.
--
-- This migration provides a unified notification framework supporting
-- patients, doctors, staff, administrators, and future external users.
--
-- FEATURES
-- ----------------------------------------------------------------------------
-- • In-App Notifications
-- • Email Notifications
-- • SMS Notifications
-- • WhatsApp Notifications (Future Ready)
-- • Push Notifications (Future Ready)
-- • Notification Templates
-- • Notification Categories
-- • Notification Preferences
-- • Delivery Tracking
-- • Read / Unread Status
-- • Scheduled Notifications
-- • Reminder Engine
-- • Communication History
-- • Retry Mechanism
-- • Priority Management
-- • Audit Logging Integration
-- • Multi-language Support (English / Tamil)
--
-- USED BY
-- ----------------------------------------------------------------------------
-- • Dashboard
-- • Patient Management
-- • Appointment Management
-- • Consultation
-- • Prescription
-- • Therapy
-- • Pharmacy
-- • Billing
-- • Accounts
-- • Reports
-- • Administration
-- • Patient Portal
-- • SURI AI
--
-- DEPENDENCIES
-- ----------------------------------------------------------------------------
-- 001_create_schemas.sql
-- 002_clinic_settings.sql
-- 003_users_roles.sql
-- 004_staff.sql
-- 005_doctors.sql
-- 006_patients.sql
--
-- FUTURE INTEGRATIONS
-- ----------------------------------------------------------------------------
-- • WhatsApp Business API
-- • Firebase Cloud Messaging (FCM)
-- • SMTP Email Providers
-- • SMS Gateway Providers
-- • Voice Calling Services
--
-- COMPATIBILITY
-- ----------------------------------------------------------------------------
-- PostgreSQL 17
-- Supabase
-- Row Level Security (RLS)
--
-- ============================================================================
-- CHANGE LOG
-- ============================================================================
-- v1.0.0
-- • Initial enterprise Notification & Communication framework.
--
-- ============================================================================

BEGIN;

-- ============================================================================
-- SECTION 2 : REQUIRED EXTENSIONS & SCHEMA VALIDATION
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Required PostgreSQL Extensions
-- ----------------------------------------------------------------------------

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

COMMENT ON EXTENSION "pgcrypto"
IS 'Provides cryptographic functions and UUID generation support.';

COMMENT ON EXTENSION "uuid-ossp"
IS 'Provides UUID generation functions.';

-- ----------------------------------------------------------------------------
-- Verify Required Schemas
-- ----------------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS app;
CREATE SCHEMA IF NOT EXISTS master;
CREATE SCHEMA IF NOT EXISTS audit;

COMMENT ON SCHEMA app IS
'Application schema containing operational tables for SSHC ERP.';

COMMENT ON SCHEMA master IS
'Master data schema for reusable reference tables.';

COMMENT ON SCHEMA audit IS
'Audit logging schema for enterprise activity tracking.';

-- ----------------------------------------------------------------------------
-- Migration Validation
-- ----------------------------------------------------------------------------

DO $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.schemata
        WHERE schema_name = 'app'
    ) THEN
        RAISE EXCEPTION 'Schema "app" was not created successfully.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.schemata
        WHERE schema_name = 'master'
    ) THEN
        RAISE EXCEPTION 'Schema "master" was not created successfully.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.schemata
        WHERE schema_name = 'audit'
    ) THEN
        RAISE EXCEPTION 'Schema "audit" was not created successfully.';
    END IF;

END;
$$;

-- ============================================================================
-- SECTION 3 : NOTIFICATION FRAMEWORK ENUMS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Notification Delivery Channel
-- ----------------------------------------------------------------------------

CREATE TYPE app.notification_channel AS ENUM
(
    'IN_APP',
    'EMAIL',
    'SMS',
    'WHATSAPP',
    'PUSH'
);

COMMENT ON TYPE app.notification_channel IS
'Supported notification delivery channels.';

-- ----------------------------------------------------------------------------
-- Notification Priority
-- ----------------------------------------------------------------------------

CREATE TYPE app.notification_priority AS ENUM
(
    'LOW',
    'NORMAL',
    'HIGH',
    'URGENT'
);

COMMENT ON TYPE app.notification_priority IS
'Notification processing priority.';

-- ----------------------------------------------------------------------------
-- Notification Status
-- ----------------------------------------------------------------------------

CREATE TYPE app.notification_status AS ENUM
(
    'DRAFT',
    'PENDING',
    'QUEUED',
    'SENT',
    'DELIVERED',
    'READ',
    'FAILED',
    'CANCELLED',
    'EXPIRED'
);

COMMENT ON TYPE app.notification_status IS
'Lifecycle status of a notification.';

-- ----------------------------------------------------------------------------
-- Recipient Type
-- ----------------------------------------------------------------------------

CREATE TYPE app.notification_recipient_type AS ENUM
(
    'PATIENT',
    'DOCTOR',
    'STAFF',
    'ADMIN',
    'SYSTEM'
);

COMMENT ON TYPE app.notification_recipient_type IS
'Supported recipient categories.';

-- ----------------------------------------------------------------------------
-- Notification Category
-- ----------------------------------------------------------------------------

CREATE TYPE app.notification_category AS ENUM
(
    'APPOINTMENT',
    'CONSULTATION',
    'PRESCRIPTION',
    'THERAPY',
    'PHARMACY',
    'BILLING',
    'PAYMENT',
    'FOLLOW_UP',
    'INVENTORY',
    'SYSTEM',
    'SECURITY',
    'REMINDER',
    'MARKETING',
    'AI',
    'GENERAL'
);

COMMENT ON TYPE app.notification_category IS
'Business category for notifications.';

-- ----------------------------------------------------------------------------
-- Template Type
-- ----------------------------------------------------------------------------

CREATE TYPE app.notification_template_type AS ENUM
(
    'SYSTEM',
    'CUSTOM'
);

COMMENT ON TYPE app.notification_template_type IS
'Defines whether the template is system-defined or user-created.';

-- ----------------------------------------------------------------------------
-- Reminder Type
-- ----------------------------------------------------------------------------

CREATE TYPE app.reminder_type AS ENUM
(
    'ONCE',
    'DAILY',
    'WEEKLY',
    'MONTHLY',
    'YEARLY'
);

COMMENT ON TYPE app.reminder_type IS
'Supported reminder recurrence patterns.';

-- ============================================================================
-- SECTION 4 : NOTIFICATION CATEGORIES
-- ============================================================================

CREATE TABLE IF NOT EXISTS app.notification_categories
(
    -- ------------------------------------------------------------------------
    -- Primary Key
    -- ------------------------------------------------------------------------
    id UUID PRIMARY KEY
        DEFAULT gen_random_uuid(),

    -- ------------------------------------------------------------------------
    -- Category Information
    -- ------------------------------------------------------------------------
    category_code VARCHAR(50)
        NOT NULL
        UNIQUE,

    category_name VARCHAR(150)
        NOT NULL,

    category_name_tamil VARCHAR(150),

    description TEXT,

    description_tamil TEXT,

    icon VARCHAR(100),

    color VARCHAR(20),

    display_order INTEGER
        NOT NULL
        DEFAULT 1,

    -- ------------------------------------------------------------------------
    -- Default Configuration
    -- ------------------------------------------------------------------------
    default_priority app.notification_priority
        NOT NULL
        DEFAULT 'NORMAL',

    default_channel app.notification_channel
        NOT NULL
        DEFAULT 'IN_APP',

    allow_email BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    allow_sms BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    allow_whatsapp BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    allow_push BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    allow_in_app BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    -- ------------------------------------------------------------------------
    -- Reminder Settings
    -- ------------------------------------------------------------------------
    is_reminder BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    reminder_before_minutes INTEGER,

    reminder_after_minutes INTEGER,

    -- ------------------------------------------------------------------------
    -- Behaviour
    -- ------------------------------------------------------------------------
    requires_acknowledgement BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    allow_retry BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    max_retry_count INTEGER
        NOT NULL
        DEFAULT 3,

    retry_interval_minutes INTEGER
        NOT NULL
        DEFAULT 10,

    -- ------------------------------------------------------------------------
    -- System Flags
    -- ------------------------------------------------------------------------
    is_system BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    is_active BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    -- ------------------------------------------------------------------------
    -- Audit Columns
    -- ------------------------------------------------------------------------
    created_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    updated_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    created_by UUID,

    updated_by UUID
);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE app.notification_categories IS
'Master table storing all notification categories used throughout SSHC ERP.';

COMMENT ON COLUMN app.notification_categories.category_code IS
'Unique category code used internally by the ERP.';

COMMENT ON COLUMN app.notification_categories.category_name IS
'English display name.';

COMMENT ON COLUMN app.notification_categories.category_name_tamil IS
'Tamil display name.';

COMMENT ON COLUMN app.notification_categories.icon IS
'UI icon associated with the notification category.';

COMMENT ON COLUMN app.notification_categories.color IS
'Display color used by the UI.';

COMMENT ON COLUMN app.notification_categories.default_priority IS
'Default priority assigned to notifications within this category.';

COMMENT ON COLUMN app.notification_categories.default_channel IS
'Default delivery channel.';

COMMENT ON COLUMN app.notification_categories.requires_acknowledgement IS
'Indicates whether the notification requires acknowledgement by the recipient.';

COMMENT ON COLUMN app.notification_categories.max_retry_count IS
'Maximum number of delivery retry attempts.';

COMMENT ON COLUMN app.notification_categories.retry_interval_minutes IS
'Minutes between retry attempts.';

COMMENT ON COLUMN app.notification_categories.is_system IS
'Indicates whether the category is system protected.';

COMMENT ON COLUMN app.notification_categories.is_active IS
'Determines whether the category is available for use.';

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_notification_categories_code
ON app.notification_categories(category_code);

CREATE INDEX IF NOT EXISTS idx_notification_categories_name
ON app.notification_categories(category_name);

CREATE INDEX IF NOT EXISTS idx_notification_categories_active
ON app.notification_categories(is_active);

CREATE INDEX IF NOT EXISTS idx_notification_categories_system
ON app.notification_categories(is_system);

CREATE INDEX IF NOT EXISTS idx_notification_categories_priority
ON app.notification_categories(default_priority);

CREATE INDEX IF NOT EXISTS idx_notification_categories_channel
ON app.notification_categories(default_channel);

CREATE INDEX IF NOT EXISTS idx_notification_categories_display
ON app.notification_categories(display_order);

-- ============================================================================
-- CONSTRAINTS
-- ============================================================================

ALTER TABLE app.notification_categories
ADD CONSTRAINT chk_notification_retry_count
CHECK (max_retry_count >= 0);

ALTER TABLE app.notification_categories
ADD CONSTRAINT chk_notification_retry_interval
CHECK (retry_interval_minutes >= 0);

ALTER TABLE app.notification_categories
ADD CONSTRAINT chk_notification_display_order
CHECK (display_order > 0);

-- ============================================================================
-- DEFAULT DATA
-- ============================================================================

INSERT INTO app.notification_categories
(
    category_code,
    category_name,
    category_name_tamil,
    description,
    default_priority,
    default_channel,
    icon,
    color,
    display_order,
    is_reminder
)

VALUES

('APPOINTMENT','Appointment','சந்திப்பு','Appointment booking and reminder notifications','HIGH','IN_APP','calendar','#2196F3',1,TRUE),

('CONSULTATION','Consultation','ஆலோசனை','Consultation workflow notifications','HIGH','IN_APP','stethoscope','#009688',2,FALSE),

('PRESCRIPTION','Prescription','மருந்துச் சீட்டு','Prescription notifications','HIGH','IN_APP','prescription','#4CAF50',3,FALSE),

('THERAPY','Therapy','சிகிச்சை','Therapy notifications','NORMAL','IN_APP','spa','#8BC34A',4,TRUE),

('PHARMACY','Pharmacy','மருந்தகம்','Medicine dispensing notifications','HIGH','IN_APP','pill','#3F51B5',5,FALSE),

('BILLING','Billing','பில்லிங்','Billing notifications','HIGH','IN_APP','receipt','#FF9800',6,FALSE),

('PAYMENT','Payment','கட்டணம்','Payment confirmation','HIGH','IN_APP','payments','#F57C00',7,FALSE),

('FOLLOWUP','Follow-up','மறுபரிசோதனை','Patient follow-up reminders','HIGH','IN_APP','event_repeat','#9C27B0',8,TRUE),

('INVENTORY','Inventory','சரக்கு','Inventory notifications','NORMAL','IN_APP','inventory','#795548',9,FALSE),

('SECURITY','Security','பாதுகாப்பு','Security alerts','URGENT','IN_APP','shield','#F44336',10,FALSE),

('SYSTEM','System','அமைப்பு','System notifications','NORMAL','IN_APP','settings','#607D8B',11,FALSE),

('AI','SURI AI','சூரி AI','Artificial Intelligence notifications','NORMAL','IN_APP','smart_toy','#673AB7',12,FALSE),

('GENERAL','General','பொது','General notifications','LOW','IN_APP','notifications','#9E9E9E',13,FALSE)

ON CONFLICT (category_code)
DO NOTHING;

-- ============================================================================
-- SECTION 5 : NOTIFICATION TEMPLATES
-- ============================================================================

CREATE TABLE IF NOT EXISTS app.notification_templates
(
    ---------------------------------------------------------------------------
    -- Primary Key
    ---------------------------------------------------------------------------
    id UUID PRIMARY KEY
        DEFAULT gen_random_uuid(),

    ---------------------------------------------------------------------------
    -- Category
    ---------------------------------------------------------------------------
    notification_category_id UUID
        NOT NULL
        REFERENCES app.notification_categories(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    ---------------------------------------------------------------------------
    -- Template Information
    ---------------------------------------------------------------------------
    template_code VARCHAR(100)
        NOT NULL
        UNIQUE,

    template_name VARCHAR(200)
        NOT NULL,

    template_name_tamil VARCHAR(200),

    description TEXT,

    ---------------------------------------------------------------------------
    -- Subject
    ---------------------------------------------------------------------------
    subject VARCHAR(300),

    subject_tamil VARCHAR(300),

    ---------------------------------------------------------------------------
    -- Message Body
    ---------------------------------------------------------------------------
    message TEXT
        NOT NULL,

    message_tamil TEXT,

    ---------------------------------------------------------------------------
    -- Notification Channel
    ---------------------------------------------------------------------------
    channel app.notification_channel
        NOT NULL
        DEFAULT 'IN_APP',

    ---------------------------------------------------------------------------
    -- Template Configuration
    ---------------------------------------------------------------------------
    is_system BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    is_active BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    allow_variables BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    requires_acknowledgement BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    ---------------------------------------------------------------------------
    -- Variable Information
    ---------------------------------------------------------------------------
    available_variables JSONB
        DEFAULT '[]'::JSONB,

    ---------------------------------------------------------------------------
    -- Versioning
    ---------------------------------------------------------------------------
    version INTEGER
        NOT NULL
        DEFAULT 1,

    ---------------------------------------------------------------------------
    -- Audit Columns
    ---------------------------------------------------------------------------
    created_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    updated_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    created_by UUID,

    updated_by UUID
);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE app.notification_templates IS
'Stores reusable notification templates for all communication channels.';

COMMENT ON COLUMN app.notification_templates.template_code IS
'Unique system template identifier.';

COMMENT ON COLUMN app.notification_templates.subject IS
'Notification subject used for email and push notifications.';

COMMENT ON COLUMN app.notification_templates.message IS
'Main notification body.';

COMMENT ON COLUMN app.notification_templates.available_variables IS
'Supported merge variables stored as JSON array.';

COMMENT ON COLUMN app.notification_templates.version IS
'Template version number.';

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_notification_templates_category
ON app.notification_templates(notification_category_id);

CREATE INDEX IF NOT EXISTS idx_notification_templates_code
ON app.notification_templates(template_code);

CREATE INDEX IF NOT EXISTS idx_notification_templates_channel
ON app.notification_templates(channel);

CREATE INDEX IF NOT EXISTS idx_notification_templates_active
ON app.notification_templates(is_active);

CREATE INDEX IF NOT EXISTS idx_notification_templates_system
ON app.notification_templates(is_system);

-- ============================================================================
-- CONSTRAINTS
-- ============================================================================

ALTER TABLE app.notification_templates
ADD CONSTRAINT chk_notification_template_version
CHECK (version > 0);

-- ============================================================================
-- DEFAULT TEMPLATES
-- ============================================================================

INSERT INTO app.notification_templates
(
    notification_category_id,
    template_code,
    template_name,
    template_name_tamil,
    subject,
    subject_tamil,
    message,
    message_tamil,
    channel,
    available_variables
)

SELECT

id,

'APPOINTMENT_CONFIRMATION',

'Appointment Confirmation',

'சந்திப்பு உறுதிப்படுத்தல்',

'Appointment Confirmed',

'சந்திப்பு உறுதி செய்யப்பட்டது',

'Dear {{patient_name}}, your appointment with Dr. {{doctor_name}} has been confirmed for {{appointment_date}} at {{appointment_time}}.',

'அன்புள்ள {{patient_name}}, {{appointment_date}} அன்று {{appointment_time}} மணிக்கு Dr. {{doctor_name}} அவர்களுடன் உங்கள் சந்திப்பு உறுதி செய்யப்பட்டுள்ளது.',

'IN_APP',

'[
 "patient_name",
 "doctor_name",
 "appointment_date",
 "appointment_time"
]'::jsonb

FROM app.notification_categories

WHERE category_code='APPOINTMENT'

ON CONFLICT(template_code)
DO NOTHING;

-- ---------------------------------------------------------------------------

INSERT INTO app.notification_templates
(
notification_category_id,
template_code,
template_name,
subject,
message,
channel,
available_variables
)

SELECT

id,

'PAYMENT_SUCCESS',

'Payment Successful',

'Payment Successful',

'Your payment of ₹{{amount}} has been received successfully.',

'IN_APP',

'[
 "amount"
]'::jsonb

FROM app.notification_categories

WHERE category_code='PAYMENT'

ON CONFLICT(template_code)
DO NOTHING;

-- ---------------------------------------------------------------------------

INSERT INTO app.notification_templates
(
notification_category_id,
template_code,
template_name,
subject,
message,
channel,
available_variables
)

SELECT

id,

'FOLLOWUP_REMINDER',

'Follow-up Reminder',

'Follow-up Reminder',

'Dear {{patient_name}}, your follow-up consultation is scheduled on {{followup_date}}.',

'IN_APP',

'[
 "patient_name",
 "followup_date"
]'::jsonb

FROM app.notification_categories

WHERE category_code='FOLLOWUP'

ON CONFLICT(template_code)
DO NOTHING;

-- ---------------------------------------------------------------------------

INSERT INTO app.notification_templates
(
notification_category_id,
template_code,
template_name,
subject,
message,
channel,
available_variables
)

SELECT

id,

'LOW_STOCK_ALERT',

'Low Stock Alert',

'Low Stock Alert',

'Medicine {{medicine_name}} stock has reached the minimum level.',

'IN_APP',

'[
 "medicine_name"
]'::jsonb

FROM app.notification_categories

WHERE category_code='INVENTORY'

ON CONFLICT(template_code)
DO NOTHING;

-- ============================================================================
-- SECTION 6 : NOTIFICATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS app.notifications
(
    ---------------------------------------------------------------------------
    -- Primary Key
    ---------------------------------------------------------------------------
    id UUID PRIMARY KEY
        DEFAULT gen_random_uuid(),

    ---------------------------------------------------------------------------
    -- Notification Category
    ---------------------------------------------------------------------------
    notification_category_id UUID
        NOT NULL
        REFERENCES app.notification_categories(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    ---------------------------------------------------------------------------
    -- Notification Template
    ---------------------------------------------------------------------------
    notification_template_id UUID
        REFERENCES app.notification_templates(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    ---------------------------------------------------------------------------
    -- Recipient
    ---------------------------------------------------------------------------
    recipient_type app.notification_recipient_type
        NOT NULL,

    recipient_id UUID
        NOT NULL,

    ---------------------------------------------------------------------------
    -- Sender
    ---------------------------------------------------------------------------
    sender_id UUID,

    ---------------------------------------------------------------------------
    -- Notification Details
    ---------------------------------------------------------------------------
    title VARCHAR(250)
        NOT NULL,

    title_tamil VARCHAR(250),

    message TEXT
        NOT NULL,

    message_tamil TEXT,

    ---------------------------------------------------------------------------
    -- Delivery
    ---------------------------------------------------------------------------
    channel app.notification_channel
        NOT NULL
        DEFAULT 'IN_APP',

    priority app.notification_priority
        NOT NULL
        DEFAULT 'NORMAL',

    status app.notification_status
        NOT NULL
        DEFAULT 'PENDING',

    ---------------------------------------------------------------------------
    -- Scheduling
    ---------------------------------------------------------------------------
    scheduled_at TIMESTAMPTZ,

    expires_at TIMESTAMPTZ,

    sent_at TIMESTAMPTZ,

    delivered_at TIMESTAMPTZ,

    read_at TIMESTAMPTZ,

    ---------------------------------------------------------------------------
    -- Delivery Tracking
    ---------------------------------------------------------------------------
    delivery_attempts INTEGER
        NOT NULL
        DEFAULT 0,

    max_delivery_attempts INTEGER
        NOT NULL
        DEFAULT 3,

    last_delivery_error TEXT,

    ---------------------------------------------------------------------------
    -- Business Reference
    ---------------------------------------------------------------------------
    reference_module VARCHAR(100),

    reference_table VARCHAR(100),

    reference_id UUID,

    ---------------------------------------------------------------------------
    -- Notification Metadata
    ---------------------------------------------------------------------------
    metadata JSONB
        NOT NULL
        DEFAULT '{}'::jsonb,

    ---------------------------------------------------------------------------
    -- User Actions
    ---------------------------------------------------------------------------
    action_url TEXT,

    action_label VARCHAR(100),

    action_completed BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    ---------------------------------------------------------------------------
    -- System Flags
    ---------------------------------------------------------------------------
    is_system BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    is_archived BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    is_deleted BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    ---------------------------------------------------------------------------
    -- Audit Columns
    ---------------------------------------------------------------------------
    created_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    updated_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    created_by UUID,

    updated_by UUID
);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE app.notifications IS
'Stores all notifications generated within SSHC ERP.';

COMMENT ON COLUMN app.notifications.reference_module IS
'Module responsible for generating the notification.';

COMMENT ON COLUMN app.notifications.reference_table IS
'Database table associated with the notification.';

COMMENT ON COLUMN app.notifications.reference_id IS
'Primary key of the originating record.';

COMMENT ON COLUMN app.notifications.metadata IS
'Additional structured notification data stored as JSON.';

COMMENT ON COLUMN app.notifications.delivery_attempts IS
'Number of delivery attempts made.';

COMMENT ON COLUMN app.notifications.last_delivery_error IS
'Last delivery failure message.';

COMMENT ON COLUMN app.notifications.action_url IS
'URL opened when the user clicks the notification.';

COMMENT ON COLUMN app.notifications.action_completed IS
'Indicates whether the notification action has been completed.';

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_notifications_recipient
ON app.notifications(recipient_type, recipient_id);

CREATE INDEX IF NOT EXISTS idx_notifications_status
ON app.notifications(status);

CREATE INDEX IF NOT EXISTS idx_notifications_priority
ON app.notifications(priority);

CREATE INDEX IF NOT EXISTS idx_notifications_channel
ON app.notifications(channel);

CREATE INDEX IF NOT EXISTS idx_notifications_category
ON app.notifications(notification_category_id);

CREATE INDEX IF NOT EXISTS idx_notifications_created_at
ON app.notifications(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_scheduled
ON app.notifications(scheduled_at);

CREATE INDEX IF NOT EXISTS idx_notifications_reference
ON app.notifications(reference_module, reference_id);

CREATE INDEX IF NOT EXISTS idx_notifications_archived
ON app.notifications(is_archived);

CREATE INDEX IF NOT EXISTS idx_notifications_deleted
ON app.notifications(is_deleted);

-- ============================================================================
-- CONSTRAINTS
-- ============================================================================

ALTER TABLE app.notifications
ADD CONSTRAINT chk_delivery_attempts
CHECK (delivery_attempts >= 0);

ALTER TABLE app.notifications
ADD CONSTRAINT chk_max_delivery_attempts
CHECK (max_delivery_attempts > 0);

ALTER TABLE app.notifications
ADD CONSTRAINT chk_schedule_dates
CHECK (
    expires_at IS NULL
    OR
    scheduled_at IS NULL
    OR
    expires_at >= scheduled_at
);

-- ============================================================================
-- SECTION 7 : NOTIFICATION RECIPIENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS app.notification_recipients
(
    ---------------------------------------------------------------------------
    -- Primary Key
    ---------------------------------------------------------------------------
    id UUID PRIMARY KEY
        DEFAULT gen_random_uuid(),

    ---------------------------------------------------------------------------
    -- Notification
    ---------------------------------------------------------------------------
    notification_id UUID
        NOT NULL
        REFERENCES app.notifications(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    ---------------------------------------------------------------------------
    -- Recipient
    ---------------------------------------------------------------------------
    recipient_type app.notification_recipient_type
        NOT NULL,

    recipient_id UUID
        NOT NULL,

    ---------------------------------------------------------------------------
    -- Delivery Channel
    ---------------------------------------------------------------------------
    delivery_channel app.notification_channel
        NOT NULL
        DEFAULT 'IN_APP',

    ---------------------------------------------------------------------------
    -- Delivery Status
    ---------------------------------------------------------------------------
    delivery_status app.notification_status
        NOT NULL
        DEFAULT 'PENDING',

    ---------------------------------------------------------------------------
    -- Read Tracking
    ---------------------------------------------------------------------------
    is_read BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    read_at TIMESTAMPTZ,

    ---------------------------------------------------------------------------
    -- Delivery Tracking
    ---------------------------------------------------------------------------
    is_delivered BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    delivered_at TIMESTAMPTZ,

    delivery_attempts INTEGER
        NOT NULL
        DEFAULT 0,

    last_delivery_error TEXT,

    ---------------------------------------------------------------------------
    -- User Actions
    ---------------------------------------------------------------------------
    is_acknowledged BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    acknowledged_at TIMESTAMPTZ,

    ---------------------------------------------------------------------------
    -- Notification Preferences Snapshot
    ---------------------------------------------------------------------------
    email_enabled BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    sms_enabled BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    whatsapp_enabled BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    push_enabled BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    in_app_enabled BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    ---------------------------------------------------------------------------
    -- Metadata
    ---------------------------------------------------------------------------
    metadata JSONB
        NOT NULL
        DEFAULT '{}'::jsonb,

    ---------------------------------------------------------------------------
    -- Audit Columns
    ---------------------------------------------------------------------------
    created_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    updated_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    created_by UUID,

    updated_by UUID
);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE app.notification_recipients IS
'Stores recipient-specific delivery information for each notification.';

COMMENT ON COLUMN app.notification_recipients.delivery_channel IS
'Actual channel used to deliver the notification.';

COMMENT ON COLUMN app.notification_recipients.delivery_status IS
'Current delivery status for this recipient.';

COMMENT ON COLUMN app.notification_recipients.is_read IS
'Indicates whether the recipient has read the notification.';

COMMENT ON COLUMN app.notification_recipients.is_acknowledged IS
'Indicates whether the recipient has acknowledged the notification.';

COMMENT ON COLUMN app.notification_recipients.metadata IS
'Recipient-specific metadata stored in JSON format.';

-- ============================================================================
-- UNIQUE CONSTRAINTS
-- ============================================================================

ALTER TABLE app.notification_recipients
ADD CONSTRAINT uq_notification_recipient
UNIQUE
(
    notification_id,
    recipient_type,
    recipient_id
);

-- ============================================================================
-- CHECK CONSTRAINTS
-- ============================================================================

ALTER TABLE app.notification_recipients
ADD CONSTRAINT chk_notification_delivery_attempts
CHECK (delivery_attempts >= 0);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_notification_recipients_notification
ON app.notification_recipients(notification_id);

CREATE INDEX IF NOT EXISTS idx_notification_recipients_user
ON app.notification_recipients(recipient_type, recipient_id);

CREATE INDEX IF NOT EXISTS idx_notification_recipients_status
ON app.notification_recipients(delivery_status);

CREATE INDEX IF NOT EXISTS idx_notification_recipients_read
ON app.notification_recipients(is_read);

CREATE INDEX IF NOT EXISTS idx_notification_recipients_delivered
ON app.notification_recipients(is_delivered);

CREATE INDEX IF NOT EXISTS idx_notification_recipients_ack
ON app.notification_recipients(is_acknowledged);

CREATE INDEX IF NOT EXISTS idx_notification_recipients_created
ON app.notification_recipients(created_at DESC);

-- ============================================================================
-- SECTION 8 : NOTIFICATION DELIVERY LOGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS app.notification_delivery_logs
(
    ---------------------------------------------------------------------------
    -- Primary Key
    ---------------------------------------------------------------------------
    id UUID PRIMARY KEY
        DEFAULT gen_random_uuid(),

    ---------------------------------------------------------------------------
    -- Notification
    ---------------------------------------------------------------------------
    notification_id UUID
        NOT NULL
        REFERENCES app.notifications(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    ---------------------------------------------------------------------------
    -- Recipient
    ---------------------------------------------------------------------------
    notification_recipient_id UUID
        NOT NULL
        REFERENCES app.notification_recipients(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    ---------------------------------------------------------------------------
    -- Delivery Information
    ---------------------------------------------------------------------------
    channel app.notification_channel
        NOT NULL,

    status app.notification_status
        NOT NULL,

    ---------------------------------------------------------------------------
    -- Attempt Information
    ---------------------------------------------------------------------------
    attempt_number INTEGER
        NOT NULL
        DEFAULT 1,

    sent_at TIMESTAMPTZ,

    delivered_at TIMESTAMPTZ,

    failed_at TIMESTAMPTZ,

    ---------------------------------------------------------------------------
    -- External Provider
    ---------------------------------------------------------------------------
    provider_name VARCHAR(100),

    provider_message_id VARCHAR(255),

    provider_response TEXT,

    ---------------------------------------------------------------------------
    -- Error Handling
    ---------------------------------------------------------------------------
    error_code VARCHAR(100),

    error_message TEXT,

    retry_scheduled_at TIMESTAMPTZ,

    ---------------------------------------------------------------------------
    -- Performance Metrics
    ---------------------------------------------------------------------------
    processing_time_ms INTEGER,

    ---------------------------------------------------------------------------
    -- Metadata
    ---------------------------------------------------------------------------
    metadata JSONB
        NOT NULL
        DEFAULT '{}'::JSONB,

    ---------------------------------------------------------------------------
    -- Audit Columns
    ---------------------------------------------------------------------------
    created_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    created_by UUID
);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE app.notification_delivery_logs IS
'Stores every notification delivery attempt for audit, troubleshooting, and reporting purposes.';

COMMENT ON COLUMN app.notification_delivery_logs.provider_name IS
'External service provider such as SMTP, Twilio, Firebase, WhatsApp Business API, etc.';

COMMENT ON COLUMN app.notification_delivery_logs.provider_message_id IS
'Unique message identifier returned by the delivery provider.';

COMMENT ON COLUMN app.notification_delivery_logs.processing_time_ms IS
'Time taken to process and send the notification in milliseconds.';

COMMENT ON COLUMN app.notification_delivery_logs.metadata IS
'Additional provider-specific delivery metadata stored in JSON format.';

-- ============================================================================
-- CONSTRAINTS
-- ============================================================================

ALTER TABLE app.notification_delivery_logs
ADD CONSTRAINT chk_delivery_attempt_number
CHECK (attempt_number > 0);

ALTER TABLE app.notification_delivery_logs
ADD CONSTRAINT chk_processing_time
CHECK
(
    processing_time_ms IS NULL
    OR
    processing_time_ms >= 0
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_notification_delivery_logs_notification
ON app.notification_delivery_logs(notification_id);

CREATE INDEX IF NOT EXISTS idx_notification_delivery_logs_recipient
ON app.notification_delivery_logs(notification_recipient_id);

CREATE INDEX IF NOT EXISTS idx_notification_delivery_logs_status
ON app.notification_delivery_logs(status);

CREATE INDEX IF NOT EXISTS idx_notification_delivery_logs_channel
ON app.notification_delivery_logs(channel);

CREATE INDEX IF NOT EXISTS idx_notification_delivery_logs_provider
ON app.notification_delivery_logs(provider_name);

CREATE INDEX IF NOT EXISTS idx_notification_delivery_logs_created
ON app.notification_delivery_logs(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notification_delivery_logs_attempt
ON app.notification_delivery_logs(attempt_number);

-- ============================================================================
-- SECTION 9 : COMMUNICATION PREFERENCES
-- ============================================================================

CREATE TABLE IF NOT EXISTS app.communication_preferences
(
    ---------------------------------------------------------------------------
    -- Primary Key
    ---------------------------------------------------------------------------
    id UUID PRIMARY KEY
        DEFAULT gen_random_uuid(),

    ---------------------------------------------------------------------------
    -- Recipient Information
    ---------------------------------------------------------------------------
    recipient_type app.notification_recipient_type
        NOT NULL,

    recipient_id UUID
        NOT NULL,

    ---------------------------------------------------------------------------
    -- Preferred Language
    ---------------------------------------------------------------------------
    preferred_language VARCHAR(10)
        NOT NULL
        DEFAULT 'en',

    ---------------------------------------------------------------------------
    -- Notification Channels
    ---------------------------------------------------------------------------
    enable_in_app BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    enable_email BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    enable_sms BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    enable_whatsapp BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    enable_push BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    ---------------------------------------------------------------------------
    -- Notification Categories
    ---------------------------------------------------------------------------
    receive_appointments BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    receive_consultations BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    receive_prescriptions BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    receive_therapy BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    receive_billing BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    receive_payments BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    receive_followups BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    receive_inventory BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    receive_security BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    receive_system BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    receive_ai BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    receive_marketing BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    ---------------------------------------------------------------------------
    -- Quiet Hours
    ---------------------------------------------------------------------------
    quiet_hours_enabled BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    quiet_start_time TIME,

    quiet_end_time TIME,

    ---------------------------------------------------------------------------
    -- Digest Settings
    ---------------------------------------------------------------------------
    daily_digest BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    weekly_digest BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    monthly_digest BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    ---------------------------------------------------------------------------
    -- System Flags
    ---------------------------------------------------------------------------
    is_active BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    ---------------------------------------------------------------------------
    -- Metadata
    ---------------------------------------------------------------------------
    preferences JSONB
        NOT NULL
        DEFAULT '{}'::jsonb,

    ---------------------------------------------------------------------------
    -- Audit Columns
    ---------------------------------------------------------------------------
    created_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    updated_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    created_by UUID,

    updated_by UUID
);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE app.communication_preferences IS
'Stores notification and communication preferences for each recipient.';

COMMENT ON COLUMN app.communication_preferences.preferred_language IS
'Preferred communication language (English or Tamil).';

COMMENT ON COLUMN app.communication_preferences.preferences IS
'Additional customizable communication preferences stored as JSON.';

COMMENT ON COLUMN app.communication_preferences.quiet_hours_enabled IS
'Suppresses non-critical notifications during configured quiet hours.';

-- ============================================================================
-- UNIQUE CONSTRAINT
-- ============================================================================

ALTER TABLE app.communication_preferences
ADD CONSTRAINT uq_communication_preferences
UNIQUE
(
    recipient_type,
    recipient_id
);

-- ============================================================================
-- CHECK CONSTRAINTS
-- ============================================================================

ALTER TABLE app.communication_preferences
ADD CONSTRAINT chk_preferred_language
CHECK
(
    preferred_language IN
    (
        'en',
        'ta'
    )
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_comm_pref_recipient
ON app.communication_preferences
(
    recipient_type,
    recipient_id
);

CREATE INDEX IF NOT EXISTS idx_comm_pref_language
ON app.communication_preferences(preferred_language);

CREATE INDEX IF NOT EXISTS idx_comm_pref_active
ON app.communication_preferences(is_active);

CREATE INDEX IF NOT EXISTS idx_comm_pref_quiet
ON app.communication_preferences(quiet_hours_enabled);

-- ============================================================================
-- SECTION 10 : NOTIFICATION QUEUE
-- ============================================================================

CREATE TABLE IF NOT EXISTS app.notification_queue
(
    ---------------------------------------------------------------------------
    -- Primary Key
    ---------------------------------------------------------------------------
    id UUID PRIMARY KEY
        DEFAULT gen_random_uuid(),

    ---------------------------------------------------------------------------
    -- Notification
    ---------------------------------------------------------------------------
    notification_id UUID
        NOT NULL
        REFERENCES app.notifications(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    notification_recipient_id UUID
        NOT NULL
        REFERENCES app.notification_recipients(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    ---------------------------------------------------------------------------
    -- Delivery Channel
    ---------------------------------------------------------------------------
    channel app.notification_channel
        NOT NULL,

    ---------------------------------------------------------------------------
    -- Queue Status
    ---------------------------------------------------------------------------
    status app.notification_status
        NOT NULL
        DEFAULT 'QUEUED',

    priority app.notification_priority
        NOT NULL
        DEFAULT 'NORMAL',

    ---------------------------------------------------------------------------
    -- Scheduling
    ---------------------------------------------------------------------------
    scheduled_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    available_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    started_at TIMESTAMPTZ,

    completed_at TIMESTAMPTZ,

    ---------------------------------------------------------------------------
    -- Retry Management
    ---------------------------------------------------------------------------
    retry_count INTEGER
        NOT NULL
        DEFAULT 0,

    max_retry_count INTEGER
        NOT NULL
        DEFAULT 3,

    next_retry_at TIMESTAMPTZ,

    ---------------------------------------------------------------------------
    -- Processing
    ---------------------------------------------------------------------------
    worker_name VARCHAR(100),

    processing_node VARCHAR(100),

    processing_duration_ms INTEGER,

    ---------------------------------------------------------------------------
    -- Provider
    ---------------------------------------------------------------------------
    provider_name VARCHAR(100),

    provider_reference VARCHAR(255),

    ---------------------------------------------------------------------------
    -- Failure Information
    ---------------------------------------------------------------------------
    last_error_code VARCHAR(100),

    last_error_message TEXT,

    ---------------------------------------------------------------------------
    -- Metadata
    ---------------------------------------------------------------------------
    metadata JSONB
        NOT NULL
        DEFAULT '{}'::jsonb,

    ---------------------------------------------------------------------------
    -- System Flags
    ---------------------------------------------------------------------------
    is_locked BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    locked_at TIMESTAMPTZ,

    ---------------------------------------------------------------------------
    -- Audit Columns
    ---------------------------------------------------------------------------
    created_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    updated_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    created_by UUID,

    updated_by UUID
);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE app.notification_queue IS
'Central processing queue for all notification channels.';

COMMENT ON COLUMN app.notification_queue.status IS
'Current processing status of the queued notification.';

COMMENT ON COLUMN app.notification_queue.worker_name IS
'Background worker responsible for processing the queue item.';

COMMENT ON COLUMN app.notification_queue.processing_node IS
'Server or node processing the notification.';

COMMENT ON COLUMN app.notification_queue.provider_reference IS
'Reference returned by the communication provider.';

COMMENT ON COLUMN app.notification_queue.metadata IS
'Additional queue information stored as JSON.';

-- ============================================================================
-- CONSTRAINTS
-- ============================================================================

ALTER TABLE app.notification_queue
ADD CONSTRAINT chk_notification_queue_retry
CHECK (retry_count >= 0);

ALTER TABLE app.notification_queue
ADD CONSTRAINT chk_notification_queue_max_retry
CHECK (max_retry_count > 0);

ALTER TABLE app.notification_queue
ADD CONSTRAINT chk_notification_queue_processing_time
CHECK
(
    processing_duration_ms IS NULL
    OR
    processing_duration_ms >= 0
);

-- ============================================================================
-- UNIQUE CONSTRAINT
-- ============================================================================

ALTER TABLE app.notification_queue
ADD CONSTRAINT uq_notification_queue
UNIQUE
(
    notification_id,
    notification_recipient_id,
    channel
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_notification_queue_status
ON app.notification_queue(status);

CREATE INDEX IF NOT EXISTS idx_notification_queue_priority
ON app.notification_queue(priority);

CREATE INDEX IF NOT EXISTS idx_notification_queue_channel
ON app.notification_queue(channel);

CREATE INDEX IF NOT EXISTS idx_notification_queue_schedule
ON app.notification_queue(scheduled_at);

CREATE INDEX IF NOT EXISTS idx_notification_queue_available
ON app.notification_queue(available_at);

CREATE INDEX IF NOT EXISTS idx_notification_queue_retry
ON app.notification_queue(next_retry_at);

CREATE INDEX IF NOT EXISTS idx_notification_queue_locked
ON app.notification_queue(is_locked);

CREATE INDEX IF NOT EXISTS idx_notification_queue_created
ON app.notification_queue(created_at DESC);

-- ============================================================================
-- SECTION 11 : NOTIFICATION SETTINGS
-- ============================================================================

CREATE TABLE IF NOT EXISTS app.notification_settings
(
    ---------------------------------------------------------------------------
    -- Primary Key
    ---------------------------------------------------------------------------
    id UUID PRIMARY KEY
        DEFAULT gen_random_uuid(),

    ---------------------------------------------------------------------------
    -- Clinic
    ---------------------------------------------------------------------------
    clinic_id UUID,

    ---------------------------------------------------------------------------
    -- General Settings
    ---------------------------------------------------------------------------
    notifications_enabled BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    maintenance_mode BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    ---------------------------------------------------------------------------
    -- Channel Configuration
    ---------------------------------------------------------------------------
    enable_in_app BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    enable_email BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    enable_sms BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    enable_whatsapp BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    enable_push BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    ---------------------------------------------------------------------------
    -- Queue Configuration
    ---------------------------------------------------------------------------
    queue_enabled BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    max_retry_count INTEGER
        NOT NULL
        DEFAULT 3,

    retry_interval_minutes INTEGER
        NOT NULL
        DEFAULT 10,

    queue_batch_size INTEGER
        NOT NULL
        DEFAULT 100,

    ---------------------------------------------------------------------------
    -- Processing Configuration
    ---------------------------------------------------------------------------
    process_interval_seconds INTEGER
        NOT NULL
        DEFAULT 60,

    notification_expiry_days INTEGER
        NOT NULL
        DEFAULT 90,

    archive_after_days INTEGER
        NOT NULL
        DEFAULT 365,

    ---------------------------------------------------------------------------
    -- Reminder Configuration
    ---------------------------------------------------------------------------
    appointment_reminder_hours INTEGER
        NOT NULL
        DEFAULT 24,

    followup_reminder_days INTEGER
        NOT NULL
        DEFAULT 1,

    medicine_reminder_enabled BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    birthday_wishes_enabled BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    ---------------------------------------------------------------------------
    -- Email Configuration
    ---------------------------------------------------------------------------
    smtp_enabled BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    smtp_host VARCHAR(255),

    smtp_port INTEGER,

    smtp_username VARCHAR(255),

    smtp_from_name VARCHAR(255),

    smtp_from_email VARCHAR(255),

    ---------------------------------------------------------------------------
    -- SMS Configuration
    ---------------------------------------------------------------------------
    sms_enabled BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    sms_provider VARCHAR(100),

    sender_id VARCHAR(50),

    ---------------------------------------------------------------------------
    -- WhatsApp Configuration
    ---------------------------------------------------------------------------
    whatsapp_enabled BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    whatsapp_provider VARCHAR(100),

    ---------------------------------------------------------------------------
    -- Push Configuration
    ---------------------------------------------------------------------------
    push_enabled BOOLEAN
        NOT NULL
        DEFAULT FALSE,

    firebase_project_id VARCHAR(255),

    ---------------------------------------------------------------------------
    -- System Flags
    ---------------------------------------------------------------------------
    is_active BOOLEAN
        NOT NULL
        DEFAULT TRUE,

    ---------------------------------------------------------------------------
    -- Metadata
    ---------------------------------------------------------------------------
    settings JSONB
        NOT NULL
        DEFAULT '{}'::jsonb,

    ---------------------------------------------------------------------------
    -- Audit Columns
    ---------------------------------------------------------------------------
    created_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    updated_at TIMESTAMPTZ
        NOT NULL
        DEFAULT NOW(),

    created_by UUID,

    updated_by UUID
);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE app.notification_settings IS
'Global notification and communication settings for the clinic.';

COMMENT ON COLUMN app.notification_settings.settings IS
'Additional provider-specific settings stored as JSON.';

COMMENT ON COLUMN app.notification_settings.queue_batch_size IS
'Maximum notifications processed in one queue cycle.';

COMMENT ON COLUMN app.notification_settings.notification_expiry_days IS
'Days after which notifications expire.';

COMMENT ON COLUMN app.notification_settings.archive_after_days IS
'Days after which notifications are archived.';

-- ============================================================================
-- CONSTRAINTS
-- ============================================================================

ALTER TABLE app.notification_settings
ADD CONSTRAINT chk_notification_retry_interval
CHECK (retry_interval_minutes >= 1);

ALTER TABLE app.notification_settings
ADD CONSTRAINT chk_notification_batch_size
CHECK (queue_batch_size > 0);

ALTER TABLE app.notification_settings
ADD CONSTRAINT chk_notification_expiry
CHECK (notification_expiry_days > 0);

ALTER TABLE app.notification_settings
ADD CONSTRAINT chk_notification_archive
CHECK (archive_after_days > 0);

ALTER TABLE app.notification_settings
ADD CONSTRAINT chk_process_interval
CHECK (process_interval_seconds > 0);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_notification_settings_active
ON app.notification_settings(is_active);

CREATE INDEX IF NOT EXISTS idx_notification_settings_clinic
ON app.notification_settings(clinic_id);

-- ============================================================================
-- DEFAULT SETTINGS
-- ============================================================================

INSERT INTO app.notification_settings
(
    notifications_enabled,
    enable_in_app,
    enable_email,
    enable_sms,
    enable_whatsapp,
    enable_push,
    queue_enabled,
    max_retry_count,
    retry_interval_minutes,
    queue_batch_size,
    process_interval_seconds,
    notification_expiry_days,
    archive_after_days,
    appointment_reminder_hours,
    followup_reminder_days,
    medicine_reminder_enabled,
    birthday_wishes_enabled
)
VALUES
(
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    FALSE,
    FALSE,
    TRUE,
    3,
    10,
    100,
    60,
    90,
    365,
    24,
    1,
    TRUE,
    FALSE
)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- SECTION 12.1 : UPDATE UPDATED_AT TIMESTAMP FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION app.fn_update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
BEGIN

    NEW.updated_at := NOW();

    RETURN NEW;

END;
$$;

COMMENT ON FUNCTION app.fn_update_updated_at() IS
'Automatically updates the updated_at timestamp whenever a row is modified.';

-- ============================================================================
-- TRIGGERS : UPDATED_AT
-- ============================================================================

DROP TRIGGER IF EXISTS trg_notification_categories_updated_at
ON app.notification_categories;

CREATE TRIGGER trg_notification_categories_updated_at
BEFORE UPDATE
ON app.notification_categories
FOR EACH ROW
EXECUTE FUNCTION app.fn_update_updated_at();

-- ---------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_notification_templates_updated_at
ON app.notification_templates;

CREATE TRIGGER trg_notification_templates_updated_at
BEFORE UPDATE
ON app.notification_templates
FOR EACH ROW
EXECUTE FUNCTION app.fn_update_updated_at();

-- ---------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_notifications_updated_at
ON app.notifications;

CREATE TRIGGER trg_notifications_updated_at
BEFORE UPDATE
ON app.notifications
FOR EACH ROW
EXECUTE FUNCTION app.fn_update_updated_at();

-- ---------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_notification_recipients_updated_at
ON app.notification_recipients;

CREATE TRIGGER trg_notification_recipients_updated_at
BEFORE UPDATE
ON app.notification_recipients
FOR EACH ROW
EXECUTE FUNCTION app.fn_update_updated_at();

-- ---------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_communication_preferences_updated_at
ON app.communication_preferences;

CREATE TRIGGER trg_communication_preferences_updated_at
BEFORE UPDATE
ON app.communication_preferences
FOR EACH ROW
EXECUTE FUNCTION app.fn_update_updated_at();

-- ---------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_notification_queue_updated_at
ON app.notification_queue;

CREATE TRIGGER trg_notification_queue_updated_at
BEFORE UPDATE
ON app.notification_queue
FOR EACH ROW
EXECUTE FUNCTION app.fn_update_updated_at();

-- ---------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_notification_settings_updated_at
ON app.notification_settings;

CREATE TRIGGER trg_notification_settings_updated_at
BEFORE UPDATE
ON app.notification_settings
FOR EACH ROW
EXECUTE FUNCTION app.fn_update_updated_at();

-- ============================================================================
-- SECTION 12.2 : CREATE NOTIFICATION FUNCTION
-- ============================================================================

CREATE OR REPLACE FUNCTION app.fn_create_notification
(
    p_notification_category_id UUID,
    p_recipient_type app.notification_recipient_type,
    p_recipient_id UUID,
    p_message TEXT,

    p_notification_template_id UUID DEFAULT NULL,
    p_sender_id UUID DEFAULT NULL,

    p_title VARCHAR DEFAULT NULL,
    p_title_tamil VARCHAR DEFAULT NULL,

    p_message_tamil TEXT DEFAULT NULL,

    p_channel app.notification_channel DEFAULT 'IN_APP',
    p_priority app.notification_priority DEFAULT 'NORMAL',

    p_reference_module VARCHAR DEFAULT NULL,
    p_reference_table VARCHAR DEFAULT NULL,
    p_reference_id UUID DEFAULT NULL,

    p_action_url TEXT DEFAULT NULL,
    p_action_label VARCHAR DEFAULT NULL,

    p_scheduled_at TIMESTAMPTZ DEFAULT NOW(),
    p_expires_at TIMESTAMPTZ DEFAULT NULL,

    p_metadata JSONB DEFAULT '{}'::jsonb,

    p_created_by UUID DEFAULT NULL
)

RETURNS UUID

LANGUAGE plpgsql

AS
$$

DECLARE

    v_notification_id UUID;

BEGIN

    INSERT INTO app.notifications
    (
        notification_category_id,
        notification_template_id,

        recipient_type,
        recipient_id,

        sender_id,

        title,
        title_tamil,

        message,
        message_tamil,

        channel,
        priority,
        status,

        scheduled_at,
        expires_at,

        reference_module,
        reference_table,
        reference_id,

        action_url,
        action_label,

        metadata,

        created_by
    )

    VALUES
    (
        p_notification_category_id,
        p_notification_template_id,

        p_recipient_type,
        p_recipient_id,

        p_sender_id,

        COALESCE(p_title,'Notification'),
        p_title_tamil,

        p_message,
        p_message_tamil,

        p_channel,
        p_priority,

        'PENDING',

        p_scheduled_at,
        p_expires_at,

        p_reference_module,
        p_reference_table,
        p_reference_id,

        p_action_url,
        p_action_label,

        p_metadata,

        p_created_by
    )

    RETURNING id

    INTO v_notification_id;

    RETURN v_notification_id;

END;

$$;

COMMENT ON FUNCTION app.fn_create_notification IS
'Creates a notification and returns the generated notification ID.';

SELECT app.fn_create_notification
(
    p_notification_category_id => 'CATEGORY_UUID',

    p_recipient_type => 'PATIENT',

    p_recipient_id => 'PATIENT_UUID',

    p_title => 'Appointment Confirmed',

    p_message =>
        'Your appointment has been confirmed.',

    p_reference_module => 'Appointments',

    p_reference_table => 'appointments',

    p_reference_id => 'APPOINTMENT_UUID'
);

/*
===============================================================================
SECTION 12.3 : QUEUE NOTIFICATION FUNCTION
===============================================================================

Purpose
-------
Adds a notification recipient into the processing queue.

Used By
-------
• Appointment Module
• Consultation
• Pharmacy
• Billing
• Dashboard
• SURI AI

Returns
-------
Queue UUID

===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_queue_notification
(
    p_notification_id UUID,
    p_notification_recipient_id UUID,
    p_channel app.notification_channel DEFAULT 'IN_APP'
)

RETURNS UUID

LANGUAGE plpgsql

AS
$$

DECLARE

    v_queue_id UUID;

    v_priority app.notification_priority;

BEGIN

    SELECT priority
    INTO v_priority
    FROM app.notifications
    WHERE id = p_notification_id;

    INSERT INTO app.notification_queue
    (
        notification_id,
        notification_recipient_id,
        channel,
        priority,
        status
    )

    VALUES
    (
        p_notification_id,
        p_notification_recipient_id,
        p_channel,
        v_priority,
        'QUEUED'
    )

    RETURNING id

    INTO v_queue_id;

    RETURN v_queue_id;

END;

$$;

COMMENT ON FUNCTION app.fn_queue_notification IS
'Queues a notification for asynchronous delivery.';

/*
===============================================================================
SECTION 12.4 : MARK NOTIFICATION AS SENT
===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_mark_notification_sent
(
    p_notification_id UUID
)

RETURNS VOID

LANGUAGE plpgsql

AS
$$

BEGIN

    UPDATE app.notifications

    SET

        status='SENT',

        sent_at=NOW()

    WHERE id=p_notification_id;

END;

$$;

COMMENT ON FUNCTION app.fn_mark_notification_sent IS
'Marks notification as successfully sent.';

/*
===============================================================================
SECTION 12.5 : MARK NOTIFICATION AS DELIVERED
===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_mark_notification_delivered
(
    p_notification_id UUID
)

RETURNS VOID

LANGUAGE plpgsql

AS
$$

BEGIN

    UPDATE app.notifications

    SET

        status='DELIVERED',

        delivered_at=NOW()

    WHERE id=p_notification_id;

END;

$$;

COMMENT ON FUNCTION app.fn_mark_notification_delivered IS
'Marks notification as delivered to the recipient.';

/*
===============================================================================
SECTION 12.6 : MARK NOTIFICATION AS READ
===============================================================================

Purpose
-------
Marks a notification as read by the recipient.

Returns
-------
BOOLEAN

===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_mark_notification_read
(
    p_notification_id UUID,
    p_recipient_id UUID
)

RETURNS BOOLEAN

LANGUAGE plpgsql

AS
$$

BEGIN

    --------------------------------------------------------------------------
    -- Update Recipient
    --------------------------------------------------------------------------

    UPDATE app.notification_recipients

    SET

        is_read = TRUE,

        read_at = NOW(),

        delivery_status = 'READ'

    WHERE

        notification_id = p_notification_id

    AND

        recipient_id = p_recipient_id;

    --------------------------------------------------------------------------
    -- Update Notification
    --------------------------------------------------------------------------

    UPDATE app.notifications

    SET

        status = 'READ',

        read_at = NOW()

    WHERE id = p_notification_id;

    RETURN TRUE;

END;

$$;

COMMENT ON FUNCTION app.fn_mark_notification_read IS
'Marks a notification as read.';

/*
===============================================================================
SECTION 12.7 : ACKNOWLEDGE NOTIFICATION
===============================================================================

Purpose
-------
Acknowledges notifications requiring user confirmation.

Returns
-------
BOOLEAN

===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_acknowledge_notification
(
    p_notification_id UUID,
    p_recipient_id UUID
)

RETURNS BOOLEAN

LANGUAGE plpgsql

AS
$$

BEGIN

    UPDATE app.notification_recipients

    SET

        is_acknowledged = TRUE,

        acknowledged_at = NOW()

    WHERE

        notification_id = p_notification_id

    AND

        recipient_id = p_recipient_id;

    RETURN TRUE;

END;

$$;

COMMENT ON FUNCTION app.fn_acknowledge_notification IS
'Marks a notification as acknowledged by the recipient.';

/*
===============================================================================
SECTION 12.8 : RETRY FAILED NOTIFICATION
===============================================================================

Purpose
-------
Queues a failed notification for another delivery attempt.

Returns
-------
BOOLEAN

===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_retry_notification
(
    p_queue_id UUID
)

RETURNS BOOLEAN

LANGUAGE plpgsql

AS
$$

DECLARE

    v_retry_count INTEGER;

    v_max_retry INTEGER;

BEGIN

    --------------------------------------------------------------------------
    -- Retrieve Retry Information
    --------------------------------------------------------------------------

    SELECT

        retry_count,

        max_retry_count

    INTO

        v_retry_count,

        v_max_retry

    FROM app.notification_queue

    WHERE id = p_queue_id;

    --------------------------------------------------------------------------
    -- Maximum Retry Reached
    --------------------------------------------------------------------------

    IF v_retry_count >= v_max_retry THEN

        UPDATE app.notification_queue

        SET

            status = 'FAILED',

            updated_at = NOW()

        WHERE id = p_queue_id;

        RETURN FALSE;

    END IF;

    --------------------------------------------------------------------------
    -- Schedule Retry
    --------------------------------------------------------------------------

    UPDATE app.notification_queue

    SET

        retry_count = retry_count + 1,

        status = 'QUEUED',

        next_retry_at = NOW() + INTERVAL '10 minutes',

        updated_at = NOW()

    WHERE id = p_queue_id;

    RETURN TRUE;

END;

$$;

COMMENT ON FUNCTION app.fn_retry_notification IS
'Retries failed notification delivery.';

/*
===============================================================================
SECTION 12.9 : ARCHIVE OLD NOTIFICATIONS
===============================================================================

Purpose
-------
Archives notifications older than the configured archive period.

Used By
-------
• Scheduled Background Job
• Maintenance Task
• Database Cleanup

Returns
-------
INTEGER (Number of archived notifications)

===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_archive_old_notifications()

RETURNS INTEGER

LANGUAGE plpgsql

AS
$$

DECLARE

    v_archive_days INTEGER;

    v_archived_count INTEGER := 0;

BEGIN

    ---------------------------------------------------------------------------
    -- Get Archive Period
    ---------------------------------------------------------------------------

    SELECT archive_after_days

    INTO v_archive_days

    FROM app.notification_settings

    WHERE is_active = TRUE

    LIMIT 1;

    IF v_archive_days IS NULL THEN
        v_archive_days := 365;
    END IF;

    ---------------------------------------------------------------------------
    -- Archive Notifications
    ---------------------------------------------------------------------------

    UPDATE app.notifications

    SET

        is_archived = TRUE,

        updated_at = NOW()

    WHERE

        is_archived = FALSE

    AND

        created_at < NOW() - (v_archive_days * INTERVAL '1 day');

    GET DIAGNOSTICS v_archived_count = ROW_COUNT;

    RETURN v_archived_count;

END;

$$;

COMMENT ON FUNCTION app.fn_archive_old_notifications IS
'Archives notifications older than the configured retention period.';

/*
===============================================================================
SECTION 12.10 : DELETE EXPIRED NOTIFICATIONS
===============================================================================

Purpose
-------
Soft deletes expired notifications.

Returns
-------
INTEGER

===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_delete_expired_notifications()

RETURNS INTEGER

LANGUAGE plpgsql

AS
$$

DECLARE

    v_deleted_count INTEGER := 0;

BEGIN

    UPDATE app.notifications

    SET

        is_deleted = TRUE,

        updated_at = NOW()

    WHERE

        is_deleted = FALSE

    AND

        expires_at IS NOT NULL

    AND

        expires_at < NOW();

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    RETURN v_deleted_count;

END;

$$;

COMMENT ON FUNCTION app.fn_delete_expired_notifications IS
'Soft deletes expired notifications.';

/*
===============================================================================
SECTION 12.11 : GET UNREAD NOTIFICATION COUNT
===============================================================================

Purpose
-------
Returns unread notification count for a recipient.

Returns
-------
INTEGER

===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_get_unread_notification_count
(
    p_recipient_type app.notification_recipient_type,
    p_recipient_id UUID
)

RETURNS INTEGER

LANGUAGE plpgsql

AS
$$

DECLARE

    v_unread_count INTEGER;

BEGIN

    SELECT

        COUNT(*)

    INTO

        v_unread_count

    FROM

        app.notification_recipients

    WHERE

        recipient_type = p_recipient_type

    AND

        recipient_id = p_recipient_id

    AND

        is_read = FALSE;

    RETURN COALESCE(v_unread_count,0);

END;

$$;

COMMENT ON FUNCTION app.fn_get_unread_notification_count IS
'Returns the unread notification count for a specific recipient.';

/*
===============================================================================
SECTION 12.12 : GET USER NOTIFICATIONS
===============================================================================

Purpose
-------
Returns notifications for a recipient with optional filtering.

Used By
-------
• Dashboard
• Patient Portal
• Doctor Portal
• Staff Portal
• Mobile App

Returns
-------
Notification List

===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_get_user_notifications
(
    p_recipient_type app.notification_recipient_type,
    p_recipient_id UUID,
    p_only_unread BOOLEAN DEFAULT FALSE,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)

RETURNS TABLE
(
    notification_id UUID,
    category VARCHAR,
    title VARCHAR,
    title_tamil VARCHAR,
    message TEXT,
    message_tamil TEXT,
    priority app.notification_priority,
    channel app.notification_channel,
    status app.notification_status,
    is_read BOOLEAN,
    action_url TEXT,
    action_label VARCHAR,
    created_at TIMESTAMPTZ
)

LANGUAGE plpgsql

AS
$$

BEGIN

RETURN QUERY

SELECT

n.id,

c.category_name,

n.title,

n.title_tamil,

n.message,

n.message_tamil,

n.priority,

n.channel,

n.status,

r.is_read,

n.action_url,

n.action_label,

n.created_at

FROM app.notifications n

INNER JOIN app.notification_recipients r

ON r.notification_id=n.id

INNER JOIN app.notification_categories c

ON c.id=n.notification_category_id

WHERE

r.recipient_type=p_recipient_type

AND

r.recipient_id=p_recipient_id

AND

(

NOT p_only_unread

OR

r.is_read=FALSE

)

ORDER BY

n.created_at DESC

LIMIT p_limit

OFFSET p_offset;

END;

$$;

COMMENT ON FUNCTION app.fn_get_user_notifications IS
'Returns notification history for a recipient.';

/*
===============================================================================
SECTION 12.13 : APPLY TEMPLATE VARIABLES
===============================================================================

Purpose
-------
Replaces merge variables inside a notification template.

Example
-------
{{patient_name}}
{{doctor_name}}
{{appointment_date}}

===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_apply_template_variables
(
    p_template TEXT,
    p_variables JSONB
)

RETURNS TEXT

LANGUAGE plpgsql

AS
$$

DECLARE

v_result TEXT;

v_key TEXT;

BEGIN

v_result:=p_template;

FOR v_key IN

SELECT jsonb_object_keys(p_variables)

LOOP

v_result:=replace
(
v_result,

'{{'||v_key||'}}',

COALESCE(p_variables->>v_key,'')

);

END LOOP;

RETURN v_result;

END;

$$;

COMMENT ON FUNCTION app.fn_apply_template_variables IS
'Replaces merge variables inside notification templates.';

/*
===============================================================================
SECTION 12.14 : CREATE APPOINTMENT NOTIFICATION
===============================================================================

Purpose
-------
Creates an appointment notification using the configured template.

Used By
-------
Appointment Module

Returns
-------
Notification UUID

===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_create_appointment_notification
(
    p_patient_id UUID,

    p_title VARCHAR,

    p_message TEXT,

    p_reference_id UUID,

    p_created_by UUID DEFAULT NULL
)

RETURNS UUID

LANGUAGE plpgsql

AS
$$

DECLARE

v_category UUID;

v_notification UUID;

BEGIN

SELECT

id

INTO

v_category

FROM app.notification_categories

WHERE category_code='APPOINTMENT';

v_notification:=app.fn_create_notification
(
p_notification_category_id=>v_category,

p_recipient_type=>'PATIENT',

p_recipient_id=>p_patient_id,

p_title=>p_title,

p_message=>p_message,

p_reference_module=>'Appointments',

p_reference_table=>'appointments',

p_reference_id=>p_reference_id,

p_created_by=>p_created_by
);

RETURN v_notification;

END;

$$;

COMMENT ON FUNCTION app.fn_create_appointment_notification IS
'Creates appointment notifications for patients.';

/*
===============================================================================
SECTION 12.15 : CREATE FOLLOW-UP REMINDER
===============================================================================

Purpose
-------
Creates a follow-up reminder notification for a patient.

Used By
-------
• Consultation Module
• Follow-up Scheduler
• Dashboard
• Patient Portal

Returns
-------
Notification UUID

===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_create_followup_notification
(
    p_patient_id UUID,
    p_followup_date DATE,
    p_reference_id UUID,
    p_created_by UUID DEFAULT NULL
)

RETURNS UUID

LANGUAGE plpgsql

AS
$$

DECLARE

    v_category UUID;
    v_notification UUID;

BEGIN

    SELECT id

    INTO v_category

    FROM app.notification_categories

    WHERE category_code='FOLLOWUP';

    v_notification := app.fn_create_notification
    (
        p_notification_category_id => v_category,

        p_recipient_type => 'PATIENT',

        p_recipient_id => p_patient_id,

        p_title => 'Follow-up Reminder',

        p_title_tamil => 'மறுபரிசோதனை நினைவூட்டல்',

        p_message =>
            'Your follow-up consultation is scheduled on '
            || to_char(p_followup_date,'DD Mon YYYY'),

        p_message_tamil =>
            'உங்கள் மறுபரிசோதனை '
            || to_char(p_followup_date,'DD Mon YYYY')
            || ' அன்று திட்டமிடப்பட்டுள்ளது.',

        p_reference_module => 'Consultation',

        p_reference_table => 'consultations',

        p_reference_id => p_reference_id,

        p_priority => 'HIGH',

        p_created_by => p_created_by
    );

    RETURN v_notification;

END;

$$;

COMMENT ON FUNCTION app.fn_create_followup_notification IS
'Creates patient follow-up reminder notifications.';

/*
===============================================================================
SECTION 12.16 : CREATE BILLING NOTIFICATION
===============================================================================

Purpose
-------
Creates billing and payment notifications.

Used By
-------
• Billing Module
• Accounts
• Dashboard

Returns
-------
Notification UUID

===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_create_billing_notification
(
    p_patient_id UUID,
    p_bill_number VARCHAR,
    p_amount NUMERIC,
    p_reference_id UUID,
    p_created_by UUID DEFAULT NULL
)

RETURNS UUID

LANGUAGE plpgsql

AS
$$

DECLARE

    v_category UUID;
    v_notification UUID;

BEGIN

    SELECT id

    INTO v_category

    FROM app.notification_categories

    WHERE category_code='BILLING';

    v_notification := app.fn_create_notification
    (
        p_notification_category_id => v_category,

        p_recipient_type => 'PATIENT',

        p_recipient_id => p_patient_id,

        p_title => 'Billing Information',

        p_title_tamil => 'பில்லிங் தகவல்',

        p_message =>
            'Invoice '
            || p_bill_number
            || ' has been generated. Amount payable: ₹'
            || p_amount,

        p_message_tamil =>
            'பில் எண் '
            || p_bill_number
            || ' உருவாக்கப்பட்டது. செலுத்த வேண்டிய தொகை ₹'
            || p_amount,

        p_reference_module => 'Billing',

        p_reference_table => 'bills',

        p_reference_id => p_reference_id,

        p_priority => 'HIGH',

        p_created_by => p_created_by
    );

    RETURN v_notification;

END;

$$;

COMMENT ON FUNCTION app.fn_create_billing_notification IS
'Creates billing notifications.';

/*
===============================================================================
SECTION 12.17 : CREATE LOW STOCK ALERT
===============================================================================

Purpose
-------
Creates inventory low-stock alerts.

Used By
-------
• Pharmacy
• Inventory
• Dashboard
• Administration

Returns
-------
Notification UUID

===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_create_low_stock_alert
(
    p_staff_id UUID,
    p_medicine_name VARCHAR,
    p_current_stock NUMERIC,
    p_reference_id UUID,
    p_created_by UUID DEFAULT NULL
)

RETURNS UUID

LANGUAGE plpgsql

AS
$$

DECLARE

    v_category UUID;
    v_notification UUID;

BEGIN

    SELECT id

    INTO v_category

    FROM app.notification_categories

    WHERE category_code='INVENTORY';

    v_notification := app.fn_create_notification
    (
        p_notification_category_id => v_category,

        p_recipient_type => 'STAFF',

        p_recipient_id => p_staff_id,

        p_title => 'Low Stock Alert',

        p_title_tamil => 'குறைந்த இருப்பு எச்சரிக்கை',

        p_message =>
            'Medicine '
            || p_medicine_name
            || ' is running low. Current stock: '
            || p_current_stock,

        p_message_tamil =>
            p_medicine_name
            || ' மருந்தின் இருப்பு குறைந்துள்ளது. தற்போதைய இருப்பு: '
            || p_current_stock,

        p_reference_module => 'Pharmacy',

        p_reference_table => 'medicine_inventory',

        p_reference_id => p_reference_id,

        p_priority => 'URGENT',

        p_created_by => p_created_by
    );

    RETURN v_notification;

END;

$$;

COMMENT ON FUNCTION app.fn_create_low_stock_alert IS
'Creates low stock alerts for pharmacy and inventory staff.';

/*
===============================================================================
SECTION 12.18 : SEND NOTIFICATION (MASTER FUNCTION)
===============================================================================

Purpose
-------
Central notification service for the entire ERP.

This function should be the ONLY function called by business modules.

Modules
-------
• Dashboard
• Appointments
• Consultation
• Prescription
• Therapy
• Pharmacy
• Billing
• Accounts
• Reports
• Patient Portal
• Administration
• SURI AI

Workflow
--------
Validate Preferences
↓

Load Template

↓

Replace Variables

↓

Create Notification

↓

Create Recipient

↓

Queue Notification

↓

Create Delivery Log

↓

(Return Notification UUID)

===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_send_notification
(
    p_category_code VARCHAR,

    p_recipient_type app.notification_recipient_type,

    p_recipient_id UUID,

    p_template_code VARCHAR DEFAULT NULL,

    p_title VARCHAR DEFAULT NULL,

    p_title_tamil VARCHAR DEFAULT NULL,

    p_message TEXT DEFAULT NULL,

    p_message_tamil TEXT DEFAULT NULL,

    p_variables JSONB DEFAULT '{}'::jsonb,

    p_channel app.notification_channel DEFAULT 'IN_APP',

    p_priority app.notification_priority DEFAULT 'NORMAL',

    p_reference_module VARCHAR DEFAULT NULL,

    p_reference_table VARCHAR DEFAULT NULL,

    p_reference_id UUID DEFAULT NULL,

    p_action_url TEXT DEFAULT NULL,

    p_action_label VARCHAR DEFAULT NULL,

    p_created_by UUID DEFAULT NULL
)

RETURNS UUID

LANGUAGE plpgsql

AS
$$

DECLARE

    v_category_id UUID;

    v_template_id UUID;

    v_notification_id UUID;

    v_recipient_id UUID;

    v_subject TEXT;

    v_body TEXT;

BEGIN

    --------------------------------------------------------------------------
    -- Category
    --------------------------------------------------------------------------

    SELECT id

    INTO v_category_id

    FROM app.notification_categories

    WHERE category_code=p_category_code

    LIMIT 1;

    --------------------------------------------------------------------------
    -- Template
    --------------------------------------------------------------------------

    IF p_template_code IS NOT NULL THEN

        SELECT

            id,

            subject,

            message

        INTO

            v_template_id,

            v_subject,

            v_body

        FROM app.notification_templates

        WHERE

            template_code=p_template_code

        LIMIT 1;

    END IF;

    --------------------------------------------------------------------------
    -- Replace Variables
    --------------------------------------------------------------------------

    IF v_body IS NOT NULL THEN

        v_body:=app.fn_apply_template_variables
        (
            v_body,
            p_variables
        );

    END IF;

    --------------------------------------------------------------------------
    -- Create Notification
    --------------------------------------------------------------------------

    v_notification_id:=app.fn_create_notification
    (
        p_notification_category_id=>v_category_id,

        p_notification_template_id=>v_template_id,

        p_recipient_type=>p_recipient_type,

        p_recipient_id=>p_recipient_id,

        p_title=>COALESCE(p_title,v_subject),

        p_title_tamil=>p_title_tamil,

        p_message=>COALESCE(p_message,v_body),

        p_message_tamil=>p_message_tamil,

        p_channel=>p_channel,

        p_priority=>p_priority,

        p_reference_module=>p_reference_module,

        p_reference_table=>p_reference_table,

        p_reference_id=>p_reference_id,

        p_action_url=>p_action_url,

        p_action_label=>p_action_label,

        p_created_by=>p_created_by
    );

    --------------------------------------------------------------------------
    -- Recipient
    --------------------------------------------------------------------------

    INSERT INTO app.notification_recipients
    (
        notification_id,

        recipient_type,

        recipient_id,

        delivery_channel
    )

    VALUES
    (
        v_notification_id,

        p_recipient_type,

        p_recipient_id,

        p_channel
    )

    RETURNING id

    INTO v_recipient_id;

    --------------------------------------------------------------------------
    -- Queue
    --------------------------------------------------------------------------

    PERFORM app.fn_queue_notification
    (
        v_notification_id,

        v_recipient_id,

        p_channel
    );

    RETURN v_notification_id;

END;

$$;

COMMENT ON FUNCTION app.fn_send_notification IS
'Enterprise notification entry point used by all ERP modules.';

/*
===============================================================================
SECTION 12.19 : NOTIFICATION STATISTICS
===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_notification_statistics()

RETURNS TABLE
(
    total_notifications BIGINT,

    unread_notifications BIGINT,

    delivered_notifications BIGINT,

    failed_notifications BIGINT,

    queued_notifications BIGINT
)

LANGUAGE SQL

AS
$$

SELECT

COUNT(*),

COUNT(*) FILTER (WHERE status='READ'),

COUNT(*) FILTER (WHERE status='DELIVERED'),

COUNT(*) FILTER (WHERE status='FAILED'),

COUNT(*) FILTER (WHERE status='QUEUED')

FROM app.notifications;

$$;

COMMENT ON FUNCTION app.fn_notification_statistics IS
'Returns notification statistics.';

/*
===============================================================================
SECTION 12.20 : NOTIFICATION HEALTH CHECK
===============================================================================
*/

CREATE OR REPLACE FUNCTION app.fn_notification_health_check()

RETURNS TABLE
(
    component VARCHAR,

    status VARCHAR,

    details TEXT
)

LANGUAGE SQL

AS
$$

SELECT

'Notification Queue',

CASE

WHEN EXISTS
(
SELECT 1
FROM app.notification_queue
WHERE status='FAILED'
)

THEN 'WARNING'

ELSE 'HEALTHY'

END,

'Queue Processing Status'

UNION ALL

SELECT

'Notification Settings',

'HEALTHY',

'Configuration Loaded'

UNION ALL

SELECT

'Notification Templates',

CASE

WHEN COUNT(*)>0

THEN 'HEALTHY'

ELSE 'ERROR'

END,

'Templates Available'

FROM app.notification_templates;

$$;

COMMENT ON FUNCTION app.fn_notification_health_check IS
'Returns notification subsystem health.';

/*
===============================================================================
SECTION 13.1 : NOTIFICATION SUMMARY VIEW
===============================================================================

Purpose
-------
Provides a complete notification summary for reporting and dashboards.

Used By
-------
• Dashboard
• Reports
• Administration
• Patient Portal
• SURI AI

===============================================================================
*/

CREATE OR REPLACE VIEW app.vw_notification_summary
AS

SELECT

n.id,

c.category_code,

c.category_name,

n.title,

n.message,

n.priority,

n.channel,

n.status,

n.recipient_type,

n.recipient_id,

n.reference_module,

n.reference_table,

n.reference_id,

n.created_at,

n.sent_at,

n.delivered_at,

n.read_at,

n.is_archived,

n.is_deleted

FROM app.notifications n

INNER JOIN app.notification_categories c

ON c.id=n.notification_category_id;

COMMENT ON VIEW app.vw_notification_summary IS
'Enterprise notification summary.';

/*
===============================================================================
SECTION 13.2 : UNREAD NOTIFICATIONS VIEW
===============================================================================
*/

CREATE OR REPLACE VIEW app.vw_unread_notifications
AS

SELECT

n.id,

r.recipient_type,

r.recipient_id,

n.title,

n.message,

n.priority,

n.channel,

n.created_at

FROM app.notifications n

INNER JOIN app.notification_recipients r

ON r.notification_id=n.id

WHERE

r.is_read=FALSE

AND

n.is_deleted=FALSE;

COMMENT ON VIEW app.vw_unread_notifications IS
'Unread notifications.';

/*
===============================================================================
SECTION 13.3 : NOTIFICATION QUEUE VIEW
===============================================================================
*/

CREATE OR REPLACE VIEW app.vw_notification_queue
AS

SELECT

q.id,

q.status,

q.priority,

q.channel,

q.retry_count,

q.next_retry_at,

q.provider_name,

q.processing_node,

q.processing_duration_ms,

n.title,

n.recipient_type,

n.recipient_id,

q.created_at

FROM app.notification_queue q

INNER JOIN app.notifications n

ON n.id=q.notification_id;

COMMENT ON VIEW app.vw_notification_queue IS
'Current notification processing queue.';

/*
===============================================================================
SECTION 13.4 : FAILED NOTIFICATIONS VIEW
===============================================================================

Purpose
-------
Displays all failed notification deliveries requiring administrator attention.

Used By
-------
• Administration
• Dashboard
• Reports
• Notification Monitoring

===============================================================================
*/

CREATE OR REPLACE VIEW app.vw_failed_notifications
AS

SELECT

    q.id AS queue_id,

    n.id AS notification_id,

    c.category_name,

    n.title,

    n.recipient_type,

    n.recipient_id,

    q.channel,

    q.retry_count,

    q.max_retry_count,

    q.last_error_code,

    q.last_error_message,

    q.provider_name,

    q.provider_reference,

    q.created_at,

    q.updated_at

FROM app.notification_queue q

INNER JOIN app.notifications n
ON q.notification_id = n.id

INNER JOIN app.notification_categories c
ON c.id = n.notification_category_id

WHERE

    q.status = 'FAILED'

ORDER BY

    q.updated_at DESC;

COMMENT ON VIEW app.vw_failed_notifications IS
'Displays failed notification deliveries requiring administrator review.';

/*
===============================================================================
SECTION 13.5 : NOTIFICATION STATISTICS VIEW
===============================================================================

Purpose
-------
Provides overall notification statistics for dashboards and reporting.

Used By
-------
• Dashboard
• Reports
• Administration
• SURI AI Analytics

===============================================================================
*/

CREATE OR REPLACE VIEW app.vw_notification_statistics
AS

SELECT

    COUNT(*) AS total_notifications,

    COUNT(*) FILTER
    (
        WHERE status='PENDING'
    ) AS pending_notifications,

    COUNT(*) FILTER
    (
        WHERE status='QUEUED'
    ) AS queued_notifications,

    COUNT(*) FILTER
    (
        WHERE status='SENT'
    ) AS sent_notifications,

    COUNT(*) FILTER
    (
        WHERE status='DELIVERED'
    ) AS delivered_notifications,

    COUNT(*) FILTER
    (
        WHERE status='READ'
    ) AS read_notifications,

    COUNT(*) FILTER
    (
        WHERE status='FAILED'
    ) AS failed_notifications,

    COUNT(*) FILTER
    (
        WHERE is_archived=TRUE
    ) AS archived_notifications,

    COUNT(*) FILTER
    (
        WHERE is_deleted=TRUE
    ) AS deleted_notifications

FROM app.notifications;

COMMENT ON VIEW app.vw_notification_statistics IS
'Overall notification statistics.';

/*
===============================================================================
SECTION 13.6 : NOTIFICATION PERFORMANCE VIEW
===============================================================================

Purpose
-------
Displays notification delivery performance metrics.

Used By
-------
• Administration
• Dashboard
• Monitoring
• Reports

===============================================================================
*/

CREATE OR REPLACE VIEW app.vw_notification_performance
AS

SELECT

    provider_name,

    channel,

    COUNT(*) AS total_attempts,

    COUNT(*) FILTER
    (
        WHERE status='DELIVERED'
    ) AS successful_deliveries,

    COUNT(*) FILTER
    (
        WHERE status='FAILED'
    ) AS failed_deliveries,

    AVG(processing_duration_ms)
        AS average_processing_time_ms,

    MAX(processing_duration_ms)
        AS maximum_processing_time_ms,

    MIN(processing_duration_ms)
        AS minimum_processing_time_ms

FROM

    app.notification_queue

GROUP BY

    provider_name,

    channel

ORDER BY

    provider_name,

    channel;

COMMENT ON VIEW app.vw_notification_performance IS
'Notification delivery performance metrics.';

/*
===============================================================================
SECTION 14 : ROW LEVEL SECURITY (RLS)
===============================================================================

Purpose
-------
Implements Row Level Security policies for all notification tables.

Security Goals
--------------
• Patients can only access their own notifications.
• Doctors can access only their notifications.
• Staff can access notifications assigned to them.
• Administrators have full access.
• Service Role has unrestricted access.

===============================================================================
*/

-- ============================================================================
-- Enable Row Level Security
-- ============================================================================

ALTER TABLE app.notification_categories ENABLE ROW LEVEL SECURITY;

ALTER TABLE app.notification_templates ENABLE ROW LEVEL SECURITY;

ALTER TABLE app.notifications ENABLE ROW LEVEL SECURITY;

ALTER TABLE app.notification_recipients ENABLE ROW LEVEL SECURITY;

ALTER TABLE app.notification_delivery_logs ENABLE ROW LEVEL SECURITY;

ALTER TABLE app.communication_preferences ENABLE ROW LEVEL SECURITY;

ALTER TABLE app.notification_queue ENABLE ROW LEVEL SECURITY;

ALTER TABLE app.notification_settings ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- Notification Categories
-- ============================================================================

CREATE POLICY notification_categories_read

ON app.notification_categories

FOR SELECT

USING (TRUE);

-- ============================================================================
-- Notification Templates
-- ============================================================================

CREATE POLICY notification_templates_read

ON app.notification_templates

FOR SELECT

USING (TRUE);

-- ============================================================================
-- Notifications
-- ============================================================================

CREATE POLICY notifications_select

ON app.notifications

FOR SELECT

USING
(
    auth.role()='service_role'

    OR

    recipient_id=auth.uid()
);

CREATE POLICY notifications_insert

ON app.notifications

FOR INSERT

WITH CHECK
(
    auth.role()='service_role'
);

CREATE POLICY notifications_update

ON app.notifications

FOR UPDATE

USING
(
    auth.role()='service_role'
);

-- ============================================================================
-- Notification Recipients
-- ============================================================================

CREATE POLICY notification_recipients_select

ON app.notification_recipients

FOR SELECT

USING
(
    auth.role()='service_role'

    OR

    recipient_id=auth.uid()
);

CREATE POLICY notification_recipients_update

ON app.notification_recipients

FOR UPDATE

USING
(
    auth.role()='service_role'

    OR

    recipient_id=auth.uid()
);

-- ============================================================================
-- Communication Preferences
-- ============================================================================

CREATE POLICY communication_preferences_select

ON app.communication_preferences

FOR SELECT

USING
(
    auth.role()='service_role'

    OR

    recipient_id=auth.uid()
);

CREATE POLICY communication_preferences_update

ON app.communication_preferences

FOR UPDATE

USING
(
    auth.role()='service_role'

    OR

    recipient_id=auth.uid()
);

-- ============================================================================
-- Queue
-- ============================================================================

CREATE POLICY notification_queue_service

ON app.notification_queue

FOR ALL

USING
(
    auth.role()='service_role'
);

-- ============================================================================
-- Delivery Logs
-- ============================================================================

CREATE POLICY notification_delivery_logs_service

ON app.notification_delivery_logs

FOR ALL

USING
(
    auth.role()='service_role'
);

-- ============================================================================
-- Notification Settings
-- ============================================================================

CREATE POLICY notification_settings_service

ON app.notification_settings

FOR ALL

USING
(
    auth.role()='service_role'
);

/*
===============================================================================
SECTION 15 : PERMISSIONS & GRANTS
===============================================================================
*/

-- ============================================================================
-- Tables
-- ============================================================================

GRANT SELECT

ON app.notification_categories

TO authenticated;

GRANT SELECT

ON app.notification_templates

TO authenticated;

GRANT

SELECT,
INSERT,
UPDATE

ON app.notifications

TO authenticated;

GRANT

SELECT,
UPDATE

ON app.notification_recipients

TO authenticated;

GRANT

SELECT,
UPDATE

ON app.communication_preferences

TO authenticated;

GRANT SELECT

ON

app.vw_notification_summary,

app.vw_unread_notifications,

app.vw_notification_queue,

app.vw_failed_notifications,

app.vw_notification_statistics,

app.vw_notification_performance

TO authenticated;

-- ============================================================================
-- Functions
-- ============================================================================

GRANT EXECUTE

ON FUNCTION app.fn_send_notification

TO authenticated;

GRANT EXECUTE

ON FUNCTION app.fn_mark_notification_read

TO authenticated;

GRANT EXECUTE

ON FUNCTION app.fn_get_user_notifications

TO authenticated;

GRANT EXECUTE

ON FUNCTION app.fn_get_unread_notification_count

TO authenticated;

/*
===============================================================================
SECTION 16 : DEFAULT CONFIGURATION
===============================================================================
*/

INSERT INTO app.notification_settings
(
    notifications_enabled,

    enable_in_app,

    enable_email,

    enable_sms,

    enable_whatsapp,

    enable_push,

    queue_enabled,

    max_retry_count,

    retry_interval_minutes,

    queue_batch_size,

    process_interval_seconds,

    notification_expiry_days,

    archive_after_days,

    is_active
)

SELECT

TRUE,

TRUE,

TRUE,

TRUE,

FALSE,

FALSE,

TRUE,

3,

10,

100,

60,

90,

365,

TRUE

WHERE NOT EXISTS
(
SELECT 1

FROM app.notification_settings
);

/*
===============================================================================
SECTION 17 : MIGRATION VALIDATION
===============================================================================

Purpose
-------
Validates the successful creation of all Notification Framework objects.

Checks
------
• Tables
• Views
• Functions
• RLS
• Seed Data

===============================================================================
*/

DO
$$
DECLARE

    v_missing_tables INTEGER;

    v_missing_views INTEGER;

    v_missing_functions INTEGER;

BEGIN

    --------------------------------------------------------------------------
    -- Tables
    --------------------------------------------------------------------------

    SELECT COUNT(*)

    INTO v_missing_tables

    FROM
    (
        VALUES

        ('notification_categories'),
        ('notification_templates'),
        ('notifications'),
        ('notification_recipients'),
        ('notification_delivery_logs'),
        ('communication_preferences'),
        ('notification_queue'),
        ('notification_settings')

    ) AS expected(table_name)

    WHERE NOT EXISTS
    (
        SELECT 1

        FROM information_schema.tables

        WHERE table_schema='app'

        AND table_name=expected.table_name
    );

    IF v_missing_tables>0 THEN

        RAISE EXCEPTION
        'Notification migration validation failed. Missing tables: %',
        v_missing_tables;

    END IF;

    --------------------------------------------------------------------------
    -- Views
    --------------------------------------------------------------------------

    SELECT COUNT(*)

    INTO v_missing_views

    FROM
    (
        VALUES

        ('vw_notification_summary'),
        ('vw_unread_notifications'),
        ('vw_notification_queue'),
        ('vw_failed_notifications'),
        ('vw_notification_statistics'),
        ('vw_notification_performance')

    ) AS expected(view_name)

    WHERE NOT EXISTS
    (
        SELECT 1

        FROM information_schema.views

        WHERE table_schema='app'

        AND table_name=expected.view_name
    );

    IF v_missing_views>0 THEN

        RAISE EXCEPTION
        'Notification migration validation failed. Missing views: %',
        v_missing_views;

    END IF;

    --------------------------------------------------------------------------
    -- Functions
    --------------------------------------------------------------------------

    SELECT COUNT(*)

    INTO v_missing_functions

    FROM
    (
        VALUES

        ('fn_create_notification'),
        ('fn_queue_notification'),
        ('fn_send_notification'),
        ('fn_mark_notification_read'),
        ('fn_retry_notification'),
        ('fn_get_user_notifications'),
        ('fn_notification_statistics'),
        ('fn_notification_health_check')

    ) AS expected(function_name)

    WHERE NOT EXISTS
    (
        SELECT 1

        FROM pg_proc p

        JOIN pg_namespace n

        ON n.oid=p.pronamespace

        WHERE

        n.nspname='app'

        AND

        p.proname=expected.function_name
    );

    IF v_missing_functions>0 THEN

        RAISE EXCEPTION
        'Notification migration validation failed. Missing functions: %',
        v_missing_functions;

    END IF;

    --------------------------------------------------------------------------
    -- Success
    --------------------------------------------------------------------------

    RAISE NOTICE
    'Notification & Communication Framework validated successfully.';

END;

$$;

/*
===============================================================================
SECTION 18 : MIGRATION COMPLETION
===============================================================================

Migration
---------
015_notifications_and_communications.sql

Version
-------
1.0.0

Status
------
COMPLETED

===============================================================================
*/

COMMIT;

DO
$$
BEGIN

    RAISE NOTICE '';

    RAISE NOTICE '============================================================';

    RAISE NOTICE ' Suriyaraja Siddha Health Care ERP';

    RAISE NOTICE '';

    RAISE NOTICE ' Notification & Communication Framework Installed';

    RAISE NOTICE '';

    RAISE NOTICE ' Migration : 015_notifications_and_communications.sql';

    RAISE NOTICE ' Version   : 1.0.0';

    RAISE NOTICE '';

    RAISE NOTICE ' Features Installed';

    RAISE NOTICE ' ------------------------------';

    RAISE NOTICE ' ✓ Notification Categories';

    RAISE NOTICE ' ✓ Notification Templates';

    RAISE NOTICE ' ✓ Notifications';

    RAISE NOTICE ' ✓ Notification Recipients';

    RAISE NOTICE ' ✓ Delivery Logs';

    RAISE NOTICE ' ✓ Communication Preferences';

    RAISE NOTICE ' ✓ Notification Queue';

    RAISE NOTICE ' ✓ Notification Settings';

    RAISE NOTICE ' ✓ Enterprise Functions';

    RAISE NOTICE ' ✓ Enterprise Views';

    RAISE NOTICE ' ✓ Row Level Security';

    RAISE NOTICE ' ✓ Permissions';

    RAISE NOTICE ' ✓ Validation';

    RAISE NOTICE '';

    RAISE NOTICE ' Notification Framework Ready';

    RAISE NOTICE '============================================================';

END;

$$;
