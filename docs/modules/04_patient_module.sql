-- ============================================================================
-- SSHC ERP
-- Migration : 04_patient_module.sql
-- Version   : 1.0.0
-- ============================================================================

BEGIN;

-- ============================================================================
-- PATIENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS patients (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    patient_number VARCHAR(20) NOT NULL UNIQUE,

    first_name VARCHAR(100) NOT NULL,

    middle_name VARCHAR(100),

    last_name VARCHAR(100),

    full_name VARCHAR(250) NOT NULL,

    gender VARCHAR(20) NOT NULL,

    date_of_birth DATE,

    age_years INTEGER,

    age_months INTEGER,

    blood_group VARCHAR(10),

    marital_status VARCHAR(30),

    mobile_number VARCHAR(20),

    alternate_mobile VARCHAR(20),

    email VARCHAR(150),

    aadhaar_number VARCHAR(20),

    occupation_id UUID REFERENCES occupations(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE patients IS
'Stores basic demographic details of patients.';

CREATE TRIGGER trg_patients_updated_at
BEFORE UPDATE ON patients
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PATIENT ADDRESSES
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_addresses (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    patient_id UUID NOT NULL,

    address_types VARCHAR(30) NOT NULL,

    address_line1 TEXT NOT NULL,

    address_line2 TEXT,

    village_city VARCHAR(150),

    taluk VARCHAR(100),

    district VARCHAR(100),

    state VARCHAR(100),

    country VARCHAR(100) DEFAULT 'India',

    pincode VARCHAR(10),

    is_primary BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_address_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE patient_addresses IS
'Stores patient addresses.';

CREATE TRIGGER trg_patient_addresses_updated_at
BEFORE UPDATE ON patient_addresses
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PATIENT EMERGENCY CONTACTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_emergency_contacts (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    patient_id UUID NOT NULL,

    contact_name VARCHAR(150) NOT NULL,

    relationship VARCHAR(50),

    relationship_type VARCHAR(30),

    mobile_number VARCHAR(20) NOT NULL,

    alternate_mobile VARCHAR(20),

    address TEXT,

    is_primary BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_emergency_contact
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE patient_emergency_contacts IS
'Stores emergency contact details for patients.';

CREATE TRIGGER trg_patient_emergency_contacts_updated_at
BEFORE UPDATE ON patient_emergency_contacts
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PATIENT ALLERGIES
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_allergies (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    patient_id UUID NOT NULL,

    allergy_type VARCHAR(50),

    allergen_name VARCHAR(200) NOT NULL,

    reaction VARCHAR(200),

    severity VARCHAR(20),

    is_verified BOOLEAN NOT NULL DEFAULT FALSE,

    notes TEXT,

    diagnosed_date DATE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_allergy_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE patient_allergies IS
'Stores patient allergy history.';

CREATE TRIGGER trg_patient_allergies_updated_at
BEFORE UPDATE ON patient_allergies
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
  
-- ============================================================================
-- PATIENT MEDICAL HISTORY
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_medical_history (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    patient_id UUID NOT NULL,

    disease_id UUID REFERENCES diseases(id),

    diagnosis_date DATE,

    status VARCHAR(30),

    is_chronic BOOLEAN NOT NULL DEFAULT FALSE,

    treatment_details TEXT,

    medications TEXT,

    treating_doctor VARCHAR(150),

    hospital_name VARCHAR(200),

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_medical_history_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE patient_medical_history IS
'Stores past and current medical history of patients.';

CREATE TRIGGER trg_patient_medical_history_updated_at
BEFORE UPDATE ON patient_medical_history
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PATIENT FAMILY HISTORY
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_family_history (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    patient_id UUID NOT NULL,

    relationship VARCHAR(50) NOT NULL,

    disease_id UUID REFERENCES diseases(id),

    status VARCHAR(30),

    age_at_diagnosis INTEGER,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_family_history_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE patient_family_history IS
'Stores family medical history of patients.';

CREATE TRIGGER trg_patient_family_history_updated_at
BEFORE UPDATE ON patient_family_history
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PATIENT LIFESTYLE HISTORY
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_lifestyle_history (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    patient_id UUID NOT NULL,

    smoking_status VARCHAR(30),

    alcohol_status VARCHAR(30),

    tobacco_status VARCHAR(30),

    diet_type VARCHAR(50),

    exercise_frequency VARCHAR(100),

    water_intake_liters NUMERIC(4,1),

    physical_activity_level VARCHAR(50),

    sleep_duration_hours NUMERIC(4,1),

    occupation_id UUID REFERENCES occupations(id),

    stress_level VARCHAR(20),

    bowel_habits VARCHAR(100),

    bladder_habits VARCHAR(100),

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_lifestyle_history_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE patient_lifestyle_history IS
'Stores lifestyle and habit history of patients.';

CREATE TRIGGER trg_patient_lifestyle_history_updated_at
BEFORE UPDATE ON patient_lifestyle_history
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PATIENT DOCUMENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_documents (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    patient_id UUID NOT NULL,

    document_type VARCHAR(50) NOT NULL,

    document_name VARCHAR(200) NOT NULL,

    document_date DATE,

    file_url TEXT NOT NULL,

    file_type VARCHAR(50),

    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    created_by UUID,

    updated_by UUID,
    
    uploaded_by UUID,

    remarks TEXT,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_documents_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE patient_documents IS
'Stores uploaded documents related to patients.';

CREATE TRIGGER trg_patient_documents_updated_at
BEFORE UPDATE ON patient_documents
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PATIENT PHOTOS
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_photos (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    patient_id UUID NOT NULL,

    photo_url TEXT NOT NULL,

    photo_type VARCHAR(50) DEFAULT 'Profile',

    captured_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    uploaded_by UUID,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_photos_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE patient_photos IS
'Stores profile and clinical photographs of patients.';

CREATE TRIGGER trg_patient_photos_updated_at
BEFORE UPDATE ON patient_photos
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- OP REGISTRATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS op_registrations (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    op_number VARCHAR(20) NOT NULL UNIQUE,

    patient_id UUID NOT NULL,

    visit_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    visit_type VARCHAR(30) NOT NULL,

    doctor_id UUID NOT NULL REFERENCES user_profiles(id),

    department VARCHAR(100),

    priority VARCHAR(20) DEFAULT 'Normal',

    followup_of UUID REFERENCES op_registrations(id),
  
    chief_complaint TEXT,

    token_number INTEGER,

    queue_number INTEGER,

    appointment_id UUID,

    status VARCHAR(30) NOT NULL DEFAULT 'Waiting',

    consultation_started_at TIMESTAMPTZ,

    consultation_completed_at TIMESTAMPTZ,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_op_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE op_registrations IS
'Stores outpatient registrations and visit details.';

CREATE TRIGGER trg_op_registrations_updated_at
BEFORE UPDATE ON op_registrations
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_patients_patient_number
ON patients(patient_number);

CREATE INDEX IF NOT EXISTS idx_patients_mobile
ON patients(mobile_number);

CREATE INDEX IF NOT EXISTS idx_patients_name
ON patients(full_name);

CREATE INDEX IF NOT EXISTS idx_patient_addresses_patient
ON patient_addresses(patient_id);

CREATE INDEX IF NOT EXISTS idx_patient_emergency_contacts_patient
ON patient_emergency_contacts(patient_id);

CREATE INDEX IF NOT EXISTS idx_patient_allergies_patient
ON patient_allergies(patient_id);

CREATE INDEX IF NOT EXISTS idx_patient_medical_history_patient
ON patient_medical_history(patient_id);

CREATE INDEX IF NOT EXISTS idx_patient_family_history_patient
ON patient_family_history(patient_id);

CREATE INDEX IF NOT EXISTS idx_patient_lifestyle_history_patient
ON patient_lifestyle_history(patient_id);

CREATE INDEX IF NOT EXISTS idx_patient_documents_patient
ON patient_documents(patient_id);

CREATE INDEX IF NOT EXISTS idx_patient_photos_patient
ON patient_photos(patient_id);

CREATE INDEX IF NOT EXISTS idx_op_registrations_patient
ON op_registrations(patient_id);

CREATE INDEX IF NOT EXISTS idx_op_registrations_doctor
ON op_registrations(doctor_id);

CREATE INDEX IF NOT EXISTS idx_op_registrations_visit_date
ON op_registrations(visit_date);

CREATE INDEX IF NOT EXISTS idx_op_registrations_status
ON op_registrations(status);

CREATE INDEX IF NOT EXISTS idx_op_registrations_op_number
ON op_registrations(op_number);

CREATE INDEX IF NOT EXISTS idx_patients_occupation
ON patients(occupation_id);

CREATE INDEX IF NOT EXISTS idx_patient_medical_history_disease
ON patient_medical_history(disease_id);

CREATE INDEX IF NOT EXISTS idx_patient_family_history_disease
ON patient_family_history(disease_id);

CREATE INDEX IF NOT EXISTS idx_patients_aadhaar
ON patients(aadhaar_number);

COMMIT; 
