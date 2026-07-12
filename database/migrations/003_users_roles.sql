-- ==========================================================
-- Suriyaraja Siddha Health Care ERP
-- Migration: 003_users_roles.sql
-- Description: User Roles Master
-- ========================================================== 

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users.user_roles (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    role_code VARCHAR(20) NOT NULL UNIQUE,
    role_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,

    is_system_role BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE users.user_roles IS
'Master list of ERP user roles';

CREATE INDEX IF NOT EXISTS idx_user_roles_code
ON users.user_roles(role_code);

CREATE INDEX IF NOT EXISTS idx_user_roles_active
ON users.user_roles(is_active);

INSERT INTO users.user_roles
(role_code, role_name, description)
VALUES

('ADMIN','Administrator','Full ERP Access'),

('DOCTOR','Doctor',
'Siddha Physician'),

('RECEPTION','Receptionist',
'Patient Registration & Appointment'),

('PHARMACY','Pharmacist',
'Pharmacy & Inventory'),

('THERAPIST','Therapist',
'Therapy Management'),

('ACCOUNTS','Accountant',
'Billing & Accounts'),

('LAB','Laboratory',
'Laboratory Management'),

('STORE','Store Manager',
'Inventory Control'),

('MANUFACTURING','Manufacturing',
'Medicine Manufacturing'),

('PATIENT','Patient',
'Patient Portal')

ON CONFLICT (role_code)
DO NOTHING;
