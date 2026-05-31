# Jalankan Parete Mobile di Chrome (paling mudah di Windows tanpa Visual Studio)
$ErrorActionPreference = "Stop"

$FlutterPath = "C:\src\flutter\bin"
if (Test-Path $FlutterPath) {
    $env:Path = "$FlutterPath;" + $env:Path
}

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

flutter pub get
flutter run -d chrome --web-port 7357
