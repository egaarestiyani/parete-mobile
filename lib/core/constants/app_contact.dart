/// Kontak admin RT (WhatsApp, email, dll.).
class AppContact {
  const AppContact._();

  static const String _waNumber = '628907654321';

  static final Uri adminWhatsApp = Uri.parse(
    'https://wa.me/$_waNumber?text=${Uri.encodeComponent('Halo Admin RT, saya butuh bantuan untuk masuk ke aplikasi Parete.')}',
  );

  /// Lupa ID / kata sandi — dari tombol "lupa akses?" di login.
  static final Uri adminWhatsAppLupaAkses = Uri.parse(
    'https://wa.me/$_waNumber?text=${Uri.encodeComponent('Halo Admin RT, saya lupa ID Keluarga atau kata sandi untuk aplikasi Parete. Mohon bantuannya.')}',
  );

  static final Uri adminEmail = Uri.parse('mailto:rt05.malabar@email.com');
}
