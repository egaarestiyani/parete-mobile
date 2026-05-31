import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/permohonan_service.dart';

/// Form pengajuan permohonan dokumen resmi.
class DocumentSubmissionScreen extends StatefulWidget {
  const DocumentSubmissionScreen({super.key});

  static const String routeName = '/documents/submit';

  @override
  State<DocumentSubmissionScreen> createState() => _DocumentSubmissionScreenState();
}

class _DocumentSubmissionScreenState extends State<DocumentSubmissionScreen> {
  static const List<String> _documentTypes = [
    'Surat Pengantar RT',
    'Surat Keterangan Domisili',
    'Surat Keterangan Tidak Mampu',
    'Surat Keterangan Usaha',
    'Lainnya',
  ];

  static const String _otherLabel = 'Lainnya';

  String _selectedType = _documentTypes.first;
  final TextEditingController _otherTypeController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  PlatformFile? _filledTemplateFile;
  PlatformFile? _supportingFile;

  static const int _maxFileBytes = 15 * 1024 * 1024;

  bool get _isOther => _selectedType == _otherLabel;

  bool get _canSubmit {
    if (_purposeController.text.trim().isEmpty) return false;
    if (_isOther && _otherTypeController.text.trim().isEmpty) return false;
    return true;
  }

  @override
  void dispose() {
    _otherTypeController.dispose();
    _purposeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int _fileByteSize(PlatformFile f) {
    if (f.size > 0) return f.size;
    if (f.bytes != null) return f.bytes!.length;
    return 0;
  }

  Future<void> _pickPdfDoc({required bool filledTemplate}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx'],
        allowMultiple: false,
        withData: true,
        dialogTitle: filledTemplate ? 'Pilih dokumen yang sudah diisi' : 'Pilih dokumen pendukung',
      );
      if (!mounted || result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final bytes = _fileByteSize(file);
      if (bytes == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran file tidak terbaca. Coba pilih file lain.')),
        );
        return;
      }
      if (bytes > _maxFileBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran file maksimal 15 MB.')),
        );
        return;
      }
      setState(() {
        if (filledTemplate) {
          _filledTemplateFile = file;
        } else {
          _supportingFile = file;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih file: $e')),
      );
    }
  }

  bool _submitting = false;

  Future<void> _submit() async {
    if (!_canSubmit || _submitting) {
      if (!_canSubmit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lengkapi jenis dokumen dan keperluan dokumen terlebih dahulu.'),
          ),
        );
      }
      return;
    }
    setState(() => _submitting = true);
    try {
      final api = context.read<AuthService>().api;
      await PermohonanService(api).submit(
        jenisDokumen: _selectedType,
        jenisLainnya: _selectedType == 'Lainnya' ? _otherTypeController.text.trim() : null,
        keperluan: _purposeController.text.trim(),
        catatan: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        berkasDiisi: _filledTemplateFile,
        dokumenPendukung: _supportingFile,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan dokumen berhasil dikirim ke Admin RT.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  InputDecoration _fieldDecoration({String? hint, String? helper}) {
    return InputDecoration(
      hintText: hint,
      helperText: helper,
      helperMaxLines: 3,
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

  Widget _uploadTile({
    required String title,
    required String helper,
    required PlatformFile? file,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.darkBlueText,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          helper,
          style: const TextStyle(
            color: AppColors.mutedText,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Material(
          color: const Color(0xFFF0F2F7),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.upload_file_rounded, color: AppColors.mutedText.withValues(alpha: 0.85)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      file == null ? 'Tap untuk memilih file' : file.name,
                      style: TextStyle(
                        color: file == null
                            ? AppColors.mutedText.withValues(alpha: 0.9)
                            : AppColors.darkBlueText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (file != null)
                    IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: AppColors.mutedText,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2E7DBC),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Pengajuan Dokumen',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Jenis Dokumen',
                    style: TextStyle(
                      color: AppColors.darkBlueText,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: _fieldDecoration(hint: 'Pilih jenis dokumen').copyWith(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    ),
                    items: _documentTypes
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _selectedType = v);
                    },
                  ),
                  if (_isOther) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Sebutkan Jenis Dokumen',
                      style: TextStyle(
                        color: AppColors.darkBlueText,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _otherTypeController,
                      onChanged: (_) => setState(() {}),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _fieldDecoration(hint: 'Tuliskan jenis dokumen yang Anda butuhkan'),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Keperluan Dokumen',
                    style: TextStyle(
                      color: AppColors.darkBlueText,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _purposeController,
                    onChanged: (_) => setState(() {}),
                    minLines: 3,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _fieldDecoration(
                      hint: 'Contoh: Untuk beasiswa, sekolah, atau administrasi lainnya.',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _uploadTile(
                    title: 'Unggah Dokumen yang Sudah Diisi (Opsional)',
                    helper: 'Unggah file PDF atau DOC jika Anda sudah mengisi template.',
                    file: _filledTemplateFile,
                    onPick: () => _pickPdfDoc(filledTemplate: true),
                    onClear: () => setState(() => _filledTemplateFile = null),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _uploadTile(
                    title: 'Dokumen Pendukung (Opsional)',
                    helper: 'Contoh: KTP, Kartu Keluarga, atau dokumen pendukung lainnya.',
                    file: _supportingFile,
                    onPick: () => _pickPdfDoc(filledTemplate: false),
                    onClear: () => setState(() => _supportingFile = null),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Catatan Tambahan (Opsional)',
                    style: TextStyle(
                      color: AppColors.darkBlueText,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _notesController,
                    minLines: 2,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _fieldDecoration(hint: 'Tambahkan informasi lain jika perlu'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F3FC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue, size: 22),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Setelah pengajuan dikirim, Anda dapat memantau status proses permohonan '
                            'atau mengunduh dokumen yang telah ditandatangani secara digital melalui '
                            'halaman Dokumen.',
                            style: TextStyle(
                              color: AppColors.darkBlueText,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
            child: SafeArea(
              top: false,
              child: FilledButton(
                onPressed: _canSubmit ? _submit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: AppColors.border,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: AppColors.mutedText,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Kirim Pengajuan',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
