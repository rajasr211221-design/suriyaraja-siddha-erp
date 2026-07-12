-- ============================================================================
-- Suriyaraja Siddha Health Care ERP (SSHC ERP)
-- Migration : 08_billing_module.sql
-- Version   : 1.0.0
-- Database  : PostgreSQL 17 (Supabase)
-- Author    : Dr. Raja Suriyaraja & ChatGPT
--
-- Description:
-- Billing module for SSHC ERP.
-- Stores patient bills, bill items,
-- consultation charges, medicine charges,
-- therapy charges, discounts, taxes,
-- payments, refunds and billing history.
--
-- This module integrates with:
-- • Patients
-- • OP Registration
-- • Consultations
-- • Prescriptions
-- • Pharmacy
-- • Therapies
-- • Accounts
-- ============================================================================

BEGIN;

-- ============================================================================
-- BILLS
-- ============================================================================

CREATE TABLE IF NOT EXISTS bills (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    bill_number VARCHAR(20) NOT NULL UNIQUE,

    patient_id UUID NOT NULL,

    op_registration_id UUID,

    consultation_id UUID,

    prescription_id UUID,

    bill_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    bill_type VARCHAR(30) NOT NULL DEFAULT 'OP',

    bill_status VARCHAR(30) NOT NULL DEFAULT 'Draft',

    bill_source VARCHAR(30) DEFAULT 'Clinic',

    payment_status VARCHAR(30) NOT NULL DEFAULT 'Pending',

    subtotal NUMERIC(12,2) NOT NULL DEFAULT 0,

    discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    taxable_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    cgst_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    sgst_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    igst_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    cess_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    round_off_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    amount_paid NUMERIC(12,2) NOT NULL DEFAULT 0,

    balance_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    payment_due_date DATE,

    billing_notes TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_bills_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_bills_op_registration
        FOREIGN KEY (op_registration_id)
        REFERENCES op_registrations(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_bills_consultation
        FOREIGN KEY (consultation_id)
        REFERENCES consultations(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_bills_prescription
        FOREIGN KEY (prescription_id)
        REFERENCES prescriptions(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE bills IS
'Stores billing header information including patient invoice, consultation, prescription, payment status and financial summary.';

CREATE TRIGGER trg_bills_updated_at
BEFORE UPDATE ON bills
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- BILL ITEMS
-- ============================================================================

CREATE TABLE IF NOT EXISTS bill_items (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    bill_id UUID NOT NULL,

    item_type VARCHAR(30) NOT NULL,
    -- Consultation / Medicine / Therapy /
    -- Investigation / Procedure / Registration / Other

    reference_id UUID,

    reference_table VARCHAR(50),

    item_name VARCHAR(250) NOT NULL,

    item_description TEXT,

    quantity NUMERIC(10,2) NOT NULL DEFAULT 1,

    unit VARCHAR(30),

    unit_price NUMERIC(12,2) NOT NULL DEFAULT 0,

    discount_percent NUMERIC(5,2) DEFAULT 0,

    discount_amount NUMERIC(12,2) DEFAULT 0,

    tax_percent NUMERIC(5,2) DEFAULT 0,

    tax_amount NUMERIC(12,2) DEFAULT 0,

    line_total NUMERIC(12,2) NOT NULL DEFAULT 0,

    display_order INTEGER DEFAULT 1,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_bill_items_bill
        FOREIGN KEY (bill_id)
        REFERENCES bills(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE bill_items IS
'Stores individual bill line items including consultation fees, medicines, therapies, investigations, procedures and other billable services.';

CREATE TRIGGER trg_bill_items_updated_at
BEFORE UPDATE ON bill_items
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PAYMENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS payments (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    payment_number VARCHAR(20) NOT NULL UNIQUE,

    bill_id UUID NOT NULL,

    payment_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    payment_method VARCHAR(30) NOT NULL,
    -- Cash / UPI / Card / Bank Transfer / Cheque / Wallet / Advance

    payment_status VARCHAR(30) NOT NULL DEFAULT 'Completed',
    -- Pending / Completed / Failed / Cancelled / Refunded

    transaction_reference VARCHAR(150),

    amount_paid NUMERIC(12,2) NOT NULL,

    advance_payment BOOLEAN NOT NULL DEFAULT FALSE,

    received_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    bank_name VARCHAR(150),

    cheque_number VARCHAR(50),

    cheque_date DATE,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_payments_bill
        FOREIGN KEY (bill_id)
        REFERENCES bills(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE payments IS
'Stores payment transactions for patient bills including cash, UPI, card, bank transfer, cheque and advance payments.';

CREATE TRIGGER trg_payments_updated_at
BEFORE UPDATE ON payments
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- REFUNDS
-- ============================================================================

CREATE TABLE IF NOT EXISTS refunds (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    refund_number VARCHAR(20) NOT NULL UNIQUE,

    bill_id UUID NOT NULL,

    payment_id UUID,

    refund_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    refund_type VARCHAR(30) NOT NULL,
    -- Bill Cancellation / Medicine Return /
    -- Excess Payment / Advance Refund / Other

    refund_status VARCHAR(30) NOT NULL DEFAULT 'Completed',
    -- Pending / Completed / Cancelled

    refund_method VARCHAR(30),
    -- Cash / UPI / Card / Bank Transfer / Cheque

    refund_amount NUMERIC(12,2) NOT NULL,

    refund_reference VARCHAR(100),

    transaction_reference VARCHAR(150),

    approved_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    processed_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    refund_reason TEXT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_refunds_bill
        FOREIGN KEY (bill_id)
        REFERENCES bills(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_refunds_payment
        FOREIGN KEY (payment_id)
        REFERENCES payments(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE refunds IS
'Stores patient refunds for cancelled bills, medicine returns, excess payments and advance payment refunds.';

CREATE TRIGGER trg_refunds_updated_at
BEFORE UPDATE ON refunds
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_bills_number
ON bills(bill_number);

CREATE INDEX IF NOT EXISTS idx_bills_patient
ON bills(patient_id);

CREATE INDEX IF NOT EXISTS idx_bills_op_registration
ON bills(op_registration_id);

CREATE INDEX IF NOT EXISTS idx_bills_consultation
ON bills(consultation_id);

CREATE INDEX IF NOT EXISTS idx_bills_prescription
ON bills(prescription_id);

CREATE INDEX IF NOT EXISTS idx_bills_date
ON bills(bill_date);

CREATE INDEX IF NOT EXISTS idx_bills_status
ON bills(bill_status);

CREATE INDEX IF NOT EXISTS idx_bills_payment_status
ON bills(payment_status);

CREATE INDEX IF NOT EXISTS idx_bill_items_bill
ON bill_items(bill_id);

CREATE INDEX IF NOT EXISTS idx_bill_items_type
ON bill_items(item_type);

CREATE INDEX IF NOT EXISTS idx_bill_items_reference
ON bill_items(reference_id);

CREATE INDEX IF NOT EXISTS idx_payments_number
ON payments(payment_number);

CREATE INDEX IF NOT EXISTS idx_payments_bill
ON payments(bill_id);

CREATE INDEX IF NOT EXISTS idx_payments_date
ON payments(payment_date);

CREATE INDEX IF NOT EXISTS idx_payments_method
ON payments(payment_method);

CREATE INDEX IF NOT EXISTS idx_payments_status
ON payments(payment_status);

CREATE INDEX IF NOT EXISTS idx_refunds_number
ON refunds(refund_number);

CREATE INDEX IF NOT EXISTS idx_refunds_bill
ON refunds(bill_id);

CREATE INDEX IF NOT EXISTS idx_refunds_payment
ON refunds(payment_id);

CREATE INDEX IF NOT EXISTS idx_refunds_date
ON refunds(refund_date);

CREATE INDEX IF NOT EXISTS idx_refunds_status
ON refunds(refund_status);

CREATE INDEX IF NOT EXISTS idx_bills_type
ON bills(bill_type);

CREATE INDEX IF NOT EXISTS idx_bills_due_date
ON bills(payment_due_date);

CREATE INDEX IF NOT EXISTS idx_payments_received_by
ON payments(received_by);

CREATE INDEX IF NOT EXISTS idx_refunds_processed_by
ON refunds(processed_by);

COMMIT;

