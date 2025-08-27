-- PropertyInspect Pro Database Setup Script
-- Run this script in your Supabase SQL Editor to create all required tables

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    role TEXT DEFAULT 'staff' CHECK (role IN ('admin', 'manager', 'staff')),
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    company TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Create inspections table
CREATE TABLE IF NOT EXISTS inspections (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    client_name TEXT,
    property_type TEXT NOT NULL,
    inspector_name TEXT NOT NULL,
    inspection_date DATE NOT NULL,
    property_location TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create inspection_areas table
CREATE TABLE IF NOT EXISTS inspection_areas (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    inspection_id UUID REFERENCES inspections(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create inspection_items table
CREATE TABLE IF NOT EXISTS inspection_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    area_id UUID REFERENCES inspection_areas(id) ON DELETE CASCADE,
    point TEXT NOT NULL,
    category TEXT NOT NULL,
    status TEXT CHECK (status IN ('Pass', 'Fail', 'N/A', 'Needs Review')),
    comments TEXT,
    location TEXT,
    photos TEXT[] DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create invoices table
CREATE TABLE IF NOT EXISTS invoices (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    inspection_id UUID REFERENCES inspections(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    invoice_number TEXT UNIQUE NOT NULL,
    client_name TEXT NOT NULL,
    client_email TEXT,
    client_address TEXT,
    amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'sent', 'paid', 'overdue', 'cancelled')),
    due_date DATE,
    paid_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create schedules table
CREATE TABLE IF NOT EXISTS schedules (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    property_address TEXT NOT NULL,
    client_name TEXT,
    client_phone TEXT,
    client_email TEXT,
    scheduled_date TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER DEFAULT 120,
    status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled')),
    property_type TEXT,
    special_instructions TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_inspections_user_id ON inspections(user_id);
CREATE INDEX IF NOT EXISTS idx_inspections_date ON inspections(inspection_date);
CREATE INDEX IF NOT EXISTS idx_inspections_status ON inspections(status);
CREATE INDEX IF NOT EXISTS idx_inspection_areas_inspection_id ON inspection_areas(inspection_id);
CREATE INDEX IF NOT EXISTS idx_inspection_items_area_id ON inspection_items(area_id);
CREATE INDEX IF NOT EXISTS idx_inspection_items_status ON inspection_items(status);
CREATE INDEX IF NOT EXISTS idx_invoices_user_id ON invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_invoices_inspection_id ON invoices(inspection_id);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);
CREATE INDEX IF NOT EXISTS idx_schedules_user_id ON schedules(user_id);
CREATE INDEX IF NOT EXISTS idx_schedules_date ON schedules(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_schedules_status ON schedules(status);

-- Enable Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE inspections ENABLE ROW LEVEL SECURITY;
ALTER TABLE inspection_areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE inspection_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for profiles
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create RLS policies for inspections
DROP POLICY IF EXISTS "Users can view own inspections" ON inspections;
CREATE POLICY "Users can view own inspections" ON inspections FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own inspections" ON inspections;
CREATE POLICY "Users can insert own inspections" ON inspections FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own inspections" ON inspections;
CREATE POLICY "Users can update own inspections" ON inspections FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own inspections" ON inspections;
CREATE POLICY "Users can delete own inspections" ON inspections FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for inspection_areas
DROP POLICY IF EXISTS "Users can view inspection areas" ON inspection_areas;
CREATE POLICY "Users can view inspection areas" ON inspection_areas FOR SELECT USING (
    EXISTS (SELECT 1 FROM inspections WHERE inspections.id = inspection_areas.inspection_id AND inspections.user_id = auth.uid())
);

DROP POLICY IF EXISTS "Users can insert inspection areas" ON inspection_areas;
CREATE POLICY "Users can insert inspection areas" ON inspection_areas FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM inspections WHERE inspections.id = inspection_areas.inspection_id AND inspections.user_id = auth.uid())
);

DROP POLICY IF EXISTS "Users can update inspection areas" ON inspection_areas;
CREATE POLICY "Users can update inspection areas" ON inspection_areas FOR UPDATE USING (
    EXISTS (SELECT 1 FROM inspections WHERE inspections.id = inspection_areas.inspection_id AND inspections.user_id = auth.uid())
);

DROP POLICY IF EXISTS "Users can delete inspection areas" ON inspection_areas;
CREATE POLICY "Users can delete inspection areas" ON inspection_areas FOR DELETE USING (
    EXISTS (SELECT 1 FROM inspections WHERE inspections.id = inspection_areas.inspection_id AND inspections.user_id = auth.uid())
);

-- Create RLS policies for inspection_items
DROP POLICY IF EXISTS "Users can view inspection items" ON inspection_items;
CREATE POLICY "Users can view inspection items" ON inspection_items FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM inspection_areas 
        JOIN inspections ON inspections.id = inspection_areas.inspection_id 
        WHERE inspection_areas.id = inspection_items.area_id AND inspections.user_id = auth.uid()
    )
);

