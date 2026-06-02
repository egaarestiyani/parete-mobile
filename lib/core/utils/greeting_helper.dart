/// Sapaan beranda berdasarkan jam lokal perangkat.
class DayGreeting {
  const DayGreeting({
    required this.label,
    required this.emoji,
  });

  final String label;
  final String emoji;

  String get full => '$label $emoji';
}

DayGreeting greetingForTime([DateTime? now]) {
  final hour = (now ?? DateTime.now()).hour;

  // Malam: bulan
  if (hour >= 19 || hour < 5) {
    return const DayGreeting(label: 'Selamat Malam', emoji: '🌙');
  }

  // Pagi–sore: matahari
  if (hour < 11) {
    return const DayGreeting(label: 'Selamat Pagi', emoji: '☀️');
  }
  if (hour < 15) {
    return const DayGreeting(label: 'Selamat Siang', emoji: '☀️');
  }
  return const DayGreeting(label: 'Selamat Sore', emoji: '☀️');
}
