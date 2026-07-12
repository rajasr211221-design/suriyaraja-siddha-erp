-- ============================================================================
-- SSHC ERP
-- Migration : 03_mapping_tables.sql
-- Version   : 1.0.0
-- Database  : PostgreSQL 17 (Supabase)
-- ============================================================================
 
BEGIN;

-- ============================================================================
-- DISEASE ↔ COMPLAINTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS disease_complaints (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    disease_id UUID NOT NULL,

    complaint_id UUID NOT NULL,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    display_order INTEGER DEFAULT 1,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_dc_disease
        FOREIGN KEY (disease_id)
        REFERENCES diseases(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_dc_complaint
        FOREIGN KEY (complaint_id)
        REFERENCES complaints(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_disease_complaint
        UNIQUE(disease_id, complaint_id)

);

COMMENT ON TABLE disease_complaints IS
'Maps diseases with chief complaints.';

CREATE TRIGGER trg_disease_complaints_updated_at
BEFORE UPDATE ON disease_complaints
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DISEASE ↔ MODERN DIAGNOSES
-- ============================================================================

CREATE TABLE IF NOT EXISTS disease_modern_diagnoses (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    disease_id UUID NOT NULL,

    modern_diagnosis_id UUID NOT NULL,

    is_primary BOOLEAN NOT NULL DEFAULT TRUE,

    display_order INTEGER DEFAULT 1,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_dmd_disease
        FOREIGN KEY (disease_id)
        REFERENCES diseases(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_dmd_modern_diagnosis
        FOREIGN KEY (modern_diagnosis_id)
        REFERENCES modern_diagnoses(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_disease_modern_diagnosis
        UNIQUE(disease_id, modern_diagnosis_id)

);

COMMENT ON TABLE disease_modern_diagnoses IS
'Maps diseases with modern diagnoses.';

CREATE TRIGGER trg_disease_modern_diagnoses_updated_at
BEFORE UPDATE ON disease_modern_diagnoses
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DISEASE ↔ SIDDHA DIAGNOSES
-- ============================================================================

CREATE TABLE IF NOT EXISTS disease_siddha_diagnoses (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    disease_id UUID NOT NULL,

    siddha_diagnosis_id UUID NOT NULL,

    is_primary BOOLEAN NOT NULL DEFAULT TRUE,

    display_order INTEGER DEFAULT 1,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_dsd_disease
        FOREIGN KEY (disease_id)
        REFERENCES diseases(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_dsd_siddha_diagnosis
        FOREIGN KEY (siddha_diagnosis_id)
        REFERENCES siddha_diagnoses(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_disease_siddha_diagnosis
        UNIQUE(disease_id, siddha_diagnosis_id)

);

COMMENT ON TABLE disease_siddha_diagnoses IS
'Maps diseases with Siddha diagnoses.';

CREATE TRIGGER trg_disease_siddha_diagnoses_updated_at
BEFORE UPDATE ON disease_siddha_diagnoses
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DISEASE ↔ MEDICINES
-- ============================================================================

CREATE TABLE IF NOT EXISTS disease_medicines (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    disease_id UUID NOT NULL,

    medicine_id UUID NOT NULL,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    display_order INTEGER DEFAULT 1,

    dosage TEXT,

    duration TEXT,

    frequency VARCHAR(100),

    route VARCHAR(50),

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_dm_disease
        FOREIGN KEY (disease_id)
        REFERENCES diseases(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_dm_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES medicines(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_disease_medicine
        UNIQUE(disease_id, medicine_id)

);

COMMENT ON TABLE disease_medicines IS
'Maps diseases with recommended medicines.';

CREATE TRIGGER trg_disease_medicines_updated_at
BEFORE UPDATE ON disease_medicines
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DISEASE ↔ INVESTIGATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS disease_investigations (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    disease_id UUID NOT NULL,

    investigation_id UUID NOT NULL,

    is_mandatory BOOLEAN NOT NULL DEFAULT FALSE,

    recommended_frequency VARCHAR(100),

    priority VARCHAR(20),

    display_order INTEGER DEFAULT 1,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_di_disease
        FOREIGN KEY (disease_id)
        REFERENCES diseases(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_di_investigation
        FOREIGN KEY (investigation_id)
        REFERENCES investigations(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_disease_investigation
        UNIQUE(disease_id, investigation_id)

);

COMMENT ON TABLE disease_investigations IS
'Maps diseases with recommended investigations.';

CREATE TRIGGER trg_disease_investigations_updated_at
BEFORE UPDATE ON disease_investigations
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DISEASE ↔ MODERN CLINICAL EXAMINATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS disease_modern_clinical_examinations (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    disease_id UUID NOT NULL,

    modern_clinical_examination_id UUID NOT NULL,

    is_mandatory BOOLEAN NOT NULL DEFAULT FALSE,

    recommended_frequency VARCHAR(100),

    priority VARCHAR(20),

    display_order INTEGER DEFAULT 1,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_dmce_disease
        FOREIGN KEY (disease_id)
        REFERENCES diseases(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_dmce_examination
        FOREIGN KEY (modern_clinical_examination_id)
        REFERENCES modern_clinical_examinations(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_disease_modern_clinical_examination
        UNIQUE(disease_id, modern_clinical_examination_id)

);

COMMENT ON TABLE disease_modern_clinical_examinations IS
'Maps diseases with recommended modern clinical examinations.';

CREATE TRIGGER trg_disease_modern_clinical_examinations_updated_at
BEFORE UPDATE ON disease_modern_clinical_examinations
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DISEASE ↔ SIDDHA CLINICAL EXAMINATIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS disease_siddha_clinical_examinations (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    disease_id UUID NOT NULL,

    siddha_clinical_examination_id UUID NOT NULL,

    is_mandatory BOOLEAN NOT NULL DEFAULT FALSE,

    recommended_frequency VARCHAR(100),

    priority VARCHAR(20),

    display_order INTEGER DEFAULT 1,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_dsce_disease
        FOREIGN KEY (disease_id)
        REFERENCES diseases(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_dsce_examination
        FOREIGN KEY (siddha_clinical_examination_id)
        REFERENCES siddha_clinical_examinations(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_disease_siddha_clinical_examination
        UNIQUE(disease_id, siddha_clinical_examination_id)

);

COMMENT ON TABLE disease_siddha_clinical_examinations IS
'Maps diseases with recommended Siddha clinical examinations.';

CREATE TRIGGER trg_disease_siddha_clinical_examinations_updated_at
BEFORE UPDATE ON disease_siddha_clinical_examinations
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DISEASE ↔ THERAPIES
-- ============================================================================

CREATE TABLE IF NOT EXISTS disease_therapies (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    disease_id UUID NOT NULL,

    therapy_id UUID NOT NULL,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    display_order INTEGER DEFAULT 1,

    duration_days INTEGER,

    sessions INTEGER,

    therapy_frequency VARCHAR(100),

    requires_followup BOOLEAN NOT NULL DEFAULT TRUE,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_dt_disease
        FOREIGN KEY (disease_id)
        REFERENCES diseases(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_dt_therapy
        FOREIGN KEY (therapy_id)
        REFERENCES therapies(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_disease_therapy
        UNIQUE(disease_id, therapy_id)

);

COMMENT ON TABLE disease_therapies IS
'Maps diseases with recommended Siddha therapies.';

CREATE TRIGGER trg_disease_therapies_updated_at
BEFORE UPDATE ON disease_therapies
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DISEASE ↔ FOODS
-- ============================================================================

CREATE TABLE IF NOT EXISTS disease_foods (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    disease_id UUID NOT NULL,

    food_id UUID NOT NULL,

    recommendation_type VARCHAR(20) NOT NULL,

    diet_priority VARCHAR(20),

    display_order INTEGER DEFAULT 1,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_df_disease
        FOREIGN KEY (disease_id)
        REFERENCES diseases(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_df_food
        FOREIGN KEY (food_id)
        REFERENCES foods(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_disease_food
        UNIQUE(disease_id, food_id)

);

COMMENT ON TABLE disease_foods IS
'Maps diseases with recommended and restricted foods.';

CREATE TRIGGER trg_disease_foods_updated_at
BEFORE UPDATE ON disease_foods
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DISEASE ↔ LIFESTYLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS disease_lifestyle (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    disease_id UUID NOT NULL,

    lifestyle_id UUID NOT NULL,

    recommendation_type VARCHAR(20) NOT NULL,

    duration VARCHAR(100),

    display_order INTEGER DEFAULT 1,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
 
    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_dl_disease
        FOREIGN KEY (disease_id)
        REFERENCES diseases(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_dl_lifestyle
        FOREIGN KEY (lifestyle_id)
        REFERENCES lifestyle(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_disease_lifestyle
        UNIQUE(disease_id, lifestyle_id)

);

COMMENT ON TABLE disease_lifestyle IS
'Maps diseases with recommended lifestyle modifications.';

CREATE TRIGGER trg_disease_lifestyle_updated_at
BEFORE UPDATE ON disease_lifestyle
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DISEASE ↔ RISK FACTORS
-- ============================================================================

CREATE TABLE IF NOT EXISTS disease_risk_factors (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    disease_id UUID NOT NULL,

    risk_factor_id UUID NOT NULL,

    risk_level VARCHAR(20),

    modifiable BOOLEAN,

    recommendation TEXT,

    display_order INTEGER DEFAULT 1,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_drf_disease
        FOREIGN KEY (disease_id)
        REFERENCES diseases(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_drf_risk_factor
        FOREIGN KEY (risk_factor_id)
        REFERENCES risk_factors(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_disease_risk_factor
        UNIQUE(disease_id, risk_factor_id)

);

COMMENT ON TABLE disease_risk_factors IS
'Maps diseases with associated risk factors.';

CREATE TRIGGER trg_disease_risk_factors_updated_at
BEFORE UPDATE ON disease_risk_factors
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DISEASE ↔ FOLLOW-UP TEMPLATES
-- ============================================================================

CREATE TABLE IF NOT EXISTS disease_followup_templates (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    disease_id UUID NOT NULL,

    followup_template_id UUID NOT NULL,

    is_default BOOLEAN NOT NULL DEFAULT TRUE,

    followup_reason VARCHAR(200),

    reminder_required BOOLEAN NOT NULL DEFAULT TRUE,

    display_order INTEGER DEFAULT 1,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_dft_disease
        FOREIGN KEY (disease_id)
        REFERENCES diseases(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_dft_followup
        FOREIGN KEY (followup_template_id)
        REFERENCES followup_templates(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_disease_followup
        UNIQUE(disease_id, followup_template_id)

);

COMMENT ON TABLE disease_followup_templates IS
'Maps diseases with recommended follow-up templates.';

CREATE TRIGGER trg_disease_followup_templates_updated_at
BEFORE UPDATE ON disease_followup_templates
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_disease_complaints_disease
ON disease_complaints(disease_id);

CREATE INDEX IF NOT EXISTS idx_disease_complaints_complaint
ON disease_complaints(complaint_id);

CREATE INDEX IF NOT EXISTS idx_disease_modern_diagnoses_disease
ON disease_modern_diagnoses(disease_id);

CREATE INDEX IF NOT EXISTS idx_disease_modern_diagnoses_modern
ON disease_modern_diagnoses(modern_diagnosis_id);

CREATE INDEX IF NOT EXISTS idx_disease_siddha_diagnoses_disease
ON disease_siddha_diagnoses(disease_id);

CREATE INDEX IF NOT EXISTS idx_disease_siddha_diagnoses_siddha
ON disease_siddha_diagnoses(siddha_diagnosis_id);

CREATE INDEX IF NOT EXISTS idx_disease_medicines_disease
ON disease_medicines(disease_id);

CREATE INDEX IF NOT EXISTS idx_disease_medicines_medicine
ON disease_medicines(medicine_id);

CREATE INDEX IF NOT EXISTS idx_disease_investigations_disease
ON disease_investigations(disease_id);

CREATE INDEX IF NOT EXISTS idx_disease_investigations_investigation
ON disease_investigations(investigation_id);

CREATE INDEX IF NOT EXISTS idx_disease_modern_clinical_examinations_disease
ON disease_modern_clinical_examinations(disease_id);

CREATE INDEX IF NOT EXISTS idx_disease_modern_clinical_examinations_exam
ON disease_modern_clinical_examinations(modern_clinical_examination_id);

CREATE INDEX IF NOT EXISTS idx_disease_siddha_clinical_examinations_disease
ON disease_siddha_clinical_examinations(disease_id);

CREATE INDEX IF NOT EXISTS idx_disease_siddha_clinical_examinations_exam
ON disease_siddha_clinical_examinations(siddha_clinical_examination_id);

CREATE INDEX IF NOT EXISTS idx_disease_therapies_disease
ON disease_therapies(disease_id);

CREATE INDEX IF NOT EXISTS idx_disease_therapies_therapy
ON disease_therapies(therapy_id);

CREATE INDEX IF NOT EXISTS idx_disease_foods_disease
ON disease_foods(disease_id);

CREATE INDEX IF NOT EXISTS idx_disease_foods_food
ON disease_foods(food_id);

CREATE INDEX IF NOT EXISTS idx_disease_lifestyle_disease
ON disease_lifestyle(disease_id);

CREATE INDEX IF NOT EXISTS idx_disease_lifestyle_lifestyle
ON disease_lifestyle(lifestyle_id);

CREATE INDEX IF NOT EXISTS idx_disease_risk_factors_disease
ON disease_risk_factors(disease_id);

CREATE INDEX IF NOT EXISTS idx_disease_risk_factors_risk
ON disease_risk_factors(risk_factor_id);

CREATE INDEX IF NOT EXISTS idx_disease_followup_templates_disease
ON disease_followup_templates(disease_id);

CREATE INDEX IF NOT EXISTS idx_disease_followup_templates_followup
ON disease_followup_templates(followup_template_id);

COMMIT;
