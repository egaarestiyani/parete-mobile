import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';

/// Gambar dari backend (path MongoDB → URL `/api/media/...`).
class PareteNetworkImage extends StatefulWidget {
  const PareteNetworkImage({
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.image_outlined,
    super.key,
  });

  final String? url;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  @override
  State<PareteNetworkImage> createState() => _PareteNetworkImageState();
}

class _PareteNetworkImageState extends State<PareteNetworkImage> {
  Uint8List? _bytes;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(covariant PareteNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _bytes = null;
      _failed = false;
      _load();
    }
  }

  Future<void> _load() async {
    final imageUrl = widget.url?.trim();
    if (imageUrl == null || imageUrl.isEmpty) {
      return;
    }

    try {
      String? token;
      try {
        token = await context.read<AuthService>().currentToken();
      } catch (_) {}

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: {if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'},
        ),
      );

      final response = await dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes, followRedirects: true),
      );

      if (!mounted) return;
      final data = response.data;
      if (data == null || data.isEmpty) {
        setState(() => _failed = true);
        return;
      }
      setState(() {
        _bytes = Uint8List.fromList(data);
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    final imageUrl = widget.url?.trim();
    if (imageUrl == null || imageUrl.isEmpty) {
      child = _placeholder();
    } else if (_failed) {
      child = _placeholder(broken: true);
    } else if (_bytes != null) {
      child = Image.memory(
        _bytes!,
        fit: widget.fit,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) => _placeholder(broken: true),
      );
    } else {
      child = Container(
        color: AppColors.primaryBlue.withValues(alpha: 0.15),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (widget.borderRadius != null) {
      return ClipRRect(borderRadius: widget.borderRadius!, child: child);
    }
    return child;
  }

  Widget _placeholder({bool broken = false}) {
    return ColoredBox(
      color: Colors.white.withValues(alpha: 0.15),
      child: Center(
        child: Icon(
          broken ? Icons.broken_image_outlined : widget.placeholderIcon,
          color: Colors.white70,
          size: 48,
        ),
      ),
    );
  }
}
