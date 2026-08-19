import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final VoidCallback? onTap;

  const CyberCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? AppTheme.borderDark;
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppTheme.cyberCyan.withOpacity(0.1),
          highlightColor: AppTheme.cyberCyan.withOpacity(0.05),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
