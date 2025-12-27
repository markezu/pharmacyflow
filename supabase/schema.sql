-- Users Table (Extends Supabase Auth or Standalone)
-- In Supabase, we typically use auth.users for authentication.
-- We will create a 'profiles' table to store additional user info linking to auth.users if needed,
-- or just a 'users' table if we are managing users manually within the app (less recommended for Auth, but follows Schema).
-- For this schema, I will create tables as requested but adjust for PostgreSQL.

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ROLES
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NOT NULL,
    permissions JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- USERS (Note: In Supabase, use auth.users. This table is for app-specific data)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role_id INTEGER REFERENCES roles(id),
    avatar VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- CATEGORIES
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NOT NULL,
    parent_id INTEGER REFERENCES categories(id),
    icon VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- SUPPLIERS
CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Sudan',
    tax_number VARCHAR(50),
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- MEDICINES
CREATE TABLE medicines (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    name_ar VARCHAR(255),
    generic_name VARCHAR(255),
    barcode VARCHAR(100) UNIQUE,
    category_id INTEGER REFERENCES categories(id),
    supplier_id INTEGER REFERENCES suppliers(id),
    manufacturer VARCHAR(255),
    unit VARCHAR(50) DEFAULT 'piece',
    purchase_price DECIMAL(10,2) NOT NULL,
    selling_price DECIMAL(10,2) NOT NULL,
    quantity INTEGER DEFAULT 0,
    min_quantity INTEGER DEFAULT 10,
    expiry_date DATE,
    batch_number VARCHAR(100),
    shelf_location VARCHAR(50),
    requires_prescription BOOLEAN DEFAULT FALSE,
    description TEXT,
    image VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- CUSTOMERS
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    national_id VARCHAR(50),
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female')),
    loyalty_points INTEGER DEFAULT 0,
    credit_limit DECIMAL(10,2) DEFAULT 0,
    credit_balance DECIMAL(10,2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PRESCRIPTIONS
CREATE TABLE prescriptions (
    id SERIAL PRIMARY KEY,
    prescription_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INTEGER REFERENCES customers(id),
    doctor_name VARCHAR(255),
    doctor_specialty VARCHAR(100),
    hospital_clinic VARCHAR(255),
    diagnosis TEXT,
    prescription_date DATE NOT NULL,
    issue_date TIMESTAMPTZ DEFAULT NOW(),
    expiry_date DATE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'dispensed', 'partial', 'expired')),
    notes TEXT,
    image VARCHAR(255),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- SALES
CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INTEGER REFERENCES customers(id),
    user_id UUID REFERENCES users(id),
    prescription_id INTEGER REFERENCES prescriptions(id),
    subtotal DECIMAL(12,2) NOT NULL,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL,
    paid_amount DECIMAL(12,2) NOT NULL,
    change_amount DECIMAL(10,2) DEFAULT 0,
    payment_method VARCHAR(20) DEFAULT 'cash' CHECK (payment_method IN ('cash', 'bank', 'card', 'credit')),
    payment_status VARCHAR(20) DEFAULT 'paid' CHECK (payment_status IN ('paid', 'partial', 'unpaid')),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- SALE ITEMS
CREATE TABLE sale_items (
    id SERIAL PRIMARY KEY,
    sale_id INTEGER REFERENCES sales(id) ON DELETE CASCADE,
    medicine_id INTEGER REFERENCES medicines(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount DECIMAL(10,2) DEFAULT 0,
    total_price DECIMAL(12,2) NOT NULL
);

-- PRESCRIPTION ITEMS
CREATE TABLE prescription_items (
    id SERIAL PRIMARY KEY,
    prescription_id INTEGER REFERENCES prescriptions(id) ON DELETE CASCADE,
    medicine_name VARCHAR(255) NOT NULL,
    medicine_id INTEGER REFERENCES medicines(id),
    dosage VARCHAR(100),
    frequency VARCHAR(100),
    duration VARCHAR(100),
    quantity INTEGER,
    dispensed_quantity INTEGER DEFAULT 0,
    instructions TEXT
);

-- ACTIVITY LOGS
CREATE TABLE activity_logs (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    model_type VARCHAR(100),
    model_id INTEGER, -- Assuming most models use integer IDs, UUID models would need adjustment
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- SETTINGS
CREATE TABLE settings (
    id SERIAL PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT,
    type VARCHAR(20) DEFAULT 'string' CHECK (type IN ('string', 'number', 'boolean', 'json')),
    group_name VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- INITIAL SEED DATA
INSERT INTO roles (name, name_ar, permissions) VALUES
('Admin', 'مدير', '{"all": true}'),
('Pharmacist', 'صيدلي', '{"sales": true, "inventory": true}'),
('Accountant', 'محاسب', '{"reports": true}');

INSERT INTO categories (name, name_ar, icon) VALUES
('Antibiotics', 'مضادات حيوية', 'pill'),
('Painkillers', 'مسكنات', 'activity');

-- Insert a default user (password handling would be done via Supabase Auth in real app)
-- INSERT INTO users (email, name, role_id) VALUES ('admin@pharmasys.com', 'Admin User', 1);
