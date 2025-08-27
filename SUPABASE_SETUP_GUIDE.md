# Supabase Database Setup Guide for PropertyInspect Pro

## 🎯 Overview
This guide will help you set up your Supabase database for the PropertyInspect Pro mobile application.

## 📋 Prerequisites
- Supabase account and project created
- Project ID: `epirocvvdzxiypdvdlwf`
- API Key configured in your app

## 🚀 Step-by-Step Setup

### 1. Access Supabase Dashboard
1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Navigate to your project: `epirocvvdzxiypdvdlwf`
3. Click on "SQL Editor" in the left sidebar

### 2. Run Database Setup Script
1. Copy the entire content from `database_setup.sql`
2. Paste it into the SQL Editor
3. Click "Run" to execute the script
4. You should see: "PropertyInspect Pro database setup completed successfully!"

### 3. Verify Tables Created
Go to "Table Editor" and verify these tables exist:
- ✅ `profiles` - User profile information
- ✅ `inspections` - Main inspection records
- ✅ `inspection_areas` - Areas within inspections (Kitchen, Bathroom, etc.)
- ✅ `inspection_items` - Individual inspection points
- ✅ `invoices` - Invoice generation and tracking
- ✅ `schedules` - Inspection scheduling

### 4. Configure Authentication
1. Go to "Authentication" → "Settings"
2. Enable "Email confirmations" if desired
3. Set up email templates (optional)
4. Configure redirect URLs for your app

### 5. Set up Storage (Optional)
1. Go to "Storage"
2. Create a bucket named `inspection-photos`
3. Set up policies for photo uploads:
   ```sql
   -- Allow authenticated users to upload photos
   CREATE POLICY "Users can upload photos" ON storage.objects
   FOR INSERT WITH CHECK (auth.role() = 'authenticated');
   
   -- Allow users to view their own photos
   CREATE POLICY "Users can view own photos" ON storage.objects
   FOR SELECT USING (auth.uid()::text = (storage.foldername(name))[1]);
   ```

## 🧪 Testing Your Setup

### 1. Run the App
```bash
flutter run --dart-define-from-file=env.json
```

### 2. Access Debug Screen
1. Login with any of the demo credentials
2. Navigate to Dashboard
3. Click "Debug" button (only visible in debug mode)
4. Run "Test Database Connection"

### 3. Verify Connection
The debug screen should show:
- ✅ Connection: `true`
- ✅ Initialized: `true`
- ✅ All table counts

## 🔧 Troubleshooting

### Common Issues

#### 1. "Table does not exist" Error
**Solution:** Run the `database_setup.sql` script in Supabase SQL Editor

#### 2. "Permission denied" Error
**Solution:** Check Row Level Security policies are properly set up

#### 3. "Invalid API Key" Error
**Solution:** Verify your API key in `env.json` matches your Supabase project

#### 4. Connection Timeout
**Solution:** Check your internet connection and Supabase service status

### Debug Commands

#### Test Connection in SQL Editor:
```sql
SELECT 'Connection successful!' as status;
```

#### Check Table Counts:
```sql
SELECT 
  (SELECT COUNT(*) FROM profiles) as profiles_count,
  (SELECT COUNT(*) FROM inspections) as inspections_count,
  (SELECT COUNT(*) FROM inspection_areas) as areas_count,
  (SELECT COUNT(*) FROM inspection_items) as items_count,
  (SELECT COUNT(*) FROM invoices) as invoices_count,
  (SELECT COUNT(*) FROM schedules) as schedules_count;
```

#### Verify RLS Policies:
```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public';
```

## 📊 Database Schema Overview

### Core Tables Structure:
```
profiles (user info)
├── inspections (main records)
    ├── inspection_areas (rooms/areas)
        └── inspection_items (individual checks)
    └── invoices (billing)
└── schedules (appointments)
```

### Key Relationships:
- Users → Profiles (1:1)
- Users → Inspections (1:many)
- Inspections → Areas (1:many)
- Areas → Items (1:many)
- Inspections → Invoices (1:many)
- Users → Schedules (1:many)

## 🔐 Security Features

### Row Level Security (RLS)
- ✅ Users can only access their own data
- ✅ Automatic profile creation on signup
- ✅ Secure data isolation between users

### Data Validation
- ✅ Check constraints on status fields
- ✅ Foreign key relationships
- ✅ Required field validation

## 📱 App Integration

### Environment Variables
Your app is configured with:
```json
{
  "SUPABASE_URL": "https://epirocvvdzxiypdvdlwf.supabase.co",
  "SUPABASE_ANON_KEY": "your-anon-key-here"
}
```

### Connection Status
Check connection status in your app:
```dart
final isConnected = SupabaseService.instance.isConnected;
final status = SupabaseService.instance.connectionStatus;
```

## 🎉 Next Steps

1. ✅ Database setup complete
2. ✅ Test connection successful
3. 🔄 Start using the app features:
   - Create inspections
   - Add inspection areas and items
   - Generate invoices
   - Schedule appointments

## 📞 Support

If you encounter issues:
1. Check the debug screen in your app
2. Review Supabase logs in the dashboard
3. Verify all tables and policies are created
4. Test with sample data

Your PropertyInspect Pro app is now fully connected to Supabase! 🚀