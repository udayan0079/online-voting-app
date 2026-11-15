import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/constants/app_theme.dart';
import '../models/candidate_model.dart';

class CandidateTile extends StatelessWidget {
  final CandidateModel candidate;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showResults;
  final bool isWinner;

  const CandidateTile({
    super.key,
    required this.candidate,
    this.isSelected = false,
    this.onTap,
    this.showResults = false,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isWinner
            ? const Color(0xFFF0FDF4)
            : isSelected
                ? const Color(0xFFEFF6FF)
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWinner
              ? AppTheme.success
              : isSelected
                  ? AppTheme.primary
                  : AppTheme.border,
          width: isWinner || isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Candidate Avatar / Photo
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.border, width: 1.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      child: candidate.photoUrl.trim().isNotEmpty
                          ? _buildImageWidget(candidate.photoUrl.trim(), 54, 54, isCircle: true)
                          : Text(
                              candidate.name.isNotEmpty
                                  ? candidate.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
                                  : 'C',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),

                    // Candidate Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  candidate.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textMain,
                                  ),
                                ),
                              ),
                              if (isWinner)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.success,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.emoji_events, size: 14, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'WINNER',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: ${candidate.companyId}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          if (candidate.symbolName.isNotEmpty || candidate.logoUrl.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (candidate.logoUrl.trim().isNotEmpty) ...[
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppTheme.border, width: 0.5),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: _buildImageWidget(candidate.logoUrl.trim(), 22, 22),
                                  ),
                                  const SizedBox(width: 6),
                                ] else
                                  const Icon(Icons.stars, size: 14, color: AppTheme.accent),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    candidate.symbolName.isNotEmpty ? 'Symbol: ${candidate.symbolName}' : 'Symbol Logo Attached',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Selector Checkbox / Radio
                    if (!showResults && onTap != null)
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppTheme.primary : Colors.white,
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : AppTheme.border,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                  ],
                ),

                // Bio / Manifesto
                if (candidate.bio.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      candidate.bio,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],

                // Results Mode: Progress bar + Vote Count
                if (showResults) ...[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${candidate.voteCount} Votes',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMain,
                        ),
                      ),
                      Text(
                        '${candidate.votePercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isWinner ? AppTheme.success : AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: candidate.votePercentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isWinner ? AppTheme.success : AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String src, double width, double height, {bool isCircle = false}) {
    if (src.isEmpty) return const SizedBox.shrink();

    Widget image;
    try {
      if (src.startsWith('data:image') || src.contains(';base64,')) {
        final base64Str = src.contains(';base64,') ? src.split(';base64,').last : src;
        final bytes = base64Decode(base64Str);
        image = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppTheme.textMuted),
        );
      } else if (src.startsWith('http://') || src.startsWith('https://')) {
        image = Image.network(
          src,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppTheme.textMuted),
        );
      } else {
        // Raw Base64 string fallback
        final bytes = base64Decode(src);
        image = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppTheme.textMuted),
        );
      }
    } catch (_) {
      image = const Icon(Icons.person, color: AppTheme.textMuted);
    }

    if (isCircle) {
      return ClipOval(child: image);
    }
    return image;
  }
}