DROP POLICY IF EXISTS "Users can insert inspection items" ON inspection_items;
CREATE POLICY "Users can insert inspection items" ON inspection_items FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM inspection_areas 
        JOIN inspections ON inspections.id = inspection_areas.inspection_id 
        WHERE inspection_areas.id = inspection_items.area_id AND inspections.user_id = auth.uid()
    )
);

DROP POLICY IF EXISTS "Users can update inspection items" ON inspection_items;
CREATE POLICY "Users can update inspection items" ON inspection_items FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM inspection_areas 
        JOIN inspections ON inspections.id = inspection_areas.inspection_id 
        WHERE inspection_areas.id = inspection_items.area_id AND inspections.user_id = auth.uid()
    )
);

DROP POLICY IF EXISTS "Users can delete inspection items" ON inspection_items;
CREATE POLICY "Users can delete inspection items" ON inspection_items FOR DELETE USING (
    EXISTS (
        SELECT 1 FROM inspection_areas 
        JOIN inspections ON inspections.id = inspection_areas.inspection_id 
        WHERE inspection_areas.id = inspection_items.area_id AND inspections.user_id = auth.uid()
    )
);

-- Create RLS policies for invoices
DROP POLICY IF EXISTS "Users can view own invoices" ON invoices;
CREATE POLICY "Users can view own invoices" ON invoices FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own invoices" ON invoices;
CREATE POLICY "Users can insert own invoices" ON invoices FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own invoices" ON invoices;
CREATE POLICY "Users can update own invoices" ON invoices FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own invoices" ON invoices;
CREATE POLICY "Users can delete own invoices" ON invoices FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for schedules
DROP POLICY IF EXISTS "Users can view own schedules" ON schedules;
CREATE POLICY "Users can view own schedules" ON schedules FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own schedules" ON schedules;
CREATE POLICY "Users can insert own schedules" ON schedules FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own schedules" ON schedules;
CREATE POLICY "Users can update own schedules" ON schedules FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own schedules" ON schedules;
CREATE POLICY "Users can delete own schedules" ON schedules FOR DELETE USING (auth.uid() = user_id);

-- Create function to automatically create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (user_id, email, role)
    VALUES (NEW.id, NEW.email, 'staff');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create profile on user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically update updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_inspections_updated_at BEFORE UPDATE ON inspections FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_inspection_areas_updated_at BEFORE UPDATE ON inspection_areas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_inspection_items_updated_at BEFORE UPDATE ON inspection_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON invoices FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON schedules FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data for testing (optional)
-- Uncomment the following lines if you want sample data

/*
-- Sample inspection data
INSERT INTO inspections (user_id, client_name, property_type, inspector_name, inspection_date, property_location, status, notes)
VALUES 
    (auth.uid(), 'Sample Client 1', 'Residential', 'John Inspector', CURRENT_DATE, '123 Main St, Sample City, SC 12345', 'pending', 'Sample residential inspection'),
    (auth.uid(), 'Sample Client 2', 'Commercial', 'Jane Inspector', CURRENT_DATE + INTERVAL '1 day', '456 Business Ave, Sample City, SC 12345', 'scheduled', 'Sample commercial inspection');

-- Sample schedule data
INSERT INTO schedules (user_id, title, property_address, client_name, scheduled_date, property_type, status)
VALUES 
    (auth.uid(), 'Morning Inspection', '789 Oak St, Sample City, SC 12345', 'Sample Client 3', NOW() + INTERVAL '1 day', 'Residential', 'scheduled'),
    (auth.uid(), 'Afternoon Inspection', '321 Pine Ave, Sample City, SC 12345', 'Sample Client 4', NOW() + INTERVAL '2 days', 'Multi-family', 'scheduled');
*/

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- Success message
SELECT 'PropertyInspect Pro database setup completed successfully!' as message;