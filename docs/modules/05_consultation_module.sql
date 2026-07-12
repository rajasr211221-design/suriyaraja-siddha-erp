-- ============================================================================
-- Suriyaraja Siddha Health Care ERP (SSHC ERP)
-- Migration : 05_consultation_module.sql
-- Version   : 1.0.0
-- Database  : PostgreSQL 17 (Supabase)
-- Author    : Dr. Raja Suriyaraja & ChatGPT
--
-- Description:
-- Consultation module for SSHC ERP.
-- Stores consultation records, patient vitals,
-- general examination, Siddha examination
-- (Envagai Thervu, Naadi, Neerkuri, Neikuri),
-- complaints, symptoms, diagnoses,
-- investigations, therapies, diet advice,
-- lifestyle advice and clinical notes.
-- ============================================================================

BEGIN;

-- ============================================================================
-- CONSULTATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS consultations (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    consultation_number VARCHAR(20) NOT NULL UNIQUE,

    op_registration_id UUID NOT NULL,

    patient_id UUID NOT NULL,

    doctor_id UUID NOT NULL,

    consultation_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    consultation_type VARCHAR(30) NOT NULL DEFAULT 'New',

    consultation_status VARCHAR(30) NOT NULL DEFAULT 'In Progress',

    provisional_diagnosis TEXT,

    final_diagnosis TEXT,

    consultation_notes TEXT,

    followup_required BOOLEAN NOT NULL DEFAULT FALSE,

    followup_after_days INTEGER,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_consultation_op
        FOREIGN KEY (op_registration_id)
        REFERENCES op_registrations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_consultation_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_consultation_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES user_profiles(id)

);

COMMENT ON TABLE consultations IS
'Stores consultation details for each OP visit.';

