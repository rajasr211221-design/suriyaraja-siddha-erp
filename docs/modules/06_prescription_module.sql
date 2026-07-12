-- ============================================================================
-- Suriyaraja Siddha Health Care ERP (SSHC ERP)
-- Migration : 06_prescription_module.sql
-- Version   : 1.0.0
-- Database  : PostgreSQL 17 (Supabase)
-- Author    : Dr. Raja Suriyaraja & ChatGPT
--
-- Description:
-- Prescription module for SSHC ERP.
-- Stores prescription headers, prescribed medicines,
-- Siddha formulations, dosage instructions,
-- dispensing status, refill information,
-- prescription notes and dispensing history.
--
-- This module integrates with:
-- • Consultations
-- • Medicines
-- • Pharmacy Inventory
-- • Billing
-- • Follow-up
-- ============================================================================

BEGIN;

-- ============================================================================
-- PRESCRIPTIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS prescriptions (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    prescription_number VARCHAR(20) NOT NULL UNIQUE,

    consultation_id UUID NOT NULL,

    patient_id UUID NOT NULL,

    doctor_id UUID NOT NULL,

    prescription_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    prescription_type VARCHAR(30) NOT NULL DEFAULT 'OP',

    prescription_status VARCHAR(30) NOT NULL DEFAULT 'Draft',

    validity_days INTEGER DEFAULT 30,

    total_medicines INTEGER DEFAULT 0,

    total_quantity NUMERIC(10,2) DEFAULT 0,

    dispensing_status VARCHAR(30) NOT NULL DEFAULT 'Pending',

    is_dispensed BOOLEAN NOT NULL DEFAULT FALSE,

    dispensed_at TIMESTAMPTZ,

    dispensed_by UUID REFERENCES user_profiles(id)
    ON DELETE RESTRICT,

    instructions TEXT,

    pharmacist_notes TEXT,

    doctor_notes TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_prescription_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_prescription_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_prescription_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT

);

COMMENT ON TABLE prescriptions IS
'Stores prescription header information generated after consultation.';

CREATE TRIGGER trg_prescriptions_updated_at
BEFORE UPDATE ON prescriptions
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PRESCRIPTION MEDICINES
-- ============================================================================

CREATE TABLE IF NOT EXISTS prescription_medicines (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    prescription_id UUID NOT NULL,

    medicine_id UUID NOT NULL,

    medicine_name VARCHAR(250),

    dosage VARCHAR(100),

    dosage_form VARCHAR(50),

    strength VARCHAR(100),

    route VARCHAR(50) DEFAULT 'Oral',

    frequency VARCHAR(100),

    timing VARCHAR(100),

    duration_days INTEGER,

    quantity_prescribed NUMERIC(10,2) NOT NULL,

    quantity_dispensed NUMERIC(10,2) DEFAULT 0,

    unit VARCHAR(30),

    before_food BOOLEAN,

    after_food BOOLEAN,

    with_food BOOLEAN,

    is_prn BOOLEAN NOT NULL DEFAULT FALSE,

    special_instructions TEXT,

    refill_allowed BOOLEAN NOT NULL DEFAULT FALSE,

    refill_count INTEGER DEFAULT 0,

    dispensing_status VARCHAR(30) DEFAULT 'Pending',

    batch_id UUID
    REFERENCES medicine_batches(id)
    ON DELETE RESTRICT,

    expiry_date DATE,

    unit_price NUMERIC(10,2),

    total_price NUMERIC(10,2),

    display_order INTEGER DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_prescription_medicine_prescription
        FOREIGN KEY (prescription_id)
        REFERENCES prescriptions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_prescription_medicine_master
        FOREIGN KEY (medicine_id)
        REFERENCES medicines(id)
        ON DELETE RESTRICT

);

COMMENT ON TABLE prescription_medicines IS
'Stores medicines prescribed in each prescription including dosage, duration, dispensing and pricing information.';

CREATE TRIGGER trg_prescription_medicines_updated_at
BEFORE UPDATE ON prescription_medicines
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PRESCRIPTION THERAPIES
-- ============================================================================

