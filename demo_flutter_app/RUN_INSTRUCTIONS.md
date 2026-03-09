# Automation Script for Demo Flutter App

This script launches the Pixel 6 emulator and then runs the Flutter application.

## Usage
Run this in your PowerShell terminal:
```powershell
.\run.ps1
```

## Script Content
```powershell
Write-Host "Launching Pixel 6 emulator..." -ForegroundColor Cyan
Start-Process "C:\Users\vedant\AppData\Local\Android\Sdk\emulator\emulator.exe" -ArgumentList "-avd pixel_6"

Write-Host "Waiting for device to initialize (20s)..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

Write-Host "Starting Flutter app..." -ForegroundColor Green
flutter run
```
