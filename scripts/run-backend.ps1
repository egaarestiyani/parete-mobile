@echo off
REM Jalankan backend Laravel Parete untuk integrasi mobile
cd /d c:\xampp\htdocs\parete
php artisan serve --host=127.0.0.1 --port=8000
