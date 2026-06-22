import 'package:flutter/material.dart'; 

class CustomTextfield extends StatelessWidget {
final TextEditingController controller;
final String hintText ;
final bool ?obscureText ;
final TextInputType? keyboardType ;
final Widget ? suffixIcon ;
final Widget ? prefixIcon ;
final FocusNode ? focusNode ;
final String? Function(String?)? validator ;
final TextStyle? hintstyle ;
final EdgeInsetsGeometry? contentpadding ;
final TextInputAction? textInputAction ;
const CustomTextfield(
{super.key ,
  required this.controller,
  required this.hintText ,
  this.obscureText = false,
  this.focusNode,
  this.keyboardType,
  this.prefixIcon,
  this.suffixIcon ,
  this.validator,
  this.hintstyle,
  this.contentpadding,
  this.textInputAction,
}
    );
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText!,
      validator: validator,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintstyle,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: contentpadding,
      ),

    );
  }
}
