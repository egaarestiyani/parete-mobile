# Jalankan Parete Mobile di emulator/perangkat Android
$ErrorActionPreference = "Stop"

$FlutterPath = "C:\src\flutter\bin"
if (Test-Path $FlutterPath) {
    $env:Path = "$FlutterPath;" + $env:Path
}

$sdk = "$env:LOCALAPPDATA\Android\sdk"
if (Test-Path $sdk) {
    $env:ANDROID_HOME = $sdk
    $env:ANDROID_SDK_ROOT = $sdk
}

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

Write-Host "Perangkat tersedia:"
flutter devices

Write-Host ""
Write-Host "Pastikan Developer Mode Windows aktif (Settings > System > For developers)."
Write-Host "Jika Android toolchain belum lengkap, buka Android Studio > SDK Manager > install Command-line Tools."
Write-Host ""

flutter pub get
flutter run
