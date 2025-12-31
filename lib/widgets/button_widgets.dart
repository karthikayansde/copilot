import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class BasicButtonWidget extends StatefulWidget {
  final void Function() onPressed;
  final String label;
  final Color? labelColor;
  final Color? color;
  final double? height;
  final double? width;
  final double radius;
  final bool isDisable;
  final bool? elevation;

  const BasicButtonWidget({super.key, required this.onPressed, required this.label, this.height = 55, this.width = double.maxFinite, this.color = AppColors.black, this.radius = 20, this.isDisable = false, this.labelColor, this.elevation});

  @override
  State<BasicButtonWidget> createState() => _BasicButtonWidgetState();
}

class _BasicButtonWidgetState extends State<BasicButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 450, maxHeight: 45),
      child: InkWell(
        focusColor: AppColors.transparent,
        hoverColor: AppColors.transparent,
        highlightColor: AppColors.transparent,
        splashColor: AppColors.transparent,
        onTap: widget.isDisable ? null : widget.onPressed,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
            border: Border.all(
              color: widget.isDisable ? AppColors.grey : (widget.color ?? AppColors.primary),
              width: 1.5,
            ),
            boxShadow: widget.elevation == true || widget.elevation != null
                ? [
              BoxShadow(
                color: AppColors.black.withOpacity(0.20),
                offset: const Offset(0, 1),
                blurRadius: 3,
                spreadRadius: 0,
              )
            ]
                : null,
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                color: widget.isDisable
                    ? AppColors.grey
                    : (widget.labelColor ?? widget.color ?? AppColors.primary),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}