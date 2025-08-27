# PropertyInspect Pro Setup Verification Script
# Run this script to verify your implementation

Write-Host "🚀 PropertyInspect Pro - Setup Verification" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

# Function to check if file exists
function Test-FileExists {
    param([string]$FilePath, [string]$Description)
    
    if (Test-Path $FilePath) {
        Write-Host "✅ $Description" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ $Description (Missing: $FilePath)" -ForegroundColor Red
        return $false
    }
}

# Function to check if text exists in file
function Test-TextInFile {
    param([string]$FilePath, [string]$SearchText, [string]$Description)
    
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        if ($content -match $SearchText) {
            Write-Host "✅ $Description" -ForegroundColor Green
            return $true
        } else {
            Write-Host "⚠️ $Description (Not found in $FilePath)" -ForegroundColor Yellow
            return $false
        }
    } else {
        Write-Host "❌ $Description (File missing: $FilePath)" -ForegroundColor Red
        return $false
    }
}

Write-Host "📁 Checking Core Files..." -ForegroundColor Cyan
$coreFiles = @(
    @("lib/main.dart", "Main application file"),
    @("lib/services/crash_reporting_service.dart", "Crash reporting service"),
    @("lib/services/app_initialization_service.dart", "App initialization service"),
    @("lib/services/error_service.dart", "Error handling service"),
    @("lib/services/performance_service.dart", "Performance monitoring service"),
    @("lib/services/offline_service.dart", "Offline functionality service"),
    @("lib/services/photo_service.dart", "Photo management service"),
    @("lib/services/backup_service.dart", "Data backup service"),
    @("lib/mixins/validation_mixin.dart", "Form validation mixin"),
    @("lib/utils/validation_helper.dart", "Validation helper utilities"),
    @("lib/firebase_options.dart", "Firebase configuration"),
    @("pubspec.yaml", "Project dependencies")
)

$coreFilesCount = 0
foreach ($file in $coreFiles) {
    if (Test-FileExists $file[0] $file[1]) {
        $coreFilesCount++
    }
}

Write-Host ""
Write-Host "📦 Checking Dependencies..." -ForegroundColor Cyan

$dependencies = @(
    "firebase_core",
    "firebase_crashlytics",
    "crypto",
    "path_provider",
    "flutter_image_compress",
    "geolocator",
    "uuid"
)

$depCount = 0
foreach ($dep in $dependencies) {
    if (Test-TextInFile "pubspec.yaml" $dep "Dependency: $dep") {
        $depCount++
    }
}

Write-Host ""
Write-Host "🔧 Checking Implementation..." -ForegroundColor Cyan

$implementations = @(
    @("lib/main.dart", "runZonedGuarded", "Error boundary implementation"),
    @("lib/main.dart", "AppInitializationService", "App initialization service usage"),
    @("lib/services/crash_reporting_service.dart", "ErrorBoundary", "Error boundary widget"),
    @("lib/presentation/login_screen/login_screen.dart", "ValidationMixin", "Validation mixin usage"),
    @("lib/services/offline_service.dart", "PerformanceService", "Performance tracking in offline service")
)

$implCount = 0
foreach ($impl in $implementations) {
    if (Test-TextInFile $impl[0] $impl[1] $impl[2]) {
        $implCount++
    }
}

Write-Host ""
Write-Host "📊 Verification Summary" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host "Core Files: $coreFilesCount/$($coreFiles.Count)" -ForegroundColor $(if ($coreFilesCount -eq $coreFiles.Count) { "Green" } else { "Yellow" })
Write-Host "Dependencies: $depCount/$($dependencies.Count)" -ForegroundColor $(if ($depCount -eq $dependencies.Count) { "Green" } else { "Yellow" })
Write-Host "Implementations: $implCount/$($implementations.Count)" -ForegroundColor $(if ($implCount -eq $implementations.Count) { "Green" } else { "Yellow" })

$totalScore = $coreFilesCount + $depCount + $implCount
$maxScore = $coreFiles.Count + $dependencies.Count + $implementations.Count
$percentage = [math]::Round(($totalScore / $maxScore) * 100, 1)

Write-Host ""
Write-Host "🎯 Overall Score: $totalScore/$maxScore ($percentage%)" -ForegroundColor $(if ($percentage -ge 90) { "Green" } elseif ($percentage -ge 70) { "Yellow" } else { "Red" })

Write-Host ""
if ($percentage -ge 90) {
    Write-Host "🎉 Excellent! Your implementation is ready for testing." -ForegroundColor Green
    Write-Host "Next steps:" -ForegroundColor Green
    Write-Host "1. Run: flutter pub get" -ForegroundColor White
    Write-Host "2. Run: flutter run --dart-define-from-file=env.json" -ForegroundColor White
} elseif ($percentage -ge 70) {
    Write-Host "⚠️ Good progress! A few items need attention." -ForegroundColor Yellow
    Write-Host "Please review the missing items above and complete the implementation." -ForegroundColor Yellow
} else {
    Write-Host "❌ Implementation incomplete. Please review the missing items." -ForegroundColor Red
    Write-Host "Refer to IMPLEMENTATION_GUIDE.md for detailed instructions." -ForegroundColor Red
}

Write-Host ""
Write-Host "📚 Additional Resources:" -ForegroundColor Cyan
Write-Host "- IMPLEMENTATION_GUIDE.md - Complete implementation guide" -ForegroundColor White
Write-Host "- MANUAL_TESTING_GUIDE.md - Testing instructions" -ForegroundColor White
Write-Host "- SUPABASE_SETUP_GUIDE.md - Database setup guide" -ForegroundColor White

Write-Host ""
Write-Host "🔧 Quick Commands:" -ForegroundColor Cyan
Write-Host "flutter pub get                                    # Install dependencies" -ForegroundColor White
Write-Host "flutter run --dart-define-from-file=env.json      # Run the app" -ForegroundColor White
Write-Host "flutter doctor                                     # Check Flutter setup" -ForegroundColor White