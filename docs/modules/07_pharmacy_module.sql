-- ============================================================================
-- Suriyaraja Siddha Health Care ERP (SSHC ERP)
-- Migration : 07_pharmacy_module.sql
-- Version   : 1.0.0
-- Database  : PostgreSQL 17 (Supabase)
-- Author    : Dr. Raja Suriyaraja & ChatGPT
--
-- Description:
-- Pharmacy and Inventory module for SSHC ERP.
-- Stores medicine batches, stock transactions,
-- purchases, stock adjustments, dispensing,
-- returns, expiry tracking, supplier information,
-- inventory movements and FEFO stock management.
--
-- This module integrates with:
-- • Medicines
-- • Prescriptions
-- • Billing
-- • Suppliers
-- • Purchase
-- • Inventory
-- ============================================================================

BEGIN;

-- ============================================================================
-- SUPPLIERS
-- ============================================================================

CREATE TABLE IF NOT EXISTS suppliers (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    supplier_code VARCHAR(20) NOT NULL UNIQUE,

    supplier_name VARCHAR(200) NOT NULL,

    supplier_type VARCHAR(50) DEFAULT 'Distributor',

    gst_number VARCHAR(20),

    drug_license_number VARCHAR(50),

    contact_person VARCHAR(150),

    mobile_number VARCHAR(20),

    alternate_mobile VARCHAR(20),

    email VARCHAR(150),

    website VARCHAR(200),

    address_line1 TEXT,

    address_line2 TEXT,

    village_city VARCHAR(150),

    taluk VARCHAR(100),

    district VARCHAR(100),

    state VARCHAR(100),

    country VARCHAR(100) DEFAULT 'India',

    pincode VARCHAR(10),

    opening_balance NUMERIC(12,2) DEFAULT 0,

    credit_limit NUMERIC(12,2),

    credit_days INTEGER,

    payment_terms TEXT,

    bank_name VARCHAR(150),

    account_number VARCHAR(50),

    ifsc_code VARCHAR(20),

    upi_id VARCHAR(100),

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE

);

COMMENT ON TABLE suppliers IS
'Stores supplier and distributor information for medicine purchasing and inventory management.';

CREATE TRIGGER trg_suppliers_updated_at
BEFORE UPDATE ON suppliers
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- SUPPLIER CONTACTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS supplier_contacts (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    supplier_id UUID NOT NULL,

    contact_name VARCHAR(150) NOT NULL,

    designation VARCHAR(100),

    department VARCHAR(100),

    mobile_number VARCHAR(20),

    alternate_mobile VARCHAR(20),

    office_number VARCHAR(20),

    email VARCHAR(150),

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_supplier_contacts_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES suppliers(id)
        ON DELETE CASCADE

);

COMMENT ON TABLE supplier_contacts IS
'Stores multiple contact persons for suppliers including sales, accounts and support representatives.';

CREATE TRIGGER trg_supplier_contacts_updated_at
BEFORE UPDATE ON supplier_contacts
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PURCHASE HEADERS
-- ============================================================================

CREATE TABLE IF NOT EXISTS purchase_headers (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    purchase_number VARCHAR(20) NOT NULL UNIQUE,

    supplier_id UUID NOT NULL,

    invoice_number VARCHAR(100),

    invoice_date DATE,

    purchase_date DATE NOT NULL DEFAULT CURRENT_DATE,

    purchase_status VARCHAR(30) NOT NULL DEFAULT 'Draft',

    payment_status VARCHAR(30) NOT NULL DEFAULT 'Pending',

    payment_mode VARCHAR(30),

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

    due_date DATE,

    received_by UUID REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_purchase_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES suppliers(id)
        ON DELETE RESTRICT

);

COMMENT ON TABLE purchase_headers IS
'Stores medicine purchase invoices received from suppliers including payment and tax details.';

CREATE TRIGGER trg_purchase_headers_updated_at
BEFORE UPDATE ON purchase_headers
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PURCHASE ITEMS
-- ============================================================================

