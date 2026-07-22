$DeviceName = "tecno bg7"
# Check if the primary device is connected
$devices = flutter devices
if ($devices -match $DeviceName) {
    Write-Host "[Phone] Found $DeviceName. Launching app..." -ForegroundColor Green
    $TargetDevice = $DeviceName
} elseif ($devices -match "windows") {
    Write-Host "[PC] Android device not found. Falling back to Windows..." -ForegroundColor Yellow
    $TargetDevice = "windows"
} elseif ($devices -match "chrome") {
    Write-Host "[Web] Falling back to Chrome..." -ForegroundColor Yellow
    $TargetDevice = "chrome"
} else {
    Write-Host "[Warn] No suitable devices found. Flutter will ask you to pick one." -ForegroundColor Red
    $TargetDevice = $null
}

$Args = @(
    "run"
)

if ($TargetDevice) {
    $Args += "-d"
    $Args += $TargetDevice
}

$Args += "--dart-define=TMDB_TOKEN=eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5ODEwZWZkZTMwZGE0ZGMyNTZjNjI1MmVhY2NjOTc4MSIsIm5iZiI6MTc3NDA5NzQ3NC4wODYwMDAyLCJzdWIiOiI2OWJlOTQ0MjQ3MjI1NzFhYzkwZTJhOTYiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.xUFgUaLVe6oasd764gAOIFIYIpE_Vb1E-FP5YOY9H2c"
$Args += "--dart-define=SUPABASE_URL=https://ludhagtgszsaexhfgpcl.supabase.co"
$Args += "--dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx1ZGhhZ3Rnc3pzYWV4aGZncGNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM1MDYyNjcsImV4cCI6MjA5OTA4MjI2N30.B6TR3U3ULovXYzPHhEa8fgNSI8jf4aH-KjLvVWthyo0"

# Execute
flutter @Args
