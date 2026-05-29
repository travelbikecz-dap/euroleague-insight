import 'package:flutter/material.dart';

class PlayerAvatar extends StatelessWidget {
  static const _imageHeaders = {
    'Accept': 'image/*',
    'User-Agent': 'EuroLeagueInsight/1.0',
  };

  final String? photoUrl;
  final double size;
  final String? fallbackText;

  const PlayerAvatar({
    super.key,
    required this.photoUrl,
    this.size = 48,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = _buildPlaceholder();

    if (photoUrl == null || photoUrl!.isEmpty) {
      return placeholder;
    }

    return ClipOval(
      child: Image.network(
        photoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        headers: _imageHeaders,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder;
        },
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        fallbackText ?? '?',
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: size * 0.35,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