CREATE TABLE IF NOT EXISTS purchase_items (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    purchase_header_id UUID NOT NULL,

    medicine_id UUID NOT NULL,

    batch_number VARCHAR(100) NOT NULL,

    manufacturing_date DATE,

    expiry_date DATE NOT NULL,

    pack_size VARCHAR(50),

    unit VARCHAR(30),

    quantity_purchased NUMERIC(12,2) NOT NULL,

    free_quantity NUMERIC(12,2) DEFAULT 0,

    quantity_received NUMERIC(12,2) NOT NULL,

    purchase_rate NUMERIC(12,2) NOT NULL,

    mrp NUMERIC(12,2) NOT NULL,

    selling_price NUMERIC(12,2),

    discount_percent NUMERIC(5,2) DEFAULT 0,

    discount_amount NUMERIC(12,2) DEFAULT 0,

    cgst_percent NUMERIC(5,2) DEFAULT 0,

    sgst_percent NUMERIC(5,2) DEFAULT 0,

    igst_percent NUMERIC(5,2) DEFAULT 0,

    tax_amount NUMERIC(12,2) DEFAULT 0,

    line_total NUMERIC(12,2) NOT NULL,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_purchase_items_purchase
        FOREIGN KEY (purchase_header_id)
        REFERENCES purchase_headers(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_purchase_items_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES medicines(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_purchase_batch
        UNIQUE (
            purchase_header_id,
            medicine_id,
            batch_number
        )

);

COMMENT ON TABLE purchase_items IS
'Stores individual medicine items purchased from suppliers including batch details, expiry, purchase rate, MRP, taxes and received quantity.';

CREATE TRIGGER trg_purchase_items_updated_at
BEFORE UPDATE ON purchase_items
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- MEDICINE BATCHES
-- ============================================================================

CREATE TABLE IF NOT EXISTS medicine_batches (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    purchase_item_id UUID NOT NULL,

    medicine_id UUID NOT NULL,

    supplier_id UUID NOT NULL,

    batch_number VARCHAR(100) NOT NULL,

    manufacturing_date DATE,

    expiry_date DATE NOT NULL,

    purchase_rate NUMERIC(12,2) NOT NULL,

    mrp NUMERIC(12,2) NOT NULL,

    selling_price NUMERIC(12,2),

    opening_quantity NUMERIC(12,2) NOT NULL,

    current_quantity NUMERIC(12,2) NOT NULL,

    reserved_quantity NUMERIC(12,2) DEFAULT 0,

    damaged_quantity NUMERIC(12,2) DEFAULT 0,

    expired_quantity NUMERIC(12,2) DEFAULT 0,

    unit VARCHAR(30),

    received_date DATE NOT NULL DEFAULT CURRENT_DATE,

    location VARCHAR(100),
    
    last_dispensed_at TIMESTAMPTZ,

    batch_status VARCHAR(30) NOT NULL DEFAULT 'Available',

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_medicine_batches_purchase_item
        FOREIGN KEY (purchase_item_id)
        REFERENCES purchase_items(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_medicine_batches_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES medicines(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_medicine_batches_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES suppliers(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_medicine_batch
        UNIQUE (
            medicine_id,
            batch_number
        )

);

COMMENT ON TABLE medicine_batches IS
'Stores live inventory batches for medicines. Used for FEFO dispensing, expiry tracking, stock availability and inventory management.';

CREATE TRIGGER trg_medicine_batches_updated_at
BEFORE UPDATE ON medicine_batches
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- STOCK MOVEMENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS stock_movements (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    movement_number VARCHAR(20) NOT NULL UNIQUE,

    medicine_batch_id UUID NOT NULL,

    medicine_id UUID NOT NULL,

    movement_type VARCHAR(30) NOT NULL,
    -- Purchase / Sale / Dispense / Return / Purchase Return /
    -- Adjustment / Damage / Expired / Transfer In / Transfer Out

    reference_type VARCHAR(50),
    -- Purchase / Prescription / Billing / Adjustment / Return

    reference_id UUID NOT NULL,

    quantity NUMERIC(12,2) NOT NULL,

    quantity_before NUMERIC(12,2) NOT NULL,

    quantity_after NUMERIC(12,2) NOT NULL,

    unit VARCHAR(30),

    movement_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    performed_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_stock_movements_batch
        FOREIGN KEY (medicine_batch_id)
        REFERENCES medicine_batches(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_stock_movements_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES medicines(id)
        ON DELETE RESTRICT

);

COMMENT ON TABLE stock_movements IS
'Stores complete inventory movement history including purchases, dispensing, sales, returns, adjustments, damages, expiry and stock transfers for audit purposes.';

CREATE TRIGGER trg_stock_movements_updated_at
BEFORE UPDATE ON stock_movements
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- STOCK ADJUSTMENTS
-- ============================================================================

CREATE TABLE IF NOT EXISTS stock_adjustments (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    adjustment_number VARCHAR(20) NOT NULL UNIQUE,

    medicine_batch_id UUID NOT NULL,

    medicine_id UUID NOT NULL,

    adjustment_type VARCHAR(30) NOT NULL,
    -- Increase / Decrease

    adjustment_reason VARCHAR(50) NOT NULL,
    -- Physical Count / Damage / Expired /
    -- Lost / Found / Correction / Other

    quantity NUMERIC(12,2) NOT NULL,

    quantity_before NUMERIC(12,2) NOT NULL,

    quantity_after NUMERIC(12,2) NOT NULL,

    adjustment_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    approved_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    adjusted_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_stock_adjustments_batch
        FOREIGN KEY (medicine_batch_id)
        REFERENCES medicine_batches(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_stock_adjustments_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES medicines(id)
        ON DELETE RESTRICT

);

COMMENT ON TABLE stock_adjustments IS
'Stores manual stock corrections due to physical verification, damage, expiry, loss, correction or other inventory adjustments.';

CREATE TRIGGER trg_stock_adjustments_updated_at
BEFORE UPDATE ON stock_adjustments
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- MEDICINE RETURNS
-- ============================================================================

CREATE TABLE IF NOT EXISTS medicine_returns (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    return_number VARCHAR(20) NOT NULL UNIQUE,

    return_type VARCHAR(30) NOT NULL,
    -- Patient Return / Supplier Return / Expired Return

    return_status VARCHAR(30) DEFAULT 'Completed',
    
    medicine_batch_id UUID NOT NULL,

    medicine_id UUID NOT NULL,

    supplier_id UUID REFERENCES suppliers(id)
        ON DELETE RESTRICT,

    prescription_medicine_id UUID
        REFERENCES prescription_medicines(id)
        ON DELETE SET NULL,

    purchase_item_id UUID
        REFERENCES purchase_items(id)
        ON DELETE SET NULL,

    quantity NUMERIC(12,2) NOT NULL,

    return_reason VARCHAR(100) NOT NULL,
    -- Damaged / Wrong Medicine / Near Expiry /
    -- Expired / Patient Return / Supplier Recall / Other

    return_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    refund_amount NUMERIC(12,2) DEFAULT 0,

    approved_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    processed_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_medicine_returns_batch
        FOREIGN KEY (medicine_batch_id)
        REFERENCES medicine_batches(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_medicine_returns_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES medicines(id)
        ON DELETE RESTRICT

);

COMMENT ON TABLE medicine_returns IS
'Stores medicine returns including patient returns, supplier returns and expired medicine returns for inventory and financial audit purposes.';

CREATE TRIGGER trg_medicine_returns_updated_at
BEFORE UPDATE ON medicine_returns
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- PHYSICAL STOCK VERIFICATION
-- ============================================================================

CREATE TABLE IF NOT EXISTS physical_stock_verification (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    verification_number VARCHAR(20) NOT NULL UNIQUE,

    medicine_batch_id UUID NOT NULL,

    medicine_id UUID NOT NULL,

    verification_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    system_quantity NUMERIC(12,2) NOT NULL,

    physical_quantity NUMERIC(12,2) NOT NULL,

    variance_quantity NUMERIC(12,2) NOT NULL,

    variance_reason TEXT,

    adjustment_required BOOLEAN NOT NULL DEFAULT FALSE,

    adjustment_completed BOOLEAN NOT NULL DEFAULT FALSE,

    verified_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    approved_by UUID
        REFERENCES user_profiles(id)
        ON DELETE RESTRICT,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_by UUID,

    updated_by UUID,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_physical_stock_verification_batch
        FOREIGN KEY (medicine_batch_id)
        REFERENCES medicine_batches(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_physical_stock_verification_medicine
        FOREIGN KEY (medicine_id)
        REFERENCES medicines(id)
        ON DELETE RESTRICT

);

COMMENT ON TABLE physical_stock_verification IS
'Stores physical stock verification records for inventory audit, reconciliation and stock adjustment approval.';

CREATE TRIGGER trg_physical_stock_verification_updated_at
BEFORE UPDATE ON physical_stock_verification
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_suppliers_code
ON suppliers(supplier_code);

CREATE INDEX IF NOT EXISTS idx_suppliers_name
ON suppliers(supplier_name);

CREATE INDEX IF NOT EXISTS idx_supplier_contacts_supplier
ON supplier_contacts(supplier_id);

CREATE INDEX IF NOT EXISTS idx_purchase_headers_number
ON purchase_headers(purchase_number);

CREATE INDEX IF NOT EXISTS idx_purchase_headers_supplier
ON purchase_headers(supplier_id);

CREATE INDEX IF NOT EXISTS idx_purchase_headers_invoice
ON purchase_headers(invoice_number);

CREATE INDEX IF NOT EXISTS idx_purchase_headers_date
ON purchase_headers(purchase_date);

CREATE INDEX IF NOT EXISTS idx_purchase_headers_status
ON purchase_headers(purchase_status);

CREATE INDEX IF NOT EXISTS idx_purchase_items_purchase
ON purchase_items(purchase_header_id);

CREATE INDEX IF NOT EXISTS idx_purchase_items_medicine
ON purchase_items(medicine_id);

CREATE INDEX IF NOT EXISTS idx_purchase_items_batch
ON purchase_items(batch_number);

CREATE INDEX IF NOT EXISTS idx_purchase_items_expiry
ON purchase_items(expiry_date);

CREATE INDEX IF NOT EXISTS idx_medicine_batches_medicine
ON medicine_batches(medicine_id);

CREATE INDEX IF NOT EXISTS idx_medicine_batches_batch
ON medicine_batches(batch_number);

CREATE INDEX IF NOT EXISTS idx_medicine_batches_supplier
ON medicine_batches(supplier_id);

CREATE INDEX IF NOT EXISTS idx_medicine_batches_expiry
ON medicine_batches(expiry_date);

CREATE INDEX IF NOT EXISTS idx_medicine_batches_status
ON medicine_batches(batch_status);

CREATE INDEX IF NOT EXISTS idx_stock_movements_number
ON stock_movements(movement_number);

CREATE INDEX IF NOT EXISTS idx_stock_movements_batch
ON stock_movements(medicine_batch_id);

CREATE INDEX IF NOT EXISTS idx_stock_movements_medicine
ON stock_movements(medicine_id);

CREATE INDEX IF NOT EXISTS idx_stock_movements_type
ON stock_movements(movement_type);

CREATE INDEX IF NOT EXISTS idx_stock_movements_date
ON stock_movements(movement_date);

CREATE INDEX IF NOT EXISTS idx_stock_adjustments_number
ON stock_adjustments(adjustment_number);

CREATE INDEX IF NOT EXISTS idx_stock_adjustments_batch
ON stock_adjustments(medicine_batch_id);

CREATE INDEX IF NOT EXISTS idx_stock_adjustments_medicine
ON stock_adjustments(medicine_id);

CREATE INDEX IF NOT EXISTS idx_stock_adjustments_date
ON stock_adjustments(adjustment_date);

CREATE INDEX IF NOT EXISTS idx_medicine_returns_number
ON medicine_returns(return_number);

CREATE INDEX IF NOT EXISTS idx_medicine_returns_batch
ON medicine_returns(medicine_batch_id);

CREATE INDEX IF NOT EXISTS idx_medicine_returns_medicine
ON medicine_returns(medicine_id);

CREATE INDEX IF NOT EXISTS idx_medicine_returns_supplier
ON medicine_returns(supplier_id);

CREATE INDEX IF NOT EXISTS idx_medicine_returns_date
ON medicine_returns(return_date);

CREATE INDEX IF NOT EXISTS idx_physical_stock_verification_number
ON physical_stock_verification(verification_number);

CREATE INDEX IF NOT EXISTS idx_physical_stock_verification_batch
ON physical_stock_verification(medicine_batch_id);

CREATE INDEX IF NOT EXISTS idx_physical_stock_verification_medicine
ON physical_stock_verification(medicine_id);

CREATE INDEX IF NOT EXISTS idx_physical_stock_verification_date
ON physical_stock_verification(verification_date);

CREATE INDEX IF NOT EXISTS idx_medicine_returns_status
ON medicine_returns(return_status);

COMMIT;
