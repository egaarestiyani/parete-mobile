@echo off
REM Jalankan backend Laravel Parete (parete-web) untuk integrasi mobile
cd /d D:\Laragon\laragon\www\parete-web
php artisan serve --host=0.0.0.0 --port=8000
