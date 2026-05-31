# Setup Parete Mobile untuk development di Windows
$ErrorActionPreference = "Stop"

$FlutterPath = "C:\src\flutter"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

function Ensure-Flutter {
    if (-not (Test-Path "$FlutterPath\bin\flutter.bat")) {
        Write-Host "Mengunduh Flutter SDK ke $FlutterPath ..."
        New-Item -ItemType Directory -Force -Path (Split-Path $FlutterPath) | Out-Null
        git clone https://github.com/flutter/flutter.git -b stable --depth 1 $FlutterPath
    }

    $env:Path = "$FlutterPath\bin;" + $env:Path
    flutter --version
    flutter config --enable-web
}

function Ensure-AndroidEnv {
    $sdk = "$env:LOCALAPPDATA\Android\sdk"
    if (Test-Path $sdk) {
        [Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdk, "User")
        [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $sdk, "User")
        $env:ANDROID_HOME = $sdk
        $env:ANDROID_SDK_ROOT = $sdk
    }
}

function Ensure-UserPath {
    $flutterBin = "$FlutterPath\bin"
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$flutterBin*") {
        [Environment]::SetEnvironmentVariable("Path", "$flutterBin;$userPath", "User")
        Write-Host "Flutter ditambahkan ke PATH user."
    }
}

Write-Host "=== Setup Parete Mobile ===" -ForegroundColor Cyan
Ensure-Flutter
Ensure-AndroidEnv
Ensure-UserPath

Set-Location $ProjectRoot
flutter pub get
flutter doctor

Write-Host ""
Write-Host "Setup selesai." -ForegroundColor Green
Write-Host "Jalankan app di browser:  .\scripts\run-web.ps1"
Write-Host "Atau buka Cursor/VS Code lalu pilih Run > Parete (Chrome)."
