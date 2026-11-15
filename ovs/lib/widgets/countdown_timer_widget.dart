import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_theme.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime targetTime;
  final String label;
  final VoidCallback? onFinished;

  const CountdownTimerWidget({
    super.key,
    required this.targetTime,
    this.label = 'CLOSES IN',
    this.onFinished,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemaining();
    });
  }

  void _calculateRemaining() {
    final diff = widget.targetTime.difference(DateTime.now());
    if (diff.isNegative) {
      if (_remaining != Duration.zero) {
        setState(() {
          _remaining = Duration.zero;
        });
        widget.onFinished?.call();
      }
    } else {
      setState(() {
        _remaining = diff;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Time Expired',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
          ),
        ),
      );
    }

    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 16, color: AppTheme.danger),
          const SizedBox(width: 6),
          Text(
            '${widget.label}: ',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.danger,
            ),
          ),
          Text(
            '$hours:$minutes:$seconds',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.danger,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