CREATE TRIGGER trg_consultations_updated_at
BEFORE UPDATE ON consultations
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PATIENT VITALS
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_vitals (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    consultation_id UUID NOT NULL,

    height_cm NUMERIC(5,2),

    weight_kg NUMERIC(5,2),

    bmi NUMERIC(5,2),

    pulse_rate INTEGER,

    respiratory_rate INTEGER,

    systolic_bp INTEGER,

    diastolic_bp INTEGER,

    temperature_c NUMERIC(4,1),

    spo2 INTEGER,

    blood_sugar_random NUMERIC(6,2),

    blood_sugar_fasting NUMERIC(6,2),

    blood_sugar_pp NUMERIC(6,2),

    waist_cm NUMERIC(5,2),

    hip_cm NUMERIC(5,2),

    head_circumference_cm NUMERIC(5,2),

    pain_score INTEGER,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_vitals_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE patient_vitals IS
'Stores patient vital signs recorded during consultation.';

CREATE TRIGGER trg_patient_vitals_updated_at
BEFORE UPDATE ON patient_vitals
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- CONSULTATION GENERAL EXAMINATION
-- ============================================================================

CREATE TABLE IF NOT EXISTS consultation_general_examinations (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    consultation_id UUID NOT NULL,

    consciousness VARCHAR(50),

    built VARCHAR(50),

    nourishment VARCHAR(50),

    hydration VARCHAR(50),

    pallor BOOLEAN,

    icterus BOOLEAN,

    cyanosis BOOLEAN,

    clubbing BOOLEAN,

    lymphadenopathy BOOLEAN,

    edema BOOLEAN,

    dehydration BOOLEAN,

    general_appearance TEXT,

    cardiovascular_system TEXT,

    respiratory_system TEXT,

    abdomen TEXT,

    central_nervous_system TEXT,

    musculoskeletal_system TEXT,

    local_examination TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_consultation_general_examination
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE consultation_general_examinations IS
'Stores general clinical examination findings recorded during consultation.';

CREATE TRIGGER trg_consultation_general_examinations_updated_at
BEFORE UPDATE ON consultation_general_examinations
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- CONSULTATION COMPLAINTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS consultation_complaints (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    consultation_id UUID NOT NULL,

    complaint_id UUID NOT NULL,

    duration VARCHAR(100),

    severity VARCHAR(20),

    onset VARCHAR(50),

    frequency VARCHAR(50),

    progression VARCHAR(50),

    laterality VARCHAR(30),

    pain_score INTEGER,

    is_chief_complaint BOOLEAN NOT NULL DEFAULT FALSE,

    display_order INTEGER DEFAULT 1,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_consultation_complaints_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_consultation_complaints_complaint
        FOREIGN KEY (complaint_id)
        REFERENCES complaints(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_consultation_complaint
        UNIQUE (consultation_id, complaint_id)

);

COMMENT ON TABLE consultation_complaints IS
'Stores chief complaints recorded during a consultation.';

CREATE TRIGGER trg_consultation_complaints_updated_at
BEFORE UPDATE ON consultation_complaints
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- CONSULTATION SYMPTOMS
-- ============================================================================

CREATE TABLE IF NOT EXISTS consultation_symptoms (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    consultation_id UUID NOT NULL,

    symptom_id UUID NOT NULL,

    duration VARCHAR(100),

    severity VARCHAR(20),

    onset VARCHAR(50),

    frequency VARCHAR(50),

    progression VARCHAR(50),

    laterality VARCHAR(30),

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    display_order INTEGER DEFAULT 1,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_consultation_symptoms_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_consultation_symptoms_symptom
        FOREIGN KEY (symptom_id)
        REFERENCES symptoms(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_consultation_symptom
        UNIQUE (consultation_id, symptom_id)

);

COMMENT ON TABLE consultation_symptoms IS
'Stores symptoms recorded during a patient consultation.';

CREATE TRIGGER trg_consultation_symptoms_updated_at
BEFORE UPDATE ON consultation_symptoms
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();  

-- ============================================================================
-- CONSULTATION MODERN EXAMINATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS consultation_modern_examinations (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    consultation_id UUID NOT NULL,

    modern_clinical_examination_id UUID NOT NULL,

    finding TEXT,

    interpretation TEXT,

    is_normal BOOLEAN,

    severity VARCHAR(20),

    display_order INTEGER DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_consultation_modern_exam_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_consultation_modern_exam_master
        FOREIGN KEY (modern_clinical_examination_id)
        REFERENCES modern_clinical_examinations(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_consultation_modern_exam
        UNIQUE (
            consultation_id,
            modern_clinical_examination_id
        )

);

COMMENT ON TABLE consultation_modern_examinations IS
'Stores modern clinical examination findings recorded during consultation.';

CREATE TRIGGER trg_consultation_modern_examinations_updated_at
BEFORE UPDATE ON consultation_modern_examinations
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- CONSULTATION SIDDHA EXAMINATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS consultation_siddha_examinations (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    consultation_id UUID NOT NULL,

    siddha_clinical_examination_id UUID NOT NULL,

    observation TEXT,

    interpretation TEXT,

    severity VARCHAR(20),

    display_order INTEGER DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_consultation_siddha_exam_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_consultation_siddha_exam_master
        FOREIGN KEY (siddha_clinical_examination_id)
        REFERENCES siddha_clinical_examinations(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_consultation_siddha_exam
        UNIQUE (
            consultation_id,
            siddha_clinical_examination_id
        )

);

COMMENT ON TABLE consultation_siddha_examinations IS
'Stores Siddha clinical examination findings including Envagai Thervu, Naadi, Neerkuri and Neikuri.';

CREATE TRIGGER trg_consultation_siddha_examinations_updated_at
BEFORE UPDATE ON consultation_siddha_examinations
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- CONSULTATION MODERN DIAGNOSES
-- ============================================================================

CREATE TABLE IF NOT EXISTS consultation_modern_diagnoses (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    consultation_id UUID NOT NULL,

    modern_diagnosis_id UUID NOT NULL,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    diagnosis_status VARCHAR(30),

    confirmed BOOLEAN NOT NULL DEFAULT TRUE,

    display_order INTEGER DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_consultation_modern_diagnosis_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_consultation_modern_diagnosis_master
        FOREIGN KEY (modern_diagnosis_id)
        REFERENCES modern_diagnoses(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_consultation_modern_diagnosis
        UNIQUE (
            consultation_id,
            modern_diagnosis_id
        )

);

COMMENT ON TABLE consultation_modern_diagnoses IS
'Stores modern medical diagnoses recorded during patient consultation.';

CREATE TRIGGER trg_consultation_modern_diagnoses_updated_at
BEFORE UPDATE ON consultation_modern_diagnoses
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- CONSULTATION SIDDHA DIAGNOSES
-- ============================================================================

CREATE TABLE IF NOT EXISTS consultation_siddha_diagnoses (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    consultation_id UUID NOT NULL,

    siddha_diagnosis_id UUID NOT NULL,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    diagnosis_status VARCHAR(30),

    mukkutram VARCHAR(20),

    affected_udal_thathukkal VARCHAR(200),

    affected_uyir_thathukkal VARCHAR(200),

    confirmed BOOLEAN NOT NULL DEFAULT TRUE,

    display_order INTEGER DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_consultation_siddha_diagnosis_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_consultation_siddha_diagnosis_master
        FOREIGN KEY (siddha_diagnosis_id)
        REFERENCES siddha_diagnoses(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_consultation_siddha_diagnosis
        UNIQUE (
            consultation_id,
            siddha_diagnosis_id
        )

);

COMMENT ON TABLE consultation_siddha_diagnoses IS
'Stores Siddha diagnoses recorded during patient consultation.';

CREATE TRIGGER trg_consultation_siddha_diagnoses_updated_at
BEFORE UPDATE ON consultation_siddha_diagnoses
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- CONSULTATION INVESTIGATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS consultation_investigations (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    consultation_id UUID NOT NULL,

    investigation_id UUID NOT NULL,

    is_mandatory BOOLEAN NOT NULL DEFAULT FALSE,

    priority VARCHAR(20) DEFAULT 'Routine',

    status VARCHAR(30) DEFAULT 'Ordered',

    sample_collected BOOLEAN NOT NULL DEFAULT FALSE,

    sample_collected_at TIMESTAMPTZ,

    ordered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    report_received_at TIMESTAMPTZ,

    report_summary TEXT,

    interpretation TEXT,

    remarks TEXT,

    display_order INTEGER DEFAULT 1,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_consultation_investigation_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_consultation_investigation_master
        FOREIGN KEY (investigation_id)
        REFERENCES investigations(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_consultation_investigation
        UNIQUE (
            consultation_id,
            investigation_id
        )

);

COMMENT ON TABLE consultation_investigations IS
'Stores investigations ordered and their results during patient consultation.';

CREATE TRIGGER trg_consultation_investigations_updated_at
BEFORE UPDATE ON consultation_investigations
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- CONSULTATION THERAPIES
-- ============================================================================

CREATE TABLE IF NOT EXISTS consultation_therapies (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    consultation_id UUID NOT NULL,

    therapy_id UUID NOT NULL,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    therapy_status VARCHAR(30) DEFAULT 'Planned',

    start_date DATE,

    end_date DATE,

    duration_days INTEGER,

    number_of_sessions INTEGER,

    completed_sessions INTEGER DEFAULT 0,

    frequency VARCHAR(100),

    performed_by UUID REFERENCES user_profiles(id),

    requires_consent BOOLEAN NOT NULL DEFAULT FALSE,

    consent_received BOOLEAN NOT NULL DEFAULT FALSE,

    therapy_notes TEXT,

    outcome TEXT,

    display_order INTEGER DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_consultation_therapy_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_consultation_therapy_master
        FOREIGN KEY (therapy_id)
        REFERENCES therapies(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_consultation_therapy
        UNIQUE (
            consultation_id,
            therapy_id
        )

);

COMMENT ON TABLE consultation_therapies IS
'Stores therapies prescribed and performed during patient consultation.';

CREATE TRIGGER trg_consultation_therapies_updated_at
BEFORE UPDATE ON consultation_therapies
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- CONSULTATION DIET ADVICE
-- ============================================================================

CREATE TABLE IF NOT EXISTS consultation_diet_advice (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    consultation_id UUID NOT NULL,

    food_id UUID NOT NULL,

    recommendation_type VARCHAR(20) NOT NULL,
    -- Allowed / Avoid / Limit / Prefer

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

    CONSTRAINT fk_consultation_diet_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_consultation_diet_food
        FOREIGN KEY (food_id)
        REFERENCES foods(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_consultation_diet
        UNIQUE (
            consultation_id,
            food_id,
            recommendation_type
        )

);

COMMENT ON TABLE consultation_diet_advice IS
'Stores patient-specific Pathiyam and Apathiyam advice given during consultation.';

CREATE TRIGGER trg_consultation_diet_advice_updated_at
BEFORE UPDATE ON consultation_diet_advice
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- CONSULTATION LIFESTYLE ADVICE
-- ============================================================================

CREATE TABLE IF NOT EXISTS consultation_lifestyle_advice (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    consultation_id UUID NOT NULL,

    lifestyle_id UUID NOT NULL,

    recommendation_type VARCHAR(20),
    -- Recommended / Avoid / Mandatory / Optional

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

    CONSTRAINT fk_consultation_lifestyle_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_consultation_lifestyle_master
        FOREIGN KEY (lifestyle_id)
        REFERENCES lifestyle(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_consultation_lifestyle
        UNIQUE (
            consultation_id,
            lifestyle_id
        )

);

COMMENT ON TABLE consultation_lifestyle_advice IS
'Stores lifestyle advice given during patient consultation.';

CREATE TRIGGER trg_consultation_lifestyle_advice_updated_at
BEFORE UPDATE ON consultation_lifestyle_advice
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_consultations_number
ON consultations(consultation_number);

CREATE INDEX IF NOT EXISTS idx_consultations_patient
ON consultations(patient_id);

CREATE INDEX IF NOT EXISTS idx_consultations_op_registration
ON consultations(op_registration_id);

CREATE INDEX IF NOT EXISTS idx_consultations_doctor
ON consultations(doctor_id);

CREATE INDEX IF NOT EXISTS idx_consultations_date
ON consultations(consultation_date);

CREATE INDEX IF NOT EXISTS idx_consultations_status
ON consultations(consultation_status);

CREATE INDEX IF NOT EXISTS idx_consultations_type
ON consultations(consultation_type);

CREATE INDEX IF NOT EXISTS idx_patient_vitals_consultation
ON patient_vitals(consultation_id);

CREATE INDEX IF NOT EXISTS idx_consultation_general_examinations_consultation
ON consultation_general_examinations(consultation_id);

CREATE INDEX IF NOT EXISTS idx_consultation_complaints_consultation
ON consultation_complaints(consultation_id);

CREATE INDEX IF NOT EXISTS idx_consultation_complaints_complaint
ON consultation_complaints(complaint_id);

CREATE INDEX IF NOT EXISTS idx_consultation_symptoms_consultation
ON consultation_symptoms(consultation_id);

CREATE INDEX IF NOT EXISTS idx_consultation_symptoms_symptom
ON consultation_symptoms(symptom_id);

CREATE INDEX IF NOT EXISTS idx_consultation_modern_examinations_consultation
ON consultation_modern_examinations(consultation_id);

CREATE INDEX IF NOT EXISTS idx_consultation_modern_examinations_master
ON consultation_modern_examinations(modern_clinical_examination_id);

CREATE INDEX IF NOT EXISTS idx_consultation_siddha_examinations_consultation
ON consultation_siddha_examinations(consultation_id);

CREATE INDEX IF NOT EXISTS idx_consultation_siddha_examinations_master
ON consultation_siddha_examinations(siddha_clinical_examination_id);

CREATE INDEX IF NOT EXISTS idx_consultation_modern_diagnoses_consultation
ON consultation_modern_diagnoses(consultation_id);

CREATE INDEX IF NOT EXISTS idx_consultation_modern_diagnoses_master
ON consultation_modern_diagnoses(modern_diagnosis_id);

CREATE INDEX IF NOT EXISTS idx_consultation_modern_diagnoses_primary
ON consultation_modern_diagnoses(is_primary);

CREATE INDEX IF NOT EXISTS idx_consultation_siddha_diagnoses_consultation
ON consultation_siddha_diagnoses(consultation_id);

CREATE INDEX IF NOT EXISTS idx_consultation_siddha_diagnoses_master
ON consultation_siddha_diagnoses(siddha_diagnosis_id);

CREATE INDEX IF NOT EXISTS idx_consultation_siddha_diagnoses_primary
ON consultation_siddha_diagnoses(is_primary);

CREATE INDEX IF NOT EXISTS idx_consultation_investigations_consultation
ON consultation_investigations(consultation_id);

CREATE INDEX IF NOT EXISTS idx_consultation_investigations_master
ON consultation_investigations(investigation_id);

CREATE INDEX IF NOT EXISTS idx_consultation_investigations_status
ON consultation_investigations(status);

CREATE INDEX IF NOT EXISTS idx_consultation_investigations_ordered_at
ON consultation_investigations(ordered_at);

CREATE INDEX IF NOT EXISTS idx_consultation_therapies_consultation
ON consultation_therapies(consultation_id);

CREATE INDEX IF NOT EXISTS idx_consultation_therapies_master
ON consultation_therapies(therapy_id);

CREATE INDEX IF NOT EXISTS idx_consultation_therapies_status
ON consultation_therapies(therapy_status);

CREATE INDEX IF NOT EXISTS idx_consultation_therapies_performed_by
ON consultation_therapies(performed_by);

CREATE INDEX IF NOT EXISTS idx_consultation_therapies_start_date
ON consultation_therapies(start_date);

CREATE INDEX IF NOT EXISTS idx_consultation_diet_advice_consultation
ON consultation_diet_advice(consultation_id);

CREATE INDEX IF NOT EXISTS idx_consultation_diet_advice_food
ON consultation_diet_advice(food_id);

CREATE INDEX IF NOT EXISTS idx_consultation_diet_advice_recommendation
ON consultation_diet_advice(recommendation_type);

CREATE INDEX IF NOT EXISTS idx_consultation_lifestyle_advice_consultation
ON consultation_lifestyle_advice(consultation_id);

CREATE INDEX IF NOT EXISTS idx_consultation_lifestyle_advice_master
ON consultation_lifestyle_advice(lifestyle_id);

CREATE INDEX IF NOT EXISTS idx_consultation_lifestyle_advice_recommendation
ON consultation_lifestyle_advice(recommendation_type);

CREATE INDEX IF NOT EXISTS idx_consultations_doctor_date
ON consultations(doctor_id, consultation_date);

CREATE INDEX IF NOT EXISTS idx_consultations_patient_date
ON consultations(patient_id, consultation_date DESC);

CREATE INDEX IF NOT EXISTS idx_consultation_therapies_end_date
ON consultation_therapies(end_date);

COMMIT;
