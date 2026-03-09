Write-Host "--- Flutter App Launcher ---" -ForegroundColor Cyan

# 1. Launch Emulator
Write-Host "[1/2] Launching Pixel 6 Emulator..." -ForegroundColor Green
Start-Process "C:\Users\vedant\AppData\Local\Android\Sdk\emulator\emulator.exe" -ArgumentList "-avd pixel_6"

# 2. Wait for connectivity
Write-Host "[2/2] Waiting for device to be ready (approx 20s)..." -ForegroundColor Yellow
$timeout = 30
$elapsed = 0
while ($elapsed -lt $timeout) {
    $devices = flutter devices | Select-String "emulator-5554"
    if ($devices) {
        Write-Host "Device detected!" -ForegroundColor Green
        break
    }
    Start-Sleep -Seconds 2
    $elapsed += 2
    Write-Host "." -NoNewline
}
Write-Host ""

# 3. Run Flutter
Write-Host "Starting Flutter application..." -ForegroundColor Cyan
flutter run
