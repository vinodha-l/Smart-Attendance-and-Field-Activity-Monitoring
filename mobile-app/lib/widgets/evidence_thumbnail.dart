import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Preview of a photo that was captured on the device.
///
/// The web demo build cannot read local files, so it falls back to an icon.
class EvidenceThumbnail extends StatelessWidget {
  const EvidenceThumbnail({super.key, required this.path, this.size = 88});

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Widget fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_outlined),
    );

    if (kIsWeb) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) =>
                fallback,
      ),
    );
  }
}
