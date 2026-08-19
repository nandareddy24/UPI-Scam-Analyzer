import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';
import '../models/scan_result.dart';

class RiskResultCard extends StatefulWidget {
  final ScanResult result;

  const RiskResultCard({super.key, required this.result});

  @override
  State<RiskResultCard> createState() => _RiskResultCardState();
}

class _RiskResultCardState extends State<RiskResultCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scoreAnimation;
  bool _reasonsExpanded = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.result.displayScore.toDouble(),
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color get _statusColor => AppTheme.getRiskColor(widget.result.displayScore);
  Color get _statusBg => AppTheme.getRiskBgColor(widget.result.displayScore);

  @override
  Widget build(BuildContext context) {
    final isDangerous = widget.result.result.toLowerCase() == 'dangerous' || widget.result.displayScore > 70;
    final isWarning = widget.result.result.toLowerCase() == 'warning' || (widget.result.displayScore > 40 && widget.result.displayScore <= 70);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _statusColor.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withOpacity(0.15),
            blurRadius: 16,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Badge Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Icon(
                  isDangerous
                      ? Icons.gpp_maybe_rounded
                      : (isWarning ? Icons.warning_amber_rounded : Icons.verified_user_rounded),
                  color: _statusColor,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target: ${widget.result.inputData}',
                        style: TextStyle(
                          color: AppTheme.textPrimary.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Type: ${widget.result.type.toUpperCase()}',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.result.result.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Score Gauge Meter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Gauge score ring
                    AnimatedBuilder(
                      animation: _scoreAnimation,
                      builder: (context, child) {
                        final val = _scoreAnimation.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: CircularProgressIndicator(
                                value: val / 100,
                                strokeWidth: 8,
                                backgroundColor: AppTheme.cardBgElevated,
                                valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${val.round()}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: _statusColor,
                                  ),
                                ),
                                const Text(
                                  '/ 100',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            )
                          ],
                        );
                      },
                    ),

                    // Metrics Column
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Risk Level: ${AppTheme.getRiskLabel(widget.result.displayScore)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _statusColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.psychology_rounded, size: 16, color: AppTheme.cyberCyan),
                                const SizedBox(width: 6),
                                Text(
                                  'Confidence: ${widget.result.confidence}%',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Mini score bar line
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: widget.result.displayScore / 100,
                                minHeight: 6,
                                backgroundColor: AppTheme.cardBgElevated,
                                valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // Pre-Payment / Pre-Navigation Security Warning Notice
                if (widget.result.type.toUpperCase() == 'UPI' || widget.result.type.toUpperCase() == 'QR')
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDangerous ? const Color(0x33FF1744) : const Color(0x2200F2FE),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDangerous ? AppTheme.threatRed : AppTheme.cyberCyan, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shield_rounded, color: isDangerous ? AppTheme.threatRed : AppTheme.cyberCyan, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isDangerous
                                ? 'SECURITY ALERT: High fraud probability detected. Do NOT send money or scan PIN.'
                                : 'SAFETY GUARDE: Verify merchant/person name before initiating payment.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDangerous ? AppTheme.threatRed : AppTheme.cyberCyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Recommended Action Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBgElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tips_and_updates_rounded, color: AppTheme.cyberCyan, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Recommended Action',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.result.advice,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Expandable Reasons Section
                InkWell(
                  onTap: () => setState(() => _reasonsExpanded = !_reasonsExpanded),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.travel_explore_rounded, color: AppTheme.cyberBlue, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Why was this detected?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _reasonsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: AppTheme.textMuted,
                        )
                      ],
                    ),
                  ),
                ),

                if (_reasonsExpanded)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.result.reasonList.map((reasonText) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(
                                  reasonText,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // URL Open Security Option if URL type
                if (widget.result.type.toUpperCase() == 'URL' && widget.result.inputData.startsWith('http'))
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmOpenUrl(context, widget.result.inputData, isDangerous),
                      icon: Icon(
                        isDangerous ? Icons.warning_rounded : Icons.open_in_new_rounded,
                        size: 18,
                        color: isDangerous ? AppTheme.threatRed : AppTheme.cyberCyan,
                      ),
                      label: Text(
                        isDangerous ? 'Proceed to Open Suspicious URL (Unsafe)' : 'Open URL in Browser',
                        style: TextStyle(
                          color: isDangerous ? AppTheme.threatRed : AppTheme.cyberCyan,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isDangerous ? AppTheme.threatRed : AppTheme.cyberCyan),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmOpenUrl(BuildContext context, String urlStr, bool isUnsafe) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Row(
          children: [
            Icon(isUnsafe ? Icons.security_rounded : Icons.info_rounded, color: isUnsafe ? AppTheme.threatRed : AppTheme.cyberCyan),
            const SizedBox(width: 10),
            Text(isUnsafe ? 'Security Warning' : 'Open Link'),
          ],
        ),
        content: Text(
          isUnsafe
              ? 'This link was flagged as DANGEROUS/SUSPICIOUS. Opening it may expose your device or credentials to phishing attacks.\n\nAre you sure you want to proceed?'
              : 'Do you want to open this link in your default web browser?\n\n$urlStr',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isUnsafe ? AppTheme.threatRed : AppTheme.cyberCyan,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final uri = Uri.parse(urlStr);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(
              isUnsafe ? 'Open Anyway' : 'Open Link',
              style: TextStyle(color: isUnsafe ? Colors.white : Colors.black),
            ),
          )
        ],
      ),
    );
  }
}
