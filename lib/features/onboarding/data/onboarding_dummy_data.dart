import '../domain/entities/onboarding_item.dart';

class OnboardingDummyData {
  const OnboardingDummyData._();

  static const List<OnboardingItem> items = [
    OnboardingItem(
      tag: 'SELAMAT DATANG',
      title: 'Kelola RT lebih\nmudah & cepat',
      description:
          'Parete hadir sebagai jembatan antara warga dan pengurus RT untuk komunikasi yang lebih lancar dan transparan.',
      emoji: '👋',
    ),
    OnboardingItem(
      tag: 'PENGADUAN',
      title: 'Laporkan masalah,\npantau progressnya',
      description:
          'Ajukan pengaduan dengan mudah dan lacak statusnya secara real-time dari terkirim hingga selesai.',
      emoji: '📝',
    ),
    OnboardingItem(
      tag: 'INFO & DOKUMEN',
      title: 'Lihat informasi terkini &\nunduh dokumen',
      description:
          'Akses pengumuman, jadwal kegiatan, dan unduh dokumen resmi RT kapan saja dan di mana saja.',
      emoji: '📣',
    ),
    OnboardingItem(
      tag: 'SIAP MULAI',
      title: 'Keperluan RT kamu\nlebih teratur dari sekarang',
      description: 'Bergabunglah untuk merasakan kemudahan layanan RT digital bersama Parete.',
      emoji: '🚀',
    ),
  ];
}
