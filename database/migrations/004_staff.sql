-- ==========================================================
-- Suriyaraja Siddha Health Care ERP
-- Migration: 004_staff.sql
-- Description: Staff Master
-- ==========================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users.staff (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    staff_code TEXT UNIQUE NOT NULL,

    full_name TEXT NOT NULL,

    gender TEXT,

    date_of_birth DATE,

    phone TEXT,

    email TEXT,

    address TEXT,

    joining_date DATE,

    role_id UUID REFERENCES users.user_roles(id),

    qualification TEXT,

    department TEXT,

    salary NUMERIC(10,2),

    active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT now(),

    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_staff_code
ON users.staff(staff_code);

CREATE INDEX IF NOT EXISTS idx_staff_role
ON users.staff(role_id);
