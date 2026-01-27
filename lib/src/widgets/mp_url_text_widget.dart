import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MPURLTextWidget extends StatelessWidget {
  final String url;
  final String label;

  const MPURLTextWidget({super.key, required this.url, required this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final Uri? uri = Uri.tryParse(url);

          if (uri == null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Invalid URL: $url')));
            return;
          }

          try {
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Cannot open URL: $url')));
            }
          } catch (_) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed to open URL: $url')));
          }
        },
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
