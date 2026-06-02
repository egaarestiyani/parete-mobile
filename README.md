# pa-rete (Flutter)

Aplikasi warga RT 05 — terhubung ke backend **Laravel + MongoDB** (`parete-web`).

## Arsitektur (Cloud Computing)

| Lapisan | Teknologi |
|---------|-----------|
| Mobile | Flutter (proyek ini) |
| API | Laravel `parete-web` |
| Database | **MongoDB** (`db_parete`, koleksi `informasi_rt`, `data_warga`, dll.) |
| File gambar | Path di MongoDB (`gambar_informasi`), file di `storage/app/public/informasi_gambar/` |

## Menjalankan

1. **Backend** (dari folder `parete-web`):
   ```powershell
   .\scripts\run-backend.ps1
   ```
   Pastikan `php artisan storage:link` sudah pernah dijalankan sekali.

2. **Mobile Android (emulator)**:
   ```powershell
   .\scripts\run-android.ps1
   ```
   URL API default: `http://10.0.2.2:8000` (alias emulator ke PC).

3. **HP fisik** (Wi‑Fi sama dengan laptop):
   ```powershell
   flutter run --dart-define=PARETE_API_URL=http://<IP-LAPTOP>:8000
   ```

## Gambar pengumuman

- Path disimpan di **MongoDB** (`gambar_informasi`: `informasi_gambar/nama-file.jpg`).
- App memuat gambar lewat `GET /api/media/{path}` (host sama dengan API JSON).
- Jika gambar tidak muncul: pastikan backend jalan di `0.0.0.0:8000`, lalu **hot restart** (bukan hanya hot reload) aplikasi Flutter.
