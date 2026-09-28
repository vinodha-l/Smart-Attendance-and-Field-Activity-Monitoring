import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Compact civic-service mark: care (hand and heart) plus field sanitation.
/// It remains clear at small sizes without copying an existing government logo.
class FieldWorkerLogo extends StatelessWidget {
  const FieldWorkerLogo({super.key, this.size = 66});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Stack(clipBehavior: Clip.none, children: [
          Center(
            child: Icon(
              Icons.volunteer_activism_rounded,
              color: AppTheme.navy,
              size: size * .66,
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: size * .30,
              height: size * .30,
              decoration: BoxDecoration(
                color: AppTheme.saffron,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.cleaning_services_outlined,
                size: size * .18,
                color: AppTheme.navy,
              ),
            ),
          ),
        ]),
      );
}
