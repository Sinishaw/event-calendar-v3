import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TopicGridItem extends StatelessWidget {
  const TopicGridItem({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.isSelected,
  });

  final String name;
  final String imageUrl;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: isSelected ? 4 : 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isSelected
          ? theme.primaryColor.withOpacity(isDark ? 0.15 : 0.08)
          : theme.cardColor.withOpacity(isDark ? 0.35 : 0.65),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.primaryColor.withOpacity(0.12),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  height: 48,
                                  width: 48,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => Center(
                                    child: Icon(
                                      Icons.topic_rounded,
                                      size: 24,
                                      color: theme.colorScheme.secondary.withOpacity(0.2),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Icon(
                                      Icons.broken_image_rounded,
                                      size: 24,
                                      color: theme.colorScheme.secondary.withOpacity(0.2),
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.topic_rounded,
                                  size: 28,
                                  color: theme.colorScheme.secondary.withOpacity(0.3),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

