import 'package:flutter/material.dart';

class PopoverDialog {
  static OverlayEntry? _overlayEntry;

  static void show({
    required BuildContext context,
    required BuildContext anchorContext,
    required List<PopoverItem> items,
    double? width,
    EdgeInsets? padding,
    Color? backgroundColor,
    double? borderRadius,
    double? elevation,
    VoidCallback? onDismiss,
  }) {
    // Dismiss any existing popover
    dismiss();

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => _PopoverWidget(
        anchorContext: anchorContext,
        items: items,
        width: width,
        padding: padding,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        elevation: elevation,
        onDismiss: onDismiss,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _PopoverWidget extends StatefulWidget {
  final BuildContext anchorContext;
  final List<PopoverItem> items;
  final double? width;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? elevation;
  final VoidCallback? onDismiss;

  const _PopoverWidget({
    required this.anchorContext,
    required this.items,
    this.width,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    this.onDismiss,
  });

  @override
  State<_PopoverWidget> createState() => _PopoverWidgetState();
}

class _PopoverWidgetState extends State<_PopoverWidget> {
  @override
  Widget build(BuildContext context) {
    final RenderBox? renderBox = widget.anchorContext.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return const SizedBox.shrink();
    }

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;
    final double keyboardHeight = mediaQuery.viewInsets.bottom;

    // Calculate position - popover appears above the anchor
    final double popoverWidth = widget.width ?? 200.0;
    final double itemHeight = 56.0;
    final double popoverHeight = widget.items.length * itemHeight + 16;
    final double left = offset.dx;
    final double top = offset.dy - popoverHeight - 8;
    
    // Ensure popover doesn't go off screen or overlap with keyboard
    final double adjustedLeft = left + popoverWidth > screenWidth 
        ? screenWidth - popoverWidth - 16 
        : left;
    
    // Check if popover would be hidden by keyboard
    final double availableSpace = screenHeight - keyboardHeight;
    double adjustedTop = top;
    
    if (top < 0) {
      // Not enough space above, show below
      adjustedTop = offset.dy + size.height + 8;
    }
    
    // If keyboard is open and popover would be hidden, adjust position
    if (adjustedTop + popoverHeight > availableSpace) {
      adjustedTop = availableSpace - popoverHeight - 16;
      if (adjustedTop < 0) {
        adjustedTop = 16;
      }
    }

    return Stack(
      children: [
        // Backdrop that dismisses on tap (only outside popover)
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              PopoverDialog.dismiss();
              widget.onDismiss?.call();
            },
            child: Container(color: Colors.transparent),
          ),
        ),
        // Popover content
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          left: adjustedLeft,
          top: adjustedTop,
          child: GestureDetector(
            onTap: () {}, // Prevent backdrop tap from dismissing
            child: Material(
              elevation: widget.elevation ?? 2,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
              color: widget.backgroundColor ?? Colors.white,
              child: Container(
                width: popoverWidth,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.items.map((item) {
                      return _PopoverItemWidget(
                        icon: item.icon,
                        label: item.label,
                        onTap: () {
                          PopoverDialog.dismiss();
                          item.onTap?.call();
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PopoverItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _PopoverItemWidget({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: Colors.black87,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PopoverItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  PopoverItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}
