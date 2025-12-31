import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_colors.dart';

class TextFieldWidget extends StatelessWidget {
  TextFieldWidget({super.key, required this.controller, required this.hint, this.radius = 10, this.contentPadding, this.isReadOnly = false, this.suffixIcon, this.prefixIcon, this.isPassword = false, this.keyboardType, this.inputFormatters, this.formKey, this.validator, this.focusNode, this.maxLines, this.onTap, this.enableInteractiveSelection, this.onChanged, this.hasHindOnTop = false, this.bgColor = AppColors.white, this.fillBgColor = false, this.isBorderNeeded = false, this.hintColor, this.header, this.maxLength});
  final TextEditingController controller;
  final String hint;
  final String? header;
  final Color? bgColor;
  final Color? hintColor;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool isReadOnly;
  final bool? isBorderNeeded;
  final bool isPassword;
  final bool? hasHindOnTop;
  final bool? fillBgColor;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  Key? formKey;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final EdgeInsetsGeometry? contentPadding;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? maxLength;
  final double? radius;
  final bool? enableInteractiveSelection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !hasHindOnTop!?Container():Padding(
            padding: const EdgeInsets.all(1.0),
            child: Text( header??hint, style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.black
            ),),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 450 ),
            child: TextFormField(
              maxLength: maxLength,
              enableInteractiveSelection: enableInteractiveSelection,
              onTap: onTap,
              focusNode: focusNode,
              key: formKey,
              validator: validator,
              inputFormatters: inputFormatters,
              obscureText: isPassword,
              readOnly: isReadOnly,
              cursorColor: AppColors.primary,
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black
              ),
              onChanged: onChanged,
              decoration: InputDecoration(
                filled: isReadOnly?true: fillBgColor,
                fillColor: isReadOnly?Colors.grey.shade200 : bgColor,
                suffixIcon: suffixIcon,
                prefixIcon: prefixIcon,
                prefixIconConstraints: BoxConstraints(maxHeight: 40, maxWidth: 40),
                suffixIconConstraints: BoxConstraints(maxHeight: 40, maxWidth: 40),
                contentPadding: contentPadding,
                hintText: hint,
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: hintColor,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(radius??0),
                  borderSide:
                  BorderSide(color: (isBorderNeeded!?AppColors.black:AppColors.transparent)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(radius??0),
                  borderSide:
                  BorderSide(color: AppColors.primary),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius??0),
                  borderSide: const BorderSide(color: AppColors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius??0),
                  borderSide: const BorderSide(color: AppColors.primary
                ),
              ),
            ),
          ),),
        ],
      ),
    );
  }
}