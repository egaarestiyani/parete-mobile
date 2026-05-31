import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class CreateComplaintScreen extends StatefulWidget {
  const CreateComplaintScreen({super.key});

  static const String routeName = '/complaints/create';

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

enum _PhotoSource { device, googleDrive }

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  static const List<String> _topics = [
    'Infrastruktur',
    'Kebersihan',
    'Keamanan',
    'Sosial',
    'Lainnya',
  ];

  static const int _maxPhotos = 3;
  static const int _maxBytesPerPhoto = 10 * 1024 * 1024; // 10 MB

  String _topic = _topics.first;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final List<PlatformFile> _attachments = [];

  static const int _maxDesc = 500;

  bool get _isDirty =>
      _topic != _topics.first ||
      _titleController.text.trim().isNotEmpty ||
      _descController.text.trim().isNotEmpty ||
      _locationController.text.trim().isNotEmpty ||
      _attachments.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _descController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _requestExit(BuildContext context) async {
    if (!_isDirty) {
      if (context.mounted) Navigator.of(context).pop();
      return;
    }

    final leave = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Apakah Anda yakin ingin keluar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.darkBlueText,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text(
                    'Ya',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (leave == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  int _fileByteSize(PlatformFile f) {
    if (f.size > 0) return f.size;
    if (f.bytes != null) return f.bytes!.length;
    return 0;
  }

  Future<void> _showOversizeAlert() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Ukuran foto terlalu besar',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: const Text(
          'Ukuran per foto maksimal 10 MB. Pilih file yang lebih kecil atau kompres terlebih dahulu.',
          style: TextStyle(height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Oke', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showPhotoSourceSheet() {
    if (_attachments.length >= _maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal $_maxPhotos foto.')),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.computer_outlined, color: AppColors.primaryBlue),
                  title: const Text(
                    'Komputer / perangkat',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Pilih dari penyimpanan lokal atau galeri'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickPhoto(_PhotoSource.device);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.add_to_drive_outlined, color: AppColors.primaryBlue),
                  title: const Text(
                    'Google Drive',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Pilih file gambar dari akun Drive Anda'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickPhoto(_PhotoSource.googleDrive);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickPhoto(_PhotoSource source) async {
    try {
      final title = source == _PhotoSource.googleDrive
          ? 'Pilih foto dari Google Drive'
          : 'Pilih foto dari perangkat';

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
        dialogTitle: title,
      );

      if (!mounted || result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = _fileByteSize(file);
      if (bytes == 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ukuran file tidak terbaca. Coba pilih foto lain.'),
          ),
        );
        return;
      }
      if (bytes > _maxBytesPerPhoto) {
        await _showOversizeAlert();
        return;
      }

      setState(() => _attachments.add(file));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih file: $e')),
      );
    }
  }

  Widget _requiredLabel(String text) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.darkBlueText,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        children: [
          TextSpan(text: text),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _requestExit(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.darkBlueText,
          centerTitle: true,
          title: const Text(
            'Buat Pengaduan',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          leading: IconButton(
            onPressed: () => _requestExit(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.help_outline_rounded),
              color: AppColors.mutedText,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _requiredLabel('Topik Pengaduan'),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: _topics.map((t) {
                        final selected = t == _topic;
                        return ChoiceChip(
                          label: Text(t),
                          selected: selected,
                          onSelected: (_) => setState(() => _topic = t),
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppColors.darkBlueText,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: selected ? AppColors.primaryBlue : AppColors.border,
                            ),
                          ),
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _requiredLabel('Judul Pengaduan'),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _titleController,
                      onChanged: (_) => setState(() {}),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _fieldDecoration(hint: 'Ringkas masalah yang dilaporkan'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _requiredLabel('Deskripsi'),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _descController,
                      maxLines: 5,
                      maxLength: _maxDesc,
                      buildCounter: (_, {required currentLength, required isFocused, maxLength}) => Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$currentLength/$maxLength karakter',
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      decoration: _fieldDecoration(hint: 'Jelaskan detail kejadian atau kondisi').copyWith(
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _requiredLabel('Lokasi'),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _locationController,
                      onChanged: (_) => setState(() {}),
                      textCapitalization: TextCapitalization.words,
                      decoration: _fieldDecoration(hint: 'Contoh: Gang Mawar, RT 05').copyWith(
                        prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF8C96AB)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Lampiran (opsional)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (_attachments.isNotEmpty) ...[
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: List.generate(_attachments.length, (i) {
                          final name = _attachments[i].name;
                          return Chip(
                            label: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            onDeleted: () => setState(() => _attachments.removeAt(i)),
                          );
                        }),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    Material(
                      color: const Color(0xFFF0F2F7),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: _showPhotoSourceSheet,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 120,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image_outlined, size: 36, color: AppColors.mutedText.withValues(alpha: 0.7)),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Tap untuk menambah foto',
                                style: TextStyle(
                                  color: AppColors.mutedText.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Maks. $_maxPhotos foto • JPG, JPEG, PNG • maks. 10 MB per foto',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.mutedText.withValues(alpha: 0.75),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.send_rounded, size: 20),
                label: const Text('Kirim', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.warningBg,
              child: SafeArea(
                top: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.warningText, width: 1.5),
                      ),
                      child: const Text(
                        '!',
                        style: TextStyle(
                          color: AppColors.warningText,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Text(
                        'Pengaduan akan diteruskan ke Admin RT dan diproses dalam 1-3 hari kerja.',
                        style: TextStyle(
                          color: AppColors.warningText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
    );
  }
}
