-- ==========================================================
-- Suriyaraja Siddha Health Care ERP
-- Migration: 005_doctors.sql
-- Description: Doctors Master
-- ==========================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users.doctors (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    doctor_code TEXT UNIQUE NOT NULL,

    staff_id UUID REFERENCES users.staff(id),

    registration_no TEXT UNIQUE NOT NULL,

    full_name TEXT NOT NULL,

    qualification TEXT,

    specialization TEXT,

    experience_years INTEGER,

    consultation_fee NUMERIC(10,2),

    phone TEXT,

    email TEXT,

    active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT now(),

    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_doctors_registration
ON users.doctors(registration_no);

CREATE INDEX IF NOT EXISTS idx_doctors_staff
ON users.doctors(staff_id);
