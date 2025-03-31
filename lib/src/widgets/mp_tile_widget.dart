import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

class MPTileWidget extends StatefulWidget {
  final Widget? leading;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? iconColor;
  final Color? backgroundColor;
  late final EdgeInsetsGeometry contentPadding;
  final bool dense;

  MPTileWidget({
    super.key,
    this.leading,
    required this.title,
    this.trailing,
    this.onTap,
    this.textColor,
    this.iconColor,
    this.backgroundColor,
    EdgeInsetsGeometry? contentPadding,
    this.dense = false,
  }) : super() {
    this.contentPadding = contentPadding ??
        EdgeInsets.symmetric(
          horizontal: mpTileWidgetEdgeInset,
          vertical: dense ? mpTileWidgetEdgeInsetDense : mpTileWidgetEdgeInset,
        );
  }

  @override
  State<MPTileWidget> createState() => _MPTileWidgetState();
}

class _MPTileWidgetState extends State<MPTileWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color hoverColor =
        widget.backgroundColor?.withAlpha(mpTileWidgetOnHoverAlpha) ??
            Colors.grey.withAlpha(mpTileWidgetOnHoverAlpha);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: isHovered ? hoverColor : widget.backgroundColor,
          padding: widget.contentPadding,
          child: Row(
            crossAxisAlignment: widget.dense
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (widget.leading != null)
                IconTheme(
                  data: IconThemeData(color: widget.iconColor),
                  child: widget.leading!,
                ),
              if (widget.leading != null) const SizedBox(width: mpButtonSpace),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.textColor ??
                        Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              if (widget.trailing != null)
                IconTheme(
                  data: IconThemeData(color: widget.iconColor),
                  child: widget.trailing!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
