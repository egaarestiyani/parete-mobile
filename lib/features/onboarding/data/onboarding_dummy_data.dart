import '../domain/entities/onboarding_item.dart';

class OnboardingDummyData {
  const OnboardingDummyData._();

  static const List<OnboardingItem> items = [
    OnboardingItem(
      tag: 'SELAMAT DATANG',
      title: 'Kelola RT lebih mudah & cepat',
      description:
          'Parete hadir sebagai jembatan antara warga dan pengurus RT untuk komunikasi yang lebih lancar dan transparan.',
      illustrationType: OnboardingIllustrationType.welcome,
      greeting: 'Halo, Warga!',
      showTagStar: true,
    ),
    OnboardingItem(
      tag: 'PENGADUAN',
      title: 'Laporkan masalah, pantau progressnya',
      description:
          'Ajukan pengaduan dengan mudah dan lacak statusnya secara real-time dari Terkirim hingga Selesai.',
      illustrationType: OnboardingIllustrationType.complaints,
    ),
    OnboardingItem(
      tag: 'INFO & DOKUMEN',
      title: 'Lihat informasi terkini & unduh dokumen',
      description:
          'Akses pengumuman, jadwal kegiatan, dan unduh dokumen resmi RT kapan saja dan di mana saja.',
      illustrationType: OnboardingIllustrationType.documents,
    ),
    OnboardingItem(
      tag: 'SIAP MULAI',
      title: 'Keperluan RT kamu lebih teratur dari sekarang',
      description: 'Bergabunglah untuk merasakan kemudahan layanan RT digital bersama Parete.',
      illustrationType: OnboardingIllustrationType.rocket,
    ),
  ];
}
