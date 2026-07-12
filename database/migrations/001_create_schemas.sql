-- ==========================================================
-- Suriyaraja Siddha Health Care ERP
-- Migration: 001_create_schemas.sql
-- Description: Create all application schemas
-- ==========================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS users;
CREATE SCHEMA IF NOT EXISTS patients;
CREATE SCHEMA IF NOT EXISTS appointments;
CREATE SCHEMA IF NOT EXISTS consultations;
CREATE SCHEMA IF NOT EXISTS pharmacy;
CREATE SCHEMA IF NOT EXISTS inventory;
CREATE SCHEMA IF NOT EXISTS manufacturing;
CREATE SCHEMA IF NOT EXISTS billing;
CREATE SCHEMA IF NOT EXISTS accounts;
CREATE SCHEMA IF NOT EXISTS reports;
CREATE SCHEMA IF NOT EXISTS settings;
CREATE SCHEMA IF NOT EXISTS notifications;
CREATE SCHEMA IF NOT EXISTS audit;

COMMENT ON SCHEMA users IS 'Users, Doctors and Staff';
COMMENT ON SCHEMA patients IS 'Patient Management';
COMMENT ON SCHEMA appointments IS 'Appointment Management';
COMMENT ON SCHEMA consultations IS 'Clinical Consultation';
COMMENT ON SCHEMA pharmacy IS 'Pharmacy';
COMMENT ON SCHEMA inventory IS 'Inventory';
COMMENT ON SCHEMA manufacturing IS 'Medicine Manufacturing';
COMMENT ON SCHEMA billing IS 'Billing';
COMMENT ON SCHEMA accounts IS 'Accounts';
COMMENT ON SCHEMA reports IS 'Reports & Dashboard';
COMMENT ON SCHEMA settings IS 'Clinic Settings';
COMMENT ON SCHEMA notifications IS 'Alerts & Notifications';
COMMENT ON SCHEMA audit IS 'Audit Logs';
