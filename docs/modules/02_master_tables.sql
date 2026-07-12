-- ============================================================================
-- SSHC ERP
-- Migration : 02_master_tables.sql
-- Master Data
-- ============================================================================

BEGIN;

-- ============================================================================
-- DISEASES MASTER
-- ============================================================================

CREATE TABLE IF NOT EXISTS diseases (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    disease_code VARCHAR(20) NOT NULL UNIQUE,

    modern_name VARCHAR(200) NOT NULL,

    siddha_name VARCHAR(200),

    icd10_code VARCHAR(20),

    category VARCHAR(100),

    description TEXT,

    is_chronic BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE diseases IS
'Master list of diseases used in consultations.';

CREATE TRIGGER trg_diseases_updated_at
BEFORE UPDATE ON diseases
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- SYMPTOMS MASTER
-- ============================================================================

CREATE TABLE IF NOT EXISTS symptoms (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    symptom_code VARCHAR(20) NOT NULL UNIQUE,

    symptom_name VARCHAR(200) NOT NULL,

    tamil_name VARCHAR(200),

    description TEXT,

    body_system VARCHAR(100),

    severity VARCHAR(20),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE symptoms IS
'Master list of clinical symptoms used in consultations.';

CREATE TRIGGER trg_symptoms_updated_at
BEFORE UPDATE ON symptoms
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- COMPLAINTS MASTER
-- ============================================================================

CREATE TABLE IF NOT EXISTS complaints (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    complaint_code VARCHAR(20) NOT NULL UNIQUE,

    complaint_name VARCHAR(200) NOT NULL,

    tamil_name VARCHAR(200),

    description TEXT,

    complaint_type VARCHAR(100),

    body_system VARCHAR(100),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE complaints IS
'Master list of chief complaints used during patient registration and consultation.';

CREATE TRIGGER trg_complaints_updated_at
BEFORE UPDATE ON complaints
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- MODERN DIAGNOSES MASTER
-- ============================================================================

CREATE TABLE IF NOT EXISTS modern_diagnoses (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    diagnosis_code VARCHAR(20) NOT NULL UNIQUE,

    diagnosis_name VARCHAR(200) NOT NULL,

    icd10_code VARCHAR(20),

    category VARCHAR(100),

    description TEXT,

    is_chronic BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE modern_diagnoses IS
'Master list of modern medical diagnoses used in consultations.';

CREATE TRIGGER trg_modern_diagnoses_updated_at
BEFORE UPDATE ON modern_diagnoses
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- SIDDHA DIAGNOSES MASTER
-- ============================================================================

CREATE TABLE IF NOT EXISTS siddha_diagnoses (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    diagnosis_code VARCHAR(20) NOT NULL UNIQUE,

    siddha_name VARCHAR(200) NOT NULL,

    tamil_name VARCHAR(200),

    english_name VARCHAR(200),

    mukkutram VARCHAR(20),

    affected_udal_thathukkal VARCHAR(200),

    affected_uyir_thathukkal VARCHAR(200),

    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE siddha_diagnoses IS
'Master list of Siddha diagnoses used during consultations.';

CREATE TRIGGER trg_siddha_diagnoses_updated_at
BEFORE UPDATE ON siddha_diagnoses
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- MEDICINES MASTER
-- ============================================================================

CREATE TABLE IF NOT EXISTS medicines (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    medicine_code VARCHAR(20) NOT NULL UNIQUE,

    medicine_name VARCHAR(200) NOT NULL,

    tamil_name VARCHAR(200),

    english_name VARCHAR(200),

    botanical_name VARCHAR(300),

    medicine_type VARCHAR(100),

    dosage_form VARCHAR(100),

    strength VARCHAR(100),

    manufacturer VARCHAR(200),

    hsn_code VARCHAR(20),

    mrp NUMERIC(10,2),

    purchase_price NUMERIC(10,2),

    selling_price NUMERIC(10,2),

    gst_percentage NUMERIC(5,2),

    reorder_level INTEGER DEFAULT 10,

    stock_managed BOOLEAN NOT NULL DEFAULT TRUE,

    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE medicines IS
'Master list of Siddha, Herbal and Modern medicines used in SSHC ERP.';

CREATE TRIGGER trg_medicines_updated_at
BEFORE UPDATE ON medicines
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- INVESTIGATIONS MASTER
-- ============================================================================

CREATE TABLE IF NOT EXISTS investigations (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    investigation_code VARCHAR(20) NOT NULL UNIQUE,

    investigation_name VARCHAR(200) NOT NULL,

    category VARCHAR(100),

    sample_type VARCHAR(100),

    unit VARCHAR(50),

    normal_range TEXT,

    report_required BOOLEAN NOT NULL DEFAULT TRUE,

    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE investigations IS
'Master list of laboratory and imaging investigations used in SSHC ERP.';

CREATE TRIGGER trg_investigations_updated_at
BEFORE UPDATE ON investigations
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- MODERN CLINICAL EXAMINATIONS MASTER
-- ============================================================================

CREATE TABLE IF NOT EXISTS modern_clinical_examinations (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    examination_code VARCHAR(20) NOT NULL UNIQUE,

    examination_name VARCHAR(200) NOT NULL,

    category VARCHAR(100),

    body_system VARCHAR(100),

    is_mandatory BOOLEAN NOT NULL DEFAULT FALSE,

    examination_method VARCHAR(100),

    normal_finding TEXT,

    abnormal_finding TEXT,

    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE modern_clinical_examinations IS
'Master list of modern clinical examinations used during patient consultation.';

CREATE TRIGGER trg_modern_clinical_examinations_updated_at
BEFORE UPDATE ON modern_clinical_examinations
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- SIDDHA CLINICAL EXAMINATIONS MASTER
-- ============================================================================

CREATE TABLE IF NOT EXISTS siddha_clinical_examinations (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    examination_code VARCHAR(20) NOT NULL UNIQUE,

    examination_name VARCHAR(200) NOT NULL,

    tamil_name VARCHAR(200),

    examination_type VARCHAR(100),

    category VARCHAR(100),

    observation TEXT,

    interpretation TEXT,

    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE siddha_clinical_examinations IS
'Master list of Siddha clinical examinations including Envagai Thervu.';

CREATE TRIGGER trg_siddha_clinical_examinations_updated_at
BEFORE UPDATE ON siddha_clinical_examinations
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- THERAPIES MASTER
-- ============================================================================

CREATE TABLE IF NOT EXISTS therapies (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    therapy_code VARCHAR(20) NOT NULL UNIQUE,

    therapy_name VARCHAR(200) NOT NULL,

    tamil_name VARCHAR(200),

    therapy_category VARCHAR(100),

    duration_minutes INTEGER,

    default_fee NUMERIC(10,2),

    requires_consent BOOLEAN NOT NULL DEFAULT FALSE,

    description TEXT,

    contraindications TEXT,

    precautions TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE therapies IS
'Master list of Siddha therapies and procedures.';

CREATE TRIGGER trg_therapies_updated_at
BEFORE UPDATE ON therapies
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- FOODS MASTER (PATHIYAM)
-- ============================================================================

CREATE TABLE IF NOT EXISTS foods (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    food_code VARCHAR(20) NOT NULL UNIQUE,

    food_name VARCHAR(200) NOT NULL,

    tamil_name VARCHAR(200),

    food_category VARCHAR(100),

    food_type VARCHAR(50),

    recommended_for VARCHAR(200),

    is_pathiyam BOOLEAN NOT NULL DEFAULT TRUE,

    nutrition_notes TEXT,

    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE foods IS
'Master list of foods used for Siddha Pathiyam and Apathiyam advice.';

CREATE TRIGGER trg_foods_updated_at
BEFORE UPDATE ON foods
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- LIFESTYLE MASTER
-- ============================================================================

CREATE TABLE IF NOT EXISTS lifestyle (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    lifestyle_code VARCHAR(20) NOT NULL UNIQUE,

    lifestyle_name VARCHAR(200) NOT NULL,

    tamil_name VARCHAR(200),

    category VARCHAR(100),

    recommendation_type VARCHAR(20),

    duration VARCHAR(100),

    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE lifestyle IS
'Master list of lifestyle recommendations for Siddha patients.';

CREATE TRIGGER trg_lifestyle_updated_at
BEFORE UPDATE ON lifestyle
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- OCCUPATIONS MASTER
-- ============================================================================

CREATE TABLE IF NOT EXISTS occupations (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    occupation_code VARCHAR(20) NOT NULL UNIQUE,

    occupation_name VARCHAR(200) NOT NULL,

    tamil_name VARCHAR(200),

    occupation_category VARCHAR(100),

    work_environment VARCHAR(100),

    occupational_risk TEXT,

    physical_activity_level VARCHAR(50),

    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE occupations IS
'Master list of patient occupations for clinical history and research.';

CREATE TRIGGER trg_occupations_updated_at
BEFORE UPDATE ON occupations
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- RISK FACTORS MASTER
-- ============================================================================

CREATE TABLE IF NOT EXISTS risk_factors (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    risk_factor_code VARCHAR(20) NOT NULL UNIQUE,

    risk_factor_name VARCHAR(200) NOT NULL,

    tamil_name VARCHAR(200),

    risk_category VARCHAR(100),

    severity_level VARCHAR(20),

    is_modifiable BOOLEAN NOT NULL DEFAULT TRUE,

    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE risk_factors IS
'Master list of disease risk factors used in clinical assessment and research.';

CREATE TRIGGER trg_risk_factors_updated_at
BEFORE UPDATE ON risk_factors
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- FOLLOW-UP TEMPLATES MASTER
-- ============================================================================

CREATE TABLE IF NOT EXISTS followup_templates (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    template_code VARCHAR(20) NOT NULL UNIQUE,

    template_name VARCHAR(200) NOT NULL,

    followup_after_days INTEGER NOT NULL,

    default_notification BOOLEAN NOT NULL DEFAULT TRUE,

    reminder_type VARCHAR(50),

    followup_instructions TEXT,

    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE followup_templates IS
'Master list of follow-up schedules and reminder templates used in SSHC ERP.';

CREATE TRIGGER trg_followup_templates_updated_at
BEFORE UPDATE ON followup_templates
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_diseases_modern_name
ON diseases(modern_name);

CREATE INDEX IF NOT EXISTS idx_symptoms_name
ON symptoms(symptom_name);

CREATE INDEX IF NOT EXISTS idx_complaints_name
ON complaints(complaint_name);

CREATE INDEX IF NOT EXISTS idx_medicines_name
ON medicines(medicine_name);

CREATE INDEX IF NOT EXISTS idx_investigations_name
ON investigations(investigation_name);

CREATE INDEX IF NOT EXISTS idx_therapies_name
ON therapies(therapy_name);

CREATE INDEX IF NOT EXISTS idx_foods_name
ON foods(food_name);

CREATE INDEX IF NOT EXISTS idx_followup_days
ON followup_templates(followup_after_days);

COMMIT;
