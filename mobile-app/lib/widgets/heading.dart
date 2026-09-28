import 'package:flutter/material.dart';

/// Section title used across the screens.
class Heading extends StatelessWidget {
  const Heading(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}
