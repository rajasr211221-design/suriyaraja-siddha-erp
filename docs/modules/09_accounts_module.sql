-- ============================================================================
-- Suriyaraja Siddha Health Care ERP (SSHC ERP)
-- Migration : 09_accounts_module.sql
-- Version   : 1.0.0
-- Database  : PostgreSQL 17 (Supabase)
-- Author    : Dr. Raja Suriyaraja & ChatGPT
--
-- Description:
-- Accounts and Finance module for SSHC ERP.
-- Stores cash book, bank accounts,
-- bank transactions, income,
-- expenses, vendor payments,
-- patient advances, ledger entries
-- and daily financial closing.
--
-- This module integrates with:
-- • Billing
-- • Pharmacy
-- • Suppliers
-- • Patients
-- • User Profiles
-- ============================================================================

BEGIN;

-- ============================================================================
-- CASH BOOK
-- ============================================================================

CREATE TABLE IF NOT EXISTS cash_book (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    cash_entry_number VARCHAR(20) NOT NULL UNIQUE,

    transaction_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    transaction_type VARCHAR(20) NOT NULL,
    -- Receipt / Payment

    reference_type VARCHAR(50),
    -- Bill / Expense / Refund / Advance / Vendor Payment / Other

    reference_id UUID,

    payment_method VARCHAR(30),
    -- Cash / UPI / Card / Bank Transfer / Cheque

    description TEXT NOT NULL,

    amount NUMERIC(12,2) NOT NULL,

    opening_balance NUMERIC(12,2),

    closing_balance NUMERIC(12,2),

    received_from VARCHAR(200),

    paid_to VARCHAR(200),

    verified_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE cash_book IS
'Stores all cash receipts and cash payments of the clinic.';

CREATE TRIGGER trg_cash_book_updated_at
BEFORE UPDATE ON cash_book
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- BANK ACCOUNTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS bank_accounts (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    bank_account_number VARCHAR(20) NOT NULL UNIQUE,

    account_name VARCHAR(200) NOT NULL,

    bank_name VARCHAR(150) NOT NULL,

    branch_name VARCHAR(150),

    account_number VARCHAR(50) NOT NULL,

    account_type VARCHAR(30) DEFAULT 'Current',
    -- Current / Savings

    ifsc_code VARCHAR(20),

    micr_code VARCHAR(20),

    upi_id VARCHAR(100),

    opening_balance NUMERIC(12,2) NOT NULL DEFAULT 0,

    current_balance NUMERIC(12,2) NOT NULL DEFAULT 0,

    account_status VARCHAR(30) NOT NULL DEFAULT 'Active',
    -- Active / Inactive / Closed

    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    
    opened_on DATE,

    closed_on DATE,

    account_holder_name VARCHAR(200),

    contact_number VARCHAR(20),

    email VARCHAR(150),

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE bank_accounts IS
'Stores clinic bank account details used for financial transactions, payments and receipts.';

CREATE TRIGGER trg_bank_accounts_updated_at
BEFORE UPDATE ON bank_accounts
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- BANK TRANSACTIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS bank_transactions (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    transaction_number VARCHAR(20) NOT NULL UNIQUE,

    bank_account_id UUID NOT NULL,

    transaction_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    transaction_type VARCHAR(30) NOT NULL,
    -- Deposit / Withdrawal / Transfer / Interest / Charges / Refund

    payment_method VARCHAR(30),
    -- Cash / UPI / NEFT / RTGS / IMPS / Cheque / Card / Bank Transfer

    reference_type VARCHAR(50),
    -- Bill / Payment / Refund / Expense / Vendor Payment / Other

    reference_id UUID,

    transaction_reference VARCHAR(150),

    cheque_number VARCHAR(50),

    cheque_date DATE,

    amount NUMERIC(12,2) NOT NULL,

    opening_balance NUMERIC(12,2),

    closing_balance NUMERIC(12,2),

    beneficiary_name VARCHAR(200),

    description TEXT,

    verified_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_bank_transactions_bank_account
        FOREIGN KEY (bank_account_id)
        REFERENCES bank_accounts(id)
        ON DELETE RESTRICT

);

COMMENT ON TABLE bank_transactions IS
'Stores all bank transactions including deposits, withdrawals, transfers, refunds, bank charges and interest entries.';

CREATE TRIGGER trg_bank_transactions_updated_at
BEFORE UPDATE ON bank_transactions
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- EXPENSE CATEGORIES
-- ============================================================================

CREATE TABLE IF NOT EXISTS expense_categories (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    category_code VARCHAR(20) NOT NULL UNIQUE,

    category_name VARCHAR(150) NOT NULL,

    parent_category_id UUID,

    description TEXT,

    is_system BOOLEAN NOT NULL DEFAULT FALSE,

    display_order INTEGER DEFAULT 1,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_expense_category_parent
        FOREIGN KEY (parent_category_id)
        REFERENCES expense_categories(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE expense_categories IS
'Stores master list of clinic expense categories.';

CREATE TRIGGER trg_expense_categories_updated_at
BEFORE UPDATE ON expense_categories
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- EXPENSES
-- ============================================================================

CREATE TABLE IF NOT EXISTS expenses (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    expense_number VARCHAR(20) NOT NULL UNIQUE,

    expense_category_id UUID NOT NULL,

    supplier_id UUID,

    expense_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    expense_status VARCHAR(30) NOT NULL DEFAULT 'Pending',

    payment_status VARCHAR(30) NOT NULL DEFAULT 'Pending',

    payment_method VARCHAR(30),

    due_date DATE,

    invoice_number VARCHAR(100),

    invoice_date DATE,

    subtotal NUMERIC(12,2) NOT NULL DEFAULT 0,

    tax_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    discount_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    amount_paid NUMERIC(12,2) NOT NULL DEFAULT 0,

    balance_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    expense_description TEXT,

    approved_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_expenses_category
        FOREIGN KEY (expense_category_id)
        REFERENCES expense_categories(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_expenses_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES suppliers(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE expenses IS
'Stores clinic operational expenses.';

CREATE TRIGGER trg_expenses_updated_at
BEFORE UPDATE ON expenses
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- INCOME
-- ============================================================================

CREATE TABLE IF NOT EXISTS income (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    income_number VARCHAR(20) NOT NULL UNIQUE,

    income_source VARCHAR(50) NOT NULL,
    -- Consultation / Pharmacy / Therapy / Other

    reference_type VARCHAR(50),

    reference_id UUID,

    income_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    payment_method VARCHAR(30),

    amount NUMERIC(12,2) NOT NULL,

    received_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE income IS
'Stores all clinic income entries including non-billing income.';

CREATE TRIGGER trg_income_updated_at
BEFORE UPDATE ON income
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- VENDOR PAYMENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS vendor_payments (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    payment_number VARCHAR(20) NOT NULL UNIQUE,

    supplier_id UUID NOT NULL,

    purchase_header_id UUID,

    payment_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    payment_method VARCHAR(30),

    transaction_reference VARCHAR(150),

    amount_paid NUMERIC(12,2) NOT NULL,

    balance_amount NUMERIC(12,2) DEFAULT 0,

    paid_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_vendor_payments_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES suppliers(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_vendor_payments_purchase
        FOREIGN KEY (purchase_header_id)
        REFERENCES purchase_headers(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE vendor_payments IS
'Stores payments made to medicine suppliers and vendors.';

CREATE TRIGGER trg_vendor_payments_updated_at
BEFORE UPDATE ON vendor_payments
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PATIENT ADVANCES
-- ============================================================================

CREATE TABLE IF NOT EXISTS patient_advances (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    advance_number VARCHAR(20) NOT NULL UNIQUE,

    patient_id UUID NOT NULL,

    bill_id UUID,

    payment_id UUID,

    advance_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    advance_amount NUMERIC(12,2) NOT NULL,

    utilized_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    remaining_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    refund_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    advance_status VARCHAR(30) NOT NULL DEFAULT 'Available',
    -- Available / Partially Utilized / Fully Utilized / Refunded

    received_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_patient_advances_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_patient_advances_bill
        FOREIGN KEY (bill_id)
        REFERENCES bills(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_patient_advances_payment
        FOREIGN KEY (payment_id)
        REFERENCES payments(id)
        ON DELETE SET NULL

);

COMMENT ON TABLE patient_advances IS
'Stores advance payments received from patients and tracks utilization and refunds.';

CREATE TRIGGER trg_patient_advances_updated_at
BEFORE UPDATE ON patient_advances
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- LEDGER ENTRIES
-- ============================================================================

CREATE TABLE IF NOT EXISTS ledger_entries (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    ledger_number VARCHAR(20) NOT NULL UNIQUE,

    transaction_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    account_head VARCHAR(150) NOT NULL,

    account_group VARCHAR(100),

    transaction_type VARCHAR(20) NOT NULL,
    -- Debit / Credit

    reference_type VARCHAR(50),

    reference_id UUID,

    debit_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    credit_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    narration TEXT,

    entered_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE ledger_entries IS
'Stores accounting ledger entries for all financial transactions.';

CREATE TRIGGER trg_ledger_entries_updated_at
BEFORE UPDATE ON ledger_entries
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- DAILY CASH CLOSING
-- ============================================================================

CREATE TABLE IF NOT EXISTS daily_cash_closing (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    closing_number VARCHAR(20) NOT NULL UNIQUE,

    closing_date DATE NOT NULL,

    opening_cash NUMERIC(12,2) NOT NULL DEFAULT 0,

    total_cash_received NUMERIC(12,2) NOT NULL DEFAULT 0,

    total_cash_paid NUMERIC(12,2) NOT NULL DEFAULT 0,

    total_bank_received NUMERIC(12,2) NOT NULL DEFAULT 0,

    total_bank_paid NUMERIC(12,2) NOT NULL DEFAULT 0,

    closing_cash NUMERIC(12,2) NOT NULL DEFAULT 0,

    variance_amount NUMERIC(12,2) NOT NULL DEFAULT 0,

    closing_status VARCHAR(30) NOT NULL DEFAULT 'Closed',

    closed_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    closed_at TIMESTAMPTZ DEFAULT NOW(),

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE daily_cash_closing IS
'Stores daily financial closing and cash reconciliation records.';

CREATE TRIGGER trg_daily_cash_closing_updated_at
BEFORE UPDATE ON daily_cash_closing
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_cash_book_number
ON cash_book(cash_entry_number);

CREATE INDEX IF NOT EXISTS idx_cash_book_date
ON cash_book(transaction_date);

CREATE INDEX IF NOT EXISTS idx_cash_book_type
ON cash_book(transaction_type);

CREATE INDEX IF NOT EXISTS idx_bank_accounts_default
ON bank_accounts(is_default);

CREATE INDEX IF NOT EXISTS idx_bank_accounts_number
ON bank_accounts(bank_account_number);

CREATE INDEX IF NOT EXISTS idx_bank_accounts_name
ON bank_accounts(bank_name);

CREATE INDEX IF NOT EXISTS idx_bank_transactions_number
ON bank_transactions(transaction_number);

CREATE INDEX IF NOT EXISTS idx_bank_transactions_account
ON bank_transactions(bank_account_id);

CREATE INDEX IF NOT EXISTS idx_bank_transactions_date
ON bank_transactions(transaction_date);

CREATE INDEX IF NOT EXISTS idx_expense_categories_code
ON expense_categories(category_code);

CREATE INDEX IF NOT EXISTS idx_expense_categories_name
ON expense_categories(category_name);

CREATE INDEX IF NOT EXISTS idx_expenses_number
ON expenses(expense_number);

CREATE INDEX IF NOT EXISTS idx_expenses_category
ON expenses(expense_category_id);

CREATE INDEX IF NOT EXISTS idx_expenses_supplier
ON expenses(supplier_id);

CREATE INDEX IF NOT EXISTS idx_expenses_date
ON expenses(expense_date);

CREATE INDEX IF NOT EXISTS idx_expenses_status
ON expenses(expense_status);

CREATE INDEX IF NOT EXISTS idx_income_number
ON income(income_number);

CREATE INDEX IF NOT EXISTS idx_income_source
ON income(income_source);

CREATE INDEX IF NOT EXISTS idx_income_date
ON income(income_date);

CREATE INDEX IF NOT EXISTS idx_vendor_payments_number
ON vendor_payments(payment_number);

CREATE INDEX IF NOT EXISTS idx_vendor_payments_supplier
ON vendor_payments(supplier_id);

CREATE INDEX IF NOT EXISTS idx_vendor_payments_purchase
ON vendor_payments(purchase_header_id);

CREATE INDEX IF NOT EXISTS idx_vendor_payments_date
ON vendor_payments(payment_date);

CREATE INDEX IF NOT EXISTS idx_patient_advances_number
ON patient_advances(advance_number);

CREATE INDEX IF NOT EXISTS idx_patient_advances_patient
ON patient_advances(patient_id);

CREATE INDEX IF NOT EXISTS idx_patient_advances_bill
ON patient_advances(bill_id);

CREATE INDEX IF NOT EXISTS idx_patient_advances_status
ON patient_advances(advance_status);

CREATE INDEX IF NOT EXISTS idx_ledger_entries_number
ON ledger_entries(ledger_number);

CREATE INDEX IF NOT EXISTS idx_ledger_entries_date
ON ledger_entries(transaction_date);

CREATE INDEX IF NOT EXISTS idx_ledger_entries_type
ON ledger_entries(transaction_type);

CREATE INDEX IF NOT EXISTS idx_daily_cash_closing_number
ON daily_cash_closing(closing_number);

CREATE INDEX IF NOT EXISTS idx_daily_cash_closing_date
ON daily_cash_closing(closing_date);

CREATE INDEX IF NOT EXISTS idx_expenses_payment_status
ON expenses(payment_status);

CREATE INDEX IF NOT EXISTS idx_bank_transactions_type
ON bank_transactions(transaction_type);

CREATE INDEX IF NOT EXISTS idx_cash_book_payment_method
ON cash_book(payment_method);

CREATE INDEX IF NOT EXISTS idx_ledger_entries_account_group
ON ledger_entries(account_group);

COMMIT;
