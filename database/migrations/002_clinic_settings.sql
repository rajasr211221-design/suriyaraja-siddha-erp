-- ==========================================================
-- Suriyaraja Siddha Health Care ERP
-- Migration: 002_clinic_settings.sql
-- Description: Clinic master settings
-- ==========================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS settings.clinic_settings (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    clinic_name TEXT NOT NULL,
    registration_no TEXT NOT NULL,
    gst_no TEXT,
    drug_license_no TEXT,

    address TEXT,
    city TEXT,
    district TEXT,
    state TEXT,
    pincode TEXT,

    phone1 TEXT,
    phone2 TEXT,
    whatsapp TEXT,
    email TEXT,
    website TEXT,

    doctor_name TEXT,
    doctor_registration_no TEXT,

    logo_url TEXT,
    banner_url TEXT,

    clinic_timings TEXT,
    working_days TEXT,

    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO settings.clinic_settings (

    clinic_name,
    registration_no,
    doctor_name,
    doctor_registration_no,
    district,
    state,
    phone1,
    phone2,
    whatsapp,
    email,
    clinic_timings,
    working_days

)
VALUES (

    'Suriyaraja Siddha Health Care',
    'ERODSID20200015331',
    'Dr. Raja Suriyaraja',
    '8283',
    'Erode',
    'Tamil Nadu',
    '9150031833',
    '9842982233',
    '8825761967',
    'suriyarajasiddha@gmail.com',
    '10:00 AM - 8:00 PM',
    'Monday - Saturday'

)
ON CONFLICT DO NOTHING;
