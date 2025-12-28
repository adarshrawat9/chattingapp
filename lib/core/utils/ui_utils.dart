import 'package:flutter/material.dart';


class UiUtils{
  static void customSnackBar(
      BuildContext context, {
        required String message,
        bool isError = false,
      }) {
    Color backgroundColor = isError ? Colors.red.shade700 : Colors.green.shade700;
    IconData iconData = isError ? Icons.error_outline : Icons.check_circle_outline;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(iconData, color: Colors.white),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 15.0),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        elevation: 2,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        margin: const EdgeInsets.all(12.0),
      ),
    );
  }
}
