import 'package:flutter/material.dart';

enum PlayerPhotoStyle {
  /// Roster row — compact portrait card.
  compact,

  /// Player detail header — larger portrait card.
  hero,
}

class PlayerAvatar extends StatelessWidget {
  static const _imageHeaders = {
    'Accept': 'image/*',
    'User-Agent': 'EuroLeagueInsight/1.0',
  };

  /// EuroLeague headshots are consistently 750×1000 (3:4 portrait).
  static const _aspectRatio = 3 / 4;

  /// Slight upward bias for photos that are not exactly 3:4.
  static const _faceAlignment = Alignment(0, -0.2);

  final String? photoUrl;
  final PlayerPhotoStyle style;
  final String? fallbackText;

  const PlayerAvatar({
    super.key,
    required this.photoUrl,
    this.style = PlayerPhotoStyle.compact,
    this.fallbackText,
  });

  double get _width => switch (style) {
        PlayerPhotoStyle.compact => 42,
        PlayerPhotoStyle.hero => 126,
      };

  double get _height => _width / _aspectRatio;

  double get _borderRadius => switch (style) {
        PlayerPhotoStyle.compact => 10,
        PlayerPhotoStyle.hero => 20,
      };

  @override
  Widget build(BuildContext context) {
    final placeholder = _buildPlaceholder();

    return SizedBox(
      width: _width,
      height: _height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_borderRadius),
        child: photoUrl == null || photoUrl!.isEmpty
            ? placeholder
            : Image.network(
                photoUrl!,
                width: _width,
                height: _height,
                fit: BoxFit.cover,
                alignment: _faceAlignment,
                headers: _imageHeaders,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return placeholder;
                },
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      alignment: Alignment.center,
      child: Text(
        fallbackText ?? '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: _width * 0.28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
