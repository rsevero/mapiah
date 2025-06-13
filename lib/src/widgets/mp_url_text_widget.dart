import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MPURLTextWidget extends StatelessWidget {
  final String url;
  final String label;

  const MPURLTextWidget({super.key, required this.url, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(url);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Text(
        label,
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
