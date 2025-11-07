import 'package:flutter/material.dart';

/// A reusable preview component widget for displaying content previews
class PreviewComponent extends StatelessWidget {
  /// The title of the preview
  final String? title;
  
  /// The subtitle or description of the preview
  final String? subtitle;
  
  /// The main content widget to display
  final Widget? content;
  
  /// The image URL or asset path to display
  final String? imageUrl;
  
  /// Callback function when the preview is tapped
  final VoidCallback? onTap;
  
  /// Background color of the preview card
  final Color? backgroundColor;
  
  /// Whether to show a loading indicator
  final bool isLoading;
  
  /// Border radius for the preview card
  final double borderRadius;
  
  /// Padding inside the preview card
  final EdgeInsets padding;

  const PreviewComponent({
    super.key,
    this.title,
    this.subtitle,
    this.content,
    this.imageUrl,
    this.onTap,
    this.backgroundColor,
    this.isLoading = false,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: backgroundColor ?? Theme.of(context).cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (imageUrl != null) _buildImage(context),
        if (title != null) _buildTitle(context),
        if (subtitle != null) _buildSubtitle(context),
        if (content != null) content!,
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        imageUrl!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[300],
            child: const Icon(
              Icons.broken_image,
              size: 48,
              color: Colors.grey,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
      child: Text(
        title!,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        subtitle!,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// A compact preview component variant for list views
class CompactPreviewComponent extends StatelessWidget {
  /// The title of the preview
  final String? title;
  
  /// The subtitle or description
  final String? subtitle;
  
  /// The thumbnail image URL
  final String? thumbnailUrl;
  
  /// Callback when tapped
  final VoidCallback? onTap;
  
  /// Leading widget (e.g., avatar)
  final Widget? leading;

  const CompactPreviewComponent({
    super.key,
    this.title,
    this.subtitle,
    this.thumbnailUrl,
    this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading ??
          (thumbnailUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    thumbnailUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image),
                      );
                    },
                  ),
                )
              : null),
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }
}