CREATE TABLE IF NOT EXISTS prescription_therapies (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    prescription_id UUID NOT NULL,

    therapy_id UUID NOT NULL,

    therapy_status VARCHAR(30) NOT NULL DEFAULT 'Planned',

    start_date DATE,

    end_date DATE,

    duration_days INTEGER,

    number_of_sessions INTEGER,

    completed_sessions INTEGER DEFAULT 0,

    frequency VARCHAR(100),

    performed_by UUID
    REFERENCES user_profiles(id)
    ON DELETE RESTRICT,

    requires_consent BOOLEAN NOT NULL DEFAULT FALSE,

    consent_received BOOLEAN NOT NULL DEFAULT FALSE,

    therapy_instructions TEXT,

    outcome TEXT,

    display_order INTEGER DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_prescription_therapy_prescription
        FOREIGN KEY (prescription_id)
        REFERENCES prescriptions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_prescription_therapy_master
        FOREIGN KEY (therapy_id)
        REFERENCES therapies(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_prescription_therapy
        UNIQUE (prescription_id, therapy_id)

);

COMMENT ON TABLE prescription_therapies IS
'Stores Siddha therapies prescribed along with medicines in a prescription.';

CREATE TRIGGER trg_prescription_therapies_updated_at
BEFORE UPDATE ON prescription_therapies
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PRESCRIPTION DIET ADVICE
-- ============================================================================

CREATE TABLE IF NOT EXISTS prescription_diet_advice (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    prescription_id UUID NOT NULL,

    food_id UUID NOT NULL,

    recommendation_type VARCHAR(20) NOT NULL,

    meal_time VARCHAR(50),

    quantity VARCHAR(100),

    duration VARCHAR(100),

    instructions TEXT,

    display_order INTEGER DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_prescription_diet_prescription
        FOREIGN KEY (prescription_id)
        REFERENCES prescriptions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_prescription_diet_food
        FOREIGN KEY (food_id)
        REFERENCES foods(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_prescription_diet
        UNIQUE (
            prescription_id,
            food_id,
            recommendation_type
        )

);

COMMENT ON TABLE prescription_diet_advice IS
'Stores final Pathiyam and Apathiyam advice printed on the prescription.';

CREATE TRIGGER trg_prescription_diet_advice_updated_at
BEFORE UPDATE ON prescription_diet_advice
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PRESCRIPTION LIFESTYLE ADVICE
-- ============================================================================

CREATE TABLE IF NOT EXISTS prescription_lifestyle_advice (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    prescription_id UUID NOT NULL,

    lifestyle_id UUID NOT NULL,

    recommendation_type VARCHAR(20),

    duration VARCHAR(100),

    frequency VARCHAR(100),

    instructions TEXT,

    display_order INTEGER DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_prescription_lifestyle_prescription
        FOREIGN KEY (prescription_id)
        REFERENCES prescriptions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_prescription_lifestyle_master
        FOREIGN KEY (lifestyle_id)
        REFERENCES lifestyle(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_prescription_lifestyle
        UNIQUE (
            prescription_id,
            lifestyle_id
        )

);

COMMENT ON TABLE prescription_lifestyle_advice IS
'Stores final lifestyle advice printed on the prescription.';

CREATE TRIGGER trg_prescription_lifestyle_advice_updated_at
BEFORE UPDATE ON prescription_lifestyle_advice
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PRESCRIPTION FOLLOW-UP
-- ============================================================================

CREATE TABLE IF NOT EXISTS prescription_followup (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    prescription_id UUID NOT NULL,

    followup_date DATE,

    followup_after_days INTEGER,

    followup_reason VARCHAR(200),

    followup_type VARCHAR(50),

    reminder_required BOOLEAN NOT NULL DEFAULT TRUE,

    reminder_sent BOOLEAN NOT NULL DEFAULT FALSE,

    status VARCHAR(30) NOT NULL DEFAULT 'Pending',

    instructions TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_prescription_followup_prescription
        FOREIGN KEY (prescription_id)
        REFERENCES prescriptions(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE prescription_followup IS
'Stores follow-up schedule and reminder information associated with a prescription.';

CREATE TRIGGER trg_prescription_followup_updated_at
BEFORE UPDATE ON prescription_followup
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PRESCRIPTION NOTES
-- ============================================================================

CREATE TABLE IF NOT EXISTS prescription_notes (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    prescription_id UUID NOT NULL,

    note_type VARCHAR(50),

    note_title VARCHAR(150),

    note_text TEXT NOT NULL,

    display_order INTEGER DEFAULT 1,

    is_printable BOOLEAN NOT NULL DEFAULT TRUE,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_prescription_notes_prescription
        FOREIGN KEY (prescription_id)
        REFERENCES prescriptions(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE prescription_notes IS
'Stores additional prescription notes, precautions, special instructions and printable remarks.';

CREATE TRIGGER trg_prescription_notes_updated_at
BEFORE UPDATE ON prescription_notes
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DISPENSING RECORDS
-- ============================================================================

CREATE TABLE IF NOT EXISTS dispensing_records (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    prescription_medicine_id UUID NOT NULL,

    dispensed_by UUID NOT NULL,

    batch_id UUID
    REFERENCES medicine_batches(id)
    ON DELETE RESTRICT,

    quantity_dispensed NUMERIC(10,2) NOT NULL,

    unit VARCHAR(30),

    unit_price NUMERIC(10,2),

    total_price NUMERIC(10,2),

    dispensed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    dispensing_status VARCHAR(30) NOT NULL DEFAULT 'Completed',

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_dispensing_prescription_medicine
        FOREIGN KEY (prescription_medicine_id)
        REFERENCES prescription_medicines(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_dispensing_user
        FOREIGN KEY (dispensed_by)
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT

);

COMMENT ON TABLE dispensing_records IS
'Stores medicine dispensing history for pharmacy, inventory deduction, FEFO batch tracking and audit purposes.';

CREATE TRIGGER trg_dispensing_records_updated_at
BEFORE UPDATE ON dispensing_records
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_prescriptions_number
ON prescriptions(prescription_number);

CREATE INDEX IF NOT EXISTS idx_prescriptions_consultation
ON prescriptions(consultation_id);

CREATE INDEX IF NOT EXISTS idx_prescriptions_patient
ON prescriptions(patient_id);

CREATE INDEX IF NOT EXISTS idx_prescriptions_doctor
ON prescriptions(doctor_id);

CREATE INDEX IF NOT EXISTS idx_prescriptions_date
ON prescriptions(prescription_date);

CREATE INDEX IF NOT EXISTS idx_prescriptions_status
ON prescriptions(prescription_status);

CREATE INDEX IF NOT EXISTS idx_prescriptions_dispensing_status
ON prescriptions(dispensing_status);

CREATE INDEX IF NOT EXISTS idx_prescription_medicines_prescription
ON prescription_medicines(prescription_id);

CREATE INDEX IF NOT EXISTS idx_prescription_medicines_medicine
ON prescription_medicines(medicine_id);

CREATE INDEX IF NOT EXISTS idx_prescription_medicines_status
ON prescription_medicines(dispensing_status);

CREATE INDEX IF NOT EXISTS idx_prescription_medicines_batch
ON prescription_medicines(batch_id);

CREATE INDEX IF NOT EXISTS idx_prescription_therapies_prescription
ON prescription_therapies(prescription_id);

CREATE INDEX IF NOT EXISTS idx_prescription_therapies_therapy
ON prescription_therapies(therapy_id);

CREATE INDEX IF NOT EXISTS idx_prescription_therapies_status
ON prescription_therapies(therapy_status);

CREATE INDEX IF NOT EXISTS idx_prescription_diet_advice_prescription
ON prescription_diet_advice(prescription_id);

CREATE INDEX IF NOT EXISTS idx_prescription_diet_advice_food
ON prescription_diet_advice(food_id);

CREATE INDEX IF NOT EXISTS idx_prescription_lifestyle_advice_prescription
ON prescription_lifestyle_advice(prescription_id);

CREATE INDEX IF NOT EXISTS idx_prescription_lifestyle_advice_lifestyle
ON prescription_lifestyle_advice(lifestyle_id);

CREATE INDEX IF NOT EXISTS idx_prescription_followup_prescription
ON prescription_followup(prescription_id);

CREATE INDEX IF NOT EXISTS idx_prescription_followup_date
ON prescription_followup(followup_date);

CREATE INDEX IF NOT EXISTS idx_prescription_followup_status
ON prescription_followup(status);

CREATE INDEX IF NOT EXISTS idx_prescription_notes_prescription
ON prescription_notes(prescription_id);

CREATE INDEX IF NOT EXISTS idx_dispensing_records_prescription_medicine
ON dispensing_records(prescription_medicine_id);

CREATE INDEX IF NOT EXISTS idx_dispensing_records_dispensed_by
ON dispensing_records(dispensed_by);

CREATE INDEX IF NOT EXISTS idx_dispensing_records_batch
ON dispensing_records(batch_id);

CREATE INDEX IF NOT EXISTS idx_dispensing_records_dispensed_at
ON dispensing_records(dispensed_at);

CREATE INDEX IF NOT EXISTS idx_dispensing_records_status
ON dispensing_records(dispensing_status);

COMMIT;
